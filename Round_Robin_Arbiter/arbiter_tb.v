`timescale 1ns/1ps
module arbiter_tb;
    reg clk, reset;
    reg [3:0] req;
    wire [3:0] grant;

    arbiter dut (.clk(clk), .reset(reset), .req(req), .grant(grant));
    always #5 clk = ~clk;

    task tick;
    begin
        @(posedge clk);
        #1;
    end
    endtask

    task check_grant;
        input [3:0] expected;
        input [8*80-1:0] test_name;
    begin
        if (grant !== expected) begin
            $display("FAIL: %0s expected=%b actual=%b", test_name, expected, grant);
            $fatal(1);
        end else begin
            $display("PASS: %0s grant=%b", test_name, grant);
        end
    end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        req = 4'b0000;
        tick();
        reset = 0;

        // All four request. Initial priority must select requester 0.
        req = 4'b1111;
        tick();
        check_grant(4'b0001, "Initial priority selects requester 0");

        // Keep req[0] high: grant must remain with requester 0.
        repeat (2) begin
            tick();
            check_grant(4'b0001, "Grant held while request remains asserted");
        end

        // Release requester 0. Grant clears, then requester 1 wins.
        req[0] = 0;
        tick();
        check_grant(4'b0000, "Grant clears after requester 0 releases");
        tick();
        check_grant(4'b0010, "Round robin selects requester 1");

        req[1] = 0;
        tick();
        check_grant(4'b0000, "Grant clears after requester 1 releases");
        tick();
        check_grant(4'b0100, "Round robin selects requester 2");

        req[2] = 0;
        tick();
        check_grant(4'b0000, "Grant clears after requester 2 releases");
        tick();
        check_grant(4'b1000, "Round robin selects requester 3");

        req[3] = 0;
        tick();
        check_grant(4'b0000, "Grant clears after requester 3 releases");
        tick();
        check_grant(4'b0001, "Priority wraps to requester 0");

        // Release requester 0; no active requests should mean no grant.
        req = 4'b0000;
        tick();
        check_grant(4'b0000, "Grant clears when request is removed");
        tick();
        check_grant(4'b0000, "No grant when no requests are active");

        $display("================================");
        $display("ALL TEST CASES PASSED");
        $finish;
    end

    initial
        $monitor("t=%0t reset=%b req=%b grant=%b priority=%0d",
                 $time, reset, req, grant, dut.priority_ptr);
endmodule
