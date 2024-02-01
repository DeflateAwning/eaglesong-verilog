`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_all_permutations;

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
    reg start_eval;

    wire [31:0] state_output [15:0];
    wire eval_output_ready;

    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_all_permutations dut (
            .clk(tb_clk),
            .state_input(state_input),
            .start_eval(start_eval),

            .state_output(state_output),
            .eval_output_ready(eval_output_ready)
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
            start_eval <= 1'b0;
        end
    endtask

    //----------------------------------------------------------------
    // Main Test Task #1
    // Run all permutations for the 'Hello, world!\n' test.
    //----------------------------------------------------------------
    int i = 0;
    task main_test_task_1; begin
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

        start_eval <= 1'b1; // activate conversion
        $display("Starting eval.");
        #(CLK_PERIOD * 2); // TOOD: reduce to just one cycle
        start_eval <= 1'b0; // let conversion complete

        for (i = 0; i < 45; i++) begin
            $display("Round %d: eval_output_ready=%d", i, eval_output_ready);
            #(CLK_PERIOD);
        end
        #(CLK_PERIOD * 43); // should take 43ish clocks to complete
        
        if (eval_output_ready !== 1'b1) begin
            $error("Assertion failed: eval_output_ready !== 1'b1");
            tb_error_cnt = tb_error_cnt + 1;
        end

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
            $error("Assertion failed: final output of main_test_task_1 is wrong");
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

        main_test_task_1();

        if (tb_error_cnt !== 0)
            $error(" --- Done tb_eaglesong_permutation -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_permutation -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
