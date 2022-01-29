## Solutions

0. (From the README):
./malloc.py -S 100 -b 1000 -H 4 -a 4 -l ADDRSORT -p BEST -n 5 
ptr[0] = Alloc(3)  returned 1004
List: HEAD at 1008 -> size 92 (looks like size here includes the header) , next -> NULL
Free(ptr[0]) returned 0
List: HEAD at 1000, size 8 -> at 1008, size 92
ptr[1] = Alloc(5)  returned 1012
List: HEAD at 1000, size 8 -> at 1020, size 80

Free(ptr[1]) returned 0
List: HEAD at 1000, size 8 -> at 1008, size 12 -> at 1020, size 80

ptr[2] = Alloc(8)  returned 1012
List: HEAD at 1000, size 8 -> at 1020, size 80

BOOM! I'm the greatest.

1. I'm skipping doing this because it's basically the example above repeated. What you'll notice though is an increase in fragmentation over time, as we are not doing any sort of coalescing.

Ahh fine I'll do it.
 ./malloc.py -n 10 -H 0 -p BEST -s 0                              608ms  Sat Mar 21 18:07:50
seed 0
size 100
baseAddr 1000
headerSize 0
alignment -1
policy BEST
listOrder ADDRSORT
coalesce False
numOps 10
range 10
percentAlloc 50
allocList
compute False

ptr[0] = Alloc(3)  returned 1000
List: HEAD -> at 1003, size 97

Free(ptr[0]) returned 0
List: HEAD -> at 1000, size 3 -> at 1003, size 97

ptr[1] = Alloc(5)  returned 1003
List: HEAD -> at 1000, size 3 -> at 1008, size 92

Free(ptr[1]) returned 0
List: HEAD -> at 1000, size 3 -> at 1003, size 5 -> at 1008, size 92

ptr[2] = Alloc(8)  returned 1008
List: HEAD -> at 1000, size 3 -> at 1003, size 5 -> at 1016, size 84

Free(ptr[2]) returned 0
List: HEAD -> at 1000, size 3 -> at 1003, size 5 -> at 1008, size 8 -> at 1016, size 84

ptr[3] = Alloc(8)  returned 1008
List: HEAD -> at 1000, size 3 -> at 1003, size 5 -> at 1016, size 84

Free(ptr[3]) returned 0
List: HEAD -> at 1000, size 3 -> at 1003, size 5 -> at 1008, size 8 -> at 1016, size 84

ptr[4] = Alloc(2)  returned 1000
List: HEAD -> at 1002, size 1 -> at 1003, size 5 -> at 1008, size 8 -> at 1016, size 84

ptr[5] = Alloc(7)  returned 1008
List: HEAD -> at 1002, size 1 -> at 1003, size 5 -> at 1015, size 1 -> at 1016, size 84

2. With a worst fit, we'll avoid the size one chunks of dead space we have above. But without coalescing, things will still be fragmented across the address space. And that's what we see! Boom!

3. First fit in this case will do very similar to best fit, but that's by chance. In general, things will still be fragmented. First fit makes allocations much faster because it does not require traversing the entire array.

4. SIZESORT+ is a clear benefit if you're trying to do best fit, likewise for the opposite with worst fit. In each case you can terminate early. Addrsort is actually the worst for every possible strategy (except SIZESORT+ with worst fit because you may have to iterate over values you just won't fit in).

5. Over time, larger allocations just will not fit without coalescing. The free list is also quite large, filled completely with size 1 free spaces lol. The free list is size 1 with coalescing...nice! The list ordering with this many elements does not matter at all with the coalescing. I think it matters a bit at small sizes and that's it.

6. As the percent allocations near 100, we run out of space and start returning -1 earlier, which is fairly obvious. I'd hope. And when it's 0, when we coalesce we end up with a mostly contiguous free space of memory. Yay!

7. Turning off coalescing makes things more fragmented. I poked around a bit, no magical revelations here.