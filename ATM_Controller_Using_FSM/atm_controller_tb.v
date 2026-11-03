`timescale 1ns/1ps

module atm_controller_tb;

reg clk;
reg reset;
reg card_insert;
reg [15:0] pin_entered;
reg pin_submit;
reg [1:0] txn_select;
reg [15:0] amount;
reg txn_start;

wire [3:0] state;
wire [15:0] balance;
wire [15:0] balance_display;
wire cash_dispense;
wire card_eject;
wire pin_error;
wire insufficient_funds;
wire transaction_success;

// Connect ATM design
atm_controller uut(
    .clk(clk),
    .reset(reset),
    .card_insert(card_insert),
    .pin_entered(pin_entered),
    .pin_submit(pin_submit),
    .txn_select(txn_select),
    .amount(amount),
    .txn_start(txn_start),
    .state(state),
    .balance(balance),
    .balance_display(balance_display),
    .cash_dispense(cash_dispense),
    .card_eject(card_eject),
    .pin_error(pin_error),
    .insufficient_funds(insufficient_funds),
    .transaction_success(transaction_success)
);

// Clock generation
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Insert card task
task insert_card;
begin
    @(negedge clk);
    card_insert = 1;
    @(negedge clk);
    card_insert = 0;
end
endtask

// Enter PIN task
task enter_pin;
input [15:0] p;
begin
    @(negedge clk);
    pin_entered = p;
    pin_submit = 1;
    @(negedge clk);
    pin_submit = 0;
end
endtask

// Transaction task
task make_transaction;
input [1:0] selection;
input [15:0] money;
begin
    @(negedge clk);
    txn_select = selection;
    amount = money;
    txn_start = 1;
    @(negedge clk);
    txn_start = 0;
end
endtask

// Test cases
initial
begin
    reset = 1;
    card_insert = 0;
    pin_entered = 0;
    pin_submit = 0;
    txn_select = 0;
    amount = 0;
    txn_start = 0;

    #12 reset = 0;

    // TEST 1: Withdraw Rs.1000
    insert_card();
    enter_pin(1234);
    wait(state == 4'b0011);

    make_transaction(2'b01, 1000);
    wait(state == 4'b0000);

    #20;

    // TEST 2: Check balance
    insert_card();
    enter_pin(1234);
    wait(state == 4'b0011);

    make_transaction(2'b10, 0);
    wait(state == 4'b0000);

    #20;

    // TEST 3: Deposit Rs.500
    insert_card();
    enter_pin(1234);
    wait(state == 4'b0011);

    make_transaction(2'b11, 500);
    wait(state == 4'b0000);

    #20;

    // TEST 4: Three incorrect PIN attempts
    insert_card();

    enter_pin(1111);
    wait(state == 4'b0001);

    enter_pin(2222);
    wait(state == 4'b0001);

    enter_pin(3333);
    wait(state == 4'b1000);

    #30;

    $display("ATM SIMULATION COMPLETED");
    $finish;
end

// Display results
initial
begin
    $monitor(
        "Time=%0t State=%b Balance=%d Cash=%b CardEject=%b PIN_Error=%b Insufficient=%b Success=%b",
        $time,
        state,
        balance,
        cash_dispense,
        card_eject,
        pin_error,
        insufficient_funds,
        transaction_success
    );
end

endmodule