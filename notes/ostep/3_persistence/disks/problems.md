## Solutions

1. -a 0:
   165r+s0+30t = 195

-a 6:
(360-15)r + 30t + 0s = 375

-a 30:
80s + (360-15-80s)r + 30s = 375

-a 7,30,8:

<!-- 0s+15r+30t + 80s+(360-15-80s-45prev)+30t + 0s+(720-375prev-0s)+30t = 760 -->

8orig = 45r
375r so far, has to seek 80s = 455r total. needs to get to 720+45 = 765 + 30t -> 795! BOOM. Their thing lied or something.
720-455

-a 10,11,12,13:
Just compute how many full rotations it has to do, then the offset for the last one.
10+11 -> 105r+60t+0s -> 165r
12+13 -> you're going to miss 12 on the 40s skew but you'll get 13 right away, so another full rotation + 15r+30t -> 570
ohhhh but we need to do them in order :facepalm:
so it's just 360+60 or 420 total, giving 420+165 for 585 total BOOM.

2. The times change when we "save" a rotation by doing this, but otherwise do not change at all. That's an absurd number of combinations suggested in the problem, I'm not doing that.

3. Similar deal here. Faster rotation rate tends to improve things a lot.

4. For -a 7,30,8 the requests should be processed as 7,8,30 for optimal behavior. SSTF here will be optimal: 15r+60t+300r -> 375

5. SATF will be the same here because the shortest-seek time also happens to be the shortest-access time. Shortest access time is faster when it would save time to seek elsewhere and then seek back to still catch another thing on the same track.

6. Given the default seek rate, the skew should be equal to that seek time of 40. In general, if you wanted to lose no rotation time to hop elsewhere, you want the skew to exactly match that seek rate\*number of tracks covered.

Skew = track seek time.

7. The bandwidth is highest on the inner, most dense tasks. I'm not redoing all of those calculations.

8. When the scheduling window is set to 1, it does not matter what policy you use. They will all just find that thing. Maximizing performance requires _all_ of the available requests, because it could always be better to choose the next one (this feels like a trick question...).

9. Yes, the bounded shortest-available time first solves starvation by guaranteeing that it services all requests within the current frame first. It performs worse than SATF in terms of bandwidth because it's effectively limiting the information.

How should a disk make the performance vs starvation tradeoff? I think it should clearly delineate acceptable bounds for each, and then plot out the difference between performance and starvation in different workloads with different sized windows. Then it should consider the workload pattern that most closely reflects the production accesses it may see and optimize for that according to their weighted preference between perf and starvation.

10. Greedy algorithms are optimal here.
