#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  char *parents_turn = "P";
  char *file_to_read = "throwaway.txt";

  // This will open (without append) file-to-read without actually writing
  // anything, effectively clearing the file. So we can run this on repeat
  // without polluting our file.
  fclose(fopen(file_to_read, "w"));

  int rc = fork();

  // This lets us reference stdout_copy via dup2 to reopen this in the parent
  int stdout_copy = dup(1);
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0) {
    printf("hello\n");
    close(STDOUT_FILENO);
    open(file_to_read, O_CREAT | O_WRONLY | O_TRUNC, S_IRWXU);
    printf("%s", parents_turn);
  }
  else
  {
    // Prints goodbye, but only after the parent's hello, without
    // using wait(), by using our file as a synchronizing mechanism.
    // int fd = open("throwaway.txt", O_CREAT | O_WRONLY | O_TRUNC, S_IRWXU);
    int done = 0;
    fprintf(stderr, "PARENT: Just before while loop\n");
    while (done == 0) {
      char buffer[100];
      FILE *fp;
      fp = fopen(file_to_read, "r");
      if (fp == NULL) {
        perror("Error opening file");
        return(-1);
      }

      if (fgets(buffer, 5, fp) != NULL) {
        if (buffer[0] == *parents_turn) {
          // dup2 reopens stdout after being closed in the child
          dup2(stdout_copy, 1);
          printf("goodbye\n");
          done = 1;
        }
      }
      // else {
      //   perror("fgets returned NULL");
      // }
      fclose(fp);
      usleep(100);
    }
  }
}