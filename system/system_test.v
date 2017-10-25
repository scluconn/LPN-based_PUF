// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is the testbench for LPN core of the LPN-based PUF.
// Please uncomment different test cases to test the system module.
// Each test case has a short description on the top. 
// To run this testbench in ModelSim. 
// 1. Open ModelSim and enter the current directory.
// 2. source tb.tcl in the console of ModelSim

`timescale 1ns/1ns

module system_tb;

reg clk;
reg resetn;
reg mode;
reg [127:0] data_in_TDATA;
reg data_in_TVALID;
wire data_in_TREADY;
reg data_in_TLAST;
wire [127:0] data_out_TDATA;
wire data_out_TVALID;
reg data_out_TREADY;
wire data_out_TLAST;
wire fault;
reg global_start;
parameter CP = 10;
parameter r_referecen = {150{3'b101}};

reg [449:0] e;
reg [449:0] r;
reg pok_done;
wire pok_resetn;
reg [127:0] s_w;
reg [127:0] identity;
wire check_result;
wire hash_result;

system uut (clk, resetn, mode, data_in_TDATA, data_in_TVALID, data_in_TREADY, data_in_TLAST, data_out_TDATA, data_out_TVALID, data_out_TREADY, data_out_TLAST, fault, global_start, e, r, pok_done, pok_resetn, s_w, check_result, hash_result);

always #(CP/2)
    clk = ~clk;

initial
begin
    clk = 1;
    resetn = 1;
    mode = 0;
    data_in_TDATA = {16{16'h5050}};
    data_in_TVALID = 0;
    data_in_TLAST = 0;
    data_out_TREADY = 1;
    pok_done  = 0;
    s_w = {128{1'b1}};
    global_start = 0;
    identity = {1'b1, 127'b0};

    #(CP*2)
    resetn = 0;

    #(CP*3)
    resetn = 1;
  
////////////////////////////////////////
//GEN    
//for testing bit sel, bit exp
//
//   #(CP*2)
//   global_start = 1;
//   s_w = {{126{1'b1}}, 2'b00};
//
//   # (CP*80)
//   pok_done = 1;
//   e = {150{3'b101}};
//   r = {150{3'b101}};
//   global_start = 0;
//
//   //Sending A
//   #(CP*80)
//   data_in_TVALID = 1;
//   data_in_TDATA = {128{1'b1}};
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
//
//   repeat (112)
//   begin
//   #(CP*10)
//   data_in_TVALID = 1;
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
//   end
//
//   #(CP*680)
//   data_in_TVALID = 1;
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
/////////////////////////////////////

////////////////////////////////////////
//GEN    
//for testing multiplication
//
//   #(CP*2)
//   global_start = 1;
//   s_w = {{127{1'b1}}, 1'b0};
//   //s_w = {{64{1'b1}}, {64{1'b0}}};
//
//   # (CP*80)
//   pok_done = 1;
//   e = {450{1'b0}};
//   //e = {{127{1'b1}}, {323'b0}};
//   r = {450{1'b1}};
//   global_start = 0;
//
//   //Sending A
//   #(CP*80)
//   data_in_TVALID = 1;
//   //data_in_TDATA = {16{16'h5055}};
//   data_in_TDATA = {128{1'b1}};
//   //data_in_TDATA = {{15{16'h5055}}, 16'h5054};
//   //data_in_TDATA = {16'h5054, {15{16'h5055}}};
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
//
//   repeat (112)
//   begin
//   #(CP*10)
//   data_in_TVALID = 1;
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
//   end
//
//   #(CP*680)
//   data_in_TVALID = 1;
//
//   #(CP*3)
//   data_in_TLAST = 1;
//
//   #CP
//   data_in_TLAST = 0;
//   data_in_TVALID = 0;
/////////////////////////////////////

////////////////////////////////////
//GEN
//for testing row sel with a different senario.Pay attention to state MUL_CAL_FIRST
//
//    #(CP*2)
//    global_start = 1;
//    //s_w = {{126{1'b1}}, 2'b00};
//    s_w = {{127{1'b1}}, 1'b0};
// 
//    # (CP*80)
//    pok_done = 1;
//    //e = {150{3'b101}};
//    e = {450{1'b0}};
//    r = {{127{1'b1}}, 1'b0, {129{1'b1}}, {193{1'b0}}};
//    //r = {450{1'b1}};
//    global_start = 0;
// 
//    # (CP * 80)
//    //Sending A
//    identity = {1'b1, 127'b0};
// 
//    repeat (32)
//    begin
//    #(CP*10)
//    data_in_TDATA = identity;
//    data_in_TVALID = 1;
//    identity = {1'b0, identity[127:1]};
//    
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
// 
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
// 
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
//    data_in_TLAST = 1;
// 
//    #CP
//    data_in_TLAST = 0;
//    data_in_TVALID = 0;
//    end
// 
//    //sending A for the second time
//    identity = {1'b1, 127'b0};
// 
//    repeat (81)
//    begin
//    #(CP*12)
//    data_in_TDATA = identity;
//    data_in_TVALID = 1;
//    identity = {1'b0, identity[127:1]};
//    
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
// 
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
// 
//    #CP
//    data_in_TDATA = identity;
//    identity = {1'b0, identity[127:1]};
//    data_in_TLAST = 1;
// 
//    #CP
//    data_in_TLAST = 0;
//    data_in_TVALID = 0;
//    end
// 
//    #(CP*740)
//    data_in_TVALID = 1;
// 
//    #(CP*3)
//    data_in_TLAST = 1;
// 
//    #CP
//    data_in_TLAST = 0;
//    data_in_TVALID = 0;
////////////////////////////////////

////////////////////////////////////
//GEN
//for testing the hash result, and comparing with ver. It sends identity matrix as a

    #(CP*2)
    global_start = 1;
    mode = 0;
    s_w = {{127{1'b1}}, 1'b0};
 
    # (CP*80)
    pok_done = 1;
    e = {450{1'b0}};
    r = {450{1'b1}};
    global_start = 0;
 
    # (CP * 80)
    //Sending A
    identity = {1'b1, 127'b0};
 
    repeat (32)
    begin
    #(CP*10)
    data_in_TDATA = identity;
    data_in_TVALID = 1;
    identity = {1'b0, identity[127:1]};
    
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
 
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
 
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
    data_in_TLAST = 1;
 
    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
    end
 
    //sending the second half of A 
    identity = {128{1'b1}};
 
    repeat (81)
    begin
    #(CP*10)
    data_in_TDATA = identity;
    data_in_TVALID = 1;
    identity = {1'b0, identity[127:1]};
    
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
 
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
 
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
    data_in_TLAST = 1;
 
    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
    end
 
    #(CP*740)
    data_in_TVALID = 1;
 
    #(CP*3)
    data_in_TLAST = 1;
 
    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
////////////////////////////

/////////////////////////////////////////
////ver
    #(CP*300)
    mode = 1;

    #(CP*5)
    global_start = 1;

    # (CP*30)
    pok_done = 1;
    //no error
    e = {450{1'b0}};
    //inject one bit error
    //e = {{127{1'b0}}, 1'b1, 322'b0}; 
    r = {450{1'b1}};
    global_start = 0;

    //Sending I
    #(CP*100)
    data_in_TVALID = 1;
    data_in_TDATA = {128{1'b1}};

    #(CP * 3)
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;

    //Sending B
    #(CP*30)
    data_in_TVALID = 1;
    data_in_TDATA = {{127{1'b1}}, 1'b0};


    #(CP)
    data_in_TDATA = {{127{1'b1}}, 1'b0};

    #(CP)
    data_in_TDATA = 128'b0;

    #(CP)
    data_in_TDATA = 128'b0;
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;

    identity = {1'b1, 127'b0};
    //Sending A inverse
    repeat (32)
    begin
    #(CP*10)
    data_in_TDATA = identity;
    data_in_TVALID = 1;
    identity = {1'b0, identity[127:1]};
    
    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
    end

    //Sending matrix A
    identity = {1'b1, 127'b0};

    repeat (32)
    begin
    #(CP*10)
    data_in_TDATA = identity;
    data_in_TVALID = 1;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
    end

    //sending the second half of A
    identity = {1'b1, 127'b0};

    repeat (81)
    begin
    #(CP*10)
    data_in_TDATA = identity;
    data_in_TVALID = 1;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};

    #CP
    data_in_TDATA = identity;
    identity = {1'b0, identity[127:1]};
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
    end

    //Sending hash
    #(CP*10)
    data_in_TDATA = 128'h68948e1511491e5bb4db1805b8b383e2;
    data_in_TVALID = 1;

    #CP
    data_in_TDATA = 128'h3076cbb4ec431728d0c526be0aebe0c0;
    //Correct output h0 for this h1 is f4724c09405df7179e55b7500383847f,68d7a569d05ee5d629f21584ba4e741d;
    
    #(CP)
    data_in_TDATA = 128'b0;

    #CP
    data_in_TLAST = 1;

    #CP
    data_in_TLAST = 0;
    data_in_TVALID = 0;
/////////////////////////////////
end
endmodule

