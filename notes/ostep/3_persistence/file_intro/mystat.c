#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/time.h>

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: mystat file_or_directory");
    exit(1);
  }

  char *pathname = argv[1];
  struct stat statbuf;

  stat(pathname, &statbuf);
  printf("Size: %hu\tNumber of blocks allocated: %lld\tReference (link) count: "
         "%hu\t",
         statbuf.st_mode, statbuf.st_blocks, statbuf.st_nlink);
  return 0;
}