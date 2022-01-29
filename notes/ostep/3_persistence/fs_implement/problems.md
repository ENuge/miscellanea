## Solutions

1. Honestly, I did the example in the problem very quickly so I'm skipping this.

2.  ./vsfs.py -n 6 -s 21 -r
   inode bitmap 10000000
   inodes [d a:0 r:2][] [][] [][] [][]
   data bitmap 10000000
   data [(.,0) (..,0)][] [][] [][] [][]

mkdir("/o");
inode bitmap 11000000
inodes [d a:0 r:3][d a:1 r:2] [][] [][] [][]
data bitmap 11000000
data [(.,0) (..,0) (o,1)][(.,0) (..,0)] [][] [][] [][]

creat("/b");
inode bitmap 11100000
inodes [d a:0 r:3][d a:1 r:2] [f a:-1 r:1][] [][] [][]
data bitmap 11000000
data [(.,0) (..,0) (o,1) (b,2)][(.,0) (..,0)] [][] [][] [][]

creat("/o/q");
inode bitmap 11110000
inodes [d a:0 r:3][d a:1 r:2] [f a:-1 r:1][f a:-1 r:1] [][] [][]
data bitmap 11000000
data [(.,0) (..,0) (o,1) (b,2)][(.,0) (..,0) (q,3)] [][] [][] [][]

fd=open("/b", O_WRONLY|O_APPEND); write(fd, buf, BLOCKSIZE); close(fd);
inode bitmap 11110000
inodes [d a:0 r:3][d a:1 r:2] [f a:2 r:1][f a:-1 r:1] [][] [][]
data bitmap 11100000
data [(.,0) (..,0) (o,1) (b,2)][(.,0) (..,0) (q,3)] [m][] [][] [][] // i dunno why they use m specifically here but sure

fd=open("/o/q", O_WRONLY|O_APPEND); write(fd, buf, BLOCKSIZE); close(fd);
inode bitmap 11110000
inodes [d a:0 r:3][d a:1 r:2] [f a:2 r:1][f a:3 r:1] [][] [][]
data bitmap 11110000
data [(.,0) (..,0) (o,1) (b,2)][(.,0) (..,0) (q,3)] [m][j] [][] [][]

creat("/o/j");
inode bitmap 11111000
inodes [d a:0 r:3][d a:1 r:2] [f a:2 r:1][f a:3 r:1] [f a:-1 r:1][] [][]
data bitmap 11110000
data [(.,0) (..,0) (o,1) (b,2)][(.,0) (..,0) (q,3) (j,4)] [m][j] [][] [][]

At least based on how I was doing this, the inode and data algorithms like to allocate the first free block. Given there was no variable-sized blocks or anything, that could mean many things ("first free" in this case also happens to be "most available contiguous space", for instance. inode bitmap it makes sense to always start like this so you can see really easily the number of files available via binary search, the data bitmap algorithm seems naive and can be improved).

3. Uh what? If you reduce the number of data blocks to 2, you can only create empty files, as that is the only thing not requiring data... Creating a directory or writing contents to a file fail.

4. With very few inodes, you can write a lot of data to an existing file but that's about it. Creating anything new fails. The final state of the system is likely to be a gigantic blob of all of the data held in a single file, I guess. :shrug:
