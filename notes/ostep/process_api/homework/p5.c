#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  // I also just adjusted this to use for p6...
  int rc = fork();
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0) {
    wait(NULL);
    printf("child starting -- and finishing!\n");
  }
  else
  {
    int* stat_loc = NULL;
    waitpid(rc, stat_loc, 0);
    printf("Parent done!\n");
  }
}