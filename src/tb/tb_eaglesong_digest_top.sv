`timescale 1ns/1ps
`default_nettype none // recommended for better warnings

module tb_eaglesong_digest_top;

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter CLK_HALF_PERIOD = 2;
    parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [255:0] input_val;

    // must be 1 <= input_length_bytes <= 32, and is the number of bits in the input_val to be used
    reg [6:0] input_length_bytes;

    reg start_eval;

    wire [255:0] output_val;
    wire eval_output_ready;

    reg tb_clk = 0;
    reg [7:0] tb_error_cnt = 0;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    eaglesong_digest_top dut (
            .clk(tb_clk),
            .input_val(input_val),
            .input_length_bytes(input_length_bytes),
            .start_eval(start_eval),

            .output_val(output_val),
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
            input_val <= 32'h0;
            input_length_bytes <= 32'h0; // technically invalid

            // main reset
            start_eval <= 1'b0;
        end
    endtask

    //----------------------------------------------------------------
    // Main Test Task #1
    // Run digest for the 'Hello, world!\n' test.
    //----------------------------------------------------------------
    int calc_clk_count = 0;
    task main_test_task_1; begin
        #(CLK_PERIOD*2);

        // set the 'Hello, world!\n' test (literally, that text)
        // PYTHON: a = "48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21 0A".split(' ')
        // PYTHON: arev = reversed(a)
        // PYTHON: print("input_val <= 256'h" + ''.join(arev))
        input_val <= 256'h0A21646C726F77202C6F6C6C6548;
        input_length_bytes <= 7'd14;

        start_eval <= 1'b1; // activate conversion
        #(CLK_PERIOD * 2); // TODO: reduce to just one cycle
        start_eval <= 1'b0; // let conversion complete

        while ((eval_output_ready !== 1'b1) && (calc_clk_count < 120)) begin
            #(CLK_PERIOD);
            calc_clk_count ++;
        end
        
        if (eval_output_ready !== 1'b1) begin
            $error("Assertion failed: eval_output_ready !== 1'b1 after too long.");
            tb_error_cnt = tb_error_cnt + 1;
        end

        // set the 'Hello, world!\n' test (literally, that text)
        // PYTHON: a = "64867e2441d162615dc2430b6bcb4d3f4b95e4d0db529fca1eece73c077d72d6".upper()
        // PYTHON: b = [a[i]+a[i+1] for i in range(0, len(a), 2)]
        // PYTHON: c = reversed(b)
        // PYTHON: print("256'h" + ''.join(c))
        if (output_val !== 256'hD6727D073CE7EC1ECA9F52DBD0E4954B3F4DCB6B0B43C25D6162D141247E8664) begin
            $error("Assertion failed: final output of main_test_task_1 is wrong");
            tb_error_cnt = tb_error_cnt + 1;
        end

        #(CLK_PERIOD*2);
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
        $display(" --- Starting eaglesong_digest_top -> main();");

        init_task();

        main_test_task_1();
        // TODO: add more test cases, including different round numbers

        if (tb_error_cnt !== 0)
            $error(" --- Done eaglesong_digest_top -> main(). Argh, %d error(s). ", tb_error_cnt);
        else
            $display(" --- Done eaglesong_digest_top -> main(). No errors.");

        $finish;
    
    end // main()

endmodule
