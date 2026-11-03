
module riscv_7stage (
    input wire clk,
    input wire reset
);

    // Opcodes
    localparam OP_RTYPE = 7'b0110011;
    localparam OP_ITYPE = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;

    // Register file and memories
    reg [31:0] registers [0:31];
    reg [31:0] instr_mem [0:255];
    reg [31:0] data_mem [0:255];

    reg [31:0] pc;

    // Pipeline registers
    reg [31:0] if_id_pc, if_id_instr;

    reg [31:0] id_rr_pc, id_rr_instr;
    reg [31:0] id_rr_rs1_data, id_rr_rs2_data;
    reg [31:0] id_rr_imm;
    reg [4:0]  id_rr_rd, id_rr_rs1, id_rr_rs2;
    reg [6:0]  id_rr_opcode;
    reg [2:0]  id_rr_funct3;
    reg [6:0]  id_rr_funct7;

    reg [31:0] rr_ex1_pc, rr_ex1_rs1, rr_ex1_rs2;
    reg [31:0] rr_ex1_imm;
    reg [4:0]  rr_ex1_rd;
    reg [6:0]  rr_ex1_opcode;
    reg [2:0]  rr_ex1_funct3;
    reg [6:0]  rr_ex1_funct7;

    reg [31:0] ex1_ex2_pc;
    reg [31:0] ex1_ex2_alu_result;
    reg [31:0] ex1_ex2_rs2;
    reg [31:0] ex1_ex2_imm;
    reg [4:0]  ex1_ex2_rd;
    reg [6:0]  ex1_ex2_opcode;
    reg [2:0]  ex1_ex2_funct3;
    reg       ex1_ex2_zero;

    reg [31:0] ex2_mem_alu_result;
    reg [31:0] ex2_mem_store_data;
    reg [31:0] ex2_mem_pc;
    reg [4:0]  ex2_mem_rd;
    reg [6:0]  ex2_mem_opcode;
    reg [2:0]  ex2_mem_funct3;

    reg [31:0] mem_wb_result;
    reg [4:0]  mem_wb_rd;
    reg [6:0]  mem_wb_opcode;
    reg        mem_wb_reg_write;

    // Decode wires
    wire [6:0] id_opcode = if_id_instr[6:0];
    wire [4:0] id_rd     = if_id_instr[11:7];
    wire [2:0] id_funct3 = if_id_instr[14:12];
    wire [4:0] id_rs1    = if_id_instr[19:15];
    wire [4:0] id_rs2    = if_id_instr[24:20];
    wire [6:0] id_funct7 = if_id_instr[31:25];

    wire [31:0] id_imm_i =
        {{20{if_id_instr[31]}}, if_id_instr[31:20]};

    wire [31:0] id_imm_s =
        {{20{if_id_instr[31]}},
         if_id_instr[31:25], if_id_instr[11:7]};

    wire [31:0] id_imm_b =
        {{19{if_id_instr[31]}},
         if_id_instr[31], if_id_instr[7],
         if_id_instr[30:25], if_id_instr[11:8], 1'b0};

    // Instruction Decode immediate selection
    wire [31:0] decoded_imm =
        (id_opcode == OP_STORE)  ? id_imm_s :
        (id_opcode == OP_BRANCH) ? id_imm_b : id_imm_i;

    // Register Read stage
    wire [31:0] rr_rs1_data =
        (id_rr_rs1 == 0) ? 32'b0 : registers[id_rr_rs1];

    wire [31:0] rr_rs2_data =
        (id_rr_rs2 == 0) ? 32'b0 : registers[id_rr_rs2];

    // ALU stage 1
    reg [31:0] alu_result;
    reg [31:0] alu_operand_b;

    always @(*) begin
        alu_operand_b = rr_ex1_rs2;

        if (rr_ex1_opcode == OP_ITYPE ||
            rr_ex1_opcode == OP_LOAD ||
            rr_ex1_opcode == OP_STORE)
            alu_operand_b = rr_ex1_imm;

        case (rr_ex1_funct3)
            3'b000:
                if (rr_ex1_opcode == OP_RTYPE &&
                    rr_ex1_funct7 == 7'b0100000)
                    alu_result = rr_ex1_rs1 - rr_ex1_rs2;
                else
                    alu_result = rr_ex1_rs1 + alu_operand_b;

            3'b111: alu_result = rr_ex1_rs1 & alu_operand_b;
            3'b110: alu_result = rr_ex1_rs1 | alu_operand_b;
            default: alu_result = 32'b0;
        endcase
    end

    // Branch decision in EX2
    wire ex2_branch_taken =
        (ex1_ex2_opcode == OP_BRANCH) &&
        (ex1_ex2_zero);

    wire [31:0] ex2_branch_target =
        ex1_ex2_pc + ex1_ex2_imm;

    // Memory stage read data
    wire [31:0] mem_read_data =
        data_mem[ex2_mem_alu_result[9:2]];

    // Write-back selection
    wire [31:0] wb_value =
        (ex2_mem_opcode == OP_LOAD) ?
        mem_read_data : ex2_mem_alu_result;

    integer i;

    // Pipeline operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;

            if_id_pc <= 0;
            if_id_instr <= 0;

            id_rr_pc <= 0;
            id_rr_instr <= 0;
            id_rr_rs1_data <= 0;
            id_rr_rs2_data <= 0;
            id_rr_imm <= 0;
            id_rr_rd <= 0;
            id_rr_rs1 <= 0;
            id_rr_rs2 <= 0;
            id_rr_opcode <= 0;
            id_rr_funct3 <= 0;
            id_rr_funct7 <= 0;

            rr_ex1_pc <= 0;
            rr_ex1_rs1 <= 0;
            rr_ex1_rs2 <= 0;
            rr_ex1_imm <= 0;
            rr_ex1_rd <= 0;
            rr_ex1_opcode <= 0;
            rr_ex1_funct3 <= 0;
            rr_ex1_funct7 <= 0;

            ex1_ex2_pc <= 0;
            ex1_ex2_alu_result <= 0;
            ex1_ex2_rs2 <= 0;
            ex1_ex2_imm <= 0;
            ex1_ex2_rd <= 0;
            ex1_ex2_opcode <= 0;
            ex1_ex2_funct3 <= 0;
            ex1_ex2_zero <= 0;

            ex2_mem_alu_result <= 0;
            ex2_mem_store_data <= 0;
            ex2_mem_pc <= 0;
            ex2_mem_rd <= 0;
            ex2_mem_opcode <= 0;
            ex2_mem_funct3 <= 0;

            mem_wb_result <= 0;
            mem_wb_rd <= 0;
            mem_wb_opcode <= 0;
            mem_wb_reg_write <= 0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 0;

            for (i = 0; i < 256; i = i + 1) begin
                instr_mem[i] <= 32'b0;
                data_mem[i] <= 32'b0;
            end
        end
        else begin

            // WB: Write Back
            if (mem_wb_reg_write && mem_wb_rd != 0)
                registers[mem_wb_rd] <= mem_wb_result;

            registers[0] <= 0;

            // MEM: Memory Access
            if (ex2_mem_opcode == OP_STORE)
                data_mem[ex2_mem_alu_result[9:2]]
                    <= ex2_mem_store_data;

            mem_wb_rd <= ex2_mem_rd;
            mem_wb_opcode <= ex2_mem_opcode;
            mem_wb_reg_write <=
                (ex2_mem_opcode == OP_RTYPE ||
                 ex2_mem_opcode == OP_ITYPE ||
                 ex2_mem_opcode == OP_LOAD);

            mem_wb_result <= wb_value;

            // EX2: Result / Branch Processing
            ex2_mem_alu_result <= ex1_ex2_alu_result;
            ex2_mem_store_data <= ex1_ex2_rs2;
            ex2_mem_pc <= ex1_ex2_pc;
            ex2_mem_rd <= ex1_ex2_rd;
            ex2_mem_opcode <= ex1_ex2_opcode;
            ex2_mem_funct3 <= ex1_ex2_funct3;

            // EX1: ALU Execution
            ex1_ex2_pc <= rr_ex1_pc;
            ex1_ex2_alu_result <= alu_result;
            ex1_ex2_rs2 <= rr_ex1_rs2;
            ex1_ex2_imm <= rr_ex1_imm;
            ex1_ex2_rd <= rr_ex1_rd;
            ex1_ex2_opcode <= rr_ex1_opcode;
            ex1_ex2_funct3 <= rr_ex1_funct3;
            ex1_ex2_zero <= (rr_ex1_rs1 == rr_ex1_rs2);

            // RR: Register Read
            rr_ex1_pc <= id_rr_pc;
            rr_ex1_rs1 <= id_rr_rs1_data;
            rr_ex1_rs2 <= id_rr_rs2_data;
            rr_ex1_imm <= id_rr_imm;
            rr_ex1_rd <= id_rr_rd;
            rr_ex1_opcode <= id_rr_opcode;
            rr_ex1_funct3 <= id_rr_funct3;
            rr_ex1_funct7 <= id_rr_funct7;

            // ID: Instruction Decode
            id_rr_pc <= if_id_pc;
            id_rr_instr <= if_id_instr;
            id_rr_rs1 <= id_rs1;
            id_rr_rs2 <= id_rs2;
            id_rr_rd <= id_rd;
            id_rr_opcode <= id_opcode;
            id_rr_funct3 <= id_funct3;
            id_rr_funct7 <= id_funct7;
            id_rr_imm <= decoded_imm;
            id_rr_rs1_data <=
                (id_rs1 == 0) ? 0 : registers[id_rs1];
            id_rr_rs2_data <=
                (id_rs2 == 0) ? 0 : registers[id_rs2];

            // IF: Instruction Fetch
            if (ex2_branch_taken) begin
                pc <= ex2_branch_target;
                if_id_instr <= 0;
                if_id_pc <= 0;
            end
            else begin
                if_id_instr <= instr_mem[pc[9:2]];
                if_id_pc <= pc;
                pc <= pc + 4;
            end
        end
    end

endmodule
