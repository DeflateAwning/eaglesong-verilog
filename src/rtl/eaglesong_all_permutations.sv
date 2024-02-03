`timescale 1ns/1ps

module eaglesong_all_permutations(
        input clk,
        // TODO: decide if we need a reset for anything

        input [31:0] state_input [15:0],
        input start_eval,

        output [31:0] state_output [15:0],
        output eval_output_ready
    );

    genvar i;

    reg [31:0] state_input_store [15:0];
    reg [31:0] state [15:0];
    wire [31:0] perm_state_output [15:0];
    reg [5:0] round_num; // must be 0 <= round_num <= 42
    reg eval_output_ready_reg;

    eaglesong_permutation perm( // combinational
            .state_input(state),
            .round_num(round_num),

            .state_output(perm_state_output)
        );

    // handle start_eval case: copy state_input to state (for every index)
    generate
        for (i = 0; i < 16; i++) begin
            always_ff @(posedge clk) begin // TODO: figure out what always_latch means, and maybe this should be always_latch
                if (start_eval == 1'b1) begin
                    state[i] <= state_input[i];
                end
                else if (start_eval == 1'b0) begin
                    if (eval_output_ready_reg == 1'b0) begin // if not yet complete
                        // if we're not through every round, then copy this round's data to state
                        state[i] <= perm_state_output[i];
                    end
                end
            end
        end
    endgenerate

    // handle start_eval case: non-generate part
    always_ff @(posedge clk) begin
        if (start_eval == 1'b1) begin
            eval_output_ready_reg <= 1'b0; // not ready
            round_num <= 6'b0; // 0th round
        end

        else if (start_eval == 1'b0) begin
            // handle each clock by incrementing the round_num and setting eval_output_ready_reg
            if (eval_output_ready_reg == 1'b0) begin
                // state <= perm_state_output; // moved to separate generate block
                if (round_num <= 6'd41) begin
                    eval_output_ready_reg <= 1'b0; // mark as output not ready
                    round_num <= round_num + 1;
                end
                else if (round_num == 6'd42) begin
                    eval_output_ready_reg <= 1'b1; // mark as output ready
                end
            end
        end
    end

    // assign output registers to output wires/ports
    generate
        for (i = 0; i < 16; i++) begin
            assign state_output[i] = state[i];
        end
    endgenerate
    assign eval_output_ready = eval_output_ready_reg;
    
    // Error check, just for fun
    always @(posedge clk) begin
        if (round_num > 6'd42) begin
            $error("In eaglesong_all_permutations, round_num has an invalid value (must be <=42).");
            $finish;
        end
    end

    initial begin
        $monitor("Time=%d, state_input[0,1,14,15]=%h %h ... %h %h, round_num=%d, eval_output_ready_reg=%d,\nstate=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
            $time,
            state_input[0], state_input[1], state_input[14], state_input[15],
            round_num, eval_output_ready_reg,
            state[0], state[1], state[2], state[3],
            state[4], state[5], state[6], state[7],
            state[8], state[9], state[10], state[11],
            state[12], state[13], state[14], state[15]
        );
    end

endmodule
