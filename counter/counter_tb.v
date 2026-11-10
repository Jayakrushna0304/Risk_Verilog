
module counter_tb;

    reg clk;
    reg reset;
    reg enable;
    reg up_down;
    reg load;
    reg [7:0] load_data;

    wire [7:0] count;

    integer passed = 0;
    integer failed = 0;

    counter uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .up_down(up_down),
        .load(load),
        .load_data(load_data),
        .count(count)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to check output
    task check;
        input [7:0] expected;
        begin
            #1;

            if (count === expected) begin
                $display("PASS: count = %d", count);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: count = %d Expected = %d",
                         count, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        clk = 0;
        reset = 0;
        enable = 0;
        up_down = 1;
        load = 0;
        load_data = 0;

        $display("==============================");
        $display("8-BIT UP/DOWN COUNTER TEST");
        $display("==============================");

        // Test 1: Reset
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        check(0);

        // Release reset
        @(negedge clk);
        reset = 0;

        // Test 2: Parallel load
        load = 1;
        load_data = 8'd10;
        @(posedge clk);
        check(10);

        // Release load
        @(negedge clk);
        load = 0;

        // Test 3: Count up
        enable = 1;
        up_down = 1;
        @(posedge clk);
        check(11);

        @(posedge clk);
        check(12);

        // Test 4: Count down
        @(negedge clk);
        up_down = 0;
        @(posedge clk);
        check(11);

        // Test 5: Disable counter
        @(negedge clk);
        enable = 0;
        @(posedge clk);
        check(11);

        // Test 6: Count up again
        @(negedge clk);
        enable = 1;
        up_down = 1;
        @(posedge clk);
        check(12);

        // Test 7: Load maximum value
        @(negedge clk);
        enable = 0;
        load = 1;
        load_data = 8'hFF;
        @(posedge clk);
        check(255);

        // Test 8: Overflow / wrap around
        @(negedge clk);
        load = 0;
        enable = 1;
        up_down = 1;
        @(posedge clk);
        check(0);

        // Test 9: Count down from zero
        @(negedge clk);
        up_down = 0;
        @(posedge clk);
        check(255);

        // Final result
        $display("==============================");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);
        $display("==============================");

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule
 