Traffic Light Controller with Pedestrian Request

Files:
- traffic.v      : Parameterized traffic light controller
- traffic_tb.v   : Testbench with short timing values for simulation

Features:
- Parameterized GREEN_TIME, YELLOW_TIME, RED_TIME and WALK_TIME.
- A pedestrian request is remembered and served after the current green
  period and yellow period.
- During WALK, car RED is active.
- A request received during WALK is ignored by the controller.
- After WALK, the controller stays RED for RED_TIME and then returns to GREEN.

ModelSim Intel FPGA Edition commands:
pwd
vlib work
vmap work work
vlog traffic.v traffic_tb.v
vsim work.traffic_tb
add wave -r *
run -all
wave zoom full

Expected sequence when a pedestrian request is received:
GREEN -> YELLOW -> RED_WALK -> RED -> GREEN

Note:
This is an educational RTL model. The testbench uses shorter timing values
than the default module parameters to keep simulation quick.
