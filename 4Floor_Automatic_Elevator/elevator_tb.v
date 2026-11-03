`timescale 1ns/1ps

module elevator_tb;

reg clk;
reg reset;
reg emergency;
reg [2:0] floor_request;

wire [2:0] current_floor;
wire motor_up;
wire motor_down;
wire door_open;

// Connect elevator design
elevator #(
    .DOOR_TIME_CYCLES(30)
) uut (
    .clk(clk),
    .reset(reset),
    .emergency(emergency),
    .floor_request(floor_request),
    .current_floor(current_floor),
    .motor_up(motor_up),
    .motor_down(motor_down),
    .door_open(door_open)
);

// Generate clock
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test cases
initial
begin
    reset = 1;
    emergency = 0;
    floor_request = 0;

    #12 reset = 0;

    // Test 1: Floor 1 to Floor 3
    #10 floor_request = 3;
    #10 floor_request = 0;
    #400;

    // Test 2: Floor 3 to Floor 2
    floor_request = 2;
    #10 floor_request = 0;
    #400;

    // Test 3: Floor 2 to Floor 4
    floor_request = 4;
    #10 floor_request = 0;
    #400;

    // Test 4: Floor 4 to Floor 1
    floor_request = 1;
    #10 floor_request = 0;
    #400;

    // Emergency test
    emergency = 1;
    #20 emergency = 0;

    $display("ELEVATOR SIMULATION COMPLETED");

    #20 $finish;
end

// Display values in Transcript
initial
begin
    $monitor(
        "Time=%0t Floor=%d Request=%d UP=%b DOWN=%b DOOR=%b EMERGENCY=%b",
        $time,
        current_floor,
        floor_request,
        motor_up,
        motor_down,
        door_open,
        emergency
    );
end

endmodule