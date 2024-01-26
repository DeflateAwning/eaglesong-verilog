module eaglesong_coefficients(
        input [6:0] index_to_request, // must be from d0 to d47 inclusive
        output [4:0] requested_coefficient
    );

    // Generated with Python:
    /*
        In [1]: a = [0, 2, 4, 0, 13, 22, 0, 4, 19, 0, 3, 14, 0, 27, 31, 0, 3, 8, 0, 17, 26, 0, 3, 12, 0, 18, 22, 0, 12, 18, 0, 4, 7, 0, 4, 31, 0, 12, 27, 0, 7, 17, 0, 7, 8, 0, 1, 13]

        In [2]: max(a)
        Out[2]: 31

        In [3]: 1 << 5
        Out[3]: 32

        In [4]: len(a)
        Out[4]: 48

        In [5]: for idx, val in enumerate(a): print(f"assign coeffs_const[{idx}] = 5'd{val};")
    */

    // TODO: confirm this assert works
    assert (index_to_request >= 0 && index_to_request <= 47) else $fatal("index_to_request must be from d0 to d47 inclusive");

    // 48 coefficients, each 5 bits wide
    reg [47:0] coeffs_const [4:0];
    
    // region assign coeffs_const values
    assign coeffs_const[0] = 5'd0;
    assign coeffs_const[1] = 5'd2;
    assign coeffs_const[2] = 5'd4;
    assign coeffs_const[3] = 5'd0;
    assign coeffs_const[4] = 5'd13;
    assign coeffs_const[5] = 5'd22;
    assign coeffs_const[6] = 5'd0;
    assign coeffs_const[7] = 5'd4;
    assign coeffs_const[8] = 5'd19;
    assign coeffs_const[9] = 5'd0;
    assign coeffs_const[10] = 5'd3;
    assign coeffs_const[11] = 5'd14;
    assign coeffs_const[12] = 5'd0;
    assign coeffs_const[13] = 5'd27;
    assign coeffs_const[14] = 5'd31;
    assign coeffs_const[15] = 5'd0;
    assign coeffs_const[16] = 5'd3;
    assign coeffs_const[17] = 5'd8;
    assign coeffs_const[18] = 5'd0;
    assign coeffs_const[19] = 5'd17;
    assign coeffs_const[20] = 5'd26;
    assign coeffs_const[21] = 5'd0;
    assign coeffs_const[22] = 5'd3;
    assign coeffs_const[23] = 5'd12;
    assign coeffs_const[24] = 5'd0;
    assign coeffs_const[25] = 5'd18;
    assign coeffs_const[26] = 5'd22;
    assign coeffs_const[27] = 5'd0;
    assign coeffs_const[28] = 5'd12;
    assign coeffs_const[29] = 5'd18;
    assign coeffs_const[30] = 5'd0;
    assign coeffs_const[31] = 5'd4;
    assign coeffs_const[32] = 5'd7;
    assign coeffs_const[33] = 5'd0;
    assign coeffs_const[34] = 5'd4;
    assign coeffs_const[35] = 5'd31;
    assign coeffs_const[36] = 5'd0;
    assign coeffs_const[37] = 5'd12;
    assign coeffs_const[38] = 5'd27;
    assign coeffs_const[39] = 5'd0;
    assign coeffs_const[40] = 5'd7;
    assign coeffs_const[41] = 5'd17;
    assign coeffs_const[42] = 5'd0;
    assign coeffs_const[43] = 5'd7;
    assign coeffs_const[44] = 5'd8;
    assign coeffs_const[45] = 5'd0;
    assign coeffs_const[46] = 5'd1;
    assign coeffs_const[47] = 5'd13;
    // endregion assign coeffs_const values

    assign requested_coefficient = coeffs_const[index_to_request];
endmodule
