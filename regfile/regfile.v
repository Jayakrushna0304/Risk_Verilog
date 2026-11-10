
module regfile (
    input clk,
    input we,
    input [4:0] ra1,
    input [4:0] ra2,
    input [4:0] wa,
    input [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] registers [0:31];

    integer i;

    // Initialize all registers to zero
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    // Write operation
    always @(posedge clk) begin
        if (we && wa != 0)
            registers[wa] <= wd;

        // x0 is always zero
        registers[0] <= 32'b0;
    end

    // Read operation with bypass logic
    assign rd1 = (ra1 == 0) ? 32'b0 :
                 (we && wa == ra1) ? wd : registers[ra1];

    assign rd2 = (ra2 == 0) ? 32'b0 :
                 (we && wa == ra2) ? wd : registers[ra2];

endmodule
