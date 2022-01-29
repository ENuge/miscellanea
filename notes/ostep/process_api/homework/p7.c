#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  int rc = fork();
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0) {
    wait(NULL);
    printf("child starting -- and finishing!\n");
    close(STDOUT_FILENO);
    printf("child printing some more after closing stdout\n");
  }
  else
  {
    int* statLoc = NULL;
    waitpid(rc, statLoc, 0);
    printf("Parent done!\n");
  }
}