module atm_controller(
    input clk,
    input reset,

    input card_insert,
    input [15:0] pin_entered,
    input pin_submit,

    input [1:0] txn_select,
    input [15:0] amount,
    input txn_start,

    output reg [3:0] state,
    output reg [15:0] balance,
    output reg [15:0] balance_display,

    output reg cash_dispense,
    output reg card_eject,
    output reg pin_error,
    output reg insufficient_funds,
    output reg transaction_success
);

// FSM states
parameter IDLE      = 4'b0000,
          PIN_ENTRY = 4'b0001,
          VERIFY    = 4'b0010,
          MENU      = 4'b0011,
          WITHDRAW  = 4'b0100,
          DEPOSIT   = 4'b0101,
          BALANCE   = 4'b0110,
          EJECT     = 4'b0111,
          LOCKED    = 4'b1000;

// ATM settings
parameter CORRECT_PIN = 16'd1234;

reg [15:0] entered_pin;
reg [15:0] transaction_amount;
reg [1:0] selected_transaction;
reg [1:0] attempts;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        state <= IDLE;
        balance <= 16'd5000;
        balance_display <= 0;
        entered_pin <= 0;
        transaction_amount <= 0;
        selected_transaction <= 0;
        attempts <= 0;

        cash_dispense <= 0;
        card_eject <= 0;
        pin_error <= 0;
        insufficient_funds <= 0;
        transaction_success <= 0;
    end

    else
    begin

        // Default pulse outputs
        cash_dispense <= 0;
        card_eject <= 0;
        pin_error <= 0;
        insufficient_funds <= 0;
        transaction_success <= 0;

        case (state)

            // Wait for ATM card
            IDLE:
            begin
                if (card_insert)
                    state <= PIN_ENTRY;
            end

            // Enter PIN
            PIN_ENTRY:
            begin
                if (pin_submit)
                begin
                    entered_pin <= pin_entered;
                    state <= VERIFY;
                end
            end

            // Verify PIN
            VERIFY:
            begin
                if (entered_pin == CORRECT_PIN)
                begin
                    attempts <= 0;
                    state <= MENU;
                end
                else
                begin
                    pin_error <= 1;
                    attempts <= attempts + 1;

                    if (attempts == 2)
                        state <= LOCKED;
                    else
                        state <= PIN_ENTRY;
                end
            end

            // Select transaction
            MENU:
            begin
                if (txn_start)
                begin
                    selected_transaction <= txn_select;
                    transaction_amount <= amount;

                    case (txn_select)

                        2'b01:
                            state <= WITHDRAW;

                        2'b10:
                            state <= BALANCE;

                        2'b11:
                            state <= DEPOSIT;

                        default:
                            state <= MENU;

                    endcase
                end
            end

            // Withdraw money
            WITHDRAW:
            begin
                if (transaction_amount > 0 &&
                    transaction_amount <= balance)
                begin
                    balance <= balance - transaction_amount;
                    cash_dispense <= 1;
                    transaction_success <= 1;
                end
                else
                begin
                    insufficient_funds <= 1;
                end

                state <= EJECT;
            end

            // Deposit money
            DEPOSIT:
            begin
                if (transaction_amount > 0)
                begin
                    balance <= balance + transaction_amount;
                    transaction_success <= 1;
                end

                state <= EJECT;
            end

            // Check balance
            BALANCE:
            begin
                balance_display <= balance;
                transaction_success <= 1;
                state <= EJECT;
            end

            // Return ATM card
            EJECT:
            begin
                card_eject <= 1;
                state <= IDLE;
            end

            // Three incorrect PIN attempts
            LOCKED:
            begin
                card_eject <= 1;
                state <= LOCKED;
            end

            default:
                state <= IDLE;

        endcase
    end
end

endmodule