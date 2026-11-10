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
11. **Carry AdderSubtractor**
    - `adder_sub.v`: Carry adder/subtractor design
    - `adder_sub_tb.v`: Testbench for adder/subtractor
    - `full_adder.v`: Full adder building block
12. **counter**
    - `counter.v`: Configurable counter design
    - `counter_tb.v`: Testbench for counter
13. **Edge Detector and Debouncer**
    - `edge_detect.v`: Edge detector module (rising/falling)
    - `debounce.v`: Button debouncer module
    - `edge_debounce_tb.v`: Combined edge detection and debouncing testbench
14. **Instruction_Extensions**
    - `riscv_cpu.v`: RISC-V CPU core with extended instructions
    - `cpu_tb.v`: Testbench for extended RISC-V CPU
    - `instruction_table.md`, `README.txt`, `program.hex`: Instruction set specification and sample program
15. **LFSR and Shift Register**
    - `lfsr.v`: Linear Feedback Shift Register (pseudo-random generator)
    - `shiftreg.v`: Universal shift register
    - `lfsr_shiftreg_tb.v`: Testbench for LFSR and shift register
16. **Priority Encoder and Decoder**
    - `encoder.v`: Priority encoder
    - `decoder.v`: Binary decoder
    - `encoder_decoder_tb.v`: Testbench for encoder and decoder
17. **Q2.1_Sequence_Detector**
    - `seq_mealy.v`: Mealy sequence detector
    - `seq_moore.v`: Moore sequence detector
    - `seq_detector_tb.v`: Testbench for sequence detectors
18. **Q2.2_Vending_Machine**
    - `vending.v`: Vending machine controller FSM
    - `vending_tb.v`: Testbench for vending machine FSM
    - `README.txt`: Documentation for vending machine states
19. **RAM_ROM_Watchdog**
    - `ram.v`, `ram_tb.v`: Single-port synchronous RAM and testbench
    - `rom.v`, `rom_tb.v`, `rom.hex`: ROM memory module and testbench
    - `watchdog.v`, `watchdog_tb.v`: Watchdog timer module and testbench
    - `README.txt`: Architectural overview
20. **regfile**
    - `regfile.v`: Multi-port register file design
    - `regfile_tb.v`: Testbench for register file
21. **RISCV_Assembly_Programs**
    - Assembly test programs in hex format: `program1_sum.hex`, `program2_fibonacci.hex`, `program3_max.hex`
    - `programs_assembly.md`, `README.txt`: Assembly program source code and execution trace documentation
22. **Round_Robin_Arbiter**
    - `arbiter.v`: Round-robin bus arbiter with priority rotation
    - `arbiter_tb.v`: Testbench for round-robin arbiter
    - `README.txt`: Arbiter design documentation
23. **shifter**
    - `shifter.v`: Barrel shifter module (logical/arithmetic shifts and rotates)
    - `shifter_tb.v`: Testbench for barrel shifter
24. **Synchronous_FIFO**
    - `fifo.v`: Parameterized synchronous FIFO buffer with full/empty flags
    - `fifo_tb.v`: Testbench for synchronous FIFO
    - `README.txt`: FIFO documentation
25. **Traffic_Light_Pedestrian**
    - `traffic.v`: Traffic light controller with pedestrian crossing FSM
    - `traffic_tb.v`: Testbench for traffic light system
    - `README.txt`: Traffic controller states documentation