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

    reg [31:0] state [15:0];
    wire [31:0] state_calc_output [15:0];
    reg [5:0] round_num; // must be 0 <= round_num <= 42
    reg eval_output_ready_reg;

    eaglesong_permutation perm(
            .state_input(state),
            .round_num(round_num),

            .state_output(state_calc_output)
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
                        state[i] <= state_calc_output[i];
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
                // state <= state_calc_output; // moved to separate generate block
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
    

    always @(posedge clk) begin
        if (round_num > 6'd42) begin
            $error("In eaglesong_all_permutations, round_num has an invalid value (must be <=42).");
            $finish;
        end
    end



endmodule
