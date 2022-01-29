#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/time.h>

int main(int argc, char *argv[])
{
  char *usage_str = "Usage: ./tlb number_of_pages_to_touch number_of_trials\n";
  if (argc != 3)
  {
    printf("%s", usage_str);
    exit(1);
  }
  char *num_pages_str = argv[1];
  int num_pages = atoi(num_pages_str);
  if (num_pages == 0)
  {
    printf("%s", usage_str);
    printf("number_of_pages_to_touch must be a positive integer greater than 0\n");
    exit(1);
  }

  char *num_trials_str = argv[1];
  int num_trials = atoi(num_trials_str);
  if (num_trials == 0)
  {
    printf("%s", usage_str);
    printf("number_of_trials must be a positive integer greater than 0\n");
    exit(1);
  }

  int PAGE_SIZE = getpagesize();
  int jump = PAGE_SIZE;
  int *array_integers = calloc(num_pages * PAGE_SIZE, sizeof(int));

  // time_diffs is an integer in microseconds because that is the
  // resolution of gettimeofday(). We can change that if worried about
  // overflow etc, but it should be fine. microseconds may not be
  // precise enough though, we may need nanoseconds? We'll see.
  int sum_time_diffs = 0;
  struct timeval tv_before;
  struct timeval tv_after;
  for (size_t trial_no = 0; trial_no < num_trials; trial_no++)
  {
    gettimeofday(&tv_before, 0);
    for (size_t i = 0; i < num_pages * jump; i += jump)
    {
      array_integers[i] += 1;
    }
    gettimeofday(&tv_after, 0);

    int sec_timediff = tv_after.tv_sec - tv_before.tv_sec;
    // microsec_timediff can be negative if a second gets incremented
    // but few microseconds tick in that second. This gets picked up
    // in the real timediff by adding the microseconds to the sec_timediff.
    int microsec_timediff = tv_after.tv_usec - tv_before.tv_usec;
    int microsecs_in_second = 1000000;
    int real_timediff_in_microsecs = sec_timediff * microsecs_in_second + microsec_timediff;

    sum_time_diffs += real_timediff_in_microsecs;
  }
  // Get average of diffs in above array.
  double avg_time_diff = (float)sum_time_diffs / (float)num_trials;
  printf("Average time diff is: %f microseconds", avg_time_diff);
  exit(0);
}