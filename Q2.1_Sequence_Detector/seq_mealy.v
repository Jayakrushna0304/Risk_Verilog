module seq_mealy (
    input clk,
    input reset,
    input din,
    output reg detected
);

    reg [1:0] state;

    parameter S0 = 2'b00,
              S1 = 2'b01,
              S2 = 2'b10,
              S3 = 2'b11;

    always @(posedge clk) begin
        if (reset)
            state <= S0;
        else begin
            case (state)
                S0: begin
                    if (din) state <= S1;
                    else state <= S0;
                end

                S1: begin
                    if (din) state <= S1;
                    else state <= S2;
                end

                S2: begin
                    if (din) state <= S3;
                    else state <= S0;
                end

                S3: begin
                    if (din) state <= S1;
                    else state <= S2;
                end

                default: state <= S0;
            endcase
        end
    end

    always @(*) begin
        detected = (state == S3) && din;
    end

endmodule
