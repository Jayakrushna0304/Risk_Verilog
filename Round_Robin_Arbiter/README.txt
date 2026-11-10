ROUND-ROBIN ARBITER - 4 REQUESTERS

Files:
- arbiter.v: synthesizable arbiter design
- arbiter_tb.v: testbench with automatic checks
- README.txt: this instruction file

Function:
- req[3:0] represents four requesters.
- grant[3:0] is one-hot; no more than one grant is active.
- Initial priority is requester 0.
- Grant is held while the granted request remains high.
- When that request goes low, grant clears and priority advances.
- Priority rotates fairly: 0 -> 1 -> 2 -> 3 -> 0.
- No active requests means grant = 0000.

ModelSim commands:
pwd
vlib work
vmap work work
vlog arbiter.v arbiter_tb.v
vsim work.arbiter_tb
add wave -r *
run -all
wave zoom full

Expected final testbench message:
ALL TEST CASES PASSED

Timing:
The grant clears on the rising edge after the granted request is released.
The next eligible requester is granted on the following rising edge.
