## Solutions

(This actually seems like a very useful exercise!)

1. With a two-level page table, you should still only need the one page directory base register to tell you where to jump to to start looking for your physical address. With a three-level page table, you may need a second to tell you where the second-layer page directory is (they can't all be contiguous, because that would imply a huge amount of internal fragmentation / unused pages for second-level pages. So you can't just offset-jump to it.). But that location would be different for each page directory, so I'm not sure that makes sense.

2.

 ./paging-multilevel-translate.py -s 0
page size: 32B
virtual address space: 1024 pages (32KB)
physical memory: 128 pages (4096)

physical address -> 12 bits
offset -> 5 bits
PFN -> 7 bits

PTE -> 1B
32 PTEs per page in the first level page table
page directory has 32 pages of page tables
(32\*32 here gives the 1024 pages in the virtual address space!)

virtual address space -> 15 bits
offset -> 5 bits
VPN -> 10 bits (top 5 for PDE, next 5 for PTE)

PDBR 108 -> page directory starts on page 108

Virtual Address 611c: Translates To What Physical Address (And Fetches what Value)? Or Fault?
611c -> 110 0001 0001 1100
11000 PDE, 01000 PTE, 11100 offset
-> 24 PDE, 8 PTE, 28 offset
jumping 24 bytes into page 108 gets us to a1 -> 1010 0001, top bit is 1 thus valid, page 0100001->33
33 is thus the page holding the process table we care about. we go to that with our 8 PTE
and get b5->10110101, which is a PFN of 0110101, or 53.
page 53, offset 28 gives us: 08 as the value fetched. It's at physical address 1724dec 0b11010111100
Virtual Address 3da8: Translates To What Physical Address (And Fetches what Value)? Or Fault?
3da8 -> 0011 1101 1010 1000
01111 PDE 01101 PTE 01000 offset
d6 in PDE -> 1(valid) 1010110->86 (page), offset into that page is 01101 or 13->7f:01111111, or invalid. FAULT!
Virtual Address 17f5: Translates To What Physical Address (And Fetches what Value)? Or Fault?
0001 0111 1111 0101
00101 PDE (5) 11111 PTE (31) 10101 offset (21)
d4 -> 1(valid) 1010100->84(page)
84 with 31 offset gives ce. ce->1(valid)1001110->78(PFN)
page 78, offset 21, gives 1c -> 0001 1100, at physical address 78\*32 + 21->2517 (0x9D5) BOOM!
Virtual Address 7f6c: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 0bad: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 6d60: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 2a5b: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 4c5e: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 2592: Translates To What Physical Address (And Fetches what Value)? Or Fault?
Virtual Address 3e99: Translates To What Physical Address (And Fetches what Value)? Or Fault?

K, I'm not doing more because this will drive me to insanity. I get the picture.

2 memory references are needed to perform each lookup.

3. The TLB caches VPN to PFN lookups. The VPN functions effectively the same with a multilevel page table, it's just now split into two sections that map first to the offset within the PDE and then the offset within the page table itself for this address. From the TLB's perspective, this could be backed in memory by a multi-level page tree or a single level and the VPN would be the same.
