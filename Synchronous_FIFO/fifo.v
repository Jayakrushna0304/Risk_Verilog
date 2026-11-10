module fifo (
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output full,
    output empty,
    output reg [4:0] count
);

    reg [7:0] memory [0:15];
    reg [3:0] write_ptr;
    reg [3:0] read_ptr;

    assign full  = (count == 5'd16);
    assign empty = (count == 5'd0);

    always @(posedge clk) begin
        if (reset) begin
            write_ptr <= 4'd0;
            read_ptr  <= 4'd0;
            count     <= 5'd0;
            data_out  <= 8'd0;
        end
        else begin
            case ({wr_en && !full, rd_en && !empty})

                // Write only
                2'b10: begin
                    memory[write_ptr] <= data_in;
                    write_ptr <= write_ptr + 1'b1;
                    count <= count + 1'b1;
                end

                // Read only
                2'b01: begin
                    data_out <= memory[read_ptr];
                    read_ptr <= read_ptr + 1'b1;
                    count <= count - 1'b1;
                end

                // Read and write in the same clock cycle
                2'b11: begin
                    memory[write_ptr] <= data_in;
                    write_ptr <= write_ptr + 1'b1;
                    data_out <= memory[read_ptr];
                    read_ptr <= read_ptr + 1'b1;
                    count <= count;
                end

                // No accepted operation
                default: begin
                    count <= count;
                end

            endcase
        end
    end

endmodule
