module elevator #(
    parameter DOOR_TIME_CYCLES = 150000000
)(
    input clk,
    input reset,
    input emergency,
    input [2:0] floor_request,

    output reg [2:0] current_floor,
    output reg motor_up,
    output reg motor_down,
    output reg door_open
);

parameter IDLE = 2'b00,
          UP   = 2'b01,
          DOWN = 2'b10,
          DOOR = 2'b11;

reg [1:0] state;
reg [2:0] target_floor;
reg [27:0] door_timer;

// Elevator movement and control
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        current_floor <= 1;
        target_floor <= 1;
        state <= IDLE;
        door_timer <= 0;
    end

    else if (emergency)
    begin
        state <= IDLE;
        door_timer <= 0;
    end

    else
    begin
        case (state)

            IDLE:
            begin
                if (floor_request >= 1 && floor_request <= 4)
                begin
                    target_floor <= floor_request;

                    if (floor_request > current_floor)
                        state <= UP;

                    else if (floor_request < current_floor)
                        state <= DOWN;

                    else
                    begin
                        state <= DOOR;
                        door_timer <= DOOR_TIME_CYCLES;
                    end
                end
            end

            UP:
            begin
                if (current_floor < target_floor)
                begin
                    current_floor <= current_floor + 1;

                    if (current_floor + 1 >= target_floor)
                    begin
                        state <= DOOR;
                        door_timer <= DOOR_TIME_CYCLES;
                    end
                end
            end

            DOWN:
            begin
                if (current_floor > target_floor)
                begin
                    current_floor <= current_floor - 1;

                    if (current_floor - 1 <= target_floor)
                    begin
                        state <= DOOR;
                        door_timer <= DOOR_TIME_CYCLES;
                    end
                end
            end

            DOOR:
            begin
                if (door_timer > 0)
                    door_timer <= door_timer - 1;
                else
                    state <= IDLE;
            end

            default:
            begin
                state <= IDLE;
                door_timer <= 0;
            end

        endcase
    end
end

// Output control
always @(*)
begin
    motor_up = 0;
    motor_down = 0;
    door_open = 0;

    if (!emergency)
    begin
        case (state)

            UP:
                motor_up = 1;

            DOWN:
                motor_down = 1;

            DOOR:
                door_open = 1;

            default:
            begin
                motor_up = 0;
                motor_down = 0;
                door_open = 0;
            end

        endcase
    end
end

endmodule