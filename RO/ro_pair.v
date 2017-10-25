// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is the file which contains 450 RO pairs.

module inv_cell
  (input a,
   output q);

   LUT1 #(
    .INIT(2'h1)) 
    inv
       (.I0(a),
        .O(q));
endmodule // inv_cell

module nand_cell
  (input  a,
   input  b,
   output q);
   
    LUT2 #(
    .INIT(4'h7)) 
    nand_gate
       (.I0(a),
        .I1(b),
        .O(q));
endmodule // nand_cell

module single_ro_pair 
#( parameter WIDTH = 5,
parameter ACC = 5)(
    input resetn,
    input clk,
    input en,

    output e,
    output r
    ); 

    (* keep = "true" *) wire    [WIDTH - 1:0]   ro_1, ro_2;
    (* keep = "true" *) reg [ACC -1 :0] cnt1, cnt2;
    wire [ACC-1:0] co;
    wire r_w;
    reg [ACC-1:0] syn_cnt1;
    reg [ACC-1:0] syn_cnt2;

   nand_cell nand_cell1 (en, ro_1[4], ro_1[0]);
    inv_cell inv1_0 (ro_1[0], ro_1[1]);
    inv_cell inv1_1 (ro_1[1], ro_1[2]);
    inv_cell inv1_2 (ro_1[2], ro_1[3]);
    inv_cell inv1_3 (ro_1[3], ro_1[4]);

    nand_cell nand_cell2 (en, ro_2[4], ro_2[0]);
    inv_cell inv2_0 (ro_2[0], ro_2[1]);
    inv_cell inv2_1 (ro_2[1], ro_2[2]);
    inv_cell inv2_2 (ro_2[2], ro_2[3]);
    inv_cell inv2_3 (ro_2[3], ro_2[4]);

    always @ (posedge ro_1[WIDTH-1] or negedge resetn)
        if (!resetn)
            cnt1 <= {ACC{1'b0}};
        else 
            cnt1 <= cnt1 + {{(ACC-1){1'b0}},1'b1}; 

    always @ (posedge ro_2[WIDTH-1] or negedge resetn)
        if (!resetn)
            cnt2 <= {ACC{1'b0}};
        else 
            cnt2 <= cnt2 + {{(ACC-1){1'b0}},1'b1}; 

    always  @ (posedge clk)
        if (!resetn)
            syn_cnt1 <= {ACC{1'b0}};
        else if (en == 1'b1)
            syn_cnt1 <= cnt1;
        else
            syn_cnt1 <= syn_cnt1;

    always  @ (posedge clk)
        if (!resetn)
            syn_cnt2 <= {ACC{1'b0}};
        else if (en == 1'b1)
            syn_cnt2 <= cnt2;
        else
            syn_cnt2 <= syn_cnt2;

    assign e = (syn_cnt1 > syn_cnt2)?  1'b1: 1'b0;
    assign co = e? (syn_cnt1 - syn_cnt2) : (syn_cnt2 - syn_cnt1);
    assign r = ((co > 5'd6)) ? 1'b1 : 1'b0;
endmodule

module ro_pair_wrapper
#(parameter NUM_RO = 450)
(clk, resetn, e, r, done);
    input clk;
    input resetn;
    output reg [NUM_RO - 1 : 0] e;
    output reg [NUM_RO - 1 : 0] r; 
    output done;

    reg [5:0] clk_cnt;
    wire resetn_ro, en;
    reg [1:0] state;
    wire [NUM_RO-1:0] e_v;
    wire [NUM_RO-1:0] r_v;

    always @ (posedge clk or negedge resetn)
        if (!resetn)
            state <= 2'b0; //Idle
        else if (state == 2'b0)
            state <= 2'b01; //run
        else if (state == 2'b01 && clk_cnt == 6'h2c)
            state <= 2'b10; //read data
        else
            state <=  state;

    always @ (posedge clk or negedge resetn)
        if (!resetn)
            clk_cnt <= 6'b00;
        else if (state == 2'b01)
            clk_cnt <= clk_cnt + 6'h1;
        else 
            clk_cnt <= clk_cnt;
       
    assign resetn_ro = (clk_cnt == 6'b01) ? 1'b0 : 1'b1;
    assign en = (state == 2'b1 && clk_cnt < 6'h18)? 1'b1 : 1'b0;
    assign done = (state == 2'b10) ? 1'b1 : 1'b0;

    always @ (posedge clk)
        if (!resetn)
            e <= {NUM_RO{1'b0}};
        else if (clk_cnt == 6'h25)
            e <= e_v;
        else
            e <= e;

    always @ (posedge clk)
        if (!resetn)
            r <= {NUM_RO{1'b0}};
        else if (clk_cnt == 6'h25)
            r <= r_v;
        else
            r <= r;

    generate
        genvar i;
        for (i=0; i<NUM_RO; i=i+1) begin : ro_pair_instance
            single_ro_pair ro_pair_int (resetn_ro, clk, en, e_v[i], r_v[i]);
        end
    endgenerate
endmodule
