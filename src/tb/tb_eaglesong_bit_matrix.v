`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_bit_matrix;

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter CLK_HALF_PERIOD = 2;
    parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [7:0] bit_index_to_request;
    wire requested_bit;
    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_bit_matrix dut (
        .bit_index_to_request(bit_index_to_request),
        .requested_bit(requested_bit)
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
    
        $monitor("Time=%t, bit_index_to_request=%h, requested_bit=%b",
            $time, bit_index_to_request, requested_bit);

        #(CLK_PERIOD); // delay one clock
        bit_index_to_request = 0;
        if (requested_bit !== 1'b1) begin
            $error("Assertion failed: bit_index_to_request=0 should yield requested_bit=1, but requested_bit=%b", requested_bit);
            tb_error_cnt = tb_error_cnt + 1;
        end

        // bit_index_to_request = 2 is the first index where bit_matix[bit_index_to_request] != bit_matrix[len-bit_index_to_request-1]
        #(CLK_PERIOD);
        bit_index_to_request = 2;
        if (requested_bit !== 1'b1) begin
            $error("Assertion failed: bit_index_to_request=2 should yield requested_bit=1, but requested_bit=%b", requested_bit);
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD);
        bit_index_to_request = 255 - 2;
        if (requested_bit !== 1'b0) begin
            $error("Assertion failed: bit_index_to_request=255-2 should yield requested_bit=0, but requested_bit=%b", requested_bit);
            tb_error_cnt = tb_error_cnt + 1;
        end

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
        $display(" --- Starting tb_eaglesong_bit_matrix -> main();");

        main_test_task();

        if (tb_error_cnt != 0)
            $error(" --- Done tb_eaglesong_bit_matrix -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_bit_matrix -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
