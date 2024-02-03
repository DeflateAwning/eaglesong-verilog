`timescale 1ns/1ps

module eaglesong_digest_top(
        input clk,

        input [255:0] input_val,
        // must be 1 <= input_length_bytes <= 32, and is the number of bits in the input_val to be used
        input [6:0] input_length_bytes,

        input start_eval,

        output [255:0] output_val,
        output eval_output_ready
    );


    // Control FSM state names.
    localparam FSM_STATE_INIT        = 3'h0;
    localparam FSM_STATE_ALL_PERMS_0 = 3'h1; // "first" time through the "all perms" block
    localparam FSM_STATE_ALL_PERMS_1 = 3'h2; // "final" time through the "all perms" block (max 2 times)
    // TODO: add squeeze state/block, probably
    localparam FSM_STATE_FINISH      = 3'h5;
    // FIXME: remove FSM probably

    genvar i;
    genvar j;
    genvar k;

    reg [2:0] fsm_state; // FIXME: either use the FSM, or remove it
    reg eval_output_ready_reg; // output of this whole block

    reg [255:0] input_val_store;
    reg [6:0] input_length_bytes_store;
    reg [31:0] state [15:0];
    wire [31:0] absorb_state_input_slice [7:0];
    wire [31:0] state_absorb_comb_out [7:0];
    wire [31:0] state_all_perm_input [15:0];
    reg [7:0] absorb_round_num;
    reg start_eval_all_perms;
    reg [31:0] state_calc_output [15:0];
    wire perms_eval_output_ready;
    reg [255:0] output_val_reg;

    // FSM_STATE_ALL_PERMS_0:
        // * init state as all zeros
        // * absorb.state_input <= state
        // * all_perm.state_input <= absorb.state_output (state_absorb_comb_out)
        // * absorb_round_num <= 8'b0;
        // When ready, then state <= state_calc_output

    // FSM_STATE_ALL_PERMS_1:
        // * absorb.state_input <= state
        // * all_perm.state_input <= absorb.state_output (state_absorb_comb_out)
        // * absorb_round_num <= 8'b0;
        // When ready, then state <= state_calc_output

    eaglesong_absorb_comb absorb(
            .state_input(absorb_state_input_slice), // absorb_state_input_slice ([7:0]) = state[7:0]
            .input_val(input_val_store),
            .input_length_bytes(input_length_bytes_store),
            .absorb_round_num(absorb_round_num),

            .state_output(state_absorb_comb_out) // [7:0]
        );

    eaglesong_all_permutations all_perm(
            .clk(clk),
            .state_input(state_all_perm_input), // state_all_perm_input = {8x 32'h0, state_absorb_comb_out[7:0]}
            .start_eval(start_eval_all_perms),

            .state_output(state_calc_output),
            .eval_output_ready(perms_eval_output_ready)
        );

    // assign absorb_state_input_slice[7:0] = state[7:0]
    // assign state_all_perm_input[7:0] = state_absorb_comb_out[7:0]
    generate
        for (i = 0; i <= 7; i++) begin
            assign absorb_state_input_slice[i] = state[i];
            assign state_all_perm_input[i] = state_absorb_comb_out[i];
        end
    endgenerate

    // assign state_absorb_comb_out[15:8] = 32'h0
    // assign state_all_perm_input[15:8] = 32'h0
    generate
        for (i = 8; i <= 15; i++) begin
            // assign state_absorb_comb_out[i] = 32'h0; // FIXME: check this, update comment above
            assign state_all_perm_input[i] = 32'h0;
        end
    endgenerate

    // handle start_eval case: copy state_input to state (for every index)
    generate
        for (i = 0; i < 16; i++) begin
            // TODO: figure out what always_latch means, and maybe this should be always_latch
            always_ff @(posedge clk) begin
                if (start_eval == 1'b1) begin
                    state[i] <= 32'h0; // any value works, just needs to be set to something
                end
                else if (start_eval == 1'b0) begin
                    if (perms_eval_output_ready == 1'b1) begin
                        // data's ready, store it
                        state[i] <= state_calc_output[i];
                    end
                end
            end
        end
    endgenerate

    // handle start_eval case: non-generate part
    always_ff @(posedge clk) begin
        if (start_eval == 1'b1) begin
            fsm_state <= FSM_STATE_INIT;

            absorb_round_num <= 8'b0;
            eval_output_ready_reg <= 1'b0; // not ready

            // store the inputs
            input_val_store <= input_val;
            input_length_bytes_store <= input_length_bytes;
            // could store input value here if we wanted
        end
        
        else if (start_eval == 1'b0) begin
            if ((eval_output_ready_reg == 1'b0) && (perms_eval_output_ready == 1'b1)) begin
                // NOT start_eval && block's output not set to ready yet && current perms block is done
                if (absorb_round_num == 8'h0) begin
                    eval_output_ready_reg <= 1'b0; // mark as output not ready
                    absorb_round_num <= absorb_round_num + 1;
                end
                else begin
                    // final output is ready
                    eval_output_ready_reg <= 1'b1; // mark as output ready
                end
            end
        end
    end

    // assign output registers to output wires/ports
    assign output_val = output_val_reg;
    assign eval_output_ready = eval_output_ready_reg;

    // assign the state-to-output_val squeeze conversion
    generate
        for (j = 0; j < 8; j++) begin // j < rate/32=8
            for (k = 0; k < 4; k++) begin
                always_ff @(posedge clk) begin
                    if (
                        (start_eval == 1'b0) &&
                        (eval_output_ready_reg == 1'b0) && (perms_eval_output_ready == 1'b1) &&
                        (absorb_round_num != 8'h1)
                    ) begin
                        // NOTE: runs only once, i=0
                        // uint32_t iratejk_const = i*rate/8 + j*4 + k;
                        // output[iratejk_const] = (state[j] >> (8*k)) & 0xff;

                        // assign in 8-byte chunks (LSB is the j+k part)
                        output_val_reg[(j << 2) | k +: 8] <= (state[j] >> (k << 3)) & 8'hFF;
                    end
                end
            end
        end
    endgenerate

endmodule
