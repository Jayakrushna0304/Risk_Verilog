SYNCHRONOUS FIFO

Files:
- fifo.v: 16-entry, 8-bit synchronous FIFO design.
- fifo_tb.v: Self-checking testbench.

Features:
- 8-bit data width and 16-entry depth.
- Synchronous reset.
- Write enable and read enable.
- Full and empty status flags.
- Simultaneous read and write supported when the FIFO is neither full nor empty.
- Write while full and read while empty are ignored.

ModelSim commands:
pwd
vlib work
vmap work work
vlog fifo.v fifo_tb.v
vsim work.fifo_tb
add wave -r *
run -all
wave zoom full

The testbench fills the FIFO, checks full, attempts an overflow write,
drains and checks FIFO order, checks empty, attempts an underflow read,
and tests simultaneous read/write.
