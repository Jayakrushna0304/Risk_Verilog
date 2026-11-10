// 4-requester round-robin arbiter.
// Holds a grant until the granted requester deasserts its request.
module arbiter (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] req,
    output reg  [3:0] grant
);
    reg [1:0] priority_ptr;
    reg [3:0] candidate;
    integer k;
    integer index;
    reg found;

    // Combinational priority search, beginning at priority_ptr.
    always @(*) begin
        candidate = 4'b0000;
        found = 1'b0;
        index = 0;
        for (k = 0; k < 4; k = k + 1) begin
            index = priority_ptr + k;
            if (index >= 4)
                index = index - 4;
            if (!found && req[index]) begin
                candidate = 4'b0001 << index;
                found = 1'b1;
            end
        end
    end

    // Registered one-hot grant and rotating priority.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant <= 4'b0000;
            priority_ptr <= 2'd0;
        end else if (grant != 4'b0000) begin
            if ((grant & req) == 4'b0000) begin
                case (grant)
                    4'b0001: priority_ptr <= 2'd1;
                    4'b0010: priority_ptr <= 2'd2;
                    4'b0100: priority_ptr <= 2'd3;
                    4'b1000: priority_ptr <= 2'd0;
                    default: priority_ptr <= priority_ptr;
                endcase
                grant <= 4'b0000;
            end
            // Otherwise hold the current grant.
        end else begin
            grant <= candidate;
        end
    end
endmodule
