`timescale 1ns/1ps
module ram_tb;
    reg clk, we;
    reg [3:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;

    ram dut (.clk(clk), .we(we), .addr(addr),
             .data_in(data_in), .data_out(data_out));
    always #5 clk = ~clk;

    initial begin
        clk = 0; we = 0; addr = 0; data_in = 0;

        // Write 0xA5 to address 3.
        @(negedge clk); addr = 3; data_in = 8'hA5; we = 1;
        @(negedge clk); we = 0;
        // Read address 3 (synchronous read).
        @(negedge clk); addr = 3;
        @(posedge clk); #1;
        if (data_out !== 8'hA5) begin
            $display("RAM FAIL: expected A5, got %h", data_out);
            $fatal(1);
        end
        $display("RAM PASS: address 3 contains %h", data_out);

        // Write and read another location.
        @(negedge clk); addr = 9; data_in = 8'h5C; we = 1;
        @(negedge clk); we = 0;
        @(negedge clk); addr = 9;
        @(posedge clk); #1;
        if (data_out !== 8'h5C) begin
            $display("RAM FAIL: expected 5C, got %h", data_out);
            $fatal(1);
        end
        $display("RAM PASS: address 9 contains %h", data_out);
        $finish;
    end
endmodule
