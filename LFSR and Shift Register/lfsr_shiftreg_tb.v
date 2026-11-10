`timescale 1ns/1ps

module lfsr_shiftreg_tb;

    reg clk, reset;
    reg [1:0] mode;
    reg [7:0] parallel_in;
    reg serial_left, serial_right;

    wire [7:0] data_out;

    reg seed_load, enable;
    reg [7:0] seed;
    wire [7:0] lfsr_out;

    integer passed = 0;
    integer failed = 0;
    integer i;
    reg zero_found;

    shiftreg uut1 (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .parallel_in(parallel_in),
        .serial_left(serial_left),
        .serial_right(serial_right),
        .data_out(data_out)
    );

    lfsr uut2 (
        .clk(clk),
        .reset(reset),
        .seed_load(seed_load),
        .enable(enable),
        .seed(seed),
        .lfsr_out(lfsr_out)
    );

    always #5 clk = ~clk;

    task check_shift;
        input [1:0] test_mode;
        input [7:0] input_data;
        input left_bit;
        input right_bit;
        input [7:0] expected;

        begin
            @(negedge clk);
            mode = test_mode;
            parallel_in = input_data;
            serial_left = left_bit;
            serial_right = right_bit;

            @(posedge clk);
            #1;

            if (data_out === expected) begin
                $display("SHIFT PASS: Mode=%b Output=%h",
                         mode, data_out);
                passed = passed + 1;
            end
            else begin
                $display("SHIFT FAIL: Expected=%h Actual=%h",
                         expected, data_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        clk = 0;
        reset = 1;
        mode = 0;
        parallel_in = 0;
        serial_left = 0;
        serial_right = 0;

        seed = 8'h01;
        seed_load = 0;
        enable = 0;
        zero_found = 0;

        $display("LFSR AND SHIFT REGISTER TEST");

        // Reset
        @(posedge clk);
        #1;
        reset = 0;

        // Universal shift register tests
        check_shift(2'b11, 8'hA5, 0, 0, 8'hA5);
        check_shift(2'b00, 8'h00, 0, 0, 8'hA5);
        check_shift(2'b01, 8'h00, 1, 0, 8'h4B);
        check_shift(2'b10, 8'h00, 0, 1, 8'hA5);

        // Load the LFSR seed
        @(negedge clk);
        seed_load = 1;
        enable = 0;
        seed = 8'h01;

        @(posedge clk);
        #1;

        @(negedge clk);
        seed_load = 0;
        enable = 1;

        // Check all 255 LFSR states
        for (i = 0; i < 255; i = i + 1) begin

            if (lfsr_out == 8'h00)
                zero_found = 1;

            @(posedge clk);
            #1;

        end

        if (zero_found == 0 && lfsr_out == 8'h01) begin
            $display("LFSR PASS: Repeated after 255 states");
            $display("LFSR PASS: All-zero state never reached");
            passed = passed + 2;
        end
        else begin
            $display("LFSR FAIL: Sequence verification failed");
            failed = failed + 1;
        end

        $display("-----------------------------");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule