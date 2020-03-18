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
    printf("child starting!\n");
    char *myargs[2];
    myargs[0] = strdup("/bin/ls");
    myargs[1] = NULL;
    execvp("/bin/ls", myargs);
  }
  else
  {
    printf("Parent done!\n");
  }
}