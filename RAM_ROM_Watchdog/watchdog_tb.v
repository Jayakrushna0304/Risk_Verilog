`timescale 1ns/1ps
module watchdog_tb;
    reg clk, reset, kick;
    wire reset_pulse;

    watchdog #(.TIMEOUT_CYCLES(4)) dut (
        .clk(clk), .reset(reset), .kick(kick),
        .reset_pulse(reset_pulse)
    );
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; kick = 0;
        repeat (2) @(negedge clk);
        reset = 0;

        // Kick before timeout: no reset pulse should occur.
        repeat (2) @(negedge clk);
        kick = 1;
        @(negedge clk); kick = 0;
        repeat (3) begin
            @(posedge clk); #1;
            if (reset_pulse !== 1'b0) begin
                $display("WATCHDOG FAIL: unexpected pulse after kick");
                $fatal(1);
            end
        end
        $display("WATCHDOG PASS: kick reloads timer");

        // Stop kicking and wait for timeout pulse.
        wait (reset_pulse === 1'b1);
        $display("WATCHDOG PASS: timeout generated reset pulse");
        @(posedge clk); #1;
        if (reset_pulse !== 1'b0) begin
            $display("WATCHDOG FAIL: pulse was not one clock wide");
            $fatal(1);
        end
        $display("WATCHDOG PASS: reset pulse is one clock wide");
        $finish;
    end
endmodule
