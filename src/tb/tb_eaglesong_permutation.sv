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

    //----------------------------------------------------------------
    // Main Test Task
    //----------------------------------------------------------------
    task main_test_task;

    begin
    
        // $monitor("Time=%t, bit_index_to_request=%h, requested_bit=%b",
        //     $time, bit_index_to_request, requested_bit);

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

        main_test_task();

        if (tb_error_cnt != 0)
            $error(" --- Done tb_eaglesong_permutation -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_permutation -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
