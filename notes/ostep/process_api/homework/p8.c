#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  int pipeFileDescriptors[2];
  // This took about five years off my life:
  // you need to create the pipe before you fork it for this
  // to work properly.
  pipe(pipeFileDescriptors);

  int rc1 = fork();

  char message[] = "From child one to child two:";
  const int commLen = strlen(message);

  if (rc1 < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc1 == 0) {
    printf("Child 1 before writing to pipe\n");
    // Close the input to the pipe - we don't use it.
    close(pipeFileDescriptors[0]);
    write(pipeFileDescriptors[1], message, commLen + 1);
    printf("Child 1 after writing to pipe\n");
    exit(0);
  }

  int rc2 = fork();

  if (rc2 < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc2 == 0) {
    // Create a buffer much larger than we actually need - it
    // will read until the null byte in the pipe so it's cool.
    char buffer[10000];
    printf("Child 2 before reading from pipe\n");
    // Close the output file descriptor, we don't need it here.
    close(pipeFileDescriptors[1]);
    // Note we don't need to explicitly wait(NULL) on child 1 because
    // this read is blocking, so it'll do the waiting for us.
    read(pipeFileDescriptors[0], buffer, sizeof(buffer));
    printf("%s\n", buffer);
    fprintf(stderr, "Child 2 after reading from pipe and printing it to stdout\n ");
  }
  
  if (rc1 > 0 && rc2 > 0) {
    // Parent must wait for _both_ children to finish
    // wait by itself just waits for _a_ child to finish,
    // which was giving me inscrutable errors :'(
    waitpid(rc1, NULL, 0);
    waitpid(rc2, NULL, 0);
    printf("Parent done!");
  }
}