#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
  int x = 100;
  int rc = fork();
  if (rc < 0)
  {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0)
  {
    printf("Before setting x in the child, x is: %d\n", x);
    x = 50;
    printf("After setting x in the child, x is: %d\n", x);
  }
  else
  {
    printf("Before setting x in the parent, x is: %d\n", x);
    x = 42;
    printf("After setting x in the parent, x is: %d\n", x);
  }
}