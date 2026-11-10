module shiftreg (
    input clk,
    input reset,
    input [1:0] mode,
    input [7:0] parallel_in,
    input serial_left,
    input serial_right,
    output reg [7:0] data_out
);

    always @(posedge clk) begin
        if (reset)
            data_out <= 8'b00000000;
        else begin
            case (mode)

                2'b00: data_out <= data_out;

                2'b01: data_out <= {data_out[6:0], serial_left};

                2'b10: data_out <= {serial_right, data_out[7:1]};

                2'b11: data_out <= parallel_in;

                default: data_out <= data_out;

            endcase
        end
    end

endmodule