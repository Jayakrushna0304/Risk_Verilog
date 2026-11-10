# Q3.1 Instruction Table

| Instruction | Opcode | funct3 | funct7 / immediate | Function |
|---|---|---|---|---|
| ADDI | 0010011 | 000 | signed 12-bit immediate | `rd = rs1 + imm` |
| ANDI | 0010011 | 111 | signed 12-bit immediate | `rd = rs1 & imm` |
| ORI | 0010011 | 110 | signed 12-bit immediate | `rd = rs1 | imm` |
| XORI | 0010011 | 100 | signed 12-bit immediate | `rd = rs1 ^ imm` |
| SLTI | 0010011 | 010 | signed 12-bit immediate | signed `rs1 < imm` |
| SLLI | 0010011 | 001 | shamt = instr[24:20] | logical left shift |
| SRLI | 0010011 | 101 | shamt = instr[24:20], funct7=0000000 | logical right shift |
| LUI | 0110111 | — | upper 20-bit immediate | `rd = imm << 12` |
| JAL | 1101111 | — | J-type immediate | `rd = PC+4`, `PC = PC+imm` |

## Test program register expectations

| Instruction | Destination | Expected result |
|---|---:|---:|
| ADDI x1,x0,15 | x1 | 15 |
| ANDI x2,x1,7 | x2 | 7 |
| ORI x3,x1,8 | x3 | 15 |
| XORI x4,x1,3 | x4 | 12 |
| SLTI x5,x1,20 | x5 | 1 |
| SLLI x6,x1,2 | x6 | 60 |
| SRLI x7,x1,1 | x7 | 7 |
| LUI x8,0x12345 | x8 | 0x12345000 |
| JAL x9,+8 | x9 | return address 36 |
| ADDI x10,x0,42 at jump target | x10 | 42 |

The JAL at address 32 jumps to address 40, skips the instruction at
address 36, and stores address 36 (PC+4) in x9.
