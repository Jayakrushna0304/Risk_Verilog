DAY 3 - ASSEMBLY PROGRAMS

This folder contains the three Q3.2 program hex files and their commented
assembly source/expected results.

Files:
- program1_sum.hex
- program2_fibonacci.hex
- program3_max.hex
- programs_assembly.md

Important:
These are program images, not a complete CPU project. Load one program into
your existing instruction memory using $readmemh. Your CPU must support ADD,
ADDI, BNE, LW, SW, BLT and JAL for these programs. The standalone Q3.1
example supplied earlier does not yet implement all of these instructions.

Expected outputs:
- Sum 1..10: x3 = 55
- Fibonacci: data words = 0,1,1,2,3,5,8,13,21,34
- Array maximum: x3 = 89 (initialize array with 12,45,7,89,23,56,3,34)

See programs_assembly.md for the commented assembly.
