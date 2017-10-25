// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This module expands a 256-bit B_{I} vector to a 450-bit B vector according
// to the selected index.  

module bit_expand (clk, resetn, en, index_valid, index, read_short_b, short_b, expanded_b, done);

input clk;
input resetn;
input en;
input index_valid;
input [449:0] index;
input read_short_b;
input [127:0] short_b;
output [449:0] expanded_b;
output done;

reg [449:0] expanded_b;
reg [255:0] short_b_reg;
reg [449:0] index_reg;
reg [9:0] cnt;
reg done;
reg flip;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        flip <= 1'b0;
    else if (read_short_b)
        flip <= ~flip;
    else
        flip <= flip;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        short_b_reg <= 256'h0;
    else if (read_short_b == 1 && flip == 1'b0)
        short_b_reg <= {short_b, short_b_reg[127:0]};
    else if (read_short_b == 1 && flip == 1'b1)
        short_b_reg <= {short_b_reg[255:128], short_b};
    else if (en == 1 && index_reg[449] == 1 && cnt < 10'd450 &&  read_short_b == 0)
        short_b_reg <= {short_b_reg[254:0], 1'b0};
    else
        short_b_reg <= short_b_reg;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        index_reg <= 450'h0;
    else if (index_valid)
        index_reg <= index;
    else if (en && cnt < 10'd450 && read_short_b == 0)
        index_reg <= {index_reg[448:0], 1'b0};
    else
        index_reg <= index_reg;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        expanded_b <= 450'h0;
    else if (en && index_reg[449] == 1'b1 && cnt < 10'd450 && read_short_b == 0)
        expanded_b <= {expanded_b[448:0], short_b_reg[255]};
    else if (en && index_reg[449] == 1'b0 && cnt < 10'd450 && read_short_b == 0)
        expanded_b <= {expanded_b[448:0], 1'b0};
    else
        expanded_b <= expanded_b;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        cnt <= 10'h0;
    else if (index_valid)
        cnt <= 10'h0;
    else if (en  && cnt < 10'd450 && read_short_b == 0)
        cnt <= cnt + 1'b1;
    else
        cnt <= cnt;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        done <= 1'b0;
    else if (index_valid == 1)
        done <= 1'b0;
    else if (cnt == 10'd450)
        done <= 1'b1;
    else
        done <= done;
endmodule
