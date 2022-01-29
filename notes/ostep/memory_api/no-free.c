#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  int *some_integer = (int *) malloc(sizeof(int));
  *some_integer = 5;
  exit(0);
}