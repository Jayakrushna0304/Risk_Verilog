DAY 3 - Q3.1: INSTRUCTION EXTENSIONS

Files:
- riscv_cpu.v          Main single-cycle CPU example
- cpu_tb.v             Self-checking testbench
- program.hex          Machine-code program loaded by $readmemh
- instruction_table.md Instruction and encoding/control summary

Q3.1 instructions implemented:
1. ANDI
2. ORI
3. XORI
4. SLTI (signed comparison)
5. SLLI (logical left shift)
6. SRLI (logical right shift)
7. LUI
8. JAL (PC-relative jump and PC+4 link address)

ADDI is also included because the demonstration program uses it to
initialize registers. BEQ is included only as a supporting base instruction
if needed; the demo program ends in a JAL-to-self loop.

ModelSim commands (run from this folder):
pwd
vlib work
vmap work work
vlog riscv_cpu.v cpu_tb.v
vsim work.cpu_tb
add wave -r *
run -all
wave zoom full

IMPORTANT:
This is a self-contained educational example because your existing CPU
source files were not provided. It demonstrates the Q3.1 instructions but
is not guaranteed to match the module interfaces of your own CPU project.
The code has not been run in your ModelSim installation. Run the testbench
and check the PASS messages before submission.
