
module tb_riscv_7stage;

    reg clk;
    reg reset;

    integer i;

    riscv_7stage uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    // I-type instruction encoder
    function [31:0] enc_i;
        input [6:0] opcode;
        input [4:0] rd;
        input [3:0] rs1;
        input [2:0] funct3;
        input [11:0] imm;
        begin
            enc_i = {imm, rs1, funct3, rd, opcode};
        end
    endfunction

    // R-type instruction encoder
    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            enc_r = {funct7, rs2, rs1, funct3, rd, opcode};
        end
    endfunction

    initial begin
        clk = 0;
        reset = 1;

        // Initialize memories
        for (i = 0; i < 256; i = i + 1) begin
            uut.instr_mem[i] = 32'h00000013;
            uut.data_mem[i] = 0;
        end

        // Initialize data memory
        uut.data_mem[0] = 32'd55;

        // Program: independent instructions for basic pipeline test
        uut.instr_mem[0] = enc_i(7'b0010011, 5'd1, 4'd0,
                                  3'b000, 12'd5);  // ADDI x1,x0,5

        uut.instr_mem[1] = enc_i(7'b0010011, 5'd2, 4'd0,
                                  3'b000, 12'd7);  // ADDI x2,x0,7

        uut.instr_mem[2] = enc_i(7'b0010011, 5'd3, 4'd0,
                                  3'b000, 12'd12); // ADDI x3,x0,12

        uut.instr_mem[3] = enc_i(7'b0010011, 5'd4, 4'd0,
                                  3'b000, 12'd9);  // ADDI x4,x0,9

        uut.instr_mem[4] = enc_i(7'b0000011, 5'd5, 4'd0,
                                  3'b010, 12'd0);  // LW x5,0(x0)

        uut.instr_mem[5] = 32'h00000013; // NOP
        uut.instr_mem[6] = 32'h00000013; // NOP

        // Release reset
        #12;
        reset = 0;

        // Wait for pipeline
        repeat (25) @(posedge clk);
        #1;

        $display("--------------------------------");
        $display("7-STAGE RISC-V PROCESSOR RESULT");
        $display("--------------------------------");

        for (i = 1; i <= 5; i = i + 1)
            $display("x%0d = %0d", i, uut.registers[i]);

        $display("MEM[0] = %0d", uut.data_mem[0]);

        $display("--------------------------------");

        if (uut.registers[1] == 5 &&
            uut.registers[2] == 7 &&
            uut.registers[3] == 12 &&
            uut.registers[4] == 9 &&
            uut.registers[5] == 55)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
