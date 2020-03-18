# Responses to the questions

1. Average SJF response time = (0 + 200 + 400) / 3 = 200.
Average SJF turnaround time = (200 + 400 + 600) / 3 = 400.
Average FIFO response time and turnaround time are the same because this policy will schedule them identically.

2. Average SJF response time = (0 + 100 + 300) / 3 = 133.33 .
Average SJF turnaround time = (100 + 300 + 600) / 3 = 333.33.
Given they all come in at the same time, FIFO depends entirely on which order they happen to be scheduled in...so it's impossible to compute here (I guess I could average all three). If we assumed it went in SJF time, we'd get the SJF values...

3. A round-robin scheduler with a time slice of 1 would have:
average response time = (0 + 1 + 2) / 3 = 1
average turnaround time = (300 + (300+200) + (300+200+100) / 3 = 466.67

4. SJF and FIFO deliver the same workaround times for tasks that are all of the same length, or tasks that happen to be scheduled shortest job first in time.

5. If the quantum length is greater than the second largest task, the response time will be the same as SJF. 

6. Response times increase (get worse) as job lengths increase. I could just repeat a bunch of runs of the simulator to prove the trend, I suppose.

7. Response time decreases as quantum lengths increase. The worst-case response time given n jobs is the sum from 1 to n of n*quanta / n. Which I think can be reduced to something algebraic. :shrug: