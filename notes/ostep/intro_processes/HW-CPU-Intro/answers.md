# Answers

1. The CPU utilization should be 100%, because each process is always
   using the CPU (there is no I/O happening here).
   And I was right:
   ```
   > ./process-run.py -l 5:100,5:100 -c -p
Time     PID: 0     PID: 1        CPU        IOs 
  1     RUN:cpu      READY          1            
  2     RUN:cpu      READY          1            
  3     RUN:cpu      READY          1            
  4     RUN:cpu      READY          1            
  5     RUN:cpu      READY          1            
  6        DONE    RUN:cpu          1            
  7        DONE    RUN:cpu          1            
  8        DONE    RUN:cpu          1            
  9        DONE    RUN:cpu          1            
 10        DONE    RUN:cpu          1            

Stats: Total Time 10
Stats: CPU Busy 10 (100.00%)
Stats: IO Busy  0 (0.00%)
```

Woohoo!

2. It will first run all of the first process, then start the second and have to wait on all its IO.
  So it will take 10 ticks total (4 for first process, 1 for actually executing second one, plus 5
  ticks of IO on second one.) Woohoo!
  ```
  > ./process-run.py -l 4:100,1:0 -c -p
Time     PID: 0     PID: 1        CPU        IOs 
  1     RUN:cpu      READY          1            
  2     RUN:cpu      READY          1            
  3     RUN:cpu      READY          1            
  4     RUN:cpu      READY          1            
  5        DONE     RUN:io          1            
  6        DONE    WAITING                     1 
  7        DONE    WAITING                     1 
  8        DONE    WAITING                     1 
  9        DONE    WAITING                     1 
 10*       DONE       DONE                       

Stats: Total Time 10
Stats: CPU Busy 5 (50.00%)
Stats: IO Busy  4 (40.00%)
```

3. Switching the order here does matter, as the OS can schedule the other process to run while the
  first one waits on IO. I expect now it will take 5 cycles total. 
  And again, I'm right.
  ```
  > ./process-run.py -l 1:0,4:100 -c -p
Time     PID: 0     PID: 1        CPU        IOs 
  1      RUN:io      READY          1            
  2     WAITING    RUN:cpu          1          1 
  3     WAITING    RUN:cpu          1          1 
  4     WAITING    RUN:cpu          1          1 
  5     WAITING    RUN:cpu          1          1 
  6*       DONE       DONE                       

Stats: Total Time 6
Stats: CPU Busy 5 (83.33%)
Stats: IO Busy  4 (66.67%)
```

4. It will take a full 10 cycles again, as it waits entirely for the IO to end before finally
  switching over, due to the `SWITCH_ON_END`.
  And boom goes the dynamite! (I'm off by one on a lot of these because I keep counting
  it as 5 IO waits while really it's 4 waits plus one execution).
  ```
  Time     PID: 0     PID: 1        CPU        IOs 
  1      RUN:io      READY          1            
  2     WAITING      READY                     1 
  3     WAITING      READY                     1 
  4     WAITING      READY                     1 
  5     WAITING      READY                     1 
  6*       DONE    RUN:cpu          1            
  7        DONE    RUN:cpu          1            
  8        DONE    RUN:cpu          1            
  9        DONE    RUN:cpu          1            

Stats: Total Time 9
Stats: CPU Busy 5 (55.56%)
Stats: IO Busy  4 (44.44%)
  ```

5. This should be identical to 3. And indeed it is!
```
> ./process-run.py -l 1:0,4:100 -c -p -S SWITCH_ON_IO
Time     PID: 0     PID: 1        CPU        IOs 
  1      RUN:io      READY          1            
  2     WAITING    RUN:cpu          1          1 
  3     WAITING    RUN:cpu          1          1 
  4     WAITING    RUN:cpu          1          1 
  5     WAITING    RUN:cpu          1          1 
  6*       DONE       DONE                       

Stats: Total Time 6
Stats: CPU Busy 5 (83.33%)
Stats: IO Busy  4 (66.67%)
```

6. I suspect system resources will be poorly utilized, because it won't necessarily go back to the
  first process that will wait for another two rounds on IO. So it may first do PID 0 until its
  IO, then PID 1,2,3 entirely, then back to PID 0 and have to wait for two full cycles.
  Yup, and that's what it did:
  ```
  > ./process-run.py -l 3:0,5:100,5:100,5:100 -S SWITCH_ON_IO -I IO_RUN_LATER -c -p
Time     PID: 0     PID: 1     PID: 2     PID: 3        CPU        IOs 
  1      RUN:io      READY      READY      READY          1            
  2     WAITING    RUN:cpu      READY      READY          1          1 
  3     WAITING    RUN:cpu      READY      READY          1          1 
  4     WAITING    RUN:cpu      READY      READY          1          1 
  5     WAITING    RUN:cpu      READY      READY          1          1 
  6*      READY    RUN:cpu      READY      READY          1            
  7       READY       DONE    RUN:cpu      READY          1            
  8       READY       DONE    RUN:cpu      READY          1            
  9       READY       DONE    RUN:cpu      READY          1            
 10       READY       DONE    RUN:cpu      READY          1            
 11       READY       DONE    RUN:cpu      READY          1            
 12       READY       DONE       DONE    RUN:cpu          1            
 13       READY       DONE       DONE    RUN:cpu          1            
 14       READY       DONE       DONE    RUN:cpu          1            
 15       READY       DONE       DONE    RUN:cpu          1            
 16       READY       DONE       DONE    RUN:cpu          1            
 17      RUN:io       DONE       DONE       DONE          1            
 18     WAITING       DONE       DONE       DONE                     1 
 19     WAITING       DONE       DONE       DONE                     1 
 20     WAITING       DONE       DONE       DONE                     1 
 21     WAITING       DONE       DONE       DONE                     1 
 22*     RUN:io       DONE       DONE       DONE          1            
 23     WAITING       DONE       DONE       DONE                     1 
 24     WAITING       DONE       DONE       DONE                     1 
 25     WAITING       DONE       DONE       DONE                     1 
 26     WAITING       DONE       DONE       DONE                     1 
 27*       DONE       DONE       DONE       DONE                       

Stats: Total Time 27
Stats: CPU Busy 18 (66.67%)
Stats: IO Busy  12 (44.44%)
```

