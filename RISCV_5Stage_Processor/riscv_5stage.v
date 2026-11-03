`timescale 1ns/1ps

// Educational 32-bit RV32I subset, five-stage pipelined processor.
// Stages: IF -> ID -> EX -> MEM -> WB
// Supported: ADD, SUB, AND, OR, ADDI, LW, SW, BEQ
// Includes load-use stall, EX forwarding, and branch flushing.

module riscv_5stage (
    input wire clk,
    input wire reset
);

    // -------------------- Memories and register file --------------------
    reg [31:0] pc;
    reg [31:0] instruction_mem [0:63];
    reg [31:0] data_mem        [0:63];
    reg [31:0] registers       [0:31];

    // -------------------- IF/ID pipeline register ----------------------
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instruction;

    // -------------------- ID/EX pipeline register ----------------------
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1_value;
    reg [31:0] id_ex_rs2_value;
    reg [31:0] id_ex_immediate;
    reg [4:0]  id_ex_rs1;
    reg [4:0]  id_ex_rs2;
    reg [4:0]  id_ex_rd;
    reg [2:0]  id_ex_funct3;
    reg [6:0]  id_ex_funct7;
    reg [6:0]  id_ex_opcode;
    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_mem_to_reg;
    reg        id_ex_alu_src;
    reg        id_ex_branch;

    // -------------------- EX/MEM pipeline register ---------------------
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg        ex_mem_mem_to_reg;

    // -------------------- MEM/WB pipeline register ---------------------
    reg [31:0] mem_wb_memory_data;
    reg [31:0] mem_wb_alu_result;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    reg        mem_wb_mem_to_reg;

    // -------------------- Instruction decode wires --------------------
    wire [6:0] if_opcode = if_id_instruction[6:0];
    wire [4:0] if_rd     = if_id_instruction[11:7];
    wire [2:0] if_funct3 = if_id_instruction[14:12];
    wire [4:0] if_rs1    = if_id_instruction[19:15];
    wire [4:0] if_rs2    = if_id_instruction[24:20];
    wire [6:0] if_funct7 = if_id_instruction[31:25];

    // Write-back-to-decode bypass handles a register being written in WB
    // during the same clock edge that a dependent instruction is decoded.
    wire [31:0] wb_data = mem_wb_mem_to_reg ? mem_wb_memory_data : mem_wb_alu_result;

    wire [31:0] reg_read_data1 = (if_rs1 == 0) ? 32'd0 :
                                  ((mem_wb_reg_write && (mem_wb_rd != 0) &&
                                    (mem_wb_rd == if_rs1)) ? wb_data : registers[if_rs1]);
    wire [31:0] reg_read_data2 = (if_rs2 == 0) ? 32'd0 :
                                  ((mem_wb_reg_write && (mem_wb_rd != 0) &&
                                    (mem_wb_rd == if_rs2)) ? wb_data : registers[if_rs2]);

    wire [31:0] imm_i = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]};
    wire [31:0] imm_s = {{20{if_id_instruction[31]}}, if_id_instruction[31:25], if_id_instruction[11:7]};
    wire [31:0] imm_b = {{19{if_id_instruction[31]}}, if_id_instruction[31],
                         if_id_instruction[7], if_id_instruction[30:25],
                         if_id_instruction[11:8], 1'b0};

    // -------------------- Main decode control --------------------------
    reg dec_reg_write;
    reg dec_mem_read;
    reg dec_mem_write;
    reg dec_mem_to_reg;
    reg dec_alu_src;
    reg dec_branch;
    reg [31:0] dec_immediate;

    always @(*) begin
        dec_reg_write  = 1'b0;
        dec_mem_read   = 1'b0;
        dec_mem_write  = 1'b0;
        dec_mem_to_reg = 1'b0;
        dec_alu_src    = 1'b0;
        dec_branch     = 1'b0;
        dec_immediate  = 32'd0;

        case (if_opcode)
            7'b0110011: begin // R-type: ADD, SUB, AND, OR
                dec_reg_write = 1'b1;
            end
            7'b0010011: begin // ADDI
                if (if_funct3 == 3'b000) begin
                    dec_reg_write = 1'b1;
                    dec_alu_src = 1'b1;
                    dec_immediate = imm_i;
                end
            end
            7'b0000011: begin // LW
                if (if_funct3 == 3'b010) begin
                    dec_reg_write = 1'b1;
                    dec_mem_read = 1'b1;
                    dec_mem_to_reg = 1'b1;
                    dec_alu_src = 1'b1;
                    dec_immediate = imm_i;
                end
            end
            7'b0100011: begin // SW
                if (if_funct3 == 3'b010) begin
                    dec_mem_write = 1'b1;
                    dec_alu_src = 1'b1;
                    dec_immediate = imm_s;
                end
            end
            7'b1100011: begin // BEQ
                if (if_funct3 == 3'b000) begin
                    dec_branch = 1'b1;
                    dec_immediate = imm_b;
                end
            end
            default: begin
                // NOP or unsupported instruction: all controls remain zero.
            end
        endcase
    end

    // -------------------- Hazard detection -----------------------------
    // A load-use dependency needs one bubble because load data is not
    // available until the MEM/WB stage.
    wire id_uses_rs1 = (if_opcode == 7'b0110011) ||
                       (if_opcode == 7'b0010011) ||
                       (if_opcode == 7'b0000011) ||
                       (if_opcode == 7'b0100011) ||
                       (if_opcode == 7'b1100011);
    wire id_uses_rs2 = (if_opcode == 7'b0110011) ||
                       (if_opcode == 7'b0100011) ||
                       (if_opcode == 7'b1100011);
    wire load_use_stall = id_ex_mem_read && (id_ex_rd != 0) &&
                          ((id_uses_rs1 && (id_ex_rd == if_rs1)) ||
                           (id_uses_rs2 && (id_ex_rd == if_rs2)));

    // -------------------- Write-back data ------------------------------
    // -------------------- EX forwarding and ALU ------------------------
    reg [31:0] forwarded_a;
    reg [31:0] forwarded_b;
    reg [31:0] alu_operand_b;
    reg [31:0] ex_alu_result;
    reg [31:0] ex_store_data;
    reg        ex_branch_taken;
    reg [31:0] ex_branch_target;

    always @(*) begin
        forwarded_a = id_ex_rs1_value;
        forwarded_b = id_ex_rs2_value;

        // Forward the newest available result from EX/MEM.
        if (ex_mem_reg_write && (ex_mem_rd != 0) && !ex_mem_mem_to_reg &&
            (ex_mem_rd == id_ex_rs1))
            forwarded_a = ex_mem_alu_result;
        else if (mem_wb_reg_write && (mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs1))
            forwarded_a = wb_data;

        if (ex_mem_reg_write && (ex_mem_rd != 0) && !ex_mem_mem_to_reg &&
            (ex_mem_rd == id_ex_rs2))
            forwarded_b = ex_mem_alu_result;
        else if (mem_wb_reg_write && (mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs2))
            forwarded_b = wb_data;

        alu_operand_b = id_ex_alu_src ? id_ex_immediate : forwarded_b;
        ex_alu_result = 32'd0;

        case (id_ex_opcode)
            7'b0110011: begin // R-type
                case (id_ex_funct3)
                    3'b000: begin
                        if (id_ex_funct7 == 7'b0100000)
                            ex_alu_result = forwarded_a - forwarded_b;
                        else
                            ex_alu_result = forwarded_a + forwarded_b;
                    end
                    3'b111: ex_alu_result = forwarded_a & forwarded_b;
                    3'b110: ex_alu_result = forwarded_a | forwarded_b;
                    default: ex_alu_result = 32'd0;
                endcase
            end
            7'b0010011: ex_alu_result = forwarded_a + id_ex_immediate; // ADDI
            7'b0000011: ex_alu_result = forwarded_a + id_ex_immediate; // LW address
            7'b0100011: ex_alu_result = forwarded_a + id_ex_immediate; // SW address
            default: ex_alu_result = 32'd0;
        endcase

        ex_store_data = forwarded_b;
        ex_branch_taken = id_ex_branch && (forwarded_a == forwarded_b);
        ex_branch_target = id_ex_pc + id_ex_immediate;
    end

    // -------------------- Sequential pipeline operation ---------------
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'd0;

            if_id_pc <= 32'd0;
            if_id_instruction <= 32'h00000013; // NOP

            id_ex_pc <= 32'd0;
            id_ex_rs1_value <= 32'd0;
            id_ex_rs2_value <= 32'd0;
            id_ex_immediate <= 32'd0;
            id_ex_rs1 <= 5'd0;
            id_ex_rs2 <= 5'd0;
            id_ex_rd <= 5'd0;
            id_ex_funct3 <= 3'd0;
            id_ex_funct7 <= 7'd0;
            id_ex_opcode <= 7'd0;
            id_ex_reg_write <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_branch <= 1'b0;

            ex_mem_alu_result <= 32'd0;
            ex_mem_store_data <= 32'd0;
            ex_mem_rd <= 5'd0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;

            mem_wb_memory_data <= 32'd0;
            mem_wb_alu_result <= 32'd0;
            mem_wb_rd <= 5'd0;
            mem_wb_reg_write <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
        end else begin
            // WB stage: write the result from MEM/WB into the register file.
            if (mem_wb_reg_write && (mem_wb_rd != 0))
                registers[mem_wb_rd] <= wb_data;
            registers[0] <= 32'd0;

            // MEM stage: access data memory and pass values to MEM/WB.
            if (ex_mem_mem_write)
                data_mem[ex_mem_alu_result[7:2]] <= ex_mem_store_data;

            mem_wb_memory_data <= ex_mem_mem_read ? data_mem[ex_mem_alu_result[7:2]] : 32'd0;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;

            // EX stage: pass ALU result and control signals to EX/MEM.
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_store_data <= ex_store_data;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;

            // A taken branch has priority: discard younger instructions.
            if (ex_branch_taken) begin
                pc <= ex_branch_target;
                if_id_pc <= 32'd0;
                if_id_instruction <= 32'h00000013; // flush IF/ID

                id_ex_pc <= 32'd0;
                id_ex_rs1_value <= 32'd0;
                id_ex_rs2_value <= 32'd0;
                id_ex_immediate <= 32'd0;
                id_ex_rs1 <= 5'd0;
                id_ex_rs2 <= 5'd0;
                id_ex_rd <= 5'd0;
                id_ex_funct3 <= 3'd0;
                id_ex_funct7 <= 7'd0;
                id_ex_opcode <= 7'd0;
                id_ex_reg_write <= 1'b0;
                id_ex_mem_read <= 1'b0;
                id_ex_mem_write <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;
                id_ex_alu_src <= 1'b0;
                id_ex_branch <= 1'b0;
            end else if (load_use_stall) begin
                // Hold PC and IF/ID; insert a bubble into ID/EX.
                pc <= pc;
                if_id_pc <= if_id_pc;
                if_id_instruction <= if_id_instruction;

                id_ex_pc <= 32'd0;
                id_ex_rs1_value <= 32'd0;
                id_ex_rs2_value <= 32'd0;
                id_ex_immediate <= 32'd0;
                id_ex_rs1 <= 5'd0;
                id_ex_rs2 <= 5'd0;
                id_ex_rd <= 5'd0;
                id_ex_funct3 <= 3'd0;
                id_ex_funct7 <= 7'd0;
                id_ex_opcode <= 7'd0;
                id_ex_reg_write <= 1'b0;
                id_ex_mem_read <= 1'b0;
                id_ex_mem_write <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;
                id_ex_alu_src <= 1'b0;
                id_ex_branch <= 1'b0;
            end else begin
                // ID stage: transfer decoded instruction and operands to ID/EX.
                id_ex_pc <= if_id_pc;
                id_ex_rs1_value <= reg_read_data1;
                id_ex_rs2_value <= reg_read_data2;
                id_ex_immediate <= dec_immediate;
                id_ex_rs1 <= if_rs1;
                id_ex_rs2 <= if_rs2;
                id_ex_rd <= if_rd;
                id_ex_funct3 <= if_funct3;
                id_ex_funct7 <= if_funct7;
                id_ex_opcode <= if_opcode;
                id_ex_reg_write <= dec_reg_write;
                id_ex_mem_read <= dec_mem_read;
                id_ex_mem_write <= dec_mem_write;
                id_ex_mem_to_reg <= dec_mem_to_reg;
                id_ex_alu_src <= dec_alu_src;
                id_ex_branch <= dec_branch;

                // IF stage: fetch next instruction and increment PC by 4.
                if_id_instruction <= instruction_mem[pc[7:2]];
                if_id_pc <= pc;
                pc <= pc + 32'd4;
            end
        end
    end

endmodule
