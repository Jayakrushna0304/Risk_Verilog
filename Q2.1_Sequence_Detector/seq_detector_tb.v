`timescale 1ns/1ps

module seq_detector_tb;

    reg clk, reset, din;
    wire moore_detected;
    wire mealy_detected;

    integer moore_count = 0;
    integer mealy_count = 0;
    integer i;

    reg [6:0] test_data = 7'b1011011;

    seq_moore u_moore (
        .clk(clk),
        .reset(reset),
        .din(din),
        .detected(moore_detected)
    );

    seq_mealy u_mealy (
        .clk(clk),
        .reset(reset),
        .din(din),
        .detected(mealy_detected)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        din = 0;

        $display("SEQUENCE DETECTOR TEST");
        $display("Input pattern = 1011011");

        repeat (2) @(negedge clk);
        reset = 0;

        for (i = 6; i >= 0; i = i - 1) begin
            @(negedge clk);
            din = test_data[i];

            // Mealy output responds to the current input.
            #1;
            if (mealy_detected)
                mealy_count = mealy_count + 1;

            // Moore output changes after the state update.
            @(posedge clk);
            #1;
            if (moore_detected)
                moore_count = moore_count + 1;
        end

        $display("--------------------------");
        $display("Moore detections = %0d", moore_count);
        $display("Mealy detections = %0d", mealy_count);

        if (moore_count == 2 && mealy_count == 2)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
