`timescale 1ns/1ps

module encoder_decoder_tb;

    reg [7:0] D;
    reg [2:0] A;
    reg enable;

    wire [2:0] Y_casez;
    wire valid_casez;

    wire [2:0] Y_if;
    wire valid_if;

    wire [7:0] decoder_out;

    integer passed = 0;
    integer failed = 0;
    integer i;

    priority_encoder_casez enc1 (
        .D(D),
        .Y(Y_casez),
        .valid(valid_casez)
    );

    priority_encoder_if enc2 (
        .D(D),
        .Y(Y_if),
        .valid(valid_if)
    );

    decoder dec1 (
        .A(A),
        .enable(enable),
        .Y(decoder_out)
    );

    task check_encoder;
        input [7:0] data;
        input [2:0] expected;
        input expected_valid;

        begin
            D = data;
            #10;

            if (Y_casez === expected &&
                Y_if === expected &&
                valid_casez === expected_valid &&
                valid_if === expected_valid) begin

                $display("ENCODER PASS: D=%b Y=%b",
                         D, Y_casez);
                passed = passed + 1;

            end
            else begin
                $display("ENCODER FAIL: D=%b Expected=%b",
                         D, expected);
                failed = failed + 1;
            end
        end
    endtask

    task check_decoder;
        input [2:0] address;
        input expected_enable;
        input [7:0] expected;

        begin
            A = address;
            enable = expected_enable;
            #10;

            if (decoder_out === expected) begin
                $display("DECODER PASS: A=%b Y=%b",
                         A, decoder_out);
                passed = passed + 1;
            end
            else begin
                $display("DECODER FAIL: A=%b Expected=%b Actual=%b",
                         A, expected, decoder_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $display("PRIORITY ENCODER AND DECODER TEST");

        // Encoder tests
        check_encoder(8'b00000000, 3'b000, 0);
        check_encoder(8'b00000001, 3'b000, 1);
        check_encoder(8'b00000010, 3'b001, 1);
        check_encoder(8'b00000100, 3'b010, 1);
        check_encoder(8'b00001000, 3'b011, 1);
        check_encoder(8'b00010000, 3'b100, 1);
        check_encoder(8'b00100000, 3'b101, 1);
        check_encoder(8'b01000000, 3'b110, 1);
        check_encoder(8'b10000000, 3'b111, 1);

        // Multiple input tests
        check_encoder(8'b10000011, 3'b111, 1);
        check_encoder(8'b00110000, 3'b101, 1);
        check_encoder(8'b00001100, 3'b011, 1);

        // Decoder tests
        for (i = 0; i < 8; i = i + 1) begin
            check_decoder(i, 1, (8'b00000001 << i));
        end

        // Decoder disabled test
        check_decoder(3'b101, 0, 8'b00000000);

        $display("-----------------------------");
        $display("TOTAL PASSED = %0d", passed);
        $display("TOTAL FAILED = %0d", failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule