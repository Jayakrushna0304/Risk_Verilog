`timescale 1ns/1ps

module adder_sub_tb;

    reg [7:0] A, B;
    reg mode;

    wire [7:0] Result;
    wire Carry, Overflow;

    integer passed = 0;
    integer failed = 0;

    adder_sub uut (
        .A(A),
        .B(B),
        .mode(mode),
        .Result(Result),
        .Carry(Carry),
        .Overflow(Overflow)
    );

    task check;
        input [7:0] a, b, expected;
        input operation;
        input expected_carry;
        input expected_overflow;

        begin
            A = a;
            B = b;
            mode = operation;

            #10;

            if (Result === expected &&
                Carry === expected_carry &&
                Overflow === expected_overflow) begin

                $display("PASS: A=%d B=%d Mode=%b Result=%d",
                         A, B, mode, Result);
                passed = passed + 1;

            end else begin

                $display("FAIL: A=%d B=%d Mode=%b Result=%d Expected=%d Carry=%b Overflow=%b",
                         A, B, mode, Result, expected, Carry, Overflow);
                failed = failed + 1;

            end
        end
    endtask

    initial begin

        $display("8-BIT ADDER SUBTRACTOR TEST");

        check(10, 5, 15, 0, 0, 0);
        check(20, 30, 50, 0, 0, 0);
        check(100, 50, 150, 0, 0, 1);
        check(255, 1, 0, 0, 1, 0);
        check(127, 1, 128, 0, 0, 1);

        check(20, 10, 10, 1, 1, 0);
        check(10, 20, 246, 1, 0, 0);
        check(50, 50, 0, 1, 1, 0);
        check(0, 1, 255, 1, 0, 0);
        check(128, 1, 127, 1, 1, 1);

        $display("--------------------------");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule