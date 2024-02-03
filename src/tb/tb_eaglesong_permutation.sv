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
            // for fun, not really needed because we set it later
            state_input[0] <= 32'h0;

            // main reset
            // start_eval <= 1'b0;

            // other good reset
            round_num <= 6'h0;
        end
    endtask

    //----------------------------------------------------------------
    // Main Test Task - str1_round0
    // round_num = 0;
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round0; begin
        #(CLK_PERIOD*2);

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
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'hC9E25AFA) ||
                    (state_output[1] !== 32'h6D5BEC80) ||
                    (state_output[2] !== 32'h19CEFBAB) ||
                    (state_output[3] !== 32'h3227B4C4) ||
                    (state_output[4] !== 32'h0FF9A2DF) ||
                    (state_output[5] !== 32'hD2C2E889) ||
                    (state_output[6] !== 32'h69EBBD09) ||
                    (state_output[7] !== 32'h99AED17F) ||
                    (state_output[8] !== 32'h7AACD046) ||
                    (state_output[9] !== 32'hB58813C8) ||
                    (state_output[10] !== 32'h80832F1E) ||
                    (state_output[11] !== 32'h27473E60) ||
                    (state_output[12] !== 32'hB7F00AE4) ||
                    (state_output[13] !== 32'h74B136CB) ||
                    (state_output[14] !== 32'hD05A7F42) ||
                    (state_output[15] !== 32'h08855BFF)
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
    // Main Test Task - str1_round3
    // round_num = 3;
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round3; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test, as it is at the output of round_num=2 (previous round)
        // Python: a = "    41271A6B 87FD3AA1 DD9E1948 B5763300 A46D0E94 3DF1A0A6 3BD5A013 27CE65A2 A0E68429 35FAA35F 078F5CC0 C62A667E 62C85595 62AD2F52 4D71F523 C7BB730A".strip().split()
        // Python: for idx, val in enumerate(a): print(f"state_input[{idx}] <= 32'h{val};")
        state_input[0] <= 32'h41271A6B;
        state_input[1] <= 32'h87FD3AA1;
        state_input[2] <= 32'hDD9E1948;
        state_input[3] <= 32'hB5763300;
        state_input[4] <= 32'hA46D0E94;
        state_input[5] <= 32'h3DF1A0A6;
        state_input[6] <= 32'h3BD5A013;
        state_input[7] <= 32'h27CE65A2;
        state_input[8] <= 32'hA0E68429;
        state_input[9] <= 32'h35FAA35F;
        state_input[10] <= 32'h078F5CC0;
        state_input[11] <= 32'hC62A667E;
        state_input[12] <= 32'h62C85595;
        state_input[13] <= 32'h62AD2F52;
        state_input[14] <= 32'h4D71F523;
        state_input[15] <= 32'hC7BB730A;

        round_num <= 6'h3;
        #(CLK_PERIOD);

        // PYTHON: a = "9C46457B 3652CF10 546F6F6B C40EDD05 4C1F4AB6 B7A40D23 059B6D0B 90D3E9DA A49E1129 BA8586B7 62D75EE9 92CE9627 B8B5E34F 00471B4D 56F6BDE5 99947A07".split(' ')
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h9C46457B) ||
                    (state_output[1] !== 32'h3652CF10) ||
                    (state_output[2] !== 32'h546F6F6B) ||
                    (state_output[3] !== 32'hC40EDD05) ||
                    (state_output[4] !== 32'h4C1F4AB6) ||
                    (state_output[5] !== 32'hB7A40D23) ||
                    (state_output[6] !== 32'h059B6D0B) ||
                    (state_output[7] !== 32'h90D3E9DA) ||
                    (state_output[8] !== 32'hA49E1129) ||
                    (state_output[9] !== 32'hBA8586B7) ||
                    (state_output[10] !== 32'h62D75EE9) ||
                    (state_output[11] !== 32'h92CE9627) ||
                    (state_output[12] !== 32'hB8B5E34F) ||
                    (state_output[13] !== 32'h00471B4D) ||
                    (state_output[14] !== 32'h56F6BDE5) ||
                    (state_output[15] !== 32'h99947A07)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str1_round3 test).");
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
    // Main Test Task - str1_round15
    // round_num = 15;
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round15; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test, as it is at the output of previous round
        // Python: a = "    E492ADB4 1A865842 E5E19E1D AA1DE3D1 1AC3377C 288313B7 B462A731 969B397E 053199D2 6281F8A7 52C79F18 0749724F 1E4AB3E1 E7F1AB19 3638A4F1 A721F663".strip().split()
        // Python: for idx, val in enumerate(a): print(f"state_input[{idx}] <= 32'h{val};")
        state_input[0] <= 32'hE492ADB4;
        state_input[1] <= 32'h1A865842;
        state_input[2] <= 32'hE5E19E1D;
        state_input[3] <= 32'hAA1DE3D1;
        state_input[4] <= 32'h1AC3377C;
        state_input[5] <= 32'h288313B7;
        state_input[6] <= 32'hB462A731;
        state_input[7] <= 32'h969B397E;
        state_input[8] <= 32'h053199D2;
        state_input[9] <= 32'h6281F8A7;
        state_input[10] <= 32'h52C79F18;
        state_input[11] <= 32'h0749724F;
        state_input[12] <= 32'h1E4AB3E1;
        state_input[13] <= 32'hE7F1AB19;
        state_input[14] <= 32'h3638A4F1;
        state_input[15] <= 32'hA721F663;

        round_num <= 6'd15;
        #(CLK_PERIOD);

        // PYTHON: a = "    F6271C7E 1F0B6305 49BE634A 6C955915 96851602 F8867CC8 3B62DCE0 C27A091A 4BF638C8 24C11FE9 76474778 C624F734 101C878F B030ACE1 CCAB2101 F6A850BE".strip().split(' ')
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'hF6271C7E) ||
                    (state_output[1] !== 32'h1F0B6305) ||
                    (state_output[2] !== 32'h49BE634A) ||
                    (state_output[3] !== 32'h6C955915) ||
                    (state_output[4] !== 32'h96851602) ||
                    (state_output[5] !== 32'hF8867CC8) ||
                    (state_output[6] !== 32'h3B62DCE0) ||
                    (state_output[7] !== 32'hC27A091A) ||
                    (state_output[8] !== 32'h4BF638C8) ||
                    (state_output[9] !== 32'h24C11FE9) ||
                    (state_output[10] !== 32'h76474778) ||
                    (state_output[11] !== 32'hC624F734) ||
                    (state_output[12] !== 32'h101C878F) ||
                    (state_output[13] !== 32'hB030ACE1) ||
                    (state_output[14] !== 32'hCCAB2101) ||
                    (state_output[15] !== 32'hF6A850BE)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str1_round15 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*3);
    end
    endtask


    //----------------------------------------------------------------
    // Main Test Task - str1_round16
    // round_num = 16;
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round16; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test, as it is at the output of previous round
        // Python: a = "    F6271C7E 1F0B6305 49BE634A 6C955915 96851602 F8867CC8 3B62DCE0 C27A091A 4BF638C8 24C11FE9 76474778 C624F734 101C878F B030ACE1 CCAB2101 F6A850BE".strip().split(' ')
        // Python: 
        state_input[0] <= 32'hF6271C7E;
        state_input[1] <= 32'h1F0B6305;
        state_input[2] <= 32'h49BE634A;
        state_input[3] <= 32'h6C955915;
        state_input[4] <= 32'h96851602;
        state_input[5] <= 32'hF8867CC8;
        state_input[6] <= 32'h3B62DCE0;
        state_input[7] <= 32'hC27A091A;
        state_input[8] <= 32'h4BF638C8;
        state_input[9] <= 32'h24C11FE9;
        state_input[10] <= 32'h76474778;
        state_input[11] <= 32'hC624F734;
        state_input[12] <= 32'h101C878F;
        state_input[13] <= 32'hB030ACE1;
        state_input[14] <= 32'hCCAB2101;
        state_input[15] <= 32'hF6A850BE;

        round_num <= 6'd16;
        #(CLK_PERIOD);

        // PYTHON: a = "    726F0601 7F6D1457 2303A76E 42FCD62C 7F660621 D28598D1 7E736F81 FAB110E6 EAA43DF3 3F9FBE36 5E070EFF D8FCB532 AF48E739 AFA2FC1D F19CCCE1 3769AB22".strip().split(' ')
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h726F0601) ||
                    (state_output[1] !== 32'h7F6D1457) ||
                    (state_output[2] !== 32'h2303A76E) ||
                    (state_output[3] !== 32'h42FCD62C) ||
                    (state_output[4] !== 32'h7F660621) ||
                    (state_output[5] !== 32'hD28598D1) ||
                    (state_output[6] !== 32'h7E736F81) ||
                    (state_output[7] !== 32'hFAB110E6) ||
                    (state_output[8] !== 32'hEAA43DF3) ||
                    (state_output[9] !== 32'h3F9FBE36) ||
                    (state_output[10] !== 32'h5E070EFF) ||
                    (state_output[11] !== 32'hD8FCB532) ||
                    (state_output[12] !== 32'hAF48E739) ||
                    (state_output[13] !== 32'hAFA2FC1D) ||
                    (state_output[14] !== 32'hF19CCCE1) ||
                    (state_output[15] !== 32'h3769AB22)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str1_round16 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*3);
    end
    endtask


    //----------------------------------------------------------------
    // Main Test Task - str1_round42
    // round_num = 42;
    // state_input is the result of input="Hello, world!\n" (str1)
    //----------------------------------------------------------------
    task main_test_task_str1_round42; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test, as it is at the output of previous round
        // Python: a = "AF303F76 2CE61625 FA031D3B 1C5019DD 9732C68C E5968C88 47A3A449 83A31388 1F8D987F B9ABDBE0 0CCAC16E F1C4DA5F E23B24AB 7A81E1B1 1D37CEA1 EF28B4BE".strip().split()
        // Python: for idx, val in enumerate(a): print(f"state_input[{idx}] <= 32'h{val};")
        state_input[0] <= 32'hAF303F76;
        state_input[1] <= 32'h2CE61625;
        state_input[2] <= 32'hFA031D3B;
        state_input[3] <= 32'h1C5019DD;
        state_input[4] <= 32'h9732C68C;
        state_input[5] <= 32'hE5968C88;
        state_input[6] <= 32'h47A3A449;
        state_input[7] <= 32'h83A31388;
        state_input[8] <= 32'h1F8D987F;
        state_input[9] <= 32'hB9ABDBE0;
        state_input[10] <= 32'h0CCAC16E;
        state_input[11] <= 32'hF1C4DA5F;
        state_input[12] <= 32'hE23B24AB;
        state_input[13] <= 32'h7A81E1B1;
        state_input[14] <= 32'h1D37CEA1;
        state_input[15] <= 32'hEF28B4BE;

        round_num <= 6'd42;
        #(CLK_PERIOD);

        // PYTHON: a = "    247E8664 6162D141 0B43C25D 3F4DCB6B D0E4954B CA9F52DB 3CE7EC1E D6727D07 B04C7AA2 FDA25B6F 0E629918 27920F6D 1F18E244 64EA88D4 A247DA8E 09ACB729".strip().split(' ')
        // PYTHON: for idx, val in enumerate(a): print(f"(state_output[{idx}] !== 32'h{val}) ||")
        if ((state_output[0] !== 32'h247E8664) ||
                    (state_output[1] !== 32'h6162D141) ||
                    (state_output[2] !== 32'h0B43C25D) ||
                    (state_output[3] !== 32'h3F4DCB6B) ||
                    (state_output[4] !== 32'hD0E4954B) ||
                    (state_output[5] !== 32'hCA9F52DB) ||
                    (state_output[6] !== 32'h3CE7EC1E) ||
                    (state_output[7] !== 32'hD6727D07) ||
                    (state_output[8] !== 32'hB04C7AA2) ||
                    (state_output[9] !== 32'hFDA25B6F) ||
                    (state_output[10] !== 32'h0E629918) ||
                    (state_output[11] !== 32'h27920F6D) ||
                    (state_output[12] !== 32'h1F18E244) ||
                    (state_output[13] !== 32'h64EA88D4) ||
                    (state_output[14] !== 32'hA247DA8E) ||
                    (state_output[15] !== 32'h09ACB729)
                ) begin
            $error("Assertion failed: state_output does not match expected value (main_test_task_str1_round42 test).");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*3);
    end
    endtask


    //----------------------------------------------------------------
    // main()
    //----------------------------------------------------------------
    initial begin : main
        $display(" --- Starting tb_eaglesong_permutation -> main();");

        init_task();

        main_test_task_str1_round0();
        main_test_task_str1_round3();
        main_test_task_str1_round15();
        main_test_task_str1_round16();
        main_test_task_str1_round42();

        if (tb_error_cnt !== 0)
            $error(" --- Done tb_eaglesong_permutation -> main(). Argh, %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_permutation -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
