## Solutions

0. First, let's get the five values in binary:
523 -> 0b1000001011
414 -> 0b0110011110
802 -> 0b1100100010
310 -> 0b0100110110 
488 -> 0b0111101000

So 523 and 802 are in segment 1 (in theory). Their real offsets from the end are then 1K (the address space size) - this value, so 523 -> 1k (1024) - 523 = 501 and 802 -> 1k (1024) - 802 = 222.

An offset of 501 is greater than the limit of 450, so it fails. The offset of 222 is fine, the physical address is thus 4692-222 = 4470.

1. ./segmentation.py -a 128 -p 512 -b 0 -l 20 -B 512 -L 20 -s 0
108 -> 0b1101100 (1) -> offset 128 - 108 = 20. 512 - 20 = 492dec in physical memory.
97  -> 0b1100001 (1) -> offset 128 - 97 = 31 = segfault (31 > 20)
53  -> 0b0110101 (0) -> segfault (53 > limit 20)
33  -> 0b0100001 (0) -> segfault (33 > limit 20)
65  -> 0b1000001 (1) -> offset 128 - 65 = 63 = segfault (63 > 20)

./segmentation.py -a 128 -p 512 -b 0 -l 20 -B 512 -L 20 -s 1
17  -> 0b0010001 (0) -> 17
108 -> 0b1101100 (1) -> offset 20, 512 - 20 = 492.
97  -> 0b1100001 (1) -> offset 31, greater than limit, segfault.
32  -> 0b0100000 (0) -> segfault
63  -> 0b0111111 (0) -> segfault

./segmentation.py -a 128 -p 512 -b 0 -l 20 -B 512 -L 20 -s 2
122 -> 0b1111010 -> 506
121 -> 0b1111001 -> 512 - 7 = 505
7   -> 0b0000111 -> 7
10  -> 0b0001010 -> 10
106 -> 0b1101010 -> segfault
BOOM!

2. The highest legal virtual address in segment 0 is 20. The lowest legal virtual address in segment 1 is 128-20 = 108. The lowest illegal address is 21, the highest is 107. You jut run it using those values...

3. The lower base would be 0, its bounds would be 1. The upper base would be 15 with a bound of 1 (growing downward).

4. If you want 90% of the generated virtual addresses to be valid (when performed enough times / in aggregate), then make your bounds large enough to take up 90% of the virtual address space. That could be done by manipulating the limit bound for either of the two segments.

5. You could run it such that no virtual addresses are valid by making the limits 0 for both segments. It's equivalent to trying to get memory somewhere when the stack and heap are both empty.