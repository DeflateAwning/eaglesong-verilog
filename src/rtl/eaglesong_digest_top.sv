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
    reg [31:0] perms_state_output [15:0];

    // Internal Wires
    wire [31:0] absorb_state_input_slice [7:0];
    wire [31:0] absorb_state_out [7:0];
    wire [31:0] perms_state_input [15:0];
    wire perms_eval_output_ready;
    
    // Output Value Storage
    reg [255:0] output_val_reg;
    reg eval_output_ready_reg; // output of this whole block

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
        for (i = 0; i <= 7; i++) begin
            assign absorb_state_input_slice[i] = state[i];
            assign perms_state_input[i] = absorb_state_out[i];
        end
    endgenerate

    // assign perms_state_input[15:8] = 32'h0
    generate
        for (i = 8; i <= 15; i++) begin
            assign perms_state_input[i] = 32'h0;
        end
    endgenerate

    // handle start_eval case: copy state_input to state (for every index)
    generate
        for (i = 0; i < 16; i++) begin
            always_ff @(posedge clk) begin
                if (start_eval == 1'b1) begin
                    // any value works, just needs to be set to something for
                    // input to absorb stage via absorb_state_input_slice
                    state[i] <= 32'h0;

                    // init the output register (probably not necessary)
                    perms_state_output[i] <= 32'h0;
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

            // init/reset the output register (probably not necessary)
            output_val_reg <= 256'h0;
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
        for (j = 0; j < 8; j++) begin // j < rate/32=8
            for (k = 0; k < 4; k++) begin
                always_ff @(posedge clk) begin
                    if (
                        (start_eval == 1'b0) &&
                        (perms_eval_output_ready == 1'b1) &&
                        (absorb_round_num == 8'h1)
                    ) begin
                        // NOTE: runs only once, i=0
                        // uint32_t iratejk_const = i*rate/8 + j*4 + k;
                        // output[iratejk_const] = (state[j] >> (8*k)) & 0xff;

                        // assign in 8-byte chunks (LSB is the j+k part)
                        // output_val_reg[(j << 2) | k +: 8] <= (state[j] >> (k << 3)) & 8'hFF;
                        output_val_reg[((j << 2) | k)*8 +: 8] <= state[j][k << 3 +: 8];
                        
                        // debugging assignment
                        // output_val_reg[((j << 2) | k)*8 +: 8] <= ((j << 2) | k);

                        // For example: 0x12345678
                        // when k = 0, then k<<3 = 0, so (state[j] >> 0) & 0xff = 0x78
                        // when k = 1, then k<<3 = 8, so (state[j] >> 8) & 0xff = 0x56
                        // when k = 2, then k<<3 = 16, so (state[j] >> 16) & 0xff = 0x34
                    end
                end
            end
        end
    endgenerate

    // assign output registers to output wires/ports
    assign output_val = output_val_reg;
    assign eval_output_ready = eval_output_ready_reg;

    initial begin
        $monitor("Time=%d, input_val_store=%h,\ninput_length_bytes_store=%h=%d,\nstate[0,1,14,15]=%h %h ... %h %h,\nstate_absorb_comb_out[0,1,6,7]=%h %h ... %h %h,\nstate_all_perm_input[0,1,14,15] = %h %h ... %h %h,\nperms_start_eval=%h, absorb_round_num=%h,\nperms_eval_output_ready=%h, perms_state_output[0,1,14,15]=%h %h ... %h %h\neval_output_ready=%h, output_val=%h\n",
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
