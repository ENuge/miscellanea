## Solutions

1. This is really trivially easy, so I did it while reading the README and am not going to bother with seeds 1, 2, and 3.

2. You have to set the bounds register to 930 to make sure they are all within the bounds. (I originally thought 929, but the bounds are _not_ inclusive!)

3. The physical memory size is 16k, so with a bound register of 100 the maximum base register so that the address still fits into physical memory in its entirety would be 16k - 100.

4. The underlying math doesn't really change with larger address spaces or physical memories.

5. That just seems like a lot of work without actually teaching much of anything, so I'm not going to do it.