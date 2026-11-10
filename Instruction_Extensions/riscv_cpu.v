// Day 3 Q3.1: Educational single-cycle RV32I subset CPU.
// New instructions: ANDI, ORI, XORI, SLTI, SLLI, SRLI, LUI and JAL.
// Supporting instructions used by the demo program: ADDI and BEQ.
module riscv_cpu (
    input wire clk,
    input wire reset
);
    reg [31:0] pc;
    reg [31:0] regs [0:31];
    reg [31:0] instr_mem [0:255];

    wire [31:0] instr;
    wire [6:0] opcode;
    wire [4:0] rd, rs1;
    wire [2:0] funct3;
    wire [4:0] shamt;
    wire [6:0] funct7;

    reg [31:0] imm;
    reg [31:0] alu_result;
    reg [31:0] next_pc;
    reg reg_write;
    integer i;

    assign instr  = instr_mem[pc[9:2]];
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign shamt  = instr[24:20];
    assign funct7 = instr[31:25];

    // Decode and execute.
    always @(*) begin
        imm        = 32'b0;
        alu_result = 32'b0;
        next_pc    = pc + 32'd4;
        reg_write  = 1'b0;

        case (opcode)
            7'b0010011: begin // I-type immediate operations
                imm = {{20{instr[31]}}, instr[31:20]};
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_result = regs[rs1] + imm; // ADDI
                    3'b111: alu_result = regs[rs1] & imm; // ANDI
                    3'b110: alu_result = regs[rs1] | imm; // ORI
                    3'b100: alu_result = regs[rs1] ^ imm; // XORI
                    3'b010: alu_result =
                        ($signed(regs[rs1]) < $signed(imm)) ? 32'd1 : 32'd0; // SLTI
                    3'b001: begin // SLLI
                        alu_result = regs[rs1] << shamt;
                    end
                    3'b101: begin // SRLI (logical right shift)
                        alu_result = regs[rs1] >> shamt;
                    end
                    default: begin
                        alu_result = 32'b0;
                        reg_write = 1'b0;
                    end
                endcase
            end

            7'b0110111: begin // LUI
                imm = {instr[31:12], 12'b0};
                alu_result = imm;
                reg_write = 1'b1;
            end

            7'b1101111: begin // JAL
                imm = {{11{instr[31]}}, instr[31], instr[19:12],
                       instr[20], instr[30:21], 1'b0};
                alu_result = pc + 32'd4; // return address
                reg_write = 1'b1;
                next_pc = pc + imm;
            end

            7'b1100011: begin // BEQ (support instruction for test program)
                imm = {{19{instr[31]}}, instr[31], instr[7],
                       instr[30:25], instr[11:8], 1'b0};
                if (funct3 == 3'b000 && regs[instr[24:20]] == regs[rs1])
                    next_pc = pc + imm;
            end

            default: begin
                // Unsupported instruction: no register write.
            end
        endcase
    end

    // Sequential state update.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            if (reg_write && (rd != 5'd0))
                regs[rd] <= alu_result;
            regs[0] <= 32'b0;
            pc <= next_pc;
        end
    end

    // Load the machine-code program from program.hex.
    initial begin
        for (i = 0; i < 256; i = i + 1)
            instr_mem[i] = 32'h00000013; // NOP = ADDI x0,x0,0
        $readmemh("program.hex", instr_mem);
    end
endmodule
