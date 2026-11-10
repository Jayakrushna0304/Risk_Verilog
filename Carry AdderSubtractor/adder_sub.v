module adder_sub (
    input [7:0] A,
    input [7:0] B,
    input mode,
    output [7:0] Result,
    output Carry,
    output Overflow
);

    wire [7:0] B_modified;
    wire [8:0] carry;

    assign B_modified = B ^ {8{mode}};
    assign carry[0] = mode;

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : ADDER
            full_adder FA (
                .a(A[i]),
                .b(B_modified[i]),
                .cin(carry[i]),
                .sum(Result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign Carry = carry[8];
    assign Overflow = carry[7] ^ carry[8];

endmodule