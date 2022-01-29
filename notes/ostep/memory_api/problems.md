1. 
 ./null                                                                                                                      509ms  Wed Mar 18 21:02:43
fish: './null' terminated by signal SIGSEGV (Address boundary error)
Is the output. Basically, it segfaults as expected.

2. It tells me that it received a segmentation fault: 
Thread 2 received signal SIGSEGV, Segmentation fault.
0x0000000100000f5b in main (argc=1, argv=0x7ffeefbffb88) at null.c:11
11	  int underlying_integer = *some_integer

3. Valgrind does not work on MacOS. :'(

4. You can't find the memory leak with gdb because that's not what the tool is intended for! You can with Valgrind, but I can't get Valgrind to work with my version of MacOS. :(

5. It...just works. Which is surprising to me. The program is not correct - it's doing undefined behavior - setting to zero a value past the end of the allocated array. It's an off-by-one error.

6. It...just works and prints the value. Looks like free doesn't actually zero out values or anything, but simply marks that it's free for future malloc calls to be able to allocate to.

7. It yells loudly if you run this - "pointer being freed was not allocated". You don't even need tools to discover this!

8. This vector performs absolutely awfully because I'm reallocating memory with every single call, instead of amortizing that at every double or something. But it was nice and easy to implement!

9. I really wish I had access to a proper gdb and valgrind. :(