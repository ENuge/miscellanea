#include <assert.h>
#include <dirent.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  bool incorrect_usage = false;
  bool print_full_details = false;
  char *dir_to_use = NULL;

  if (argc == 2 || argc == 3) {
    if (strcmp(argv[1], "-l") != 0) {
      incorrect_usage = true;
    } else if (argc == 2) {
      print_full_details = true;
      dir_to_use = getcwd(dir_to_use, 0);
    } else {
      print_full_details = true;
      dir_to_use = argv[2];
    }
  }
  if (argc > 3) {
    incorrect_usage = true;
  }

  if (incorrect_usage) {
    fprintf(stderr,
            "Usage: mystat -l dir (-l optional. if -l not "
            "provided, do not specify dir. if -l provided, dir is optional.");
    fprintf(stderr,
            "\n\n\t If -l is provided, this prints out a bunch of stats on "
            "each file entry found. If not, it just prints out their names.");
    exit(1);
  }

  if (dir_to_use == NULL) {
    dir_to_use = getcwd(dir_to_use, 0);
  }

  printf("dir_to_use is: %s\n", dir_to_use);
  DIR *dp = opendir(dir_to_use);
  assert(dp != NULL);

  struct dirent *dir_entry;
  struct stat statbuf;
  while ((dir_entry = readdir(dp)) != NULL) {
    stat(dir_entry->d_name, &statbuf);
    printf("%s\n", dir_entry->d_name);
    if (print_full_details) {
      // The "%3o" prints three octal characters, which I force st_mode into
      // being by bitwise masking it with 0777. (I got this from StackOverflow!)
      printf("\tOwner: %u\tGroup: %u\tPermissions: %3o\n", statbuf.st_uid,
             statbuf.st_gid, statbuf.st_mode & 0777);
    }
  }

  return 0;
}