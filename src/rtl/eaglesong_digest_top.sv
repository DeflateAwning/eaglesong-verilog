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

    // Pseudo-FSM Plan, roughly:
    // FSM_STATE_ALL_PERMS_0:
        // * init state as all zeros
        // * absorb.state_input <= state
        // * perms.state_input <= absorb.state_output (absorb_state_out)
        // * absorb_round_num <= 8'b0;
        // When ready, then state <= perms_state_output
    // FSM_STATE_ALL_PERMS_1:
        // * absorb.state_input <= state
        // * perms.state_input <= absorb.state_output (absorb_state_out)
        // * absorb_round_num <= 8'b0;
        // When ready, then state <= perms_state_output

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

    // handle start_eval case: copy state_input to state (for every index)
    generate
        for (i = 0; i < 16; i++) begin : gen_state_copy
            always_ff @(posedge clk) begin
                if (start_eval == 1'b1) begin
                    // any value works, just needs to be set to something for
                    // input to absorb stage via absorb_state_input_slice
                    state[i] <= 32'h0;

                    // init the output register (probably not necessary)
                    // perms_state_output[i] <= 32'h0;
                end
                else if (start_eval == 1'b0) begin
                    if (perms_eval_output_ready == 1'b1) begin
                        // data's ready, store it
                        state[i] <= perms_state_output[i];
                    end
                end
            end
        end
    endgenerate

    // handle start_eval case: non-generate part
    always_ff @(posedge clk) begin
        if (start_eval == 1'b1) begin
            absorb_round_num <= 8'b0;
            eval_output_ready_reg <= 1'b0; // not ready

            // store the inputs
            input_val_store <= input_val;
            input_length_bytes_store <= input_length_bytes;
            // could store input value here if we wanted

            // trigger starting the calculation
            perms_start_eval <= 1'b1;
        end

        else if (start_eval == 1'b0) begin
            perms_start_eval <= 1'b0;

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

    initial begin
        $monitor("Time=%d, input_val_store=%h,\ninput_length_bytes_store=%h=%d,\nstate[0,1,14,15]=%h %h ... %h %h,\nabsorb_state_out[0,1,6,7]=%h %h ... %h %h,\nperms_state_input[0,1,14,15] = %h %h ... %h %h,\nperms_start_eval=%h, absorb_round_num=%h,\nperms_eval_output_ready=%h, perms_state_output[0,1,14,15]=%h %h ... %h %h\neval_output_ready=%h, output_val=%h\n",
            $time, input_val_store, input_length_bytes_store, input_length_bytes_store,
            state[0], state[1], state[14], state[15],
            absorb_state_out[0], absorb_state_out[1], absorb_state_out[6], absorb_state_out[7],
            perms_state_input[0], perms_state_input[1], perms_state_input[14], perms_state_input[15],
            perms_start_eval, absorb_round_num,
            perms_eval_output_ready, perms_state_output[0], perms_state_output[1], perms_state_output[14], perms_state_output[15],
            eval_output_ready,
            output_val
        );
    end

endmodule
