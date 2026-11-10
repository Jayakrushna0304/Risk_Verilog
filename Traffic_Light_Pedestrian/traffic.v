module traffic #(
    parameter GREEN_TIME = 10,
    parameter YELLOW_TIME = 3,
    parameter RED_TIME = 5,
    parameter WALK_TIME = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire ped_req,
    output reg  car_red,
    output reg  car_yellow,
    output reg  car_green,
    output reg  walk
);

    localparam GREEN     = 2'b00;
    localparam YELLOW    = 2'b01;
    localparam RED_WALK  = 2'b10;
    localparam RED       = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [31:0] timer;
    reg ped_pending;

    // Remember a pedestrian request until it is served.
    always @(posedge clk or posedge reset) begin
        if (reset)
            ped_pending <= 1'b0;
        else if (state == RED_WALK)
            ped_pending <= 1'b0;
        else if (ped_req)
            ped_pending <= 1'b1;
    end

    // State timer and state register.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= GREEN;
            timer <= 0;
        end else begin
            if (timer == 0) begin
                // Load the duration for the state we are entering.
                state <= next_state;
                case (next_state)
                    GREEN:    timer <= GREEN_TIME - 1;
                    YELLOW:   timer <= YELLOW_TIME - 1;
                    RED_WALK: timer <= WALK_TIME - 1;
                    RED:      timer <= RED_TIME - 1;
                    default:  timer <= GREEN_TIME - 1;
                endcase
            end else begin
                timer <= timer - 1;
            end
        end
    end

    // Choose the next state when the current state's timer expires.
    always @(*) begin
        next_state = state;
        case (state)
            GREEN: begin
                next_state = YELLOW;
            end
            YELLOW: begin
                if (ped_pending || ped_req)
                    next_state = RED_WALK;
                else
                    next_state = RED;
            end
            RED_WALK: begin
                next_state = RED;
            end
            RED: begin
                next_state = GREEN;
            end
            default: next_state = GREEN;
        endcase
    end

    // Active-high traffic light and pedestrian walk outputs.
    always @(*) begin
        car_red    = 1'b0;
        car_yellow = 1'b0;
        car_green  = 1'b0;
        walk       = 1'b0;

        case (state)
            GREEN: begin
                car_green = 1'b1;
            end
            YELLOW: begin
                car_yellow = 1'b1;
            end
            RED_WALK: begin
                car_red = 1'b1;
                walk = 1'b1;
            end
            RED: begin
                car_red = 1'b1;
            end
            default: begin
                car_red = 1'b1;
            end
        endcase
    end

endmodule
