// Single-port synchronous RAM: 16 words x 8 bits.
module ram (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out
);
    reg [7:0] mem [0:15];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
        data_out <= mem[addr];
    end
endmodule
