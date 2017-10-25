// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This module selects 128 bits of b from a 450-bit vector of b according to
// the selected index.

module bit_sel_b (clk, resetn, en, load_index, load_b, b_w, index_w, selected_b, done);
input clk;
input resetn;
input en;
input load_index;
input load_b;
input [449:0] b_w;
input [449:0] index_w;
output reg [127:0] selected_b;
output done;

reg [449:0] index;
reg [449:0] b;
reg [8:0] cnt;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        selected_b <= 128'b0;
    else if (en == 1 && index[449] == 1'b1 && done == 0)
        selected_b <= {selected_b[126:0], b[449]};
    else
        selected_b <= selected_b;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        index <= 450'b0;
    else if (load_index == 1'b1)
        index <= index_w;
    else if (en)
        index <= {index[448:0],1'b0};
    else
        index <= index;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        b <= 450'b0;
    else if (load_b == 1'b1)
        b <= b_w;
    else if (en == 1)
        b <= {b[448:0],1'b0};
    else
        b <= b;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        cnt <= 9'b0;
    else if (load_b == 1'b1)
        cnt <= 9'b0;
    else if (en == 1 && index[449] == 1'b1  && cnt < 9'd128)
        cnt <= cnt + 1;
    else
        cnt <= cnt;

assign done = (cnt == 9'd128) ? 1'b1 : 1'b0;

endmodule

