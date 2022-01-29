## Solutions

1. Run with `./mem 1`, very little changes - free pages slowly decrease, then a bunch of pages get swapped in, and it repeats. Nothing very dramatic though, and the number of faults and general behavior looks about the same.

It is using an entire core consistently according to `top`. If I run two of these at once, two cores are maxed out and my fans start spinning, lol. `user time` is unfortunately not a field on my `vm_stat`.

2. When I kill the program, the `free` column increases dramatically. That's because all of that space that had been allocated is suddenly free! I think whether this happens suddenly or not depends on if the highwater/lowwater marks have been reached. So mine was probably accidental more than anything else.

3. The swapins and outs is 0 with `./mem 4000` _except_ for the first line in vm*stat, which is huge. (Turns out that's just a \_total*, though, which isn't useful to us here.)

There are frequent swapins but pretty infrequently any swapouts by the looks of things.

I'm trying with a huuuuuge amount (200GB) to see what happens. It segfaulted, lol.
It segfaults even at 20GB.
As the number increase, the total swapins increases a lot. At 8GB they're averaging ~2500.
Yes, the numbers make sense. As it tries to access more stuff than fits in physical memory, it's forced to swap out stuff from earlier in the array.

4. As the number of memory increases, we start to see more CPU dedicated to `kernel_task`, which is presumably the page fault handler/background daemon constantly swapping pages in and out. Neat. In fact the `mem` process has a gigantic number of faults accumulating.

5. I can't actually run ./mem 1200 :(, it segfaults on MacOS! That said, perf takes a huge nosedive with the constant swapping. The bandwidth is far higher the smaller the memory size I run this with. I could make a graph, but I'm feeling lazy, sorry.

6. I can't disable swap, but at 1200 I get segfaults on MacOS.

7. Can't really do this one either. :(
