#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  size_t data_len = 100;
  int *data = malloc(data_len*sizeof(int));
  data[data_len] = 0;

  // Problem 6:
  for (size_t i = 0; i < data_len; i++) {
    data[i] = i;
  }
  free(data);
  printf("Value halfway through data: %d", data[50]);

  // Problem 7: Pass funny data to it - a pointer halfway through
  // data, instead of the one it was malloc'ed from.
  // free(data+50);
}