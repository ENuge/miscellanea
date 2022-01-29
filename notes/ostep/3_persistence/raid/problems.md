## Solutions

1.
./raid.py -n 5 -L 1 -R 20
LOGICAL READ from addr:16 size:4096
Physical reads/writes?
Disk 0(or 1), offset 8

LOGICAL READ from addr:8 size:4096
Physical reads/writes?
Disk 0(or 1), offset 4

LOGICAL READ from addr:10 size:4096
Physical reads/writes?
Disk 0(or 1), offset 5

LOGICAL READ from addr:15 size:4096
Physical reads/writes?
Disk 2(or 3), offset 7

LOGICAL READ from addr:9 size:4096
Physical reads/writes?
Disk 2(or 3), offset 4

./raid.py -n 5 -L 4 -R 20

LOGICAL READ from addr:16 size:4096
Physical reads/writes?
disk 1, offset 5

LOGICAL READ from addr:8 size:4096
Physical reads/writes?
disk 2, offset 2

LOGICAL READ from addr:10 size:4096
Physical reads/writes?
disk 1, offset 3

LOGICAL READ from addr:15 size:4096
Physical reads/writes?
disk 0, offset 5

LOGICAL READ from addr:9 size:4096
Physical reads/writes?
disk 0, offset 3

./raid.py -n 5 -L 5 -R 20

parity bit location: 3 2 1 0 3 2 1 0
parity bit location equation = |3 - offset % 4|
find the disk normally (as if RAID0 with 3), if parity bit <= disk, add 1
LOGICAL READ from addr:16 size:4096
Physical reads/writes?
disk 0, offset 5

LOGICAL READ from addr:8 size:4096
Physical reads/writes?
disk 2, offset 2 (??WTF value are they getting? Maybe their rotating parity bit is starting elsewhere? :confused:)

LOGICAL READ from addr:10 size:4096
Physical reads/writes?
disk 2, offset 3

LOGICAL READ from addr:15 size:4096
Physical reads/writes?
disk 3, offset 5

LOGICAL READ from addr:9 size:4096
Physical reads/writes?
disk 0, offset 3

Ahhhhh I calculated mine for left asymmetric RAID5 and they're clearly using left-symmetric. Tricky hobbitses. :(
I didn't even notice the examples were also left-symmetric. That's useful knowledge!

2. The chunk size affects both the disk selection and the offset, which is kind of annoying.

3. Skipping reversing these because I think I have this under control...

4. For larger request sizes, RAID4 and RAID5 are much more efficient because they use every disk.

5. RAID4 scales horribly, as every disk is locked up on the parity disk constantly. RAID0 scales well but there's no fault tolerance there. RAID1 scales half as well as the others because it's using every other disk as a mirror.

6. When using RAID4 or RAID5, write large datasets at a time and you'll get the best performance. Otherwise a disk might be occupied with the parity bit that cannot otherwise be used for useful data manipulation.
