module debounce #(
    parameter COUNT_MAX = 4
)(
    input clk,
    input reset,
    input noisy_in,
    output reg clean_out
);

    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            clean_out <= 0;
        end
        else begin
            if (noisy_in == clean_out) begin
                count <= 0;
            end
            else begin
                if (count == COUNT_MAX - 1) begin
                    clean_out <= noisy_in;
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end
            end
        end
    end

endmodule