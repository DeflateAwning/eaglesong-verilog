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
    reg start_eval;

    wire [31:0] state_output [15:0];
    wire eval_output_ready;

    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_permutation dut (
        .state_input(state_input),
        .round_num(round_num),
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
            // for fun
            state_input[0] <= 32'h0;

            // main reset
            start_eval <= 1'b0;

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

        start_eval <= 1'b1; // activate

        #(CLK_PERIOD*2);

        $display("Output state_output[0]=h%h", state_output[0]);

        #(CLK_PERIOD*100);

        // #(CLK_PERIOD); // delay one clock
        // bit_index_to_request = 0;
        // if (requested_bit !== 1'b1) begin
        //     $error("Assertion failed: bit_index_to_request=0 should yield requested_bit=1, but requested_bit=%b", requested_bit);
        //     tb_error_cnt = tb_error_cnt + 1;
        // end

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
