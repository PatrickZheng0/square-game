# REGFILE
## Name
Patrick Zheng

## Description of Design
The Register File that I designed supports 32 individual 32 bit registers that are triggered by the positive edge of the clock and also includes an asynchronous clear signal. The Register File allows for writing to a single register at a time and reading from 2 registers at the same time. Register 0 will also always hold and output the value of 0. I used a decoder in combination with the write enable signal to determine which register to write to, the data is written on the positive edge of the clock. Similarly, on the positive edge, data is read from the registers and fed into 2 sets of tri-state buffers. Each buffer is enabled by a decoder decoding either the ctrl_readRegA or the ctrl_readRegB signals. The outputs are then put together to return what was in the specified register.

## Bugs
There are no known bugs in the design.