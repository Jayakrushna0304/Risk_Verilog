`timescale 1ns/1ps

module vending_tb;

    reg clk;
    reg reset;
    reg coin5;
    reg coin10;
    reg cancel;

    wire dispense;
    wire [4:0] change;
    wire [4:0] refund;
    wire [4:0] credit;

    integer passed = 0;
    integer failed = 0;

    vending uut (
        .clk(clk),
        .reset(reset),
        .coin5(coin5),
        .coin10(coin10),
        .cancel(cancel),
        .dispense(dispense),
        .change(change),
        .refund(refund),
        .credit(credit)
    );

    always #5 clk = ~clk;

    // Apply one input event on a falling edge and check after rising edge.
    task apply_input;
        input c5;
        input c10;
        input can;
        input expected_dispense;
        input [4:0] expected_change;
        input [4:0] expected_refund;
        input [4:0] expected_credit;
        begin
            @(negedge clk);
            coin5 = c5;
            coin10 = c10;
            cancel = can;

            @(posedge clk);
            #1;

            if (dispense === expected_dispense &&
                change === expected_change &&
                refund === expected_refund &&
                credit === expected_credit) begin
                $display("PASS: coin5=%b coin10=%b cancel=%b dispense=%b change=%0d refund=%0d credit=%0d",
                         c5, c10, can, dispense, change, refund, credit);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: coin5=%b coin10=%b cancel=%b", c5, c10, can);
                $display("     Expected: dispense=%b change=%0d refund=%0d credit=%0d",
                         expected_dispense, expected_change,
                         expected_refund, expected_credit);
                $display("     Actual:   dispense=%b change=%0d refund=%0d credit=%0d",
                         dispense, change, refund, credit);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        coin5 = 0;
        coin10 = 0;
        cancel = 0;

        $display("VENDING MACHINE TEST");
        $display("Item price = Rs.15");

        // Reset
        repeat (2) @(negedge clk);
        reset = 0;

        // Test 1: Rs.5 + Rs.10 = Rs.15; dispense, no change.
        apply_input(1, 0, 0, 0, 0, 0, 5);
        apply_input(0, 1, 0, 1, 0, 0, 0);

        // Test 2: Rs.10 + Rs.5 = Rs.15; dispense, no change.
        apply_input(0, 1, 0, 0, 0, 0, 10);
        apply_input(1, 0, 0, 1, 0, 0, 0);

        // Test 3: Rs.10 + Rs.10 = Rs.20; dispense Rs.5 change.
        apply_input(0, 1, 0, 0, 0, 0, 10);
        apply_input(0, 1, 0, 1, 5, 0, 0);

        // Test 4: Insert Rs.5 + Rs.5, then cancel and refund Rs.10.
        apply_input(1, 0, 0, 0, 0, 0, 5);
        apply_input(1, 0, 0, 0, 0, 0, 10);
        apply_input(0, 0, 1, 0, 0, 10, 0);

        // Test 5: Cancel after inserting Rs.10.
        apply_input(0, 1, 0, 0, 0, 0, 10);
        apply_input(0, 0, 1, 0, 0, 10, 0);

        // Test 6: No coin inserted; outputs remain inactive.
        apply_input(0, 0, 0, 0, 0, 0, 0);

        $display("--------------------------------");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
