// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This file contains the TRNG wrapper, which XORes 10 ring oscillator result
// together and feeds into a 128-bit long FIFO.


module trng_wrapper (clk, resetn, random_num);
input clk;
input resetn;
output reg [127:0] random_num;

parameter NUMRO_TRNG = 10;

wire random_bit;
wire [NUMRO_TRNG-1:0] ind_ro_output;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        random_num <= 128'h0;
    else
        random_num <= {random_num[126:0], random_bit};


generate
genvar 	      i;
for (i = 0; i < NUMRO_TRNG; i = i + 1)
    begin: Ring_Osc
        ringosc RO (ind_ro_output[i]);
    end
endgenerate

assign random_bit = ^ind_ro_output;

endmodule
