module seq_moore (
    input clk,
    input reset,
    input din,
    output reg detected
);

    reg [2:0] state;

    parameter S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100;

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
                    if (din) state <= S4;
                    else state <= S2;
                end

                // Preserve overlap after detecting 1011
                S4: begin
                    if (din) state <= S1;
                    else state <= S2;
                end

                default: state <= S0;
            endcase
        end
    end

    always @(*) begin
        detected = (state == S4);
    end

endmodule
