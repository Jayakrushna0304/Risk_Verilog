module lfsr (
    input clk,
    input reset,
    input seed_load,
    input enable,
    input [7:0] seed,
    output reg [7:0] lfsr_out
);

    wire feedback;

    assign feedback = lfsr_out[7] ^
                      lfsr_out[5] ^
                      lfsr_out[4] ^
                      lfsr_out[3];

    always @(posedge clk) begin

        if (reset)
            lfsr_out <= 8'h01;

        else if (seed_load) begin
            if (seed != 8'h00)
                lfsr_out <= seed;
            else
                lfsr_out <= 8'h01;
        end

        else if (enable)
            lfsr_out <= {lfsr_out[6:0], feedback};

    end

endmodule