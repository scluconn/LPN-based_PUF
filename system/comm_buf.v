// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This modules serves as a centralized communication hub to communicate 
// between the AXI stream interface with the local bus that is either 
// 128 bit wide or 450 bit wide. 
// All the internal modules that need to communicate with the processor
// connect with this module. 

`define AXI_REC 2'b00
`define AXI_SEN 2'b01
`define LOC_RD 2'b10
`define LOC_WR 2'b11

module comm_buf (clk, resetn, data_in_TDATA, data_in_TVALID, data_in_TREADY, data_in_TLAST, data_out_TDATA, data_out_TVALID, data_out_TREADY, data_out_TLAST, read_en, read_data, read2_en, read2_data, write_en, write_data, write2_en, write2_data, data_received, data_sent, op_mode);
input clk;
input resetn;
input [127:0] data_in_TDATA;
input data_in_TVALID;
output data_in_TREADY;
input data_in_TLAST;
output [127:0] data_out_TDATA;
output data_out_TVALID;
input data_out_TREADY;
output data_out_TLAST;
input read_en; //first mode of read, used to read matrix
output [127:0] read_data;
input read2_en; //second mode of reading, used to read index vector and b vector
output [449:0] read2_data;
input write_en;
input [127:0] write_data;
input write2_en;
input [449:0] write2_data;
output data_received;
output data_sent;
input [1:0] op_mode; 

reg data_in_TREADY;
reg data_out_TVALID;
reg data_out_TLAST;
reg [511:0] data_buf;
reg [2:0] package_cnt;
reg data_received;
reg data_sent;
reg [5:0] backoff_cnt;
wire axi_enable;

always @ (posedge clk or negedge resetn)
    if(!resetn)
        backoff_cnt <= 6'h0; 
    else if (package_cnt == 3'h3 && op_mode == `AXI_SEN)
        backoff_cnt <= 6'h0;
    else if (backoff_cnt < 6'h3f)
        backoff_cnt <= backoff_cnt + 1'b1;
    else
        backoff_cnt <= backoff_cnt;

assign axi_enable = (backoff_cnt == 6'h3f) ? 1'b1 : 1'b0;

always @(posedge clk or negedge resetn)
    if (!resetn)
        data_buf <= 512'h0;
    else if (op_mode == `AXI_REC && data_in_TREADY && data_in_TVALID && axi_enable)
        data_buf <= {data_buf[383:0], data_in_TDATA};
    else if (op_mode == `AXI_SEN && data_out_TREADY && data_out_TVALID && axi_enable)
        data_buf <= {data_buf[383:0], 128'b0};
    else if (op_mode == `LOC_RD && read_en)
        data_buf <= {data_buf[383:0], 128'b0};
    else if (op_mode == `LOC_WR && write_en)
        data_buf <= {data_buf[383:0], write_data};
    else if (op_mode == `LOC_WR && write2_en)
        data_buf <= {write2_data, 62'h0};
    else
        data_buf <= data_buf;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        data_in_TREADY <= 1'b0;
    else if (op_mode == `AXI_REC && package_cnt <3'h4 && axi_enable)
        data_in_TREADY <= 1'b1;
    else
        data_in_TREADY <= 1'b0;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        package_cnt <= 3'b0;
    else if (op_mode == `AXI_REC && data_in_TVALID == 1 && data_in_TREADY == 1 && axi_enable)
        package_cnt <= package_cnt + 1'b1;
    else if (op_mode == `AXI_REC && data_received == 1 && axi_enable)
        package_cnt <= package_cnt;
    else if (op_mode == `AXI_REC && data_in_TVALID == 0 && axi_enable) 
        package_cnt <= 3'b0;
    else if (op_mode == `AXI_SEN && data_out_TVALID == 1 && axi_enable)
        package_cnt <= package_cnt + 1'b1;
    else if (op_mode == `AXI_SEN && data_sent == 1 && axi_enable)
        package_cnt <= package_cnt;
    else if (op_mode == `AXI_SEN && data_out_TVALID == 0 && axi_enable)
        package_cnt <= 3'b0;
    else
        package_cnt <= package_cnt;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        data_out_TVALID <= 1'b0;
    else if (op_mode == `AXI_SEN && data_out_TREADY == 1 && package_cnt <3'h3 && axi_enable)
        data_out_TVALID <= 1'b1;
    else 
        data_out_TVALID <= 1'b0;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        data_out_TLAST <= 1'b0;
    else if (op_mode == `AXI_SEN && data_out_TVALID == 1 && package_cnt == 3'h2 && axi_enable)
        data_out_TLAST <= 1'b1;
    else
        data_out_TLAST <= 1'b0;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        data_received <= 1'b0;
    else if (op_mode == `AXI_REC && data_in_TLAST == 1'b1 && axi_enable)
        data_received <= 1'b1;
    else if (op_mode == `AXI_REC && axi_enable)
        data_received <= data_received;
    else
        data_received <= 1'b0;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        data_sent <= 1'b0;
    else if (op_mode == `AXI_SEN && data_out_TLAST == 1'b1 && axi_enable)
        data_sent <= 1'b1;
    else if (op_mode == `AXI_SEN && axi_enable)
        data_sent <= data_sent;
    else
        data_sent <= 1'b0;

assign data_out_TDATA = data_buf[511:384];
assign read_data = data_buf[511:384];
assign read2_data = data_buf[511:62];

endmodule
