`timescale 1ns/1ps

module eaglesong_bit_matrix(
        input [7:0] bit_index_to_request,
        output requested_bit
    );

    // Generated with:
    /*
        ```python
            a = <paste in the bit_matrix[] array from the C code as list> # // Source: https://github.com/nervosnetwork/rfcs/blob/dff5235616e5c7aec706326494dce1c54163c4be/rfcs/0010-eaglesong/eaglesong.c#L4
            arev = reversed(a)
            trev = ''
            for i in arev: trev += str(i)
            print(hex(int(trev, 2))
        ```
    */
    reg [255:0] bit_matrix_const = 256'h47d7643c321e190fcb50a5a892d4896a84b5458de511755ffd78bebc9f5e8faf;

    assign requested_bit = bit_matrix_const[bit_index_to_request];

endmodule
