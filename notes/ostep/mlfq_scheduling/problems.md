1. Done in notebook, just traced out one of the problems.

2. Example 1:
  One job, 10 ms quanta, job length of 200:
    ./mlfq.py -l 0,200,0 -q 10 -n 3
Example 2:
  Two jobs: length 200 start time 0, length 20 start time 100; three queues
    ./mlfq.py -l 0,200,0:100,20,0 -q 10 -n 3
Example 3:
  Two jobs: length 200 start time 0, length 20 start time 100 (say), IO every 1ms for 1ms; three queues
    ./mlfq.py -l 0,200,0:100,20,1 -q 10 -n 3 -i 1

And those are the only ones concretely specified.

3. You can make the scheduler parameters behave just like a round-robin scheduler by simply specifying that there be only a single queue.


4. This will starve the second job by having the first one use up almost all of its alotted time and then jump into IO at the last second (every 9 goes with a quanta of 10) to game the scheduler.
./mlfq.py -l 0,100,9:0,100,0 -i 1 -q 10 -n 2 -S -c

5. If your system is running more than 20 jobs, you can never guarantee that a single long-running job would get at least 5% of the CPU. If you assume a small number of jobs (like, two, say), with a quanta of 10ms, I guess every 200ms?

6. A job that just finished IO should obviously go to the top queue and not the bottom queue, but it's a good way to sideline some jobs by doing it the other way! (There's a delightful amount of idle time for when it finally gets around to running the lowest priority queue of things just repeatedly waiting on IO!)