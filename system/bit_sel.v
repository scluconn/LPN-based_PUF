// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This module selects 128 or 256 valid bits of e vector from 450 bits. 
// The input number_select controls it to select 128 or 256 bits.

module bit_sel (clk, resetn, en, number_select, start, e_w, index_w, selected_e, done);
input clk;
input resetn;
input en;
input [8:0] number_select;
input start;
input [449:0] e_w;
input [449:0] index_w;
output reg [255:0] selected_e;
output done;

reg [449:0] index;
reg [449:0] e;
reg [8:0] cnt;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        selected_e <= 256'b0;
    else if (en == 1 && index[449] == 1'b1 && done == 0)
        selected_e <= {selected_e[254:0], e[449]};
    else
        selected_e <= selected_e;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        index <= 450'b0;
    else if (start == 1'b1)
        index <= index_w;
    else if (en)
        index <= {index[448:0],1'b0};
    else
        index <= index;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        e <= 450'b0;
    else if (start == 1'b1)
        e <= e_w;
    else if (en == 1)
        e <= {e[448:0],1'b0};
    else
        e <= e;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        cnt <= 9'b0;
    else if (start == 1'b1)
        cnt <= 9'b0;
    else if (en == 1 && index[449] == 1'b1  && cnt < number_select)
        cnt <= cnt + 1;
    else
        cnt <= cnt;

assign done = (cnt == number_select) ? 1'b1 : 1'b0;

endmodule

