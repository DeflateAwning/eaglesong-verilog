`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_coefficients;

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter CLK_HALF_PERIOD = 2;
    parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [6:0] index_to_request; // must be from d0 to d47 inclusive
    wire [4:0] requested_coefficient;
    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_coefficients dut (
        .index_to_request(index_to_request),
        .requested_coefficient(requested_coefficient)
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
        $monitor("Time=%t, index_to_request=%h, requested_coefficient=%h",
            $time, index_to_request, requested_coefficient);

        #(CLK_PERIOD);
        index_to_request = 0;
        #1; // FIXME: figure out a way to do this fully combinationally
        if (requested_coefficient !== 5'd00) begin
            $error("Assertion failed: index_to_request=d0 should yield requested_coefficient=d00, but requested_coefficient=d%d", requested_coefficient);
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD);
        index_to_request = 1;
        #1; // FIXME: figure out a way to do this fully combinationally
        if (requested_coefficient !== 5'd02) begin
            $error("Assertion failed: index_to_request=d1 should yield requested_coefficient=d02, but requested_coefficient=d%d", requested_coefficient);
            tb_error_cnt = tb_error_cnt + 1;
        end

        // index_to_request = 14 is the max return value
        #(CLK_PERIOD);
        index_to_request = 14;
        #1; // FIXME: figure out a way to do this fully combinationally
        if (requested_coefficient !== 5'd31) begin
            $error("Assertion failed: index_to_request=d14 should yield requested_coefficient=d31, but requested_coefficient=d%d", requested_coefficient);
            tb_error_cnt = tb_error_cnt + 1;
        end

        // check the last element
        #(CLK_PERIOD);
        index_to_request = 47;
        #1; // FIXME: figure out a way to do this fully combinationally
        if (requested_coefficient !== 5'd13) begin
            $error("Assertion failed: index_to_request=d47 should yield requested_coefficient=d13, but requested_coefficient=d%d", requested_coefficient);
            tb_error_cnt = tb_error_cnt + 1;
        end

        // check an "out of bounds" element
        #(CLK_PERIOD);
        index_to_request = 50;
        #1; // FIXME: figure out a way to do this fully combinationally
        if (requested_coefficient !== 1'b0) begin
            $error("Assertion failed: index_to_request=d47 should yield requested_coefficient=d0 (out of bounds), but requested_coefficient=d%d", requested_coefficient);
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
        $display(" --- Starting tb_eaglesong_coefficients -> main();");

        main_test_task();

        if (tb_error_cnt != 0)
            $error(" --- Done tb_eaglesong_coefficients -> main(). %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done tb_eaglesong_coefficients -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
