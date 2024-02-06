`timescale 1ns/1ps

module eaglesong_permutation(
        input [31:0] state_input [15:0],
        input [5:0] round_num, // must be 0 <= round_num <= 42

        output [31:0] state_output [15:0]
    );

    // calculates one instance of what's inside the permutation loop

    genvar i;
    genvar j;

    // if we turn this pipelined, these stores can be registers
    wire [31:0] state_input_store [15:0];
    wire [5:0] round_num_store;

    wire [31:0] bitmatrix_step_output_state [15:0];
    wire [31:0] circulant_step_output_state [15:0];
    wire [31:0] injection_step_output_state [15:0];

    /* verilator lint_off UNOPTFLAT */
    wire [31:0] addrotadd_step_output_state [15:0];
    /* verilator lint_on UNOPTFLAT */
    // TODO: convert logic to this: https://verilator.org/guide/latest/warnings.html#cmdoption-arg-UNOPTFLAT

    wire [31:0] addrotadd_step_intermed1 [7:0];


    // const_bit_matrix generated with Python:
        // a = <paste in the bit_matrix[] array from the C code as list> # // Source: https://github.com/nervosnetwork/rfcs/blob/dff5235616e5c7aec706326494dce1c54163c4be/rfcs/0010-eaglesong/eaglesong.c#L4
        // arev = reversed(a)
        // trev = ''
        // for i in arev: trev += str(i)
        // print(hex(int(trev, 2)))
    reg [255:0] const_bit_matrix = 256'hc7d7643c321e190fcb50a5a892d4896a84b5458de511755ffd78bebc9f5e8faf;
    reg [4:0] const_coefficients [47:0];
    reg [31:0] const_injections [687:0];

    wire [9:0] const_inj_idx [15:0];

    // initialize the const_coefficients array register
    // Python: a = [0, 2, 4, 0, 13, 22, 0, 4, 19, 0, 3, 14, 0, 27, 31, 0, 3, 8, 0, 17, 26, 0, 3, 12, 0, 18, 22, 0, 12, 18, 0, 4, 7, 0, 4, 31, 0, 12, 27, 0, 7, 17, 0, 7, 8, 0, 1, 13]
    // Python: for idx, val in enumerate(a): print(f"const_coefficients[6'd{idx:02d}] = 5'd{val:02d};")
    // In [2]: max(a) == 31 # requires 5 bits
    // In [4]: len(a) == 48
    assign const_coefficients[6'd00] = 5'd00;
    assign const_coefficients[6'd01] = 5'd02;
    assign const_coefficients[6'd02] = 5'd04;
    assign const_coefficients[6'd03] = 5'd00;
    assign const_coefficients[6'd04] = 5'd13;
    assign const_coefficients[6'd05] = 5'd22;
    assign const_coefficients[6'd06] = 5'd00;
    assign const_coefficients[6'd07] = 5'd04;
    assign const_coefficients[6'd08] = 5'd19;
    assign const_coefficients[6'd09] = 5'd00;
    assign const_coefficients[6'd10] = 5'd03;
    assign const_coefficients[6'd11] = 5'd14;
    assign const_coefficients[6'd12] = 5'd00;
    assign const_coefficients[6'd13] = 5'd27;
    assign const_coefficients[6'd14] = 5'd31;
    assign const_coefficients[6'd15] = 5'd00;
    assign const_coefficients[6'd16] = 5'd03;
    assign const_coefficients[6'd17] = 5'd08;
    assign const_coefficients[6'd18] = 5'd00;
    assign const_coefficients[6'd19] = 5'd17;
    assign const_coefficients[6'd20] = 5'd26;
    assign const_coefficients[6'd21] = 5'd00;
    assign const_coefficients[6'd22] = 5'd03;
    assign const_coefficients[6'd23] = 5'd12;
    assign const_coefficients[6'd24] = 5'd00;
    assign const_coefficients[6'd25] = 5'd18;
    assign const_coefficients[6'd26] = 5'd22;
    assign const_coefficients[6'd27] = 5'd00;
    assign const_coefficients[6'd28] = 5'd12;
    assign const_coefficients[6'd29] = 5'd18;
    assign const_coefficients[6'd30] = 5'd00;
    assign const_coefficients[6'd31] = 5'd04;
    assign const_coefficients[6'd32] = 5'd07;
    assign const_coefficients[6'd33] = 5'd00;
    assign const_coefficients[6'd34] = 5'd04;
    assign const_coefficients[6'd35] = 5'd31;
    assign const_coefficients[6'd36] = 5'd00;
    assign const_coefficients[6'd37] = 5'd12;
    assign const_coefficients[6'd38] = 5'd27;
    assign const_coefficients[6'd39] = 5'd00;
    assign const_coefficients[6'd40] = 5'd07;
    assign const_coefficients[6'd41] = 5'd17;
    assign const_coefficients[6'd42] = 5'd00;
    assign const_coefficients[6'd43] = 5'd07;
    assign const_coefficients[6'd44] = 5'd08;
    assign const_coefficients[6'd45] = 5'd00;
    assign const_coefficients[6'd46] = 5'd01;
    assign const_coefficients[6'd47] = 5'd13;

    // init the const_injections array register
    // Python: c = [0x6e9e40ae ,  0x71927c02 ,  0x9a13d3b1 , ...]
    // Python: for idx, val in enumerate(c): print(f"assign const_injections[{idx:03d}] = 32'h{val:08X};", end=('\n' if idx%8==7 else ' '))
    assign const_injections[000] = 32'h6E9E40AE; assign const_injections[001] = 32'h71927C02; assign const_injections[002] = 32'h9A13D3B1; assign const_injections[003] = 32'hDAEC32AD; assign const_injections[004] = 32'h3D8951CF; assign const_injections[005] = 32'hE1C9FE9A; assign const_injections[006] = 32'hB806B54C; assign const_injections[007] = 32'hACBBF417;
    assign const_injections[008] = 32'hD3622B3B; assign const_injections[009] = 32'hA082762A; assign const_injections[010] = 32'h9EDCF1C0; assign const_injections[011] = 32'hA9BADA77; assign const_injections[012] = 32'h7F91E46C; assign const_injections[013] = 32'hCB0F6E4F; assign const_injections[014] = 32'h265D9241; assign const_injections[015] = 32'hB7BDEAB0;
    assign const_injections[016] = 32'h6260C9E6; assign const_injections[017] = 32'hFF50DD2A; assign const_injections[018] = 32'h9036AA71; assign const_injections[019] = 32'hCE161879; assign const_injections[020] = 32'hD1307CDF; assign const_injections[021] = 32'h89E456DF; assign const_injections[022] = 32'hF83133E2; assign const_injections[023] = 32'h65F55C3D;
    assign const_injections[024] = 32'h94871B01; assign const_injections[025] = 32'hB5D204CD; assign const_injections[026] = 32'h583A3264; assign const_injections[027] = 32'h5E165957; assign const_injections[028] = 32'h4CBDA964; assign const_injections[029] = 32'h675FCA47; assign const_injections[030] = 32'hF4A3033E; assign const_injections[031] = 32'h2A417322;
    assign const_injections[032] = 32'h3B61432F; assign const_injections[033] = 32'h7F5532F2; assign const_injections[034] = 32'hB609973B; assign const_injections[035] = 32'h1A795239; assign const_injections[036] = 32'h31B477C9; assign const_injections[037] = 32'hD2949D28; assign const_injections[038] = 32'h78969712; assign const_injections[039] = 32'h0EB87B6E;
    assign const_injections[040] = 32'h7E11D22D; assign const_injections[041] = 32'hCCEE88BD; assign const_injections[042] = 32'hEED07EB8; assign const_injections[043] = 32'hE5563A81; assign const_injections[044] = 32'hE7CB6BCF; assign const_injections[045] = 32'h25DE953E; assign const_injections[046] = 32'h4D05653A; assign const_injections[047] = 32'h0B831557;
    assign const_injections[048] = 32'h94B9CD77; assign const_injections[049] = 32'h13F01579; assign const_injections[050] = 32'h794B4A4A; assign const_injections[051] = 32'h67E7C7DC; assign const_injections[052] = 32'hC456D8D4; assign const_injections[053] = 32'h59689C9B; assign const_injections[054] = 32'h668456D7; assign const_injections[055] = 32'h22D2A2E1;
    assign const_injections[056] = 32'h38B3A828; assign const_injections[057] = 32'h0315AC3C; assign const_injections[058] = 32'h438D681E; assign const_injections[059] = 32'hAB7109C5; assign const_injections[060] = 32'h97EE19A8; assign const_injections[061] = 32'hDE062B2E; assign const_injections[062] = 32'h2C76C47B; assign const_injections[063] = 32'h0084456F;
    assign const_injections[064] = 32'h908F0FD3; assign const_injections[065] = 32'hA646551F; assign const_injections[066] = 32'h3E826725; assign const_injections[067] = 32'hD521788E; assign const_injections[068] = 32'h9F01C2B0; assign const_injections[069] = 32'h93180CDC; assign const_injections[070] = 32'h92EA1DF8; assign const_injections[071] = 32'h431A9AAE;
    assign const_injections[072] = 32'h7C2EA356; assign const_injections[073] = 32'hDA33AD03; assign const_injections[074] = 32'h46926893; assign const_injections[075] = 32'h66BDE7D7; assign const_injections[076] = 32'hB501CC75; assign const_injections[077] = 32'h1F6E8A41; assign const_injections[078] = 32'h685250F4; assign const_injections[079] = 32'h3BB1F318;
    assign const_injections[080] = 32'hAF238C04; assign const_injections[081] = 32'h974ED2EC; assign const_injections[082] = 32'h5B159E49; assign const_injections[083] = 32'hD526F8BF; assign const_injections[084] = 32'h12085626; assign const_injections[085] = 32'h3E2432A9; assign const_injections[086] = 32'h6BD20C48; assign const_injections[087] = 32'h1F1D59DA;
    assign const_injections[088] = 32'h18AB1068; assign const_injections[089] = 32'h80F83CF8; assign const_injections[090] = 32'h2C8C11C0; assign const_injections[091] = 32'h7D548035; assign const_injections[092] = 32'h0FF675C3; assign const_injections[093] = 32'hFED160BF; assign const_injections[094] = 32'h74BBBB24; assign const_injections[095] = 32'hD98E006B;
    assign const_injections[096] = 32'hDEAA47EB; assign const_injections[097] = 32'h05F2179E; assign const_injections[098] = 32'h437B0B71; assign const_injections[099] = 32'hA7C95F8F; assign const_injections[100] = 32'h00A99D3B; assign const_injections[101] = 32'h3FC3C444; assign const_injections[102] = 32'h72686F8E; assign const_injections[103] = 32'h00FD01A9;
    assign const_injections[104] = 32'hDEDC0787; assign const_injections[105] = 32'hC6AF7626; assign const_injections[106] = 32'h7012FE76; assign const_injections[107] = 32'hF2A5F7CE; assign const_injections[108] = 32'h9A7B2EDA; assign const_injections[109] = 32'h5E57FCF2; assign const_injections[110] = 32'h4DA0D4AD; assign const_injections[111] = 32'h5C63B155;
    assign const_injections[112] = 32'h34117375; assign const_injections[113] = 32'hD4134C11; assign const_injections[114] = 32'h2EA77435; assign const_injections[115] = 32'h5278B6DE; assign const_injections[116] = 32'hAB522C4C; assign const_injections[117] = 32'hBC8FC702; assign const_injections[118] = 32'hC94A09E4; assign const_injections[119] = 32'hEBB93A9E;
    assign const_injections[120] = 32'h91ECB65E; assign const_injections[121] = 32'h4C52ECC6; assign const_injections[122] = 32'h8703BB52; assign const_injections[123] = 32'hCB2D60AA; assign const_injections[124] = 32'h30A0538A; assign const_injections[125] = 32'h1514F10B; assign const_injections[126] = 32'h157F6329; assign const_injections[127] = 32'h3429DC3D;
    assign const_injections[128] = 32'h5DB73EB2; assign const_injections[129] = 32'hA7A1A969; assign const_injections[130] = 32'h7286BD24; assign const_injections[131] = 32'h0DF6881E; assign const_injections[132] = 32'h3785BA5F; assign const_injections[133] = 32'hCD04623A; assign const_injections[134] = 32'h02758170; assign const_injections[135] = 32'hD827F556;
    assign const_injections[136] = 32'h99D95191; assign const_injections[137] = 32'h84457EB1; assign const_injections[138] = 32'h58A7FB22; assign const_injections[139] = 32'hD2967C5F; assign const_injections[140] = 32'h4F0C33F6; assign const_injections[141] = 32'h4A02099A; assign const_injections[142] = 32'hE0904821; assign const_injections[143] = 32'h94124036;
    assign const_injections[144] = 32'h496A031B; assign const_injections[145] = 32'h780B69C4; assign const_injections[146] = 32'hCF1A4927; assign const_injections[147] = 32'h87A119B8; assign const_injections[148] = 32'hCDFAF4F8; assign const_injections[149] = 32'h4CF9CD0F; assign const_injections[150] = 32'h27C96A84; assign const_injections[151] = 32'h6D11117E;
    assign const_injections[152] = 32'h7F8CF847; assign const_injections[153] = 32'h74CEEDE5; assign const_injections[154] = 32'hC88905E6; assign const_injections[155] = 32'h60215841; assign const_injections[156] = 32'h7172875A; assign const_injections[157] = 32'h736E993A; assign const_injections[158] = 32'h010AA53C; assign const_injections[159] = 32'h43D53C2B;
    assign const_injections[160] = 32'hF0D91A93; assign const_injections[161] = 32'h0D983B56; assign const_injections[162] = 32'hF816663C; assign const_injections[163] = 32'hE5D13363; assign const_injections[164] = 32'h0A61737C; assign const_injections[165] = 32'h09D51150; assign const_injections[166] = 32'h83A5AC2F; assign const_injections[167] = 32'h3E884905;
    assign const_injections[168] = 32'h7B01AEB5; assign const_injections[169] = 32'h600A6EA7; assign const_injections[170] = 32'hB7678F7B; assign const_injections[171] = 32'h72B38977; assign const_injections[172] = 32'h068018F2; assign const_injections[173] = 32'hCE6AE45B; assign const_injections[174] = 32'h29188AA8; assign const_injections[175] = 32'hE5A0B1E9;
    assign const_injections[176] = 32'hC04C2B86; assign const_injections[177] = 32'h8BD14D75; assign const_injections[178] = 32'h648781F3; assign const_injections[179] = 32'hDBAE1E0A; assign const_injections[180] = 32'hDDCDD8AE; assign const_injections[181] = 32'hAB4D81A3; assign const_injections[182] = 32'h446BAABA; assign const_injections[183] = 32'h1CC0C19D;
    assign const_injections[184] = 32'h17BE4F90; assign const_injections[185] = 32'h82C0E65D; assign const_injections[186] = 32'h676F9C95; assign const_injections[187] = 32'h5C708DB2; assign const_injections[188] = 32'h6FD4C867; assign const_injections[189] = 32'hA5106EF0; assign const_injections[190] = 32'h19DDE49D; assign const_injections[191] = 32'h78182F95;
    assign const_injections[192] = 32'hD089CD81; assign const_injections[193] = 32'hA32E98FE; assign const_injections[194] = 32'hBE306C82; assign const_injections[195] = 32'h6CD83D8C; assign const_injections[196] = 32'h037F1BDE; assign const_injections[197] = 32'h0B15722D; assign const_injections[198] = 32'hEDDC1E22; assign const_injections[199] = 32'h93C76559;
    assign const_injections[200] = 32'h8A2F571B; assign const_injections[201] = 32'h92CC81B4; assign const_injections[202] = 32'h021B7477; assign const_injections[203] = 32'h67523904; assign const_injections[204] = 32'hC95DBCCC; assign const_injections[205] = 32'hAC17EE9D; assign const_injections[206] = 32'h944E46BC; assign const_injections[207] = 32'h0781867E;
    assign const_injections[208] = 32'hC854DD9D; assign const_injections[209] = 32'h26E2C30C; assign const_injections[210] = 32'h858C0416; assign const_injections[211] = 32'h6D397708; assign const_injections[212] = 32'hEBE29C58; assign const_injections[213] = 32'hC80CED86; assign const_injections[214] = 32'hD496B4AB; assign const_injections[215] = 32'hBE45E6F5;
    assign const_injections[216] = 32'h10D24706; assign const_injections[217] = 32'hACF8187A; assign const_injections[218] = 32'h96F523CB; assign const_injections[219] = 32'h2227E143; assign const_injections[220] = 32'h78C36564; assign const_injections[221] = 32'h4643ADC2; assign const_injections[222] = 32'h4729D97A; assign const_injections[223] = 32'hCFF93E0D;
    assign const_injections[224] = 32'h25484BBD; assign const_injections[225] = 32'h91C6798E; assign const_injections[226] = 32'h95F773F4; assign const_injections[227] = 32'h44204675; assign const_injections[228] = 32'h2EDA57BA; assign const_injections[229] = 32'h06D313EF; assign const_injections[230] = 32'hEEAA4466; assign const_injections[231] = 32'h2DFA7530;
    assign const_injections[232] = 32'hA8AF0C9B; assign const_injections[233] = 32'h39F1535E; assign const_injections[234] = 32'h0CC2B7BD; assign const_injections[235] = 32'h38A76C0E; assign const_injections[236] = 32'h4F41071D; assign const_injections[237] = 32'hCDAF2475; assign const_injections[238] = 32'h49A6EFF8; assign const_injections[239] = 32'h01621748;
    assign const_injections[240] = 32'h36EBACAB; assign const_injections[241] = 32'hBD6D9A29; assign const_injections[242] = 32'h44D1CD65; assign const_injections[243] = 32'h40815DFD; assign const_injections[244] = 32'h55FA5A1A; assign const_injections[245] = 32'h87CCE9E9; assign const_injections[246] = 32'hAE559B45; assign const_injections[247] = 32'hD76B4C26;
    assign const_injections[248] = 32'h637D60AD; assign const_injections[249] = 32'hDE29F5F9; assign const_injections[250] = 32'h97491CBB; assign const_injections[251] = 32'hFB350040; assign const_injections[252] = 32'hFFE7F997; assign const_injections[253] = 32'h201C9DCD; assign const_injections[254] = 32'hE61320E9; assign const_injections[255] = 32'hA90987A3;
    assign const_injections[256] = 32'hE24AFA83; assign const_injections[257] = 32'h61C1E6FC; assign const_injections[258] = 32'hCC87FF62; assign const_injections[259] = 32'hF1C9D8FA; assign const_injections[260] = 32'h4FD04546; assign const_injections[261] = 32'h90ECC76E; assign const_injections[262] = 32'h46E456B9; assign const_injections[263] = 32'h305DCEB8;
    assign const_injections[264] = 32'hF627E68C; assign const_injections[265] = 32'h2D286815; assign const_injections[266] = 32'hC705BBFD; assign const_injections[267] = 32'h101B6DF3; assign const_injections[268] = 32'h892DAE62; assign const_injections[269] = 32'hD5B7FB44; assign const_injections[270] = 32'hEA1D5C94; assign const_injections[271] = 32'h5332E3CB;
    assign const_injections[272] = 32'hF856F88A; assign const_injections[273] = 32'hB341B0E9; assign const_injections[274] = 32'h28408D9D; assign const_injections[275] = 32'h5421BC17; assign const_injections[276] = 32'hEB9AF9BC; assign const_injections[277] = 32'h602371C5; assign const_injections[278] = 32'h67985A91; assign const_injections[279] = 32'hD774907F;
    assign const_injections[280] = 32'h7C4D697D; assign const_injections[281] = 32'h9370B0B8; assign const_injections[282] = 32'h6FF5CEBB; assign const_injections[283] = 32'h7D465744; assign const_injections[284] = 32'h674CEAC0; assign const_injections[285] = 32'hEA9102FC; assign const_injections[286] = 32'h0DE94784; assign const_injections[287] = 32'hC793DE69;
    assign const_injections[288] = 32'hFE599BB1; assign const_injections[289] = 32'hC6AD952F; assign const_injections[290] = 32'h6D6CA9C3; assign const_injections[291] = 32'h928C3F91; assign const_injections[292] = 32'hF9022F05; assign const_injections[293] = 32'h24A164DC; assign const_injections[294] = 32'hE5E98CD3; assign const_injections[295] = 32'h7649EFDB;
    assign const_injections[296] = 32'h6DF3BCDB; assign const_injections[297] = 32'h5D1E9FF1; assign const_injections[298] = 32'h17F5D010; assign const_injections[299] = 32'hE2686EA1; assign const_injections[300] = 32'h6EAC77FE; assign const_injections[301] = 32'h7BB5C585; assign const_injections[302] = 32'h88D90CBB; assign const_injections[303] = 32'h18689163;
    assign const_injections[304] = 32'h67C9EFA5; assign const_injections[305] = 32'hC0B76D9B; assign const_injections[306] = 32'h960EFBAB; assign const_injections[307] = 32'hBD872807; assign const_injections[308] = 32'h70F4C474; assign const_injections[309] = 32'h56C29D20; assign const_injections[310] = 32'hD1541D15; assign const_injections[311] = 32'h88137033;
    assign const_injections[312] = 32'hE3F02B3E; assign const_injections[313] = 32'hB6D9B28D; assign const_injections[314] = 32'h53A077BA; assign const_injections[315] = 32'hEEDCD29E; assign const_injections[316] = 32'hA50A6C1D; assign const_injections[317] = 32'h12C2801E; assign const_injections[318] = 32'h52BA335B; assign const_injections[319] = 32'h35984614;
    assign const_injections[320] = 32'hE2599AA8; assign const_injections[321] = 32'hAF94ED1D; assign const_injections[322] = 32'hD90D4767; assign const_injections[323] = 32'h202C7D07; assign const_injections[324] = 32'h77BEC4F4; assign const_injections[325] = 32'hFA71BC80; assign const_injections[326] = 32'hFC5C8B76; assign const_injections[327] = 32'h8D0FBBFC;
    assign const_injections[328] = 32'hDA366DC6; assign const_injections[329] = 32'h8B32A0C7; assign const_injections[330] = 32'h1B36F7FC; assign const_injections[331] = 32'h6642DCBC; assign const_injections[332] = 32'h6FE7E724; assign const_injections[333] = 32'h8B5FA782; assign const_injections[334] = 32'hC4227404; assign const_injections[335] = 32'h3A7D1DA7;
    assign const_injections[336] = 32'h517ED658; assign const_injections[337] = 32'h8A18DF6D; assign const_injections[338] = 32'h3E5C9B23; assign const_injections[339] = 32'h1FBD51EF; assign const_injections[340] = 32'h1470601D; assign const_injections[341] = 32'h3400389C; assign const_injections[342] = 32'h676B065D; assign const_injections[343] = 32'h8864AD80;
    assign const_injections[344] = 32'hEA6F1A9C; assign const_injections[345] = 32'h2DB484E1; assign const_injections[346] = 32'h608785F0; assign const_injections[347] = 32'h8DD384AF; assign const_injections[348] = 32'h69D26699; assign const_injections[349] = 32'h409C4E16; assign const_injections[350] = 32'h77F9986A; assign const_injections[351] = 32'h7F491266;
    assign const_injections[352] = 32'h883EA6CF; assign const_injections[353] = 32'hEAA06072; assign const_injections[354] = 32'hFA2E5DB5; assign const_injections[355] = 32'h352594B4; assign const_injections[356] = 32'h9156BB89; assign const_injections[357] = 32'hA2FBBBFB; assign const_injections[358] = 32'hAC3989C7; assign const_injections[359] = 32'h6E2422B1;
    assign const_injections[360] = 32'h581F3560; assign const_injections[361] = 32'h1009A9B5; assign const_injections[362] = 32'h7E5AD9CD; assign const_injections[363] = 32'hA9FC0A6E; assign const_injections[364] = 32'h43E5998E; assign const_injections[365] = 32'h7F8778F9; assign const_injections[366] = 32'hF038F8E1; assign const_injections[367] = 32'h5415C2E8;
    assign const_injections[368] = 32'h6499B731; assign const_injections[369] = 32'hB82389AE; assign const_injections[370] = 32'h05D4D819; assign const_injections[371] = 32'h0F06440E; assign const_injections[372] = 32'hF1735AA0; assign const_injections[373] = 32'h986430EE; assign const_injections[374] = 32'h47EC952C; assign const_injections[375] = 32'hBF149CC5;
    assign const_injections[376] = 32'hB3CB2CB6; assign const_injections[377] = 32'h3F41E8C2; assign const_injections[378] = 32'h271AC51B; assign const_injections[379] = 32'h48AC5DED; assign const_injections[380] = 32'hF76A0469; assign const_injections[381] = 32'h717BBA4D; assign const_injections[382] = 32'h4F5C90D6; assign const_injections[383] = 32'h3B74F756;
    assign const_injections[384] = 32'h1824110A; assign const_injections[385] = 32'hA4FD43E3; assign const_injections[386] = 32'h1EB0507C; assign const_injections[387] = 32'hA9375C08; assign const_injections[388] = 32'h157C59A7; assign const_injections[389] = 32'h0CAD8F51; assign const_injections[390] = 32'hD66031A0; assign const_injections[391] = 32'hABB5343F;
    assign const_injections[392] = 32'hE533FA43; assign const_injections[393] = 32'h1996E2BB; assign const_injections[394] = 32'hD7953A71; assign const_injections[395] = 32'hD2529B94; assign const_injections[396] = 32'h58F0FA07; assign const_injections[397] = 32'h4C9B1877; assign const_injections[398] = 32'h057E990D; assign const_injections[399] = 32'h8BFE19C4;
    assign const_injections[400] = 32'hA8E2C0C9; assign const_injections[401] = 32'h99FCAADA; assign const_injections[402] = 32'h69D2AACA; assign const_injections[403] = 32'hDC1C4642; assign const_injections[404] = 32'hF4D22307; assign const_injections[405] = 32'h7FE27E8C; assign const_injections[406] = 32'h1366AA07; assign const_injections[407] = 32'h1594E637;
    assign const_injections[408] = 32'hCE1066BF; assign const_injections[409] = 32'hDB922552; assign const_injections[410] = 32'h9930B52A; assign const_injections[411] = 32'hAEAA9A3E; assign const_injections[412] = 32'h31FF7EB4; assign const_injections[413] = 32'h5E1F945A; assign const_injections[414] = 32'h150AC49C; assign const_injections[415] = 32'h0CCDAC2D;
    assign const_injections[416] = 32'hD8A8A217; assign const_injections[417] = 32'hB82EA6E5; assign const_injections[418] = 32'hD6A74659; assign const_injections[419] = 32'h67B7E3E6; assign const_injections[420] = 32'h836EEF4A; assign const_injections[421] = 32'hB6F90074; assign const_injections[422] = 32'h7FA3EA4B; assign const_injections[423] = 32'hCB038123;
    assign const_injections[424] = 32'hBF069F55; assign const_injections[425] = 32'h1FA83FC4; assign const_injections[426] = 32'hD6EBDB23; assign const_injections[427] = 32'h16F0A137; assign const_injections[428] = 32'h19A7110D; assign const_injections[429] = 32'h5FF3B55F; assign const_injections[430] = 32'hFB633868; assign const_injections[431] = 32'hB466F845;
    assign const_injections[432] = 32'hBCE0C198; assign const_injections[433] = 32'h88404296; assign const_injections[434] = 32'hDDBDD88B; assign const_injections[435] = 32'h7FC52546; assign const_injections[436] = 32'h63A553F8; assign const_injections[437] = 32'hA728405A; assign const_injections[438] = 32'h378A2BCE; assign const_injections[439] = 32'h6862E570;
    assign const_injections[440] = 32'hEFB77E7D; assign const_injections[441] = 32'hC611625E; assign const_injections[442] = 32'h32515C15; assign const_injections[443] = 32'h6984B765; assign const_injections[444] = 32'hE8405976; assign const_injections[445] = 32'h9BA386FD; assign const_injections[446] = 32'hD4EED4D9; assign const_injections[447] = 32'hF8FE0309;
    assign const_injections[448] = 32'h0CE54601; assign const_injections[449] = 32'hBAF879C2; assign const_injections[450] = 32'hD8524057; assign const_injections[451] = 32'h1D8C1D7A; assign const_injections[452] = 32'h72C0A3A9; assign const_injections[453] = 32'h5A1FFBDE; assign const_injections[454] = 32'h82F33A45; assign const_injections[455] = 32'h5143F446;
    assign const_injections[456] = 32'h29C7E182; assign const_injections[457] = 32'hE536C32F; assign const_injections[458] = 32'h5A6F245B; assign const_injections[459] = 32'h44272ADB; assign const_injections[460] = 32'hCB701D9C; assign const_injections[461] = 32'hF76137EC; assign const_injections[462] = 32'h0841F145; assign const_injections[463] = 32'hE7042ECC;
    assign const_injections[464] = 32'hF1277DD7; assign const_injections[465] = 32'h745CF92C; assign const_injections[466] = 32'hA8FE65FE; assign const_injections[467] = 32'hD3E2D7CF; assign const_injections[468] = 32'h54C513EF; assign const_injections[469] = 32'h6079BC2D; assign const_injections[470] = 32'hB66336B0; assign const_injections[471] = 32'h101E383B;
    assign const_injections[472] = 32'hBCD75753; assign const_injections[473] = 32'h25BE238A; assign const_injections[474] = 32'h56A6F0BE; assign const_injections[475] = 32'hEEFFCC17; assign const_injections[476] = 32'h5EA31F3D; assign const_injections[477] = 32'h0AE772F5; assign const_injections[478] = 32'hF76DE3DE; assign const_injections[479] = 32'h1BBECDAD;
    assign const_injections[480] = 32'hC9107D43; assign const_injections[481] = 32'hF7E38DCE; assign const_injections[482] = 32'h618358CD; assign const_injections[483] = 32'h5C833F04; assign const_injections[484] = 32'hF6975906; assign const_injections[485] = 32'hDE4177E5; assign const_injections[486] = 32'h67D314DC; assign const_injections[487] = 32'hB4760F3E;
    assign const_injections[488] = 32'h56CE5888; assign const_injections[489] = 32'h0E8345A8; assign const_injections[490] = 32'hBFF6B1BF; assign const_injections[491] = 32'h78DFB112; assign const_injections[492] = 32'hF1709C1E; assign const_injections[493] = 32'h7BB8ED8B; assign const_injections[494] = 32'h902402B9; assign const_injections[495] = 32'hDAA64AE0;
    assign const_injections[496] = 32'h46B71D89; assign const_injections[497] = 32'h7EEE035F; assign const_injections[498] = 32'hBE376509; assign const_injections[499] = 32'h99648F3A; assign const_injections[500] = 32'h0863EA1F; assign const_injections[501] = 32'h49AD8887; assign const_injections[502] = 32'h79BDECC5; assign const_injections[503] = 32'h3C10B568;
    assign const_injections[504] = 32'h5F2E4BAE; assign const_injections[505] = 32'h04EF20AB; assign const_injections[506] = 32'h72F8CE7B; assign const_injections[507] = 32'h521E1EBE; assign const_injections[508] = 32'h14525535; assign const_injections[509] = 32'h2E8AF95B; assign const_injections[510] = 32'h9094CCFD; assign const_injections[511] = 32'hBCF36713;
    assign const_injections[512] = 32'hC73953EF; assign const_injections[513] = 32'hD4B91474; assign const_injections[514] = 32'h6554EC2D; assign const_injections[515] = 32'hE3885C96; assign const_injections[516] = 32'h03DC73B7; assign const_injections[517] = 32'h931688A9; assign const_injections[518] = 32'hCBBEF182; assign const_injections[519] = 32'h2B77CFC9;
    assign const_injections[520] = 32'h632A32BD; assign const_injections[521] = 32'hD2115DCC; assign const_injections[522] = 32'h1AE5533D; assign const_injections[523] = 32'h32684E13; assign const_injections[524] = 32'h4CC5A004; assign const_injections[525] = 32'h13321BDE; assign const_injections[526] = 32'h62CBD38D; assign const_injections[527] = 32'h78383A3B;
    assign const_injections[528] = 32'hD00686F1; assign const_injections[529] = 32'h9F601EE7; assign const_injections[530] = 32'h7EAF23DE; assign const_injections[531] = 32'h3110C492; assign const_injections[532] = 32'h9C351209; assign const_injections[533] = 32'h7EB89D52; assign const_injections[534] = 32'h6D566EAC; assign const_injections[535] = 32'hC2EFD226;
    assign const_injections[536] = 32'h32E9FAC5; assign const_injections[537] = 32'h52227274; assign const_injections[538] = 32'h09F84725; assign const_injections[539] = 32'hB8D0B605; assign const_injections[540] = 32'h72291F02; assign const_injections[541] = 32'h71B5C34B; assign const_injections[542] = 32'h3DBFCBB8; assign const_injections[543] = 32'h04A02263;
    assign const_injections[544] = 32'h55BA597F; assign const_injections[545] = 32'hD4E4037D; assign const_injections[546] = 32'hC813E1BE; assign const_injections[547] = 32'hFFDDEEFA; assign const_injections[548] = 32'hC3C058F3; assign const_injections[549] = 32'h87010F2E; assign const_injections[550] = 32'h1DFCF55F; assign const_injections[551] = 32'hC694EEEB;
    assign const_injections[552] = 32'hA9C01A74; assign const_injections[553] = 32'h98C2FC6B; assign const_injections[554] = 32'hE57E1428; assign const_injections[555] = 32'hDD265A71; assign const_injections[556] = 32'h836B956D; assign const_injections[557] = 32'h7E46AB1A; assign const_injections[558] = 32'h5835D541; assign const_injections[559] = 32'h50B32505;
    assign const_injections[560] = 32'hE640913C; assign const_injections[561] = 32'hBB486079; assign const_injections[562] = 32'hFE496263; assign const_injections[563] = 32'h113C5B69; assign const_injections[564] = 32'h93CD6620; assign const_injections[565] = 32'h5EFE823B; assign const_injections[566] = 32'h2D657B40; assign const_injections[567] = 32'hB46DFC6C;
    assign const_injections[568] = 32'h57710C69; assign const_injections[569] = 32'hFE9FADEB; assign const_injections[570] = 32'hB5F8728A; assign const_injections[571] = 32'hE3224170; assign const_injections[572] = 32'hCA28B751; assign const_injections[573] = 32'hFDABAE56; assign const_injections[574] = 32'h5AB12C3C; assign const_injections[575] = 32'hA697C457;
    assign const_injections[576] = 32'hD28FA2B7; assign const_injections[577] = 32'h056579F2; assign const_injections[578] = 32'h9FD9D810; assign const_injections[579] = 32'hE3557478; assign const_injections[580] = 32'hD88D89AB; assign const_injections[581] = 32'hA72A9422; assign const_injections[582] = 32'h6D47ABD0; assign const_injections[583] = 32'h405BCBD9;
    assign const_injections[584] = 32'h6F83EBAF; assign const_injections[585] = 32'h13CAEC76; assign const_injections[586] = 32'hFCEB9EE2; assign const_injections[587] = 32'h2E922DF7; assign const_injections[588] = 32'hCE9856DF; assign const_injections[589] = 32'hC05E9322; assign const_injections[590] = 32'h2772C854; assign const_injections[591] = 32'hB67F2A32;
    assign const_injections[592] = 32'h6D1AF28D; assign const_injections[593] = 32'h3A78CF77; assign const_injections[594] = 32'hDFF411E4; assign const_injections[595] = 32'h61C74CA9; assign const_injections[596] = 32'hED8B842E; assign const_injections[597] = 32'h72880845; assign const_injections[598] = 32'h6E857085; assign const_injections[599] = 32'hC6404932;
    assign const_injections[600] = 32'hEE37F6BC; assign const_injections[601] = 32'h27116F48; assign const_injections[602] = 32'h5E9EC45A; assign const_injections[603] = 32'h8EA2A51F; assign const_injections[604] = 32'hA5573DB7; assign const_injections[605] = 32'hA746D036; assign const_injections[606] = 32'h486B4768; assign const_injections[607] = 32'h5B438F3B;
    assign const_injections[608] = 32'h18C54A5C; assign const_injections[609] = 32'h64FCF08E; assign const_injections[610] = 32'hE993CDC1; assign const_injections[611] = 32'h35C1EAD3; assign const_injections[612] = 32'h9DE07DE7; assign const_injections[613] = 32'h321B841C; assign const_injections[614] = 32'h87423C5E; assign const_injections[615] = 32'h071AA0F6;
    assign const_injections[616] = 32'h962EB75B; assign const_injections[617] = 32'hBB06BDD2; assign const_injections[618] = 32'hDCDB5363; assign const_injections[619] = 32'h389752F2; assign const_injections[620] = 32'h83D9CC88; assign const_injections[621] = 32'hD014ADC6; assign const_injections[622] = 32'hC71121BB; assign const_injections[623] = 32'h2372F938;
    assign const_injections[624] = 32'hCAFF2650; assign const_injections[625] = 32'h62BE8951; assign const_injections[626] = 32'h56DCCAFF; assign const_injections[627] = 32'hAC4084C0; assign const_injections[628] = 32'h09712E95; assign const_injections[629] = 32'h1D3C288F; assign const_injections[630] = 32'h1B085744; assign const_injections[631] = 32'hE1D3CFEF;
    assign const_injections[632] = 32'h5C9A812E; assign const_injections[633] = 32'h6611FD59; assign const_injections[634] = 32'h85E46044; assign const_injections[635] = 32'h1981D885; assign const_injections[636] = 32'h5A4C903F; assign const_injections[637] = 32'h43F30D4B; assign const_injections[638] = 32'h7D1D601B; assign const_injections[639] = 32'hDD3C3391;
    assign const_injections[640] = 32'h030EC65E; assign const_injections[641] = 32'hC12878CD; assign const_injections[642] = 32'h72E795FE; assign const_injections[643] = 32'hD0C76ABD; assign const_injections[644] = 32'h1EC085DB; assign const_injections[645] = 32'h7CBB61FA; assign const_injections[646] = 32'h93E8DD1E; assign const_injections[647] = 32'h8582EB06;
    assign const_injections[648] = 32'h73563144; assign const_injections[649] = 32'h049D4E7E; assign const_injections[650] = 32'h5FD5AEFE; assign const_injections[651] = 32'h7B842A00; assign const_injections[652] = 32'h75CED665; assign const_injections[653] = 32'hBB32D458; assign const_injections[654] = 32'h4E83BBA7; assign const_injections[655] = 32'h8F15151F;
    assign const_injections[656] = 32'h7795A125; assign const_injections[657] = 32'hF0842455; assign const_injections[658] = 32'h499AF99D; assign const_injections[659] = 32'h565CC7FA; assign const_injections[660] = 32'hA3B1278D; assign const_injections[661] = 32'h3F27CE74; assign const_injections[662] = 32'h96CA058E; assign const_injections[663] = 32'h8A497443;
    assign const_injections[664] = 32'hA6FB8CAE; assign const_injections[665] = 32'hC115AA21; assign const_injections[666] = 32'h17504923; assign const_injections[667] = 32'hE4932402; assign const_injections[668] = 32'hAEA886C2; assign const_injections[669] = 32'h8EB79AF5; assign const_injections[670] = 32'hEBD5EA6B; assign const_injections[671] = 32'hC7980D3B;
    assign const_injections[672] = 32'h71369315; assign const_injections[673] = 32'h796E6A66; assign const_injections[674] = 32'h3A7EC708; assign const_injections[675] = 32'hB05175C8; assign const_injections[676] = 32'hE02B74E7; assign const_injections[677] = 32'hEB377AD3; assign const_injections[678] = 32'h6C8C1F54; assign const_injections[679] = 32'hB980C374;
    assign const_injections[680] = 32'h59AEE281; assign const_injections[681] = 32'h449CB799; assign const_injections[682] = 32'hE01F5605; assign const_injections[683] = 32'hED0E085E; assign const_injections[684] = 32'hC9A1A3B4; assign const_injections[685] = 32'hAAC481B1; assign const_injections[686] = 32'hC935C39C; assign const_injections[687] = 32'hB7D8CE7F;

    
    // assign inputs to internal wire/reg (in the future, store the input to a register)
    generate
        for (i = 0; i < 16; i=i+1) begin
            // always_ff @(posedge start_eval) begin
            //     state_input_store[i] <= state_input[i];
            //     round_num_store <= round_num;
            // end

            assign state_input_store[i] = state_input[i];
        end
    endgenerate
    assign round_num_store = round_num;

    // assign the bit_matrix stage (combinationally)
    generate
        for (j = 0; j < 16; j=j+1) begin // j = matrix column number
            byte j_byte = j;
            assign bitmatrix_step_output_state[j] = (
                    (( {32{const_bit_matrix[8'h00 | j_byte]}}) & state_input_store[4'h0]) ^
                    (( {32{const_bit_matrix[8'h10 | j_byte]}}) & state_input_store[4'h1]) ^
                    (( {32{const_bit_matrix[8'h20 | j_byte]}}) & state_input_store[4'h2]) ^
                    (( {32{const_bit_matrix[8'h30 | j_byte]}}) & state_input_store[4'h3]) ^
                    (( {32{const_bit_matrix[8'h40 | j_byte]}}) & state_input_store[4'h4]) ^
                    (( {32{const_bit_matrix[8'h50 | j_byte]}}) & state_input_store[4'h5]) ^
                    (( {32{const_bit_matrix[8'h60 | j_byte]}}) & state_input_store[4'h6]) ^
                    (( {32{const_bit_matrix[8'h70 | j_byte]}}) & state_input_store[4'h7]) ^
                    (( {32{const_bit_matrix[8'h80 | j_byte]}}) & state_input_store[4'h8]) ^
                    (( {32{const_bit_matrix[8'h90 | j_byte]}}) & state_input_store[4'h9]) ^
                    (( {32{const_bit_matrix[8'hA0 | j_byte]}}) & state_input_store[4'hA]) ^
                    (( {32{const_bit_matrix[8'hB0 | j_byte]}}) & state_input_store[4'hB]) ^
                    (( {32{const_bit_matrix[8'hC0 | j_byte]}}) & state_input_store[4'hC]) ^
                    (( {32{const_bit_matrix[8'hD0 | j_byte]}}) & state_input_store[4'hD]) ^
                    (( {32{const_bit_matrix[8'hE0 | j_byte]}}) & state_input_store[4'hE]) ^
                    (( {32{const_bit_matrix[8'hF0 | j_byte]}}) & state_input_store[4'hF])
                );
        end
    endgenerate

    // circulant multiplication stage
    generate
        for (j = 0; j < 16; j++) begin
            // byte j_byte = j;
            assign circulant_step_output_state[j] = (
                                (bitmatrix_step_output_state[j])  ^  
                                (bitmatrix_step_output_state[j] << const_coefficients[3*j+1]) ^
                                (bitmatrix_step_output_state[j] >> (32 - const_coefficients[3*j+1])) ^
                                (bitmatrix_step_output_state[j] << const_coefficients[3*j+2]) ^
                                (bitmatrix_step_output_state[j] >> (32 - const_coefficients[3*j+2]))
                            );
        end
    endgenerate

    // injection constants stage
    generate
        for (j = 0; j < 16; j++) begin
            assign const_inj_idx[j] = {round_num_store[5:0], j[3:0]};
            assign injection_step_output_state[j] = circulant_step_output_state[j] ^
                                                        const_injections[(round_num_store << 4) | j];
        end
    endgenerate

    // addrotadd stage
    generate
        for (j = 0; j < 16; j+=2) begin
            assign addrotadd_step_intermed1[j >> 1] = injection_step_output_state[j] + injection_step_output_state[j+1];
            assign addrotadd_step_output_state[j] = (addrotadd_step_intermed1[j >> 1] << 8) ^ (addrotadd_step_intermed1[j >> 1] >> 24);
            assign addrotadd_step_output_state[j+1] = addrotadd_step_output_state[j] + 
                            ((injection_step_output_state[j+1] << 24) ^ (injection_step_output_state[j+1] >> 8));
        end
    endgenerate

    // copy addrotadd_step_output_state (final operation) to state_output
    generate
        for (i = 0; i < 16; i=i+1) begin
            assign state_output[i] = addrotadd_step_output_state[i];
        end
    endgenerate

    initial begin
        /*
        $monitor("Time=%d, round_num=%d,\nbitmatrix_step_output_state=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\ncirculant_step_output_state=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\ninjection_step_output_state=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\naddrotadd_step_output_state=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
            $time, round_num_store,
            bitmatrix_step_output_state[0], bitmatrix_step_output_state[1], bitmatrix_step_output_state[2],
            bitmatrix_step_output_state[3], bitmatrix_step_output_state[4], bitmatrix_step_output_state[5],
            bitmatrix_step_output_state[6], bitmatrix_step_output_state[7], bitmatrix_step_output_state[8],
            bitmatrix_step_output_state[9], bitmatrix_step_output_state[10], bitmatrix_step_output_state[11],
            bitmatrix_step_output_state[12], bitmatrix_step_output_state[13], bitmatrix_step_output_state[14],
            bitmatrix_step_output_state[15],

            circulant_step_output_state[0], circulant_step_output_state[1], circulant_step_output_state[2],
            circulant_step_output_state[3], circulant_step_output_state[4], circulant_step_output_state[5],
            circulant_step_output_state[6], circulant_step_output_state[7], circulant_step_output_state[8],
            circulant_step_output_state[9], circulant_step_output_state[10], circulant_step_output_state[11],
            circulant_step_output_state[12], circulant_step_output_state[13], circulant_step_output_state[14],
            circulant_step_output_state[15],

            injection_step_output_state[0], injection_step_output_state[1], injection_step_output_state[2],
            injection_step_output_state[3], injection_step_output_state[4], injection_step_output_state[5],
            injection_step_output_state[6], injection_step_output_state[7], injection_step_output_state[8],
            injection_step_output_state[9], injection_step_output_state[10], injection_step_output_state[11],
            injection_step_output_state[12], injection_step_output_state[13], injection_step_output_state[14],
            injection_step_output_state[15],

            addrotadd_step_output_state[0], addrotadd_step_output_state[1], addrotadd_step_output_state[2],
            addrotadd_step_output_state[3], addrotadd_step_output_state[4], addrotadd_step_output_state[5],
            addrotadd_step_output_state[6], addrotadd_step_output_state[7], addrotadd_step_output_state[8],
            addrotadd_step_output_state[9], addrotadd_step_output_state[10], addrotadd_step_output_state[11],
            addrotadd_step_output_state[12], addrotadd_step_output_state[13], addrotadd_step_output_state[14],
            addrotadd_step_output_state[15]
        );
        */
    end

endmodule
