`timescale 1ns/1ps
`default_nettype none

module eaglesong_digest_top(
        input clk,

        input [255:0] input_val,
        // must be 1 <= input_length_bytes <= 32, and is the number of bits in the input_val to be used
        input [6:0] input_length_bytes,

        input start_eval,

        output [255:0] output_val,
        output eval_output_ready
    );

    // FSM states enum
    typedef enum logic [2:0] {
        STATE_00_STARTING,
        STATE_10_PERMS1_GOING,
        STATE_20_PERMS1_DONE,
        STATE_30_PERMS2_GOING,
        STATE_40_ALL_DONE} state_enum_t;
    state_enum_t cur_fsm_state;
    state_enum_t next_fsm_state;

    genvar i;
    genvar j;
    genvar k;

    // Input Value Storage
    reg [255:0] input_val_store;
    reg [6:0] input_length_bytes_store;

    // Internal Working Storage
    reg [31:0] state [15:0];
    reg [7:0] absorb_round_num;
    reg perms_start_eval;
    wire [31:0] perms_state_output [15:0];

    // Internal Wires
    wire [31:0] absorb_state_input_slice [7:0];
    wire [31:0] absorb_state_out [7:0];
    wire [31:0] perms_state_input [15:0];
    wire perms_eval_output_ready;

    // Output Value Storage
    reg eval_output_ready_reg;

    eaglesong_absorb_comb absorb( // combinational
            .state_input(absorb_state_input_slice), // absorb_state_input_slice ([7:0]) = state[7:0]
            .input_val(input_val_store),
            .input_length_bytes(input_length_bytes_store),
            .absorb_round_num(absorb_round_num),

            .state_output(absorb_state_out) // [7:0]
        );

    eaglesong_all_permutations perms(
            .clk(clk),
            .state_input(perms_state_input), // perms_state_input = {8x 32'h0, absorb_state_out[7:0]}
            .start_eval(perms_start_eval),

            .state_output(perms_state_output),
            .eval_output_ready(perms_eval_output_ready)
        );

    // assign absorb_state_input_slice[7:0] = state[7:0]
    // assign perms_state_input[7:0] = absorb_state_out[7:0]
    generate
        for (i = 0; i <= 7; i++) begin : gen_assign_0to7
            assign absorb_state_input_slice[i] = state[i];
            assign perms_state_input[i] = absorb_state_out[i];
        end
    endgenerate

    // assign perms_state_input[15:8] = 32'h0
    generate
        for (i = 8; i <= 15; i++) begin : gen_assign_8to15
            assign perms_state_input[i] = 32'h0;
        end
    endgenerate

    // handle: copy perms_state_output to state
    generate
        for (i = 0; i < 16; i++) begin : gen_state_copy
            always_ff @(posedge clk) begin
                if (cur_fsm_state == STATE_20_PERMS1_DONE || cur_fsm_state == STATE_40_ALL_DONE) begin
                    if (perms_eval_output_ready == 1'b1) begin
                        // data's ready, store it
                        state[i] <= perms_state_output[i];
                    end
                end
                else if (cur_fsm_state == STATE_00_STARTING) begin
                    // act as a reset
                    state[i] <= 32'h0;
                end
                // else: keep the current state value
            end
        end
    endgenerate

    // handle start_eval case: non-generate part
    always_ff @(posedge clk) begin
        if (cur_fsm_state == STATE_00_STARTING) begin // triggered by start_eval=1
            eval_output_ready_reg <= 1'b0; // not ready

            // store the inputs
            input_val_store <= input_val;
            input_length_bytes_store <= input_length_bytes;
            // could store input value here if we wanted

            // trigger starting the calculation
            perms_start_eval <= 1'b1;

            absorb_round_num <= 8'd0; // 0th round
        end

        else if (cur_fsm_state == STATE_10_PERMS1_GOING) begin
            if (next_fsm_state == STATE_20_PERMS1_DONE) perms_start_eval <= 1'b1;
            else perms_start_eval <= 1'b0;

            eval_output_ready_reg <= 1'b0; // not ready
            absorb_round_num <= 8'd0; // 0th round
        end

        else if (cur_fsm_state == STATE_20_PERMS1_DONE) begin
            perms_start_eval <= 1'b1;

            eval_output_ready_reg <= 1'b0; // not ready
            absorb_round_num <= 8'd1; // next round
        end

        else if (cur_fsm_state == STATE_30_PERMS2_GOING) begin
            if (next_fsm_state == STATE_40_ALL_DONE) perms_start_eval <= 1'b1;
            else perms_start_eval <= 1'b0;

            eval_output_ready_reg <= 1'b0; // not ready
            absorb_round_num <= 8'd1; // next round
        end

        else if (cur_fsm_state == STATE_40_ALL_DONE) begin
            eval_output_ready_reg <= 1'b1; // FINALLY READY!
            absorb_round_num <= 8'd1; // next round
        end
    end

    // assign the state-to-output_val squeeze conversion
    generate
        for (j = 0; j < 8; j++) begin : gen_state_to_output_calc_j // j < rate/32=8
            for (k = 0; k < 4; k++) begin : gen_state_to_output_calc_k
                assign output_val[((j << 2) | k)*8 +: 8] = state[j][k << 3 +: 8];
            end
        end
    endgenerate

    // assign output registers to output wires/ports
    assign eval_output_ready = eval_output_ready_reg;

    // clocked next state transition
    always_ff @(posedge clk) begin
        if (start_eval == 1'b1) begin
            cur_fsm_state <= STATE_00_STARTING;
        end
        else begin
            cur_fsm_state <= next_fsm_state;
        end
    end

    // next state logic
    always_comb begin : next_fsm_state_logic
        case (cur_fsm_state)
            STATE_00_STARTING:
                // always move on
                next_fsm_state = STATE_10_PERMS1_GOING;

            STATE_10_PERMS1_GOING: begin
                if (perms_eval_output_ready == 1'b1) begin
                    next_fsm_state = STATE_20_PERMS1_DONE;
                end
                else begin
                    next_fsm_state = STATE_10_PERMS1_GOING; // stay
                end
            end

            STATE_20_PERMS1_DONE: begin
                if (input_length_bytes_store == 32) begin
                    next_fsm_state = STATE_30_PERMS2_GOING;
                end
                else begin
                    next_fsm_state = STATE_40_ALL_DONE;
                end
            end

            STATE_30_PERMS2_GOING: begin
                if (perms_eval_output_ready == 1'b1) begin
                    next_fsm_state = STATE_40_ALL_DONE;
                end
                else begin
                    next_fsm_state = STATE_30_PERMS2_GOING; // stay
                end
            end

            // STATE_40_ALL_DONE: <stay in current state>
            default: next_fsm_state = cur_fsm_state; // default: stay in current state
        endcase
    end : next_fsm_state_logic

    // initial begin
    //     $monitor("Time=%5d, fsm=%2d (->%2d),\ninput_val_store=%h,\ninput_length_bytes_store=%h=%d,\nstate[0,1,14,15]=%h %h ... %h %h,\nabsorb_state_out[0,1,6,7]=%h %h ... %h %h,\nperms_state_input[0,1,14,15] = %h %h ... %h %h,\nperms_start_eval=%h, absorb_round_num=%h,\nperms_eval_output_ready=%h, perms_state_output[0,1,14,15]=%h %h ... %h %h\neval_output_ready=%h, output_val=%h\n",
    //         $time, cur_fsm_state, next_fsm_state, input_val_store, input_length_bytes_store, input_length_bytes_store,
    //         state[0], state[1], state[14], state[15],
    //         absorb_state_out[0], absorb_state_out[1], absorb_state_out[6], absorb_state_out[7],
    //         perms_state_input[0], perms_state_input[1], perms_state_input[14], perms_state_input[15],
    //         perms_start_eval, absorb_round_num,
    //         perms_eval_output_ready, perms_state_output[0], perms_state_output[1], perms_state_output[14], perms_state_output[15],
    //         eval_output_ready,
    //         output_val
    //     );
    // end

endmodule
