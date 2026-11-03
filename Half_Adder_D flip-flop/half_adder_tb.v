module half_adder_tb;

reg A, B;
wire Sum, Carry;

half_adder uut(
    .A(A),
    .B(B),
    .Sum(Sum),
    .Carry(Carry)
);

initial begin

    A = 0; B = 0;
    #10;

    A = 0; B = 1;
    #10;

    A = 1; B = 0;
    #10;

    A = 1; B = 1;
    #10;

    $finish;

end

endmodule