# Verilog HDL Designs

This repository contains various Verilog and SystemVerilog designs, RISC-V processor cores, and testbenches:

1. **4Floor_Automatic_Elevator**
   - `elevator.v`: 4-floor automatic elevator controller FSM
   - `elevator_tb.v`: Testbench for elevator controller
2. **4bit_half_adder**
   - `half_adder4.v`: 4-bit half adder module
   - `half_adder4_tb.v`: Testbench for 4-bit half adder
3. **alu4bit**
   - `alu4.v`: 4-bit Arithmetic Logic Unit
   - `alu4_tb.v`: Testbench for 4-bit ALU
4. **ATM_Controller_Using_FSM**
   - `atm_controller.v`: ATM controller finite state machine
   - `atm_controller_tb.v`: Testbench for ATM controller
5. **basic_2stage_riscv_verilog**
   - `riscv_2stage.v`: Basic 2-stage pipelined RISC-V processor (Fetch, Execute/Writeback)
   - `tb_riscv_2stage.v`: Testbench for 2-stage RISC-V processor
   - `README.txt`: Documentation for 2-stage processor architecture
6. **D Flip-Flop**
   - `d_ff.v`: D flip-flop module
   - `d_ff_tb.v`: Testbench for D flip-flop
7. **FSM**
   - `washing.sv`: Washing machine finite state machine controller (SystemVerilog)
   - `washing_tb.sv`: Testbench for washing machine FSM
8. **Half_Adder_D flip-flop**
   - `half_adder.v`: Half adder design
   - `half_adder_tb.v`: Testbench for half adder
9. **RISCV_5Stage_Processor**
   - `riscv_5stage.v`: Classic 5-stage pipelined RISC-V RV32I processor (IF, ID, EX, MEM, WB) with hazard detection and data forwarding
   - `tb_riscv_5stage.v`: Testbench for 5-stage RISC-V processor
   - `README.txt`: Architectural documentation and pipeline hazard details
10. **RISCV_7Stage_processor**
    - `riscv_7stage.v`: 7-stage pipelined RISC-V processor (IF1, IF2, ID, EX, MEM1, MEM2, WB)
    - `tb_riscv_7stage.v`: Testbench for 7-stage RISC-V processor