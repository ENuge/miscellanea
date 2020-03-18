#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
  close(STDOUT_FILENO);
  int fd = open("p1.c", O_CREAT | O_WRONLY | O_TRUNC, S_IRWXU);
  int rc = fork();
  if (rc < 0)
  {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0)
  {
    // printf("In the child, the file descriptor is: %d\n", fd);
    printf("In the child, writing to the file\n");
  }
  else
  {
    // printf("In the parent, the file descriptor is: %d\n", fd);
    printf("In the parent, writing to the file\n");
  }
}