`timescale 1ns/1ps

module fifo_tb;

    reg clk;
    reg reset;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire [7:0] data_out;
    wire full;
    wire empty;
    wire [4:0] count;

    integer passed = 0;
    integer failed = 0;
    integer i;

    fifo uut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .count(count)
    );

    always #5 clk = ~clk;

    task write_item;
        input [7:0] value;
        begin
            @(negedge clk);
            wr_en = 1;
            rd_en = 0;
            data_in = value;
            @(posedge clk);
            #1;
        end
    endtask

    task read_item;
        input [7:0] expected;
        begin
            @(negedge clk);
            wr_en = 0;
            rd_en = 1;
            @(posedge clk);
            #1;
            if (data_out === expected) begin
                $display("PASS: Read data = %h", data_out);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: Expected = %h, Actual = %h",
                         expected, data_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        $display("SYNCHRONOUS FIFO TEST");

        repeat (2) @(negedge clk);
        reset = 0;

        // Fill FIFO with 16 values: 0x10 to 0x1F.
        for (i = 0; i < 16; i = i + 1)
            write_item(8'h10 + i);

        @(negedge clk);
        wr_en = 0;

        if (full && count == 16) begin
            $display("PASS: FIFO becomes FULL after 16 writes");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: FIFO did not become FULL");
            failed = failed + 1;
        end

        // Attempt write while full; it must be ignored.
        @(negedge clk);
        wr_en = 1;
        rd_en = 0;
        data_in = 8'hEE;
        @(posedge clk);
        #1;
        if (full && count == 16) begin
            $display("PASS: Write while FULL is ignored");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Write while FULL changed FIFO");
            failed = failed + 1;
        end

        // Drain FIFO and check first-in, first-out order.
        for (i = 0; i < 16; i = i + 1)
            read_item(8'h10 + i);

        @(negedge clk);
        rd_en = 0;

        if (empty && count == 0) begin
            $display("PASS: FIFO becomes EMPTY after 16 reads");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: FIFO did not become EMPTY");
            failed = failed + 1;
        end

        // Attempt read while empty; it must be ignored.
        @(negedge clk);
        rd_en = 1;
        wr_en = 0;
        @(posedge clk);
        #1;
        if (empty && count == 0) begin
            $display("PASS: Read while EMPTY is ignored");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Read while EMPTY changed FIFO");
            failed = failed + 1;
        end

        // Simultaneous read and write while FIFO has data.
        @(negedge clk);
        rd_en = 0;
        wr_en = 1;
        data_in = 8'hA1;
        @(posedge clk);
        #1;

        @(negedge clk);
        data_in = 8'hB2;
        wr_en = 1;
        rd_en = 1;
        @(posedge clk);
        #1;

        if (data_out == 8'hA1 && count == 1) begin
            $display("PASS: Simultaneous read/write works");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Simultaneous read/write incorrect");
            failed = failed + 1;
        end

        // Read the remaining item.
        @(negedge clk);
        wr_en = 0;
        rd_en = 1;
        @(posedge clk);
        #1;

        if (data_out == 8'hB2 && empty) begin
            $display("PASS: FIFO preserves order after simultaneous operation");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: FIFO order/count incorrect after simultaneous operation");
            failed = failed + 1;
        end

        @(negedge clk);
        rd_en = 0;

        $display("--------------------------------");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
