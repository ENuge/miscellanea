#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

void print_array(int* array, size_t array_len) {
  // Assumes the array has real values in it...
  printf("[");
  for (size_t i = 0; i < array_len; i++) {
    if (i == array_len - 1) {
      printf("%d", array[i]);
    }
    else {
      printf("%d, ", array[i]);
    }
  }
  printf("]\n");
}

int* add(int* orig_array, int* array_len, int elem) {
  *array_len += 1;
  int *new_array = realloc(orig_array, *array_len);
  new_array[*array_len - 1] = elem;
  return new_array;
}

int* remove_last(int* orig_array, int* array_len) {
  *array_len -= 1;
  int *new_array = realloc(orig_array, *array_len);
  return new_array;
}

int main(int argc, char *argv[]) {
  // The world's least-performant dynamically-allocating array!
  int array_len = 4;
  int* array = malloc(array_len * sizeof(int));
  array[0] = 0;
  array[1] = 1;
  array[2] = 2;
  array[3] = 3;
  print_array(array, array_len);

  array = add(array, &array_len, 4);
  // array_len += 1;
  print_array(array, array_len);

  array = add(array, &array_len, 5);
  // array_len += 1;
  print_array(array, array_len);

  array = remove_last(array, &array_len);
  // array_len -= 1;
  print_array(array, array_len);
}