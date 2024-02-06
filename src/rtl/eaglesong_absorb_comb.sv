`timescale 1ns/1ps

module eaglesong_absorb_comb(
        // NOTE: state[15:8] not used/modified, and thus aren't passed

        // state_input is ignored when absorb_round_num == 0 (but cannot be bx),
        // and then the output of the previous round for the next one
        input [31:0] state_input [7:0],
        input [255:0] input_val,

        // must be 1 <= input_length_bytes <= 32, and is the number of bits in the input_val to be used
        input [6:0] input_length_bytes,

        input [7:0] absorb_round_num, // TODO: realistically is only 0 or 1 with our input_length_bytes restriction to 32 bytes
        
        // only the lower 8 elements are modified in this block
        output [31:0] state_output [7:0]
    );

    // calculates the state values from the input, going into the absorb permutation rounds

    genvar i;
    genvar j; // j = the state index, and is 0 <= j <= 7
    genvar k; // loop through 0,1,2,3

    // if we turn this pipelined, these stores can be registers
    wire [31:0] state_input_store [7:0];
    wire [255:0] input_val_store;
    wire [6:0] input_length_bytes_store;
    wire [7:0] absorb_round_num_store;
    wire [31:0] next_state_output [7:0];

    // intermediates for every loop level:
    // k_max * j_max array elements (each element is at index: [j << 2 | k] )
    wire [5:0] iratejk_const [31:0]; // 6-bit, 4 array elements (each element is at a k)
    // 32-bit Uint
    /* verilator lint_off UNOPTFLAT */
    wire [31:0] absorb_state_modifier [31:0];
    /* verilator lint_on UNOPTFLAT */
    // TODO: fix linting/simulation error via: https://verilator.org/guide/latest/warnings.html#cmdoption-arg-UNOPTFLAT

    // assign inputs to internal wire/reg (in the future, store the input to a register)
    assign input_val_store = input_val;
    assign input_length_bytes_store = input_length_bytes;
    assign absorb_round_num_store = absorb_round_num;
    generate
        for (i = 0; i < 8; i++) begin
            assign state_input_store[i][31:0] = state_input[i][31:0];
        end
    endgenerate
    
    generate
        for (j = 0; j < 8; j++) begin // rate/32 = 256/32 = 8
            for (k = 0; k < 4; k++) begin // k=0,1,2,3
                // const uint32_t iratejk_const = {absorb_round_num[0], j[2:0], k[1:0]  } = (absorb_round_num << 5) | (j << 2) | k;
                
                // assign iratejk_const[j << 2 | k] = (absorb_round_num_store << 5) | (j << 2) | k;
                assign iratejk_const[j << 2 | k][5:0] = {absorb_round_num_store[0], j[2:0], k[1:0]};

                if (k == 0) begin
                    //// SYNTAX TYPE 1 ////
                    // if ( {1'b0, iratejk_const[j << 2 | k][5:0]} < input_length_bytes_store[6:0] )
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = input_val_store[iratejk_const[j << 2 | k][5:0]];
                    // else if( {1'b0, iratejk_const[j << 2 | k][5:0]} == input_length_bytes_store[6:0] )
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = delimiter;
                    // else
                    //     // no change, use the 0 value
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = 32'h0;

                    ///// SYNTAX TYPE 2 /////
                    assign absorb_state_modifier[(j << 2) | k][31:0] = (
                                ({1'b0, iratejk_const[j << 2 | k][5:0]} < input_length_bytes_store[6:0]) ?
                                    {
                                        24'h0,
                                        input_val_store[iratejk_const[j << 2 | k][5:0]*8 +: 8]
                                    } : (
                                        ({1'b0, iratejk_const[j << 2 | k][5:0]} == input_length_bytes_store[6:0]) ?
                                            32'h06 : 32'h0
                                    )
                            );

                    ///// TESTING ///////
                    // assign absorb_state_modifier[(j << 2) | k][31:0] = 32'h0;

                    // NOTE: we can update the C model to match this better if we want
                end
                else begin
                    //// SYNTAX TYPE 1 ////
                    // if ( {1'b0, iratejk_const[j << 2 | k][5:0]} < input_length_bytes_store[6:0] )
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = (absorb_state_modifier[(j << 2) | (k - 1)] << 8) ^ input_val_store[iratejk_const[j << 2 | k][5:0]];
                    // else if( {1'b0, iratejk_const[j << 2 | k][5:0]} == input_length_bytes_store[6:0] )
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = (absorb_state_modifier[(j << 2) | (k - 1)] << 8) ^ delimiter;
                    // else
                    //     // no change, use the same value as the previous
                    //     assign absorb_state_modifier[(j << 2) | k][31:0] = absorb_state_modifier[(j << 2) | (k - 1)];

                    //// SYNTAX TYPE 2 ////
                    assign absorb_state_modifier[(j << 2) | k][31:0] = (
                                ({1'b0, iratejk_const[j << 2 | k][5:0]} < input_length_bytes_store[6:0]) ? 
                                    
                                    // ex2 = ex1[sel*4 +:4]; // vector[LSB+:width]
                                    {
                                        absorb_state_modifier[(j << 2) | (k - 1)][23:0],
                                        input_val_store[iratejk_const[j << 2 | k][5:0]*8 +: 8]
                                    } : (
                                        ({1'b0, iratejk_const[j << 2 | k][5:0]} == input_length_bytes_store[6:0]) ? 
                                            {absorb_state_modifier[(j << 2) | (k - 1)][23:0], 8'h06} : // 8'h06 is the delim
                                            absorb_state_modifier[(j << 2) | (k - 1)]
                                    )
                            );

                    //// Testing ////
                    // assign absorb_state_modifier[(j << 2) | k][31:0] = 
                    //     {absorb_state_modifier[(j << 2) | (k - 1)][23:0], 2'b0, iratejk_const[j << 2 | k][5:0] };

                    //// TESTING: assign to hex "0xjjjjjkkkkk" ////
                    // assign absorb_state_modifier[(j << 2) | k][31:0] = {{4{ j[3:0] }}, {4{k[3:0]}}};
                end
            end

            assign next_state_output[j] =
                    (
                        state_input_store[j][31:0] & 
                            {32{ (| absorb_round_num_store[7:0])}}
                    ) ^ absorb_state_modifier[(j << 2) | 3][31:0]; // force k=3 for latest, 32-bit XOR

                    // Alternative, requires an always block though:
                        // (absorb_round_num_store == 8'h0) ?
                        // 32'h0 : 
                        // state_input_store[j][31:0] ^ absorb_state_modifier[(j << 2) | 3][31:0]
        end
    endgenerate

    // pass output through
    generate
        for (i = 0; i < 8; i++) begin
            assign state_output[i] = next_state_output[i];
        end
    endgenerate
/*
    initial begin

        // PYTHON:
        // for j in range(8):
        //     for k in range(4):
        //         print(f"j{j}k{k}=%h,", end=('\n' if k == 3 else ' '))

        $monitor("Time=%d, absorb_round_num=%d=0x%h, input_length_bytes=%d, \ninput_val_store=%h,\nstate_input_store=%h %h %h %h %h %h %h %h,\nnext_state_output=%h %h %h %h %h %h %h %h,\nabsorb_state_modifier=\n    j0k0=%h, j0k1=%h, j0k2=%h, j0k3=%h,\n    j1k0=%h, j1k1=%h, j1k2=%h, j1k3=%h,\n    j2k0=%h, j2k1=%h, j2k2=%h, j2k3=%h,\n    j3k0=%h, j3k1=%h, j3k2=%h, j3k3=%h,\n    j4k0=%h, j4k1=%h, j4k2=%h, j4k3=%h,\n    j5k0=%h, j5k1=%h, j5k2=%h, j5k3=%h,\n    j6k0=%h, j6k1=%h, j6k2=%h, j6k3=%h,\n    j7k0=%h, j7k1=%h, j7k2=%h, j7k3=%h",
            $time, absorb_round_num_store,absorb_round_num_store, input_length_bytes_store,
            input_val_store,

            state_input_store[0], state_input_store[1], state_input_store[2],
            state_input_store[3], state_input_store[4], state_input_store[5],
            state_input_store[6], state_input_store[7],

            next_state_output[0], next_state_output[1], next_state_output[2],
            next_state_output[3], next_state_output[4], next_state_output[5],
            next_state_output[6], next_state_output[7],

            // for j in range(8):
            //     for k in range(4):
            //         print(f"absorb_state_modifier[{(j<<2)|k}],", end=('\n' if k == 3 else ' '))
            
            absorb_state_modifier[0], absorb_state_modifier[1], absorb_state_modifier[2], absorb_state_modifier[3],
            absorb_state_modifier[4], absorb_state_modifier[5], absorb_state_modifier[6], absorb_state_modifier[7],
            absorb_state_modifier[8], absorb_state_modifier[9], absorb_state_modifier[10], absorb_state_modifier[11],
            absorb_state_modifier[12], absorb_state_modifier[13], absorb_state_modifier[14], absorb_state_modifier[15],
            absorb_state_modifier[16], absorb_state_modifier[17], absorb_state_modifier[18], absorb_state_modifier[19],
            absorb_state_modifier[20], absorb_state_modifier[21], absorb_state_modifier[22], absorb_state_modifier[23],
            absorb_state_modifier[24], absorb_state_modifier[25], absorb_state_modifier[26], absorb_state_modifier[27],
            absorb_state_modifier[28], absorb_state_modifier[29], absorb_state_modifier[30], absorb_state_modifier[31]

        );

    end */

endmodule
