`timescale 1ns/1ps

module eaglesong_permutation(
        input [31:0] state_input [15:0],
        input start_eval,

        output [31:0] state_output [15:0],
        output eval_output_ready
    );

    genvar i;
    genvar j;

    reg [31:0] state_input_store [15:0];

    reg [31:0] bitmatrix_step_output_state [15:0]; // TODO: decide wire or reg
    reg [31:0] next_state_output [15:0];

    reg [255:0] const_bit_matrix = 256'h47d7643c321e190fcb50a5a892d4896a84b5458de511755ffd78bebc9f5e8faf;

    // store the input to a register
    generate // TODO: replace with single assignment statement, when supported by iverilog
        for (i = 0; i < 16; i=i+1) begin
            always_ff @(posedge start_eval) begin
                state_input_store[i] <= state_input[i];
            end
        end
    endgenerate

    // assign the bit_matrix stage (combinationally)
    generate
        for (j = 0; j < 16; j=j+1) begin // j = matrix column number
            byte j_byte = j;
            assign bitmatrix_step_output_state[j] = (
                    (( {32{const_bit_matrix[8'h00 | j_byte]}}) & state_input_store[4'h0]) ^
                    (( {32{const_bit_matrix[8'h10 | j_byte]}}) & state_input_store[4'h1]) ^
                    (( {32{const_bit_matrix[8'h20 | j_byte]}}) & state_input_store[4'h2]) ^
                    (( {32{const_bit_matrix[8'h30 | j_byte]}}) & state_input_store[4'h3]) ^
                    (( {32{const_bit_matrix[8'h40 | j_byte]}}) & state_input_store[4'h4]) ^
                    (( {32{const_bit_matrix[8'h50 | j_byte]}}) & state_input_store[4'h5]) ^
                    (( {32{const_bit_matrix[8'h60 | j_byte]}}) & state_input_store[4'h6]) ^
                    (( {32{const_bit_matrix[8'h70 | j_byte]}}) & state_input_store[4'h7]) ^
                    (( {32{const_bit_matrix[8'h80 | j_byte]}}) & state_input_store[4'h8]) ^
                    (( {32{const_bit_matrix[8'h90 | j_byte]}}) & state_input_store[4'h9]) ^
                    (( {32{const_bit_matrix[8'hA0 | j_byte]}}) & state_input_store[4'hA]) ^
                    (( {32{const_bit_matrix[8'hB0 | j_byte]}}) & state_input_store[4'hB]) ^
                    (( {32{const_bit_matrix[8'hC0 | j_byte]}}) & state_input_store[4'hC]) ^
                    (( {32{const_bit_matrix[8'hD0 | j_byte]}}) & state_input_store[4'hD]) ^
                    (( {32{const_bit_matrix[8'hE0 | j_byte]}}) & state_input_store[4'hE]) ^
                    (( {32{const_bit_matrix[8'hF0 | j_byte]}}) & state_input_store[4'hF])
                );
        end
    endgenerate
    


    generate
        // TEMP DEBUG: copy bitmatrix_step_output_state right to the output
        // TODO: replace this with the rest of the comb/seq logic to make this work well
        for (i = 0; i < 16; i=i+1) begin
            assign next_state_output[i] = bitmatrix_step_output_state[i];
        end
    endgenerate



    // copy next_state_output to state_output
    generate // TODO: replace with single assignment statement, when supported by iverilog
        for (i = 0; i < 16; i=i+1) begin
            assign state_output[i] = next_state_output[i];
        end
    endgenerate

    initial begin
        $monitor("Time=%d, bitmatrix_step_output_state[0]=h%h, [1]=h%h, [2]=h%h, ..., [15]=h%h",
            $time,
            bitmatrix_step_output_state[0], bitmatrix_step_output_state[1], bitmatrix_step_output_state[2],
            bitmatrix_step_output_state[15]);
    end

endmodule
