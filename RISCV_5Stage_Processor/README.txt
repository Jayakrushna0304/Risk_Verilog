5-STAGE RISC-V PIPELINED PROCESSOR (Verilog HDL)
================================================

Project objective
-----------------
Design, simulate, and verify a basic 32-bit RISC-V processor using a
five-stage pipeline in Verilog HDL. The project is an educational subset
of RV32I and is not a complete commercial RISC-V implementation.

Project files
-------------
1. riscv_5stage.v       - Five-stage processor design.
2. tb_riscv_5stage.v    - Testbench for functional verification.
3. README_5stage.txt    - Project description and run instructions.

Five-stage pipeline architecture
---------------------------------
Stage 1: Instruction Fetch (IF)
  - Uses the Program Counter (PC) to fetch an instruction.
  - Increments the PC by 4 during normal sequential execution.
  - Stores the instruction and its PC in the IF/ID pipeline register.

Stage 2: Instruction Decode (ID)
  - Decodes the instruction opcode and function fields.
  - Reads source operands from the register file.
  - Generates control signals and sign-extends I, S, and B immediates.
  - Stores decoded values and controls in the ID/EX pipeline register.

Stage 3: Execute (EX)
  - Performs ADD, SUB, AND, and OR operations in the ALU.
  - Calculates effective addresses for LW and SW.
  - Compares operands for BEQ and calculates the branch target.
  - Uses forwarding from EX/MEM and MEM/WB to reduce data dependencies.
  - Passes results and control signals through the EX/MEM register.

Stage 4: Memory Access (MEM)
  - Reads data memory for LW.
  - Writes data memory for SW.
  - Passes memory data and ALU results through the MEM/WB register.

Stage 5: Write Back (WB)
  - Selects either loaded memory data or the ALU result.
  - Writes the selected result to the destination register.
  - Register x0 is kept at zero.

Pipeline registers
------------------
- IF/ID: instruction and its PC from fetch to decode.
- ID/EX: decoded operands, immediate, register indices, and control signals.
- EX/MEM: ALU result, store data, destination register, and memory/write controls.
- MEM/WB: memory read data, ALU result, destination register, and write-back controls.

Hazard and branch handling
--------------------------
- Data forwarding: forwards available results from EX/MEM and MEM/WB to EX.
- Load-use hazard: detects a load instruction immediately followed by an
  instruction that needs its result; holds PC and IF/ID and inserts one bubble.
- Control hazard: BEQ is resolved in EX. A taken branch updates the PC to
  the branch target and flushes the younger instructions in IF/ID and ID/EX.
- This design does not implement branch prediction, interrupts, caches, or
  a full set of RV32I instructions.

Supported instructions
----------------------
- ADD  : Add two register values.
- SUB  : Subtract one register value from another.
- AND  : Bitwise AND.
- OR   : Bitwise OR.
- ADDI : Add a sign-extended immediate to a register value.
- LW   : Load a 32-bit word from data memory.
- SW   : Store a 32-bit word to data memory.
- BEQ  : Branch when two register values are equal.

Memory and register organization
--------------------------------
- Instructions are 32 bits and use standard RV32I encodings for the
  supported instruction subset.
- Instruction memory and data memory are separate arrays, each with 64 words.
- The register file contains 32 registers of 32 bits each.
- Register x0 is hardwired to zero.
- Word memory addresses use address bits [7:2] for this small demonstration.

Test program and expected results
---------------------------------
The testbench initializes and executes a short program that checks:
- ADDI: initializes x1=5 and x2=7.
- ADD: computes x3=12.
- SUB: computes x4=7.
- SW and LW: stores 12 in MEM[0] and loads it into x5.
- AND and OR: x9 = x1 AND x2 = 5; x10 = x1 OR x2 = 7.
- A dependent operation after LW checks load-use stalling and forwarding:
  x8 = x5 + x5 = 24.
- BEQ: taken branch skips the instruction that would write x6=99.
- ADDI: writes x7=11 after the branch target.

Expected final values:
  x1 = 5
  x2 = 7
  x3 = 12
  x4 = 7
  x5 = 12
  x6 = 0   (instruction skipped by taken branch)
  x7 = 11
  x8 = 24
  x9 = 5
  x10 = 7
  MEM[0] = 12

The testbench prints TEST PASSED if all expected values match.

Simulation using ModelSim / QuestaSim
-------------------------------------
Run these commands in the Transcript window from the project directory:
  vlib work
  vmap work work
  vlog riscv_5stage.v tb_riscv_5stage.v
  vsim work.tb_riscv_5stage
  add wave -r /*
  run -all
  wave zoom full

Simulation using Icarus Verilog
-------------------------------
  iverilog -g2012 -o riscv5_sim riscv_5stage.v tb_riscv_5stage.v
  vvp riscv5_sim

Optional waveform using Icarus Verilog and GTKWave
---------------------------------------------------
Add these statements to the testbench initial block before simulation ends:
  $dumpfile("riscv_5stage.vcd");
  $dumpvars(0, tb_riscv_5stage);
Then open riscv_5stage.vcd in GTKWave.

Notes for students
------------------
- The project is intended for learning pipelining, pipeline registers,
  forwarding, load-use stalls, and branch flushing.
- Review the waveform and inspect pc, if_id_instruction, id_ex_opcode,
  ex_mem_alu_result, mem_wb_alu_result, and the register file.
- This design is a teaching implementation. It should be reviewed and tested
  further before use in any larger processor project.
