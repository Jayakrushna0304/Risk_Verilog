module priority_encoder_casez (
    input [7:0] D,
    output reg [2:0] Y,
    output reg valid
);

    always @(*) begin
        valid = 1'b1;

        casez (D)
            8'b1???????: Y = 3'b111;
            8'b01??????: Y = 3'b110;
            8'b001?????: Y = 3'b101;
            8'b0001????: Y = 3'b100;
            8'b00001???: Y = 3'b011;
            8'b000001??: Y = 3'b010;
            8'b0000001?: Y = 3'b001;
            8'b00000001: Y = 3'b000;

            default: begin
                Y = 3'b000;
                valid = 1'b0;
            end
        endcase
    end

endmodule


module priority_encoder_if (
    input [7:0] D,
    output reg [2:0] Y,
    output reg valid
);

    always @(*) begin
        valid = 1'b1;

        if (D[7])
            Y = 3'b111;
        else if (D[6])
            Y = 3'b110;
        else if (D[5])
            Y = 3'b101;
        else if (D[4])
            Y = 3'b100;
        else if (D[3])
            Y = 3'b011;
        else if (D[2])
            Y = 3'b010;
        else if (D[1])
            Y = 3'b001;
        else if (D[0])
            Y = 3'b000;
        else begin
            Y = 3'b000;
            valid = 1'b0;
        end
    end

endmodule