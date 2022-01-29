## Solutions

0. 
VA  0: 0x00003229 (decimal:    12841) --> 
  0b11001000101001
  VPN 3
  0x6000 + 0x0229 -> 0x6229, or 25129
VA  1: 0x00001369 (decimal:     4969) --> 
  0b01001101101001
  VPN 1
  invalid - valid bit not set!
VA  2: 0x00001e80 (decimal:     7808) --> 
  0b01111010000000
  VPN 1
  invalid - valid bit not set!
VA  3: 0x00002556 (decimal:     9558) --> 
  0b10010101010110
  VPN 2
  invalid - valid bit not set!
VA  4: 0x00003a1e (decimal:    14878) --> 
  0b11101000011110 (0xa1e)
  VPN 3
  0x6000+0xA1E -> 0x6a1e, or 27166

Ah! Where I screwed up is the process table entry contains the physical frame number, _not_ the literal physical memory address. So the 6 in 0x8000006 refers to PFN 6. Because the page size is 4KB, we go to 4KB*6 as our first value, or 0x6000, and add our offset to that.
1. The per-process page table grows linearly as the address space increases - as we expect, there are simply more pages now in each address space. As page size increases, the page table size decreases for pretty obvious reasons - there are less pages per address space!

We shouldn't just use really big pages because there will be loads of internal fragmentation - large areas of physical memory will be walled off, despite not being used by any programs.

2. As you increase the number of pages in the address space that are allocated, the rate of segfaults decreases (until you reach 0).

 ./paging-linear-translate.py -P 1k -a 16k -p 32k -v -u 0
Virtual Address Trace
  VA 0x00003a39 (decimal:    14905) --> invalid address
  0b11101000111001
  VPN 14
  offset 569
  errm...none of the address spaces are used, so they'll all segfault :facepalm
  VA 0x00003ee5 (decimal:    16101) --> invalid address
  0b11111011100101
  VPN 15 
  VA 0x000033da (decimal:    13274) --> invalid address
  0b11001111011010
  VPN 12
  VA 0x000039bd (decimal:    14781) --> invalid address
  0b11100110111101
  VPN 14
  VA 0x000013d9 (decimal:     5081) --> invalid address
  0b01001111011001
  VPN 4

Address space is 16K, page size is 1K, so we need the top 4 bits for VPNs.

 ./paging-linear-translate.py -P 1k -a 16k -p 32k -v -u 25
  VA 0x00003986 (decimal:    14726) --> invalid address
  0b11100110000110
  VPN 14
  offset 390
  VA 0x00002bc6 (decimal:    11206) --> 20422
  0b10101111000110
  VPN 10
  offset 966
  0x13 (19) * page size(1k aka 1024) + 966 = 20422
  VA 0x00001e37 (decimal:     7735) --> invalid address
  0b01111000110111
  VPN 15
  offset 55
  VA 0x00000671 (decimal:     1649) --> Invalid address
  0b00011001110001
  VPN 1
  offset 625
  31*1024 + 625 = 31857
  VA 0x00001bc9 (decimal:     7113) --> invalid address
  0b01101111001001
  VPN 6
  offset 457
  28*1024 + 457 = 29129

I screwed that up because I didn't have the binary aligned and so thought the top bits were different than they were, and thus came up with the wrong top bits. :(

 ./paging-linear-translate.py -P 1k -a 16k -p 32k -v -u 50
Virtual Address Trace
  VA 0x00003385 (decimal:    13189) --> 16261
  0b11001110000101
  VPN 12
  901
  15*1024 + 901 -> 16261
  VA 0x0000231d (decimal:     8989) --> invalid address
  0b10001100011101
  VPN 8
  VA 0x000000e6 (decimal:      230) --> 24806
  0b00000011100110
  VPN 0
  230
  24 * 1024 + 230 -> 24806
  VA 0x00002e0f (decimal:    11791) --> invalid address
  0b10111000001111
  VPN 11
  VA 0x00001986 (decimal:     6534) --> 30086
  0b01100110000110
  VPN 6
  390
  29 * 1024 + 390 -> 30086 

OK I got it! I'm not doing it another two times here...

3. 
 ./paging-linear-translate.py -P 8 -a 32 -p 1024 -v -s 1
Page size is 8, address space size 32, so 4 total pages per address, requiring 2 top bits for the VPN.
VA 0x0000000e (decimal:       14) --> PA or invalid address?
VPN 1, offset 6 (can do decimal math here)
  VA 0x00000014 (decimal:       20) --> invalid address
  VPN 2, offset 4
  VA 0x00000019 (decimal:       25) --> invalid address
  VPN 3, offset 1
  VA 0x00000003 (decimal:        3) --> invalid address
  VPN 0, offset 3
  VA 0x00000000 (decimal:        0) --> invalid address
  VPN 0, offset 0

 ./paging-linear-translate.py -P 8k -a 32k -p 1m -v -s 2
Here we increased the address space, but increased the page size accordingly, so there are still only 4 pages per address space. 
Address space is 32k or 32*1024 or 32,768.
Page size is 8k or 8*1024 = 8192
Virtual Address Trace
  VA 0x000055b9 (decimal:    21945) --> invalid address
  VPN 2, offset 5561
  VA 0x00002771 (decimal:    10097) --> invalid address
  VPN 1, offset 1905
  VA 0x00004d8f (decimal:    19855) --> invalid address
  VPN 2, offset 3471
  VA 0x00004dab (decimal:    19883) --> invalid address
  VPN 2, offset 3499
  VA 0x00004a64 (decimal:    19044) --> invalid address
  VPN 2, offset 2660
...lol.

A page size of 1MB is quite unrealistic - it's _huge_! The others are probably unrelaistic just because physical memory consists of so few pages, but I guess it's possible. You may just have a highly internally fragmented system. 

 ./paging-linear-translate.py -P 1m -a 256m -p 512m -v -s 3
page size is 1m, or 1048576 bytes.
Virtual Address Trace
  VA 0x0308b24d (decimal: 50901581) --> 50901581
  VPN 48, offset 569933
  502 * 1048576 + 569933 = 526955085
  VA 0x042351e6 (decimal: 69423590) --> invalid address
  VPN 66, offset 217574 = 
  VA 0x02feb67b (decimal: 50247291) --> 178173563
  VPN 47, offset 964219
  169 * 1048576 + 964219 = 178173563
  VA 0x0b46977d (decimal: 189175677) --> invalid address
  VPN 180, offset 431997

  VA 0x0dbcceb4 (decimal: 230477492) --> 523030196
  VPN 219, offset 839348
  498 * 1048576 + 839348 = 523030196

4. You get an error if the address size is greater than physical memory (because we haven't learned about swapping yet!). You can also make it explode if you make the page size absolutely tiny with a reasonably large address space, because it'll just take forever to generate all those pages.
