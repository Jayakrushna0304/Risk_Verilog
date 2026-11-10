module vending (
    input clk,
    input reset,
    input coin5,
    input coin10,
    input cancel,
    output reg dispense,
    output reg [4:0] change,
    output reg [4:0] refund,
    output reg [4:0] credit
);

    // States represent the amount currently inserted:
    // S0 = Rs.0, S5 = Rs.5, S10 = Rs.10
    localparam S0  = 2'b00;
    localparam S5  = 2'b01;
    localparam S10 = 2'b10;

    reg [1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state    <= S0;
            credit   <= 5'd0;
            dispense <= 1'b0;
            change   <= 5'd0;
            refund   <= 5'd0;
        end
        else begin
            // Outputs are one-clock-cycle pulses.
            dispense <= 1'b0;
            change   <= 5'd0;
            refund   <= 5'd0;

            // Cancellation returns all money inserted so far.
            if (cancel) begin
                refund <= credit;
                credit <= 5'd0;
                state  <= S0;
            end
            else begin
                case (state)

                    S0: begin
                        credit <= 5'd0;
                        if (coin5) begin
                            credit <= 5'd5;
                            state  <= S5;
                        end
                        else if (coin10) begin
                            credit <= 5'd10;
                            state  <= S10;
                        end
                    end

                    S5: begin
                        if (coin5) begin
                            credit <= 5'd10;
                            state  <= S10;
                        end
                        else if (coin10) begin
                            // Rs.5 + Rs.10 = Rs.15
                            dispense <= 1'b1;
                            credit   <= 5'd0;
                            state    <= S0;
                        end
                    end

                    S10: begin
                        if (coin5) begin
                            // Rs.10 + Rs.5 = Rs.15
                            dispense <= 1'b1;
                            credit   <= 5'd0;
                            state    <= S0;
                        end
                        else if (coin10) begin
                            // Rs.10 + Rs.10 = Rs.20; return Rs.5.
                            dispense <= 1'b1;
                            change   <= 5'd5;
                            credit   <= 5'd0;
                            state    <= S0;
                        end
                    end

                    default: begin
                        state  <= S0;
                        credit <= 5'd0;
                    end

                endcase
            end
        end
    end

endmodule
