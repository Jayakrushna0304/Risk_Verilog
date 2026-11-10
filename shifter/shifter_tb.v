
module shifter_tb;

    reg [31:0] data_in;
    reg [4:0] shift_amount;
    reg [1:0] shift_type;

    wire [31:0] data_out;

    integer i;
    integer passed = 0;
    integer failed = 0;

    reg [31:0] expected;

    shifter uut (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .shift_type(shift_type),
        .data_out(data_out)
    );

    task check;
        input [31:0] exp;
        begin
            #5;

            if (data_out === exp) begin
                $display("PASS: Type=%b Shift=%d Output=%h",
                         shift_type, shift_amount, data_out);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: Type=%b Shift=%d Output=%h Expected=%h",
                         shift_type, shift_amount, data_out, exp);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        data_in = 32'h80000005;
        shift_amount = 0;
        shift_type = 0;

        $display("==============================");
        $display("BARREL SHIFTER TEST");
        $display("==============================");

        // Test logical left shift
        shift_type = 2'b00;

        for (i = 0; i < 32; i = i + 1) begin
            shift_amount = i;
            expected = data_in << i;
            check(expected);
        end

        // Test logical right shift
        shift_type = 2'b01;

        for (i = 0; i < 32; i = i + 1) begin
            shift_amount = i;
            expected = data_in >> i;
            check(expected);
        end

        // Test arithmetic right shift
        shift_type = 2'b10;

        for (i = 0; i < 32; i = i + 1) begin
            shift_amount = i;
            expected = $signed(data_in) >>> i;
            check(expected);
        end

        $display("==============================");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);
        $display("==============================");

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule
