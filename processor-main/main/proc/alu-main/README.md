# ALU
## Name
Patrick Zheng

## Description of Design
The Arithmetic Logic Unit (ALU) that I designed supports the features of add, subtract, and, or, logical left shift, and arithmetic right shift. These operations performed on 32-bit data inputs and 5 bits are used to determine the amount to shift. The add and subtract operations are performed using a 2 level cascaded carry-lookahead adder. The and, and or operations are done bit by bit in parallel. Shifting is performed using barrel shifters and only operates on the first input. In addition, the ALU also determines if the 2 data inputs are equal, if the first is less than the second, and if overflow occurs during the addition and subtraction.

## Bugs
There are no known bugs in the design.