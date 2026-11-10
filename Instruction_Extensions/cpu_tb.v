`timescale 1ns/1ps
module cpu_tb;
    reg clk;
    reg reset;
    integer cycle_count;

    riscv_cpu dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;
        input [8*20-1:0] test_name;
    begin
        if (dut.regs[register_number] !== expected_value) begin
            $display("FAIL: %0s | x%0d expected=%h actual=%h",
                     test_name, register_number, expected_value,
                     dut.regs[register_number]);
            $fatal(1);
        end else begin
            $display("PASS: %0s | x%0d = %h",
                     test_name, register_number, dut.regs[register_number]);
        end
    end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        cycle_count = 0;

        repeat (2) @(negedge clk);
        reset = 1'b0;

        // Program executes 11 instructions, then loops at its final JAL.
        repeat (14) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;
        end

        $display("\\n--- Q3.1 Instruction Extension Results ---");
        check_register(1, 32'd15, "ADDI base");
        check_register(2, 32'd7,  "ANDI");
        check_register(3, 32'd15, "ORI");
        check_register(4, 32'd12, "XORI");
        check_register(5, 32'd1,  "SLTI");
        check_register(6, 32'd60, "SLLI");
        check_register(7, 32'd7,  "SRLI");
        check_register(8, 32'h12345000, "LUI");
        check_register(9, 32'd36, "JAL return address");
        check_register(10, 32'd42, "JAL target instruction");

        $display("\\nALL Q3.1 TESTS PASSED");
        $finish;
    end

    initial begin
        $monitor("time=%0t PC=%h instruction=%h",
                 $time, dut.pc, dut.instr);
    end
endmodule
