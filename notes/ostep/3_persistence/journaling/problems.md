## Solutions

1.

inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

Can you figure out which files and directories exist?

/g, /t (file containing 'z') /w, /w/p (p is an empty file) /m (file containing 'g')

2.
inode bitmap 1100100010000010
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

inode bitmap check breaks: it should be 1100100010000110 . missing a 1, this is the one from the example!

3.

inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:2] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

Can you figure out how the file system was corrupted?

inode bitmap check: good
data bitmap check: good
inode-> data map:
/g /g/p /t('z') /w /w/p(empty) /m ('g') (but its reference count is 2, it should only be 1!) AND BOOM GOES THE DYNAMITE

inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:1][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

d a:6 r:1 should be d a:6 r:2 AND BOOM GOES THE DYNAMITE

4.
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (y,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

Can you figure out how the file system was corrupted?

The data is corrupted at data block 6, [(.,8) (y,0)]. The directory is dangling - not referring back to any parent directory. You could fix this by walking the directory tree back from the parent and, when coming across any invalid block, updating its value to refer to the right thing.

with -S 38:
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (b,1)][] [][] [z][] [][g]

Can you figure out how the file system was corrupted?
[(.,4) (..,0) (b,1)] has the wrong filename, it should be (p, 1). Without more data, it would be impossible to fix this.

inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (w,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

Can you figure out how the file system was corrupted?
Directory g was renamed w in [(.,0) (..,0) (w,8) (t,14) (w,4) (m,13)] . This is another data inconsistency that's impossible to recover from given this data because you just do not have access to the right value any more.

5.

-S 6
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [d a:-1 r:1][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

There's an unlinked inode directory: [d a:-1 r:1]. The repair tool should probably just clear this inode because it's unclear where it's supposed to be in the filesystem.

-S 13
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [f a:-1 r:1][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

In this case there's an unlinked file inode: [f a:-1 r:1]. The file system should just wipe that inode. The difference is one is an inode the other a directory, but the cleanup behavior is the same because they are both unlinked.

6.
-S 9
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][d a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

inode 13 is [d a:15 r:1], it should be a file. The address and reference count are correct, though. The filesystem should be able to infer whether the datablock is right or the inode is right (that is, whether this is really a directory or a file), by walking the directory tree and checking the reference count of the parent directory for this thing. That reference count will only be correct if it's a directory or file.

7.

-S 15
inode bitmap 1100100010000110
inodes [f a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

[f a:0 r:4] is a file when it should be a directory. The filesystem could determine the system is in an incorrect state at this inode or data block, and attempt to make the inode a dir (based on the datablock contents) and see if that change makes the filesystem consistent. If you couldn't repair this, your entire file system would be completely broken, ouch.

8.
-S 10
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,3) (p,1)][] [][] [z][] [][g]

[(.,4) (..,3) (p,1)] refers back to the wrong parent directory, it should be (.., 0). You could fix this by walking the directory tree to know who is actually the parent of that directory, so yeah there's redundancy that lets you move both up and down the filesystem hierarchy.

9.

-S 16
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:6 r:2][] [][] [][f a:5 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

inode 13 is corrupted: [f a:5 r:1]. It points to an empty file, in which case its address should be -1. In this case, we can determine that every other datablock is accounted for except for data block 15, so this must refer to that. We couldn't fix this though if multiple inodes pointed to incorrect datablocks at the same time.

-S 20
inode bitmap 1100100010000110
inodes [d a:0 r:4][f a:-1 r:1] [][] [d a:8 r:2][] [][] [d a:11 r:2][] [][] [][f a:15 r:1] [f a:12 r:1][]
data bitmap 1000001010001001
data [(.,0) (..,0) (g,8) (t,14) (w,4) (m,13)][] [][] [][] [(.,8) (..,0)][] [(.,4) (..,0) (p,1)][] [][] [z][] [][g]

inode 8 is corrupted: [d a:11 r:2]. The address of the datablock is empty. You could recover from this similarly as above. This is a little easier to recover from than the directory case because you have extra information: your data block should have a parent directory pointing to a known inode, and the current directory should point to the inode address that we know is corrupted.
