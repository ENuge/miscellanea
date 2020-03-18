## Solutions

1. I'm not actually going to do that - lottery scheduling is quite straightforward...

2. Job 0 may run before job 1 completes, but it's quite unlikely (it will happen on average 10% of the time). Such a ticket imbalance makes it much easier for resource starvation to occur (which isn't necessarily a bad thing - you are, after all, letting the jobs specify their tickets...).

3. It's about 90% fair, according to the numbers in the graph. I'm being lazy, but the actual work is fairly trivial - run them a bunch, divide the time the first job completes by the time the second one completes, average all those fairness values.

4. As the quantum size gets larger, the scheduling gets more unfair. You're basically reducing the number of dice rolls.

5. I could make a version, but I'm not going to. Sorry. It might be interesting to let jobs boost their own ticket values if they have not run in a while, or something; particularly if they can do that in response to a high unfairness value that negatively impacts them. With a stride scheduler, the graph would sawtooth - things would appear a bit more unfair as the differences in pass value are greatest (immediately after running the job with the highest pass value) and would become least unfair as the differences in pass value are smallest. The pattern would repeat, but the values would trend towards more fair with more runs (ie the low points in the trend will be much higher, the high points will be about the same or maybe slightly higher).