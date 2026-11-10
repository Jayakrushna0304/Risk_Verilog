
module shifter (
    input [31:0] data_in,
    input [4:0] shift_amount,
    input [1:0] shift_type,
    output reg [31:0] data_out
);

    always @(*) begin

        case (shift_type)

            2'b00: begin
                // Logical Left Shift
                data_out = data_in << shift_amount;
            end

            2'b01: begin
                // Logical Right Shift
                data_out = data_in >> shift_amount;
            end

            2'b10: begin
                // Arithmetic Right Shift
                data_out = $signed(data_in) >>> shift_amount;
            end

            default: begin
                data_out = 32'b0;
            end

        endcase

    end

endmodule
