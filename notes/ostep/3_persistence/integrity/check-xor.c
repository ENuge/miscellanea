#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>

// Computes and prints an XOR checksum over an input file
// It reads the file as raw binary, not as strings or anything.
int main(int argc, char *argv[]) {
  // printf("Size of a char is: %lu\n", sizeof(char));
  unsigned char checksum;

  if (argc != 2) {
    fprintf(stderr, "Usage: check-xor file, where file is a path to a file");
    exit(1);
  }
  char *file = argv[1];
  int fd = open(file, O_RDONLY);
  if (fd == 0) {
    fprintf(stderr, "Could not open file %s for reading", file);
  }

  // TODO: Read file as bytes, do XOR etc on it. My wrist hurts, so I'm
  // going to not-code right now.

  exit(0);
}