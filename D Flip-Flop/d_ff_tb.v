module d_ff_tb;

reg D, clk;
wire Q;

d_ff uut(
    .D(D),
    .clk(clk),
    .Q(Q)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    D = 0;
    #10 D = 1;
    #10 D = 0;
    #10 D = 1;
    #10 D = 1;
    #10 $stop;
end

endmodule