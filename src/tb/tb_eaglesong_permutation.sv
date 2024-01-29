`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_permutation;

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter CLK_HALF_PERIOD = 2;
    parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [31:0] state_input [15:0];
    reg [5:0] round_num;
    // reg start_eval;

    wire [31:0] state_output [15:0];

    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_permutation dut (
            .state_input(state_input),
            .round_num(round_num),
            // .start_eval(start_eval),

            .state_output(state_output)
        );

    //----------------------------------------------------------------
    // clk_gen
    //
    // Always running clock generator process.
    //----------------------------------------------------------------
    always begin : clk_gen
        #CLK_HALF_PERIOD;
        tb_clk = !tb_clk;
    end // clk_gen

    task init_task;
        begin
            // for fun
            state_input[0] <= 32'h0;

            // main reset
            // start_eval <= 1'b0;

            // other good reset
            round_num <= 6'h0;
        end
    endtask

    //----------------------------------------------------------------
    // Main Test Task
    //----------------------------------------------------------------
    task main_test_task;

    begin
    
        // $monitor("Time=%t, bit_index_to_request=%h, requested_bit=%b",
        //     $time, bit_index_to_request, requested_bit);
        #(CLK_PERIOD*10);

        // set the 'Hello, world!\n' test
        // state_input = {32'h48656C6C, 32'h6F2C2077, 32'h6F726C64, 32'h00210A06,
        //         32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000,
        //         32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000,
        //         32'h00000000, 32'h00000000}; // TODO: not yet supported by iverilog
        state_input[0] <= 32'h48656C6C;
        state_input[1] <= 32'h6F2C2077;
        state_input[2] <= 32'h6F726C64;
        state_input[3] <= 32'h00210A06;
        state_input[4] <= 32'h00000000;
        state_input[5] <= 32'h00000000;
        state_input[6] <= 32'h00000000;
        state_input[7] <= 32'h00000000;
        state_input[8] <= 32'h00000000;
        state_input[9] <= 32'h00000000;
        state_input[10] <= 32'h00000000;
        state_input[11] <= 32'h00000000;
        state_input[12] <= 32'h00000000;
        state_input[13] <= 32'h00000000;
        state_input[14] <= 32'h00000000;
        state_input[15] <= 32'h00000000;
        round_num <= 6'h0;

        #(CLK_PERIOD);

        // PYTHON: a = "0xC9E25AFA 0x6D5BEC80 0x19CEFBAB 0x3227B4C4 0x0FF9A2DF 0xD2C2E889 0x69EBBD09 0x99AED17F 0x7AACD046 0xB58813C8 0x80832F1E 0x27473E60 0xB7F00AE4 0x74B136CB 0xD05A7F42 0x08855BFF".replace('0x', '').split(' ')
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] != 32'h{val}) ||")
        if ((state_output[0] != 32'hC9E25AFA) ||
                    (state_output[1] != 32'h6D5BEC80) ||
                    (state_output[2] != 32'h19CEFBAB) ||
                    (state_output[3] != 32'h3227B4C4) ||
                    (state_output[4] != 32'h0FF9A2DF) ||
                    (state_output[5] != 32'hD2C2E889) ||
                    (state_output[6] != 32'h69EBBD09) ||
                    (state_output[7] != 32'h99AED17F) ||
                    (state_output[8] != 32'h7AACD046) ||
                    (state_output[9] != 32'hB58813C8) ||
                    (state_output[10] != 32'h80832F1E) ||
                    (state_output[11] != 32'h27473E60) ||
                    (state_output[12] != 32'hB7F00AE4) ||
                    (state_output[13] != 32'h74B136CB) ||
                    (state_output[14] != 32'hD05A7F42) ||
                    (state_output[15] != 32'h08855BFF)
                ) begin
            $error("Assertion failed: state_output does not match expected value (C9E25AFA test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*100);

        // TODO: add more test cases, including different round numbers

        // force an error, for confirming that the test best works
        // #(CLK_PERIOD);
        // begin
        //     $error("Forced error for testbench testing.");
        //     tb_error_cnt = tb_error_cnt + 1;
        // end
    end
    endtask

    //----------------------------------------------------------------
    // main()
    //----------------------------------------------------------------
    initial begin : main
        $display(" --- Starting tb_eaglesong_permutation -> main();");

        init_task();

        main_test_task();

        if (tb_error_cnt != 0)
            $error(" --- Done tb_eaglesong_permutation -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_permutation -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
