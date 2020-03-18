#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/time.h>

int measure_syscall();
int measure_pipe();

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Must provide one argument, exiting\n");
    exit(1);
  }
  if (strcmp(argv[1], "pipe") == 0) {
    measure_pipe();
  }
  else if (strcmp(argv[1], "syscall") == 0) {
    measure_syscall();
  }
  else {
    printf("Unknown argument, must be either pipe or syscall, exiting.\n");
    exit(1);
  }
}

int measure_syscall() {
  // OK, so about 10 microseconds for a syscall. This is doing it somewhat
  // lazily - running the entire program repeatedly, instead of looping
  // here and averaging out the diff. But it gives the general picture.
  struct timeval tv_before;
  struct timeval tv_after;
  char empty_buffer[0];

  int fd;
  fd = open("syscall_timing.c", O_RDONLY);
  if (fd == 0) {
    printf("Error opening file syscall_timing.c, exiting\n");
    exit(1);
  }

  gettimeofday(&tv_before, 0);
  read(fd, empty_buffer, 0);
  gettimeofday(&tv_after, 0);
  printf("Total time for a single syscall: %d", tv_after.tv_usec - tv_before.tv_usec);
  exit(0);
}

int measure_pipe() {
  // Measures the time for a context switching by writing 
  // time values on a pipe from a child process to a parent
  // process. It claims to be about 40 microseconds, but
  // note I'm not forcing these to happen on the same CPU
  // so these numbers are misleading.
  printf("Testing context switch times.\n\n");
  int fileDescriptors[2];
  pipe(fileDescriptors);

  // Force both processes to run on the same CPU
  printf("WELP! sched_set_affinity does not exist on MacOS. I could look into using the affinity API, but that's more effort than I'm looking for right now! Back to the book. \n");
  exit(1);

  // The stuff below this section actually does work, but it may run on
  // different cores...
  // cpu_set_t single_cpu_set;
  // CPU_ZERO(&single_cpu_set);
  // CPU_SET(1, &single_cpu_set);
  // sched_setaffinity(0, sizeof(cpu_set_t), &single_cpu_set);

  int rc = fork();

  struct timeval tv_after;
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  }
  else if (rc == 0) {
    // child process
    close(fileDescriptors[0]);
    printf("Just before writing timevalue to pipe\n");
    
    struct timeval tv_before;
    gettimeofday(&tv_before, 0);

    // Whoah...you can pipe memory addresses and it'll do what you expect
    write(fileDescriptors[1], &tv_before, strlen(&tv_before) + 1);
    exit(0);
  }
  else {
    // The parent process
    struct timeval tv_read;
    close(fileDescriptors[1]);
    read(fileDescriptors[0], &tv_read, sizeof(tv_read));
    gettimeofday(&tv_after, 0);
    printf("Total usec after: %d, total usec before: %d\n", tv_after.tv_usec, tv_read.tv_usec);
    printf("Total elapsed microseconds: %d\n", tv_after.tv_usec - tv_read.tv_usec);
    printf("Just after reading timevalue from pipe\n");
    exit(0);
  }
}