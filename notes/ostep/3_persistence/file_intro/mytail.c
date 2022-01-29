#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

char *maybe_truncate_read_buf(char *read_buf, int read_buf_size,
                              int num_lines) {
  char *new_buf = read_buf;
  int num_lines_remaining = num_lines;
  for (int i = read_buf_size - 1; i >= 0; i--) {
    if (read_buf[i] == '\n') {
      num_lines_remaining--;
    }
    new_buf[i] = read_buf[i];
    if (num_lines_remaining == 0) {
      // Bump the starting point of the char* to this
      new_buf = new_buf + i;
      break;
    }
  }
  return new_buf;
}

bool lines_reached(char *read_buf, int read_buf_size, int num_lines) {
  // Do we have num_lines newlines within read_buf?
  int newlines_remaining = num_lines;
  for (int num_chars_read = 0; num_chars_read < read_buf_size;
       num_chars_read++) {
    char curr_char = read_buf[num_chars_read];
    if (curr_char == '\n') {
      newlines_remaining--;
    }
    if (newlines_remaining == 0) {
      return true;
    }
  }
  return false;
}

int main(int argc, char *argv[]) {
  // Tail tails the last n lines of the specified file.
  // I should really clean this code up, but alas.
  // One thing I need to get in a better habit of not doing is casting unsigned
  // things like size_ts to ints... :grimace:
  bool doing_it_right = true;
  if (argc != 3) {
    doing_it_right = false;
  }
  if (argv[1][0] != '-') {
    doing_it_right = false;
  }
  if (!doing_it_right) {
    fprintf(stderr, "Usage: mytail -n file, where n is the number of lines at"
                    "the end of the file to print\n");
    exit(1);
  }

  int num_lines = atoi(argv[1] + 1);
  // Can be an absolute or relative path.
  char *file_path = argv[2];

  // Use stat to make sure the file actually exists and get the size of it
  struct stat statbuf;
  int return_code = stat(file_path, &statbuf);
  if (return_code != 0) {
    fprintf(stderr,
            "stat on `%s` returned a nonzero return code, maybe that file "
            "is not present?",
            file_path);
    exit(1);
  }
  int file_size = (int)statbuf.st_size;
  // I don't know if blocksize is in bytes or what...guess we'll see if this
  // works. :shrug:
  int block_size = (int)statbuf.st_blksize;

  int fd = open(file_path, O_RDONLY);
  if (fd == 0) {
    fprintf(stderr, "Could not open file %s for reading", file_path);
  }

  bool reached_line_length = false;
  int offset = 0;
  char *read_buf;
  int read_buf_size = 0;
  // Basically, read a block from the end. If we don't have all our
  // newlines in that, try again starting two blocks from the end.
  // Repeat until we finally have all the newlines, and then truncate
  // them after.
  // If we never reach all the newlines, then we should just spit out
  // all of the output.
  while (!reached_line_length) {
    offset = offset + block_size;
    read_buf = malloc(offset * sizeof(char));
    if (offset > file_size) {
      offset = file_size;
    }
    lseek(fd, file_size - offset, SEEK_SET);
    read(fd, read_buf, offset);

    if (lines_reached(read_buf, offset, num_lines)) {
      read_buf_size = offset;
      break;
    }

    // If we've reached the start of the file, then just tail everything.
    if (offset == file_size) {
      read_buf_size = file_size;
      break;
    }
  }
  assert(read_buf != NULL);

  char *output = maybe_truncate_read_buf(read_buf, read_buf_size, num_lines);
  printf("%s", output);

  return 0;
}