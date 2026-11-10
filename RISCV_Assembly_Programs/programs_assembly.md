# Day 3 – Assembly Programs

These three programs are RV32I machine-code examples for Q3.2. The `.hex`
files contain one 32-bit instruction per line and are loaded into instruction
memory with `$readmemh`. The code assumes a word-addressed data-memory interface
implemented using byte addresses (each word is 4 bytes).

## Program 1 – Sum of 1 to N (N = 10)

Expected result: x3 = 55.

```asm
addi x2, x0, 10       # N = 10
addi x3, x0, 0        # sum = 0
loop:
add  x3, x3, x2       # sum += N
addi x2, x2, -1       # N--
bne  x2, x0, loop
done:
jal  x0, 0
```

## Program 2 – First 10 Fibonacci numbers

Expected data-memory words at addresses 0,4,...,36:
`0, 1, 1, 2, 3, 5, 8, 13, 21, 34`.

```asm
addi x1, x0, 0        # data pointer
addi x2, x0, 0        # a = 0
addi x3, x0, 1        # b = 1
addi x4, x0, 10       # count = 10
sw   x2, 0(x1)        # store first value
addi x1, x1, 4
addi x6, x0, 1        # loop stop value
loop:
sw   x3, 0(x1)        # store next Fibonacci value
add  x5, x2, x3       # temp = a+b
addi x2, x3, 0        # a=b
addi x3, x5, 0        # b=temp
addi x1, x1, 4        # next word
addi x4, x4, -1       # count--
bne  x4, x6, loop
done:
jal  x0, 0
```

## Program 3 – Maximum of an array of 8 words

The testbench or data-memory initialization must place these values at
word addresses 0 through 7: `12, 45, 7, 89, 23, 56, 3, 34`.
Expected maximum: x3 = 89.

```asm
addi x1, x0, 0        # pointer = base
lw   x3, 0(x1)        # max = first element
addi x1, x1, 4
addi x2, x0, 7        # remaining elements
loop:
lw   x4, 0(x1)        # current element
blt  x3, x4, update  # if max < current, update max
jal  x0, skip_update
update:
addi x3, x4, 0        # max = current
skip_update:
addi x1, x1, 4
addi x2, x2, -1
bne  x2, x0, loop
done:
jal  x0, 0
```

## Register and memory expectations

| Program | Expected output |
|---|---|
| Sum | x3 = 55 |
| Fibonacci | data memory = 0,1,1,2,3,5,8,13,21,34 |
| Maximum | x3 = 89 |

## Required CPU support

These programs use ADDI, ADD, BNE, BEQ (not required by these exact streams),
LW, SW, BLT and JAL. Ensure your CPU supports these base instructions and the
correct branch immediate logic. The Q3.1 standalone example previously supplied
does not yet implement all of LW, SW, ADD and BLT/BNE, so these programs must be
run on your full single-cycle CPU after adding the needed base instruction logic.

## ModelSim

Use the CPU module and testbench from your existing project. Load one program
at a time by setting the appropriate filename in `$readmemh`, then compile and
simulate. Capture final register/data-memory values and waveforms.
