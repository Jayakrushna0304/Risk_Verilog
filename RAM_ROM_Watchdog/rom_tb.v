`timescale 1ns/1ps
module rom_tb;
    reg clk;
    reg [3:0] addr;
    wire [7:0] data_out;

    rom dut (.clk(clk), .addr(addr), .data_out(data_out));
    always #5 clk = ~clk;

    initial begin
        clk = 0; addr = 0;
        @(posedge clk); #1;
        if (data_out !== 8'h10) begin
            $display("ROM FAIL: address 0 expected 10, got %h", data_out);
            $fatal(1);
        end
        $display("ROM PASS: address 0 = %h", data_out);

        @(negedge clk); addr = 4'hF;
        @(posedge clk); #1;
        if (data_out !== 8'h1F) begin
            $display("ROM FAIL: address 15 expected 1F, got %h", data_out);
            $fatal(1);
        end
        $display("ROM PASS: address 15 = %h", data_out);
        $finish;
    end
endmodule
