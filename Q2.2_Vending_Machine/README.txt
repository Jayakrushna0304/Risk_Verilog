Q2.2 - VENDING MACHINE CONTROLLER

Files:
1. vending.v    - Main synthesizable vending machine design.
2. vending_tb.v - Testbench.

Specification:
- Accepts Rs.5 and Rs.10 coin pulses.
- Item price is Rs.15.
- Dispenses the item when the inserted amount reaches or exceeds Rs.15.
- Returns change when overpaid.
- Cancel returns the inserted credit.
- coin5 and coin10 should not be asserted together.

ModelSim commands:
pwd
vlib work
vmap work work
vlog vending.v vending_tb.v
vsim work.vending_tb
add wave -r *
run -all
wave zoom full

The testbench checks Rs.5+Rs.10, Rs.10+Rs.5, Rs.10+Rs.10,
cancellation after Rs.10 and Rs.5+Rs.5, and the idle condition.
