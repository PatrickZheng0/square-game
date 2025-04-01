# REGFILE
## Name
Patrick Zheng

## Description of Design
### Multiplication
The multiplier I designed places the inputs into D Flip Flops when the signal to multiply is given by the ctrl_MULT wire. This signal is also placed into a D Flip Flop and acts as an enable for the multiplier. It is cleared when the divide signal is given to prevent the multiplier from altering outputs. I then follow modified Booth's algorithm and use T Flip Flops as a counter to count through 16 cycles, each time cycling through a case in the algorithm. Each case is separately calculated and fed through tri-state buffers, and is then fed into another D Flip Flop to wait for the next clock cycle. Once the result is ready, a 1 is asserted through the multiplier's result_rdy line, otherwise, it is in high impedance state. The multiplier will also reset whenever a new multiplicaiton operation is provided, terminating the previous operation. This multiplier is notably a signed multiplier, and can handle multiplication of 32-bit integers. It will also indicate if overflow has occured as an exception, meaning the product requires more than 32 bits to be properly shown.

### Division
The divider I designed similarly places the inputs into D Flip Flops when the signal to divide is given by the ctrl_DIV wire. This signal is also placed into a D Flip Flop and acts as an enable for the divider. This enable is cleared by the multiply signal, also to prevent the divider from altering outputs. I then follow the non-restoring division algorithm and use T Flip Flops as a counter to count through 32 cycles. The result of each cycle is held in a D Flip Flop to wait for the next clock cycle. Once the division result is ready, a 1 is asserted through the divider's result_rdy line, otherwise, it is in high impedance state. The divider will reset whenever a new division operation is provided, terminating the previous operation. This divider is notably a unsigned divider, and only operates on positive integer inputs. The overarching multdiv module handles converting arbitrary inputs into positive ones, then handles correcting the sign of the output if necessary. An exception is asserted if a divide by zero operation was requested, and the output is set to be 0.

### Integration
The result_rdy lines of both the multiplier and divider are linked to the multdiv module's data_resultRDY line, and are activated by either module whenever they have a result that is ready to be read. Linking both lines here does not cause a problem because they are by default in the high impedance state, and can also only turn on when their respective enable bits are high. The enable bits operate on a one-hot encoding basis due to the nature that each enable bit will clear the other enable when it is high.

The multdiv module will also catch the exception if a multiply and divide operation are simultaneously requested. In this case, the result of 0 is returned, and the exception line is raised.

## Bugs
There are no known bugs in the design.