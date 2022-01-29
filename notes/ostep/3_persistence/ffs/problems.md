## Solutions

1. The resulting allocation will spread the data across multiple groups because the large file is over the large file exception. And boom! That's precisely what happens.

2. The large block exception is 30 now (-L 30), but the file is 40 blocks, so its data should still be spread across multiple groups. Maybe only across two groups now, though, depending on the implementation of the exception logic. I guess it's using that exception as the splitting point, which matches the fact that it apportioned 4 each in number 1. The behavior then is to split at 30, but given there's only 30 blocks per group to begin with, this is equivalent to having no exception at all.

3. The filespan with an exception of 4 with a 40-block file means each group gets exactly 4 datablocks. The max distance is going to be from the end of any data block in a group to the first data block in the next group (ignoring group 0). This is (30-4)+1+10 = 37. (30 data blocks per group, 10 inodes per group we skip over, 4 data blocks actually occupied, plus one for the super block).
   They got 372 which looks like my answer but is off by an order of magnitude, which makes no sense to me.

Anyhow, with -L 100, we expect all the data to cluster together. In that case, we expect the distance to be between the end of those blocks and the remaining storage space, or 40\*8+30 (because the data will extend ten into group 1), or 330.

Ohhhh I get filespan now. The max distance between the inode and _any_ data block, or between _any_ two data blocks. And it doesn't wrap around like I was assuming.

4. All the root files will go in one group, all the files under the j dir will go in a different group, and all the files under the t dir will go in a third group.

5. FFS does a fantastic job in minimizing dirspan by basically placing all files within that dir right next to each other.

6. Limiting the size of the inode table to 5 will force some files within a given directory to go into a different group. This will probably greatly increase the dirspan because the next open group may not be the literal next one (or if it is, that will force that one to bubble more of its own files up; in either case, increasing the dirspan). (Wow, I didn't expect it to perform as dramatically poorly as it did...).

7. I think it should be a weighted sum of the emptiest group (weighted heavily) and the sum of the emptiness of surrounding groups (preferring to not hop in the next empty group and screw over a previous dir that might get overspill being the reasoning). Doing things in pairs may be a good approach for exactly the reason I was thinking, and is far easier to implement in practice. It should benefit dirspan for any directory with more files than fit in the data blocks of a single group, but that within two groups.

8. All the files will be created in the same group. There will be 1-sized "holes" in them after deleting, and the newly created large thing will be stuck at the end of them all. Oh...nevermind, ffs just split it and filled all the chunks. Surprising. Thsi is problematic because it makes transferring the entire contents of /i very expensive - equivalent to if the file were twice as large. That's probably not behavior we want.

9. -C 2 solves that problem! It may increase dirspan because it's less likely the last file in a dir could still fit within the group if it can't squeeze itself between multiple other files. I think it'll increase filespan because the datablocks may be pushed farther within a given group? Less confident on the latter.
