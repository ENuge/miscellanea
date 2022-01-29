## Solutions

1. ./compute.py
   Additive: 216+194+107+66 mod 256 = 71
   Xor: 0b00110011
   Fletcher:
   s1 = 216+194+107+66 mod 255 = 73 or 0b01001001
   s2 = 216 + (216+194) + (216+194+107) + (216+194+107+66) mod 255 = 196

Tricky hobbitses changing the mod number between additive and Fletcher...

2. I'm skipping that because it's like the same shit and very repetitive.

3. One example is having four bytes where only a single bit position is 1 in each of them. Each bit position will add to 1 as well as XOR to 1. This also works with three 1s in each position due to carry. Basically, it'll happen whenever all bit positions obey addition equal x'oring, via any combination of those two or the all 0s case.

4. The checksum values for additive is basically the opposite of 3 - anywhere you have a single bit position of all 1s or two 1s will cause the XOR to be different from the addition. Note that it's _any_ here, whereas the previous answer required _all_ of the bit position to be like this.

5. Err, the additive checksum will be the same for different bytes when those four bytes add up to the same value. In addition to that, whenever they add up to the same value mod 256.

6. The XOR will be the same whenever the bit positions mentioned above are the same.

7. Fletcher is generally "better" than the additive checksum because positionality now matters. Before, you could jumble up the bytestream in any order and you'd get the same additive checksum. Now, with Fletcher, those will return different values. This is probably a significantly more likely form of error than protecting against a random combination of bitflips elsewhere, so this seems like a generally nice improvement.

8. With Fletcher, the twos complement of any single byte will return the same Fletcher checksum as the original byte, because the modulo arithmetic will net you the same value. So if you might end up with a full bytes getting bitflipped, Fletcher might not be the choice for you.
