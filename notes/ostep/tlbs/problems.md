## Solutions

1. gettimeofday() returns time in seconds and microseconds, so presumably its resolution is in microseconds. It does mention "the resolution of the system clock is hardware-dependent", so this depends on stuff on my laptop and I'm not sure how to figure that out. That makes it difficult to answer how long the operation has to take, so I'll guess at "a few seconds" and see how it does. We'll figure out how many times to loop through by attempting different amounts and seeing how long it takes.

2. I think ours also shows a three-level cache, but is super noisy because it handles really low page numbers very poorly (probably needs more trials than just 10, or microseconds is too low precision). And then increases linearly after 256, which is odd. Maybe after 128, given the larger jump in numbers, is when we've moved off the TLB caches and into main memory entirely, and from there it would increase linearly?

3. It doesn't look like loop unrolling is hurting us much (I'm seeing similar results with -O0).

4. The inability to pin threads with MacOS makes this impossible and totally screws with our numbers.

5. Zero-filling does make a pretty big difference! Switching from malloc to calloc to get that for free shows quite the time difference (the time diff increases in some cases, which I didn't expect...)

The data looks weirdly linear after 64 pages for me for some reason...frown.
