## Solutions

1.

./lfs.py -n 3
First, create file /ku3. Then, write /ku3 with contents z0z0z0z0. Then, create file /qg9.
Blocks 1-7 are dead, as well as 10? BOOM.

2. This does make it a little nicer. But it's just separating out the chunks...which wasn't really the hard part.

3. Yeah you can reason about the final state. I mean, it's deterministic - so you just run through and apply each one by one.

4. OK, so look at the checkpoint register, just 99, so we can jump there.
   Live blocks: 0, 99, 98, 97, 94, 93, 91, 95, 80, 34, 68, 69, 70, 76,77,78,79, 20, 66, 60, 64, 65
   ...and the rest are dead.
   BOOM.

5. Live blocks: 0, 16, 5, 15, 4, 8, 11, 14

6. Live blocks: 0, 13, 5, 12, 4, 8, 9, 10, 11, 12.
   If you don't buffer writes, you suffer a lot more from fragmentation. And thus more of the disk is wasted.

7. Create /foo, write 1 block of data to it at offset 0.
   The second command writes the 1 block fo data at offset 7.

The size field in the inode doesn't actually tell you the literal size of the file contents, but rather it tells you the amount of space allocated for the file. In this case, it's all offset a huge amount, so much of it is wasted.

8.
Creating a directory will create an extra data block because you immediately need to write where it is and whose parents it has. An empty file just doesn't have that. Also the reference counts for each will increase.

9.
When a hard link is created, the only things that change are the ref count of the file and the entry of the hard link is added to the datablock for the directory it lives in. There are no additional blocks allocated, though. A new file would have the directory datablock entry but also a new block for its inode (and obviously its reference count would jut be 1).

10.
Sequential makes far better use of the filesystem, allocating far fewer blocks in total (43 vs 53). Also the imap chunks and everything are much better compacted. So it's very very important.

11. Oof, running the provided command gives a list index out of range.
    If the checkpoint region was never updated, you'd have to roll forward everything to find out the latest state. You could determine what actions took place by looking at the new segment, and when you identify the imap update the checkpoint region, and repeat that each time. It would be expensive though. But it is salvageable. Updating it periodically just shortens the amount of time that you would need to roll forward (to starting at that checkpoint).
