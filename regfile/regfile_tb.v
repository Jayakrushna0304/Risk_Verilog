
module regfile_tb;

    reg clk;
    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;

    wire [31:0] rd1, rd2;

    reg [31:0] expected [0:31];

    integer i;
    integer passed = 0;
    integer failed = 0;

    reg [31:0] exp1, exp2;

    regfile uut (
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test one register-file operation
    task check_operation;
        input write_enable;
        input [4:0] read1;
        input [4:0] read2;
        input [4:0] write_addr;
        input [31:0] write_data;

        begin
            @(negedge clk);

            we = write_enable;
            ra1 = read1;
            ra2 = read2;
            wa = write_addr;
            wd = write_data;

            // Check bypass before clock edge
            #1;

            if (read1 == 0)
                exp1 = 0;
            else if (write_enable && write_addr == read1)
                exp1 = write_data;
            else
                exp1 = expected[read1];

            if (read2 == 0)
                exp2 = 0;
            else if (write_enable && write_addr == read2)
                exp2 = write_data;
            else
                exp2 = expected[read2];

            if (rd1 === exp1 && rd2 === exp2) begin
                passed = passed + 1;
                $display("PASS: Read1=%d Read2=%d",
                         rd1, rd2);
            end
            else begin
                failed = failed + 1;
                $display("FAIL: Read1=%d Expected1=%d Read2=%d Expected2=%d",
                         rd1, exp1, rd2, exp2);
            end

            // Perform write at rising clock edge
            @(posedge clk);

            if (write_enable && write_addr != 0)
                expected[write_addr] = write_data;

            expected[0] = 0;

            #1;

            // Check values after writing
            if (read1 == 0)
                exp1 = 0;
            else
                exp1 = expected[read1];

            if (read2 == 0)
                exp2 = 0;
            else
                exp2 = expected[read2];

            if (rd1 === exp1 && rd2 === exp2) begin
                passed = passed + 1;
                $display("PASS: Register values after write");
            end
            else begin
                failed = failed + 1;
                $display("FAIL: Register values after write");
            end
        end
    endtask

    initial begin

        clk = 0;
        we = 0;
        ra1 = 0;
        ra2 = 0;
        wa = 0;
        wd = 0;

        for (i = 0; i < 32; i = i + 1)
            expected[i] = 0;

        $display("================================");
        $display("REGISTER FILE TEST");
        $display("================================");

        // Test 1: Write to register 1
        check_operation(1, 1, 0, 1, 100);

        // Test 2: Write to register 2
        check_operation(1, 1, 2, 2, 200);

        // Test 3: Read two registers
        check_operation(0, 1, 2, 0, 0);

        // Test 4: Check x0 cannot be changed
        check_operation(1, 0, 1, 0, 999);

        // Test 5: Check bypass logic
        check_operation(1, 3, 3, 3, 300);

        // Test 6: Write enable disabled
        check_operation(0, 1, 2, 4, 400);

        // Test 7: 200 random operations
        for (i = 0; i < 200; i = i + 1) begin
            check_operation(
                $random & 1,
                $random & 31,
                $random & 31,
                $random & 31,
                $random
            );
        end

        $display("================================");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);
        $display("================================");

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule
