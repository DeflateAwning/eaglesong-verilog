`timescale 1ns/1ps

module test_eaglesong_bit_matrix;

    reg [7:0] bit_index_to_request;
    wire requested_bit;

    // Instantiate the module
    eaglesong_bit_matrix uut (
        .bit_index_to_request(bit_index_to_request),
        .requested_bit(requested_bit)
    );

    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        $monitor("Time=%t, bit_index_to_request=%h, requested_bit=%b", $time, bit_index_to_request, requested_bit);

        #10; // delay 10 time units
        bit_index_to_request = 0;
        #1; // delay 10 time units
        if (requested_bit !== 1'b1)
            $error("Assertion failed: bit_index_to_request=0 should yield requested_bit=1, but requested_bit=%b", requested_bit);

        // bit_index_to_request = 2 is the first index where bit_matix[bit_index_to_request] != bit_matrix[len-bit_index_to_request-1]
        #10;
        bit_index_to_request = 2;
        #1;
        if (requested_bit !== 1'b1)
            $error("Assertion failed: bit_index_to_request=2 should yield requested_bit=1, but requested_bit=%b", requested_bit);
        
        #10;
        bit_index_to_request = 255 - 2;
        #1;
        if (requested_bit !== 1'b0)
            $error("Assertion failed: bit_index_to_request=255-2 should yield requested_bit=0, but requested_bit=%b", requested_bit);

        // Finish simulation after some time
        #100;
        $finish;
    end

endmodule
