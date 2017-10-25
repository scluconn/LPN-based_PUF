// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is a pipelined 128*128 matrix and 128 bit vector multiplier.  

module matrix_mul(clk, resetn, a, b, e, o);

input clk;
input resetn;
input [16383:0] a;
input [127:0] b;
input [127:0] e;
output [127:0] o;

wire [127:0] int_val;
reg [127:0] int_val_reg;
reg [63:0] temp_b;


always @ (posedge clk or negedge resetn)
    if (!resetn)
        int_val_reg <= 128'h0;
    else
        int_val_reg <= int_val;
always @ (posedge clk or negedge resetn)
    if (!resetn)
        temp_b <= 63'h0;
    else
        temp_b <= b[63:0];

genvar genvar_i;

generate
    for (genvar_i = 0; genvar_i < 128; genvar_i= genvar_i+1)
    begin: mul_level1
        assign o[genvar_i] = int_val_reg[genvar_i] ^ (a[genvar_i * 128 +0] & temp_b[0]) ^ (a[genvar_i * 128 +1] & temp_b[1]) ^ (a[genvar_i * 128 +2] & temp_b[2]) ^ (a[genvar_i * 128 +3] & temp_b[3]) ^ (a[genvar_i * 128 +4] & temp_b[4]) ^ (a[genvar_i * 128 +5] & temp_b[5]) ^ (a[genvar_i * 128 +6] & temp_b[6]) ^ (a[genvar_i * 128 +7] & temp_b[7]) ^ (a[genvar_i * 128 +8] & temp_b[8]) ^ (a[genvar_i * 128 +9] & temp_b[9]) ^ (a[genvar_i * 128 +10] & temp_b[10]) ^ (a[genvar_i * 128 +11] & temp_b[11]) ^ (a[genvar_i * 128 +12] & temp_b[12]) ^ (a[genvar_i * 128 +13] & temp_b[13]) ^ (a[genvar_i * 128 +14] & temp_b[14]) ^ (a[genvar_i * 128 +15] & temp_b[15]) ^ (a[genvar_i * 128 +16] & temp_b[16]) ^ (a[genvar_i * 128 +17] & temp_b[17]) ^ (a[genvar_i * 128 +18] & temp_b[18]) ^ (a[genvar_i * 128 +19] & temp_b[19]) ^ (a[genvar_i * 128 +20] & temp_b[20]) ^ (a[genvar_i * 128 +21] & temp_b[21]) ^ (a[genvar_i * 128 +22] & temp_b[22]) ^ (a[genvar_i * 128 +23] & temp_b[23]) ^ (a[genvar_i * 128 +24] & temp_b[24]) ^ (a[genvar_i * 128 +25] & temp_b[25]) ^ (a[genvar_i * 128 +26] & temp_b[26]) ^ (a[genvar_i * 128 +27] & temp_b[27]) ^ (a[genvar_i * 128 +28] & temp_b[28]) ^ (a[genvar_i * 128 +29] & temp_b[29]) ^ (a[genvar_i * 128 +30] & temp_b[30]) ^ (a[genvar_i * 128 +31] & temp_b[31]) ^ (a[genvar_i * 128 +32] & temp_b[32]) ^ (a[genvar_i * 128 +33] & temp_b[33]) ^ (a[genvar_i * 128 +34] & temp_b[34]) ^ (a[genvar_i * 128 +35] & temp_b[35]) ^ (a[genvar_i * 128 +36] & temp_b[36]) ^ (a[genvar_i * 128 +37] & temp_b[37]) ^ (a[genvar_i * 128 +38] & temp_b[38]) ^ (a[genvar_i * 128 +39] & temp_b[39]) ^ (a[genvar_i * 128 +40] & temp_b[40]) ^ (a[genvar_i * 128 +41] & temp_b[41]) ^ (a[genvar_i * 128 +42] & temp_b[42]) ^ (a[genvar_i * 128 +43] & temp_b[43]) ^ (a[genvar_i * 128 +44] & temp_b[44]) ^ (a[genvar_i * 128 +45] & temp_b[45]) ^ (a[genvar_i * 128 +46] & temp_b[46]) ^ (a[genvar_i * 128 +47] & temp_b[47]) ^ (a[genvar_i * 128 +48] & temp_b[48]) ^ (a[genvar_i * 128 +49] & temp_b[49]) ^ (a[genvar_i * 128 +50] & temp_b[50]) ^ (a[genvar_i * 128 +51] & temp_b[51]) ^ (a[genvar_i * 128 +52] & temp_b[52]) ^ (a[genvar_i * 128 +53] & temp_b[53]) ^ (a[genvar_i * 128 +54] & temp_b[54]) ^ (a[genvar_i * 128 +55] & temp_b[55]) ^ (a[genvar_i * 128 +56] & temp_b[56]) ^ (a[genvar_i * 128 +57] & temp_b[57]) ^ (a[genvar_i * 128 +58] & temp_b[58]) ^ (a[genvar_i * 128 +59] & temp_b[59]) ^ (a[genvar_i * 128 +60] & temp_b[60]) ^ (a[genvar_i * 128 +61] & temp_b[61]) ^ (a[genvar_i * 128 +62] & temp_b[62]) ^ (a[genvar_i * 128 +63] & temp_b[63]);
        assign int_val[genvar_i] = (a[genvar_i * 128 +64] & b[64]) ^ (a[genvar_i * 128 +65] & b[65]) ^ (a[genvar_i * 128 +66] & b[66]) ^ (a[genvar_i * 128 +67] & b[67]) ^ (a[genvar_i * 128 +68] & b[68]) ^ (a[genvar_i * 128 +69] & b[69]) ^ (a[genvar_i * 128 +70] & b[70]) ^ (a[genvar_i * 128 +71] & b[71]) ^ (a[genvar_i * 128 +72] & b[72]) ^ (a[genvar_i * 128 +73] & b[73]) ^ (a[genvar_i * 128 +74] & b[74]) ^ (a[genvar_i * 128 +75] & b[75]) ^ (a[genvar_i * 128 +76] & b[76]) ^ (a[genvar_i * 128 +77] & b[77]) ^ (a[genvar_i * 128 +78] & b[78]) ^ (a[genvar_i * 128 +79] & b[79]) ^ (a[genvar_i * 128 +80] & b[80]) ^ (a[genvar_i * 128 +81] & b[81]) ^ (a[genvar_i * 128 +82] & b[82]) ^ (a[genvar_i * 128 +83] & b[83]) ^ (a[genvar_i * 128 +84] & b[84]) ^ (a[genvar_i * 128 +85] & b[85]) ^ (a[genvar_i * 128 +86] & b[86]) ^ (a[genvar_i * 128 +87] & b[87]) ^ (a[genvar_i * 128 +88] & b[88]) ^ (a[genvar_i * 128 +89] & b[89]) ^ (a[genvar_i * 128 +90] & b[90]) ^ (a[genvar_i * 128 +91] & b[91]) ^ (a[genvar_i * 128 +92] & b[92]) ^ (a[genvar_i * 128 +93] & b[93]) ^ (a[genvar_i * 128 +94] & b[94]) ^ (a[genvar_i * 128 +95] & b[95]) ^ (a[genvar_i * 128 +96] & b[96]) ^ (a[genvar_i * 128 +97] & b[97]) ^ (a[genvar_i * 128 +98] & b[98]) ^ (a[genvar_i * 128 +99] & b[99]) ^ (a[genvar_i * 128 +100] & b[100]) ^ (a[genvar_i * 128 +101] & b[101]) ^ (a[genvar_i * 128 +102] & b[102]) ^ (a[genvar_i * 128 +103] & b[103]) ^ (a[genvar_i * 128 +104] & b[104]) ^ (a[genvar_i * 128 +105] & b[105]) ^ (a[genvar_i * 128 +106] & b[106]) ^ (a[genvar_i * 128 +107] & b[107]) ^ (a[genvar_i * 128 +108] & b[108]) ^ (a[genvar_i * 128 +109] & b[109]) ^ (a[genvar_i * 128 +110] & b[110]) ^ (a[genvar_i * 128 +111] & b[111]) ^ (a[genvar_i * 128 +112] & b[112]) ^ (a[genvar_i * 128 +113] & b[113]) ^ (a[genvar_i * 128 +114] & b[114]) ^ (a[genvar_i * 128 +115] & b[115]) ^ (a[genvar_i * 128 +116] & b[116]) ^ (a[genvar_i * 128 +117] & b[117]) ^ (a[genvar_i * 128 +118] & b[118]) ^ (a[genvar_i * 128 +119] & b[119]) ^ (a[genvar_i * 128 +120] & b[120]) ^ (a[genvar_i * 128 +121] & b[121]) ^ (a[genvar_i * 128 +122] & b[122]) ^ (a[genvar_i * 128 +123] & b[123]) ^ (a[genvar_i * 128 +124] & b[124]) ^ (a[genvar_i * 128 +125] & b[125]) ^ (a[genvar_i * 128 +126] & b[126]) ^ (a[genvar_i * 128 +127] & b[127]) ^ e[genvar_i];
    end
endgenerate

endmodule

