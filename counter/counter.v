
module counter (
    input clk,
    input reset,
    input enable,
    input up_down,
    input load,
    input [7:0] load_data,
    output reg [7:0] count
);

    always @(posedge clk) begin

        if (reset) begin
            count <= 8'd0;
        end

        else if (load) begin
            count <= load_data;
        end

        else if (enable) begin

            if (up_down)
                count <= count + 1;

            else
                count <= count - 1;

        end

    end

endmodule
