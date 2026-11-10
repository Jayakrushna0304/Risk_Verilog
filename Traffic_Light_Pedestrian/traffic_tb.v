`timescale 1ns/1ps

module traffic_tb;

    reg clk;
    reg reset;
    reg ped_req;

    wire car_red;
    wire car_yellow;
    wire car_green;
    wire walk;

    // Short timings make simulation faster.
    traffic #(
        .GREEN_TIME(6),
        .YELLOW_TIME(2),
        .RED_TIME(3),
        .WALK_TIME(3)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ped_req(ped_req),
        .car_red(car_red),
        .car_yellow(car_yellow),
        .car_green(car_green),
        .walk(walk)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        ped_req = 0;

        $display("Starting traffic light test...");
        #12;
        reset = 0;

        // Request during green. It should be served after green/yellow.
        #10;
        ped_req = 1;
        #10;
        ped_req = 0;

        // Keep running long enough to observe walk and return to green.
        #130;

        // Check that exactly one traffic light indication is active.
        if ((car_red + car_yellow + car_green) != 1) begin
            $display("FAIL: Invalid traffic light outputs");
            $finish;
        end

        $display("Test completed. Inspect waveform for GREEN -> YELLOW -> WALK -> RED -> GREEN.");
        $finish;
    end

    initial begin
        $monitor("time=%0t reset=%b req=%b | R=%b Y=%b G=%b WALK=%b",
                 $time, reset, ped_req, car_red, car_yellow, car_green, walk);
    end

endmodule
