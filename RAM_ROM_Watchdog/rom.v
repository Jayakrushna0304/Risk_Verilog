// 16 x 8 ROM initialized from rom.hex.
module rom (
    input  wire       clk,
    input  wire [3:0] addr,
    output reg  [7:0] data_out
);
    reg [7:0] mem [0:15];

    initial begin
        $readmemh("rom.hex", mem);
    end

    always @(posedge clk) begin
        data_out <= mem[addr];
    end
endmodule
