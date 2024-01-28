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

    wire [31:0] bitmatrix_step_output_state [15:0]; // TODO: decide wire or reg
    reg [31:0] circulant_step_output_state [15:0]; // TODO: decide wire or reg
    reg [31:0] next_state_output [15:0];

    reg [255:0] const_bit_matrix = 256'h47d7643c321e190fcb50a5a892d4896a84b5458de511755ffd78bebc9f5e8faf;
    reg [4:0] const_coefficients [47:0];

    // initialie the const_coefficients array register
    // Python: a = [0, 2, 4, 0, 13, 22, 0, 4, 19, 0, 3, 14, 0, 27, 31, 0, 3, 8, 0, 17, 26, 0, 3, 12, 0, 18, 22, 0, 12, 18, 0, 4, 7, 0, 4, 31, 0, 12, 27, 0, 7, 17, 0, 7, 8, 0, 1, 13]
    // Python: for idx, val in enumerate(a): print(f"const_coefficients[6'd{idx:02d}] = 5'd{val:02d};")
    assign const_coefficients[6'd00] = 5'd00;
    assign const_coefficients[6'd01] = 5'd02;
    assign const_coefficients[6'd02] = 5'd04;
    assign const_coefficients[6'd03] = 5'd00;
    assign const_coefficients[6'd04] = 5'd13;
    assign const_coefficients[6'd05] = 5'd22;
    assign const_coefficients[6'd06] = 5'd00;
    assign const_coefficients[6'd07] = 5'd04;
    assign const_coefficients[6'd08] = 5'd19;
    assign const_coefficients[6'd09] = 5'd00;
    assign const_coefficients[6'd10] = 5'd03;
    assign const_coefficients[6'd11] = 5'd14;
    assign const_coefficients[6'd12] = 5'd00;
    assign const_coefficients[6'd13] = 5'd27;
    assign const_coefficients[6'd14] = 5'd31;
    assign const_coefficients[6'd15] = 5'd00;
    assign const_coefficients[6'd16] = 5'd03;
    assign const_coefficients[6'd17] = 5'd08;
    assign const_coefficients[6'd18] = 5'd00;
    assign const_coefficients[6'd19] = 5'd17;
    assign const_coefficients[6'd20] = 5'd26;
    assign const_coefficients[6'd21] = 5'd00;
    assign const_coefficients[6'd22] = 5'd03;
    assign const_coefficients[6'd23] = 5'd12;
    assign const_coefficients[6'd24] = 5'd00;
    assign const_coefficients[6'd25] = 5'd18;
    assign const_coefficients[6'd26] = 5'd22;
    assign const_coefficients[6'd27] = 5'd00;
    assign const_coefficients[6'd28] = 5'd12;
    assign const_coefficients[6'd29] = 5'd18;
    assign const_coefficients[6'd30] = 5'd00;
    assign const_coefficients[6'd31] = 5'd04;
    assign const_coefficients[6'd32] = 5'd07;
    assign const_coefficients[6'd33] = 5'd00;
    assign const_coefficients[6'd34] = 5'd04;
    assign const_coefficients[6'd35] = 5'd31;
    assign const_coefficients[6'd36] = 5'd00;
    assign const_coefficients[6'd37] = 5'd12;
    assign const_coefficients[6'd38] = 5'd27;
    assign const_coefficients[6'd39] = 5'd00;
    assign const_coefficients[6'd40] = 5'd07;
    assign const_coefficients[6'd41] = 5'd17;
    assign const_coefficients[6'd42] = 5'd00;
    assign const_coefficients[6'd43] = 5'd07;
    assign const_coefficients[6'd44] = 5'd08;
    assign const_coefficients[6'd45] = 5'd00;
    assign const_coefficients[6'd46] = 5'd01;
    assign const_coefficients[6'd47] = 5'd13;

    
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

    // circulant multiplication stage
    generate
        for (j = 0; j < 16; j++) begin
            byte j_byte = j;
            assign circulant_step_output_state[j] = (
                                (bitmatrix_step_output_state[j])  ^  
                                (bitmatrix_step_output_state[j] << const_coefficients[3*j+1]) ^
                                (bitmatrix_step_output_state[j] >> (32 - const_coefficients[3*j+1])) ^
                                (bitmatrix_step_output_state[j] << const_coefficients[3*j+2]) ^
                                (bitmatrix_step_output_state[j] >> (32 - const_coefficients[3*j+2]))
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

        
        $monitor("Time=%d, circulant_step_output_state[0]=h%h, [1]=h%h, [2]=h%h, ..., [15]=h%h",
            $time,
            circulant_step_output_state[0], circulant_step_output_state[1], circulant_step_output_state[2],
            circulant_step_output_state[15]);
    end

endmodule
