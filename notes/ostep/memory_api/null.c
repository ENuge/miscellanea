#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  int *some_integer;
  some_integer = NULL;
  int underlying_integer = *some_integer;
  printf("Some integer is: %d\n", underlying_integer);
}