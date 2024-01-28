`timescale 1ns/1ps

module eaglesong_coefficients(
        input [6:0] index_to_request, // must be from d0 to d47 inclusive
        output [4:0] requested_coefficient
    );
    // Outputs the coefficient at a given index.
    // If the index_to_request>d47, then requested_coefficient=0 (as this is an invalid case)

    // Generated with Python:
    /*
        In [1]: a = [0, 2, 4, 0, 13, 22, 0, 4, 19, 0, 3, 14, 0, 27, 31, 0, 3, 8, 0, 17, 26, 0, 3, 12, 0, 18, 22, 0, 12, 18, 0, 4, 7, 0, 4, 31, 0, 12, 27, 0, 7, 17, 0, 7, 8, 0, 1, 13]

        In [2]: max(a)
        Out[2]: 31

        In [3]: 1 << 5
        Out[3]: 32

        In [4]: len(a)
        Out[4]: 48

        In [5]: for idx, val in enumerate(a): print(f"7'd{idx:02d}: requested_coefficient_val = 5'd{val:02d};")
    */

    // 48 coefficients, each 5 bits wide
    // can't assign to a wire, so create a register
    reg [4:0] requested_coefficient_val;

    always @(index_to_request) begin
        // TODO: confirm if the case assignments should be '=' or '<='
        case(index_to_request)
            7'd00: requested_coefficient_val = 5'd00;
            7'd01: requested_coefficient_val = 5'd02;
            7'd02: requested_coefficient_val = 5'd04;
            7'd03: requested_coefficient_val = 5'd00;
            7'd04: requested_coefficient_val = 5'd13;
            7'd05: requested_coefficient_val = 5'd22;
            7'd06: requested_coefficient_val = 5'd00;
            7'd07: requested_coefficient_val = 5'd04;
            7'd08: requested_coefficient_val = 5'd19;
            7'd09: requested_coefficient_val = 5'd00;
            7'd10: requested_coefficient_val = 5'd03;
            7'd11: requested_coefficient_val = 5'd14;
            7'd12: requested_coefficient_val = 5'd00;
            7'd13: requested_coefficient_val = 5'd27;
            7'd14: requested_coefficient_val = 5'd31;
            7'd15: requested_coefficient_val = 5'd00;
            7'd16: requested_coefficient_val = 5'd03;
            7'd17: requested_coefficient_val = 5'd08;
            7'd18: requested_coefficient_val = 5'd00;
            7'd19: requested_coefficient_val = 5'd17;
            7'd20: requested_coefficient_val = 5'd26;
            7'd21: requested_coefficient_val = 5'd00;
            7'd22: requested_coefficient_val = 5'd03;
            7'd23: requested_coefficient_val = 5'd12;
            7'd24: requested_coefficient_val = 5'd00;
            7'd25: requested_coefficient_val = 5'd18;
            7'd26: requested_coefficient_val = 5'd22;
            7'd27: requested_coefficient_val = 5'd00;
            7'd28: requested_coefficient_val = 5'd12;
            7'd29: requested_coefficient_val = 5'd18;
            7'd30: requested_coefficient_val = 5'd00;
            7'd31: requested_coefficient_val = 5'd04;
            7'd32: requested_coefficient_val = 5'd07;
            7'd33: requested_coefficient_val = 5'd00;
            7'd34: requested_coefficient_val = 5'd04;
            7'd35: requested_coefficient_val = 5'd31;
            7'd36: requested_coefficient_val = 5'd00;
            7'd37: requested_coefficient_val = 5'd12;
            7'd38: requested_coefficient_val = 5'd27;
            7'd39: requested_coefficient_val = 5'd00;
            7'd40: requested_coefficient_val = 5'd07;
            7'd41: requested_coefficient_val = 5'd17;
            7'd42: requested_coefficient_val = 5'd00;
            7'd43: requested_coefficient_val = 5'd07;
            7'd44: requested_coefficient_val = 5'd08;
            7'd45: requested_coefficient_val = 5'd00;
            7'd46: requested_coefficient_val = 5'd01;
            7'd47: requested_coefficient_val = 5'd13;
            default: requested_coefficient_val = 5'd00; // undefined case
        endcase
    end

    assign requested_coefficient = requested_coefficient_val;
endmodule
