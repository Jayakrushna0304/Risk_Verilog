// Watchdog asserts reset_pulse for one clock when timeout expires.
// A kick reloads the counter and prevents timeout.
module watchdog #(
    parameter TIMEOUT_CYCLES = 8
)(
    input  wire clk,
    input  wire reset,
    input  wire kick,
    output reg  reset_pulse
);
    localparam COUNT_WIDTH = (TIMEOUT_CYCLES < 2) ? 1 : $clog2(TIMEOUT_CYCLES + 1);
    reg [COUNT_WIDTH-1:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= TIMEOUT_CYCLES;
            reset_pulse <= 1'b0;
        end else if (kick) begin
            count <= TIMEOUT_CYCLES;
            reset_pulse <= 1'b0;
        end else if (count <= 1) begin
            count <= TIMEOUT_CYCLES;
            reset_pulse <= 1'b1;
        end else begin
            count <= count - 1'b1;
            reset_pulse <= 1'b0;
        end
    end
endmodule
