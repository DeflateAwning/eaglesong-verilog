`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_absorb_comb;

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter CLK_HALF_PERIOD = 2;
    parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [31:0] state_input [7:0];
    reg [255:0] input_val;

    // must be 1 <= input_length_bytes <= 32, and is the number of bits in the input_val to be used
    reg [6:0] input_length_bytes;

    reg [7:0] absorb_round_num;

    wire [31:0] state_output [7:0];

    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_absorb_comb dut (
            .state_input(state_input),
            .input_val(input_val),
            .input_length_bytes(input_length_bytes),
            .absorb_round_num(absorb_round_num),

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
            // must be set to some values, but is ignored when absorb_round_num == 0
            state_input[0] <= 32'h00000000;
            state_input[1] <= 32'h11111111;
            state_input[2] <= 32'h22222222;
            state_input[3] <= 32'h33333333;
            state_input[4] <= 32'h44444444;
            state_input[5] <= 32'h55555555;
            state_input[6] <= 32'h66666666;
            state_input[7] <= 32'h77777777;

            // main reset
            // start_eval <= 1'b0;

            // other good reset
            absorb_round_num <= 6'h0;
        end
    endtask

    //----------------------------------------------------------------
    // Main Test Task - str1_round0
    // absorb_round_num = 0;
    // input_length = 14; (this str only does 1 round)
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round0; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test (literally, that text)
        // PYTHON: a = "48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21 0A".split(' ')
        // PYTHON: arev = reversed(a)
        // PYTHON: print("input_val <= 256'h" + ''.join(arev))
        input_val <= 256'h0A21646C726F77202C6F6C6C6548;
        input_length_bytes <= 7'd14;
        absorb_round_num <= 6'h0;

        #(CLK_PERIOD);

        // PYTHON: a = "48656C6C 6F2C2077 6F726C64 00210A06 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000".split(' ')[:8]
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h48656C6C) ||
                    (state_output[1] !== 32'h6F2C2077) ||
                    (state_output[2] !== 32'h6F726C64) ||
                    (state_output[3] !== 32'h00210A06) ||
                    (state_output[4] !== 32'h00000000) ||
                    (state_output[5] !== 32'h00000000) ||
                    (state_output[6] !== 32'h00000000) ||
                    (state_output[7] !== 32'h00000000)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str1_round0 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*3);

        // force an error, for confirming that the test best works
        // #(CLK_PERIOD);
        // begin
        //     $error("Forced error for testbench testing.");
        //     tb_error_cnt = tb_error_cnt + 1;
        // end
    end
    endtask


    //----------------------------------------------------------------
    // Main Test Task - str2_round0
    // absorb_round_num = 0;
    // input_length = 32;
    // state_input is the result of input=[33, 171, 95, 7, 243, 253, 131, 21, 216, 99, 103, 211, 165, 214, 209, 194, 253, 92, 153, 235, 172, 116, 61, 142, 120, 33, 235, 89, 234, 111, 7, 240] (str2)
    //----------------------------------------------------------------
    task main_test_task_str2_round0; begin
        #(CLK_PERIOD*2);
        
        // PYTHON: a = [33, 171, 95, 7, 243, 253, 131, 21, 216, 99, 103, 211, 165, 214, 209, 194, 253, 92, 153, 235, 172, 116, 61, 142, 120, 33, 235, 89, 234, 111, 7, 240]
        // PYTHON: arev = reversed(a)
        // PYTHON: arev = [f"{i:02X}" for i in arev]
        // PYTHON: print("input_val <= 256'h" + ''.join(arev))
        input_val <= 256'hF0076FEA59EB21788E3D74ACEB995CFDC2D1D6A5D36763D81583FDF3075FAB21;
        input_length_bytes <= 7'd32;
        absorb_round_num <= 6'h0;

        #(CLK_PERIOD);

        // PYTHON: a = "21AB5F07 F3FD8315 D86367D3 A5D6D1C2 FD5C99EB AC743D8E 7821EB59 EA6F07F0 ".split(' ')[:8]
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h21AB5F07) ||
                    (state_output[1] !== 32'hF3FD8315) ||
                    (state_output[2] !== 32'hD86367D3) ||
                    (state_output[3] !== 32'hA5D6D1C2) ||
                    (state_output[4] !== 32'hFD5C99EB) ||
                    (state_output[5] !== 32'hAC743D8E) ||
                    (state_output[6] !== 32'h7821EB59) ||
                    (state_output[7] !== 32'hEA6F07F0)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str2_round0 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD);
    end
    endtask

    task main_test_task_str2_round1; begin
        #(CLK_PERIOD*2);
        
        // PYTHON: a = [33, 171, 95, 7, 243, 253, 131, 21, 216, 99, 103, 211, 165, 214, 209, 194, 253, 92, 153, 235, 172, 116, 61, 142, 120, 33, 235, 89, 234, 111, 7, 240]
        // PYTHON: arev = reversed(a)
        // PYTHON: arev = [f"{i:02X}" for i in arev]
        // PYTHON: print("input_val <= 256'h" + ''.join(arev))
        input_val <= 256'hF0076FEA59EB21788E3D74ACEB995CFDC2D1D6A5D36763D81583FDF3075FAB21;
        input_length_bytes <= 7'd32;
        absorb_round_num <= 6'h0;

        // state output from round0 is the input for this round1
        // PYTHON: a = "21AB5F07 F3FD8315 D86367D3 A5D6D1C2 FD5C99EB AC743D8E 7821EB59 EA6F07F0 ".split(' ')[:8]
        // PYTHON: for idx, val in enumerate(a): print(f"state_input[{idx}] = 32'h{val};")
        state_input[0] = 32'h21AB5F07;
        state_input[1] = 32'hF3FD8315;
        state_input[2] = 32'hD86367D3;
        state_input[3] = 32'hA5D6D1C2;
        state_input[4] = 32'hFD5C99EB;
        state_input[5] = 32'hAC743D8E;
        state_input[6] = 32'h7821EB59;
        state_input[7] = 32'hEA6F07F0;

        #(CLK_PERIOD);

        // Note: for this round1, there should be no value change
        // PYTHON: a = "21AB5F07 F3FD8315 D86367D3 A5D6D1C2 FD5C99EB AC743D8E 7821EB59 EA6F07F0 ".split(' ')[:8]
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h21AB5F07) ||
                    (state_output[1] !== 32'hF3FD8315) ||
                    (state_output[2] !== 32'hD86367D3) ||
                    (state_output[3] !== 32'hA5D6D1C2) ||
                    (state_output[4] !== 32'hFD5C99EB) ||
                    (state_output[5] !== 32'hAC743D8E) ||
                    (state_output[6] !== 32'h7821EB59) ||
                    (state_output[7] !== 32'hEA6F07F0)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str2_round1 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD);
    end
    endtask

    //----------------------------------------------------------------
    // main()
    //----------------------------------------------------------------
    initial begin : main
        $display(" --- Starting tb_eaglesong_absorb_comb -> main();");

        init_task();

        main_test_task_str1_round0();

        main_test_task_str2_round0();
        main_test_task_str2_round1();
        // TODO: add more test cases, esp. with round1()

        if (tb_error_cnt !== 0)
            $error(" --- Done tb_eaglesong_absorb_comb -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_absorb_comb -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
