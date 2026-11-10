`timescale 1ns/1ps

module edge_debounce_tb;

    reg clk;
    reg reset;
    reg button;

    wire sync_button;
    wire clean_button;
    wire pulse;

    integer pulse_count = 0;
    integer passed = 0;
    integer failed = 0;

    input_sync uut1 (
        .clk(clk),
        .reset(reset),
        .async_in(button),
        .sync_out(sync_button)
    );

    debounce #(.COUNT_MAX(4)) uut2 (
        .clk(clk),
        .reset(reset),
        .noisy_in(sync_button),
        .clean_out(clean_button)
    );

    edge_detect uut3 (
        .clk(clk),
        .reset(reset),
        .signal_in(clean_button),
        .pulse(pulse)
    );

    always #5 clk = ~clk;

    // Count rising-edge pulses
    always @(posedge clk) begin
        if (!reset && pulse)
            pulse_count = pulse_count + 1;
    end

    // Apply button input for a number of clock cycles
    task drive_cycles;
        input value;
        input integer cycles;
        integer j;
        begin
            for (j = 0; j < cycles; j = j + 1) begin
                @(negedge clk);
                button = value;
            end
        end
    endtask

    initial begin

        clk = 0;
        reset = 1;
        button = 0;

        $display("EDGE DETECTOR AND DEBOUNCER TEST");

        // Reset
        repeat (3) @(negedge clk);
        reset = 0;

        // Button bouncing
        drive_cycles(1, 2);
        drive_cycles(0, 2);
        drive_cycles(1, 1);
        drive_cycles(0, 2);

        // Button settles HIGH
        drive_cycles(1, 10);

        // Wait for stable output and pulse
        repeat (3) @(negedge clk);

        if (clean_button == 1 && pulse_count == 1) begin
            $display("PASS: One clean rising-edge pulse");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Expected one pulse, got %0d",
                     pulse_count);
            failed = failed + 1;
        end

        // Keep button HIGH: no extra pulse
        drive_cycles(1, 8);

        if (pulse_count == 1) begin
            $display("PASS: No repeated pulse while button HIGH");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Unexpected repeated pulse");
            failed = failed + 1;
        end

        // Button settles LOW
        drive_cycles(0, 10);

        if (clean_button == 0) begin
            $display("PASS: Button returns to LOW");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Button did not return LOW");
            failed = failed + 1;
        end

        // Press again
        drive_cycles(1, 10);
        repeat (3) @(negedge clk);

        if (pulse_count == 2) begin
            $display("PASS: Second press produces second pulse");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Expected two total pulses, got %0d",
                     pulse_count);
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