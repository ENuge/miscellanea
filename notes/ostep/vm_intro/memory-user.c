#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Expected exactly one positional argument, exiting!\n");
    exit(1);
  }

  int array_length = atoi(argv[1]) * 1000000;
  if (array_length == 0) {
    printf("Invalid input: %s -- the input must be parseable as a non-zero natural number\n", argv[1]);
  }
  // We use a char because a char is stored as a single
  // byte and thus maps nicely to our input (megabytes).
  char* array = calloc(array_length, sizeof(char));
  if (array == NULL) {
    printf("Error! Memory not allocated.\n");
    exit(1);
  }
  printf("Just after callocing!\n");

  int current_position = 0;
  while(1) {
    // A-Za-z plus a few things like \[] etc.
    // Uses pointer arithmetic to function like array indexing.
    *(array + current_position) = 'A' + rand() % 57;

    current_position += 1;
    if (current_position == array_length) {
      current_position = 0;
    }
  }
}