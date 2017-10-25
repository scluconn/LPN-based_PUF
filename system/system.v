// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is the LPN core of the LPN-based PUF.
// It contains the state machine, inverse matrix checker, hash checker and the
// second register array for storing the 128*128 inverse matrix. 

`define AXI_REC 2'b00
`define AXI_SEN 2'b01
`define LOC_RD 2'b10
`define LOC_WR 2'b11

`define IDLE 5'h00
`define RUN_POK 5'h01
`define WR_POK_GEN 5'h02
`define SEND_CO 5'h03
`define REC_I 5'h04
`define RD_I 5'h05
`define REC_HASH 5'h06
`define RD_HASH 5'h07
`define REC_B 5'h08
`define RD_B 5'h09
`define REC_A1 5'h0A
`define RD_A1 5'h0B
`define REC_A 5'h0C
`define RD_A 5'h0D
`define BIT_SEL 5'h0E
`define MUL_CAL 5'h10
`define HASH1 5'h11
`define HASH2 5'h12
`define WR_HASH1 5'h13
`define SEND_HASH 5'h14
`define WR_POK_VER 5'h15
`define BIT_EXP 5'h16
`define WR_B 5'h17
`define SEND_B 5'h18
`define MUL_CAL_FIRST 5'h19
`define WR_HASH2 5'h1A
`define RED_RD 5'h1B

`define GEN 1'b0
`define VER 1'b1

module system (clk, resetn, mode, data_in_TDATA, data_in_TVALID, data_in_TREADY, data_in_TLAST, data_out_TDATA, data_out_TVALID, data_out_TREADY, data_out_TLAST, fault, global_start ,e , r, pok_done, pok_resetn, s_w , check_result, hash_result);

input clk;
input resetn;
input mode;
input [127:0] data_in_TDATA;
input data_in_TVALID;
output data_in_TREADY;
input data_in_TLAST;
output [127:0] data_out_TDATA;
output data_out_TVALID;
input data_out_TREADY;
output data_out_TLAST;
output fault;
input  global_start;
input [449:0] e;
input [449:0] r;
input pok_done;
output reg pok_resetn;
input [127:0] s_w;
//debugging
output check_result;
output hash_result;

//FSM
reg [8:0] state;
reg [8:0] cnt;
reg [8:0] global_cnt;
reg done_half;
reg global_start_track;
reg a_inverse_read;
reg [1:0] mul_cnt;

//Comm
wire read_en;
wire [127:0] comm_read_data;
wire read_en_2;
wire [449:0] comm_read_data_2;
wire write_en;
wire [127:0] comm_write_data;
wire write_en_2;
wire [449:0] comm_write_data_2;
reg [1:0] op_mode;

//bit sel for e
reg bit_sel_e_en;
wire bit_sel_e_start;
wire [8:0] number_select;
wire [255:0] selected_e;
wire bit_sel_e_done;
wire [449:0] bit_sel_index_w; 

//bit sel for b
reg bit_sel_b_en;
wire bit_sel_b_load_index;
wire bit_sel_b_load_b;
wire [449:0] received_b;
wire [127:0] selected_b;
wire bit_sel_b_done;

//row sel
wire row_sel_index_valid;
wire [449:0] row_sel_index;
wire row_sel_read_in;
wire [16383:0] selected_matrix;
wire matrix_shift_en;
wire [127:0] matrix_shift_out;
wire row_sel_done;
wire row_sel_half_way_done;

//hash function
wire [255:0] H_0;
reg [511:0] hash_msg;
reg hash_input_valid;
wire [255:0] hash_output;
wire hash_done;
wire hash_en;
reg hash_reset;
reg [449:0] full_b;

//bit expansion
wire bit_exp_done;
wire [449:0] b;
reg bit_exp_en;
wire bit_exp_index_valid;
wire bit_exp_read_short_b;
wire [127:0] bit_exp_short_b;

//matrix multiplier
wire [16383:0] mul_matrix;
reg [127:0] mul_vector;
wire [127:0] noise_vector;
wire [127:0] mul_output;
reg [16383:0] a_inverse;

//identity matrix checker
reg [127:0] check_ref;
reg [8:0] check_cnt;
wire check_done;
reg check_result;

//hash checker
reg [255:0] hash_ref;
reg [127:0] possible_error;
reg hash_result;
reg [8:0] hash_check_cnt;
wire hash_comp;

assign fault = check_result | hash_result;

//communication
comm_buf comm_buf (.clk(clk), .resetn(resetn), .data_in_TDATA(data_in_TDATA), .data_in_TVALID(data_in_TVALID), .data_in_TREADY(data_in_TREADY), .data_in_TLAST(data_in_TLAST), .data_out_TDATA(data_out_TDATA), .data_out_TVALID(data_out_TVALID), .data_out_TREADY(data_out_TREADY), .data_out_TLAST(data_out_TLAST), .read_en(read_en), .read_data(comm_read_data), .read2_en(read_en_2), .read2_data(comm_read_data_2), .write_en(write_en), .write_data(comm_write_data), .write2_en(write_en_2), .write2_data(comm_write_data_2), .data_received(data_received), .data_sent(data_sent), .op_mode(op_mode));

always @ (*)
begin
    case(state)
        `WR_POK_GEN:
            op_mode <= `LOC_WR;

        `SEND_CO:
            op_mode <= `AXI_SEN;

        `REC_I:
            op_mode <= `AXI_REC;

        `RD_I:
            op_mode <= `LOC_RD;

        `REC_HASH:
            op_mode <= `AXI_REC;

        `RD_HASH:
            op_mode <= `LOC_RD;

        `REC_B:
            op_mode <= `AXI_REC;

        `RD_B:
            op_mode <= `LOC_RD;

        `REC_A1:
            op_mode <= `AXI_REC;

        `RD_A1:
            op_mode <= `LOC_RD;

        `WR_HASH1:
            op_mode <= `LOC_WR;

        `WR_HASH2:
            op_mode <= `LOC_WR;

        `SEND_HASH:
            op_mode <= `AXI_SEN;

        `WR_POK_VER:
            op_mode <= `LOC_WR;

        `WR_B:
            op_mode <= `LOC_WR;

        `SEND_B:
            op_mode <= `AXI_SEN;

        `REC_A:
            op_mode <= `AXI_REC;

        `RD_A:
            op_mode <= `LOC_RD;

        `RED_RD:
            op_mode <= `AXI_REC;

        default:
            op_mode <= `LOC_RD;
    endcase
end
assign write_en_2 = (state == `WR_POK_GEN || state == `WR_POK_VER || state == `WR_B) ? 1'b1 : 1'b0;
assign write_en = (state == `WR_HASH1 || state == `WR_HASH2) ? 1'b1 : 1'b0;
assign comm_write_data_2 = (state == `WR_POK_GEN || state == `WR_POK_VER) ? r : b;
assign read_en = ((state == `RD_A && row_sel_half_way_done == 1'b0 && mode == `GEN) || (state == `RD_A && mode == `VER)|| state == `RD_HASH || state == `RD_A1) ? 1'b1 : 1'b0;
assign comm_write_data = (cnt == 0) ? hash_output[255:128] : hash_output[127:0];
assign read_en_2 = (state == `RD_I || state == `RD_B) ? 1'b1 : 1'b0;

//bit_sel for e
bit_sel bit_sel_e (.clk(clk), .resetn(resetn), .en(bit_sel_e_en), .number_select(number_select), .start(bit_sel_e_start), .e_w(e), .index_w(bit_sel_index_w), .selected_e(selected_e), .done(bit_sel_e_done));
assign bit_sel_e_start = (state == `WR_POK_GEN || state == `RD_I) ? 1'b1 : 1'b0;
assign number_select = (mode == `GEN)? 9'd256 : 9'd128;
assign bit_sel_index_w = (mode == `GEN) ? r : comm_read_data_2;

//bit_sel for b
bit_sel_b bit_sel_b (.clk(clk), .resetn(resetn), .en(bit_sel_b_en), .load_index(bit_sel_b_load_index), .load_b(bit_sel_b_load_b) , .b_w(received_b), .index_w(bit_sel_index_w), .selected_b(selected_b), .done(bit_sel_b_done));
assign bit_sel_b_load_index = (state == `RD_I) ? 1'b1 : 1'b0;
assign bit_sel_b_load_b = (state == `RD_B) ? 1'b1 : 1'b0;
assign received_b = comm_read_data_2;

//row sel
row_sel row_sel (.clk(clk), .resetn(resetn), .en(row_sel_en), .index_valid(row_sel_index_valid),.read_in(row_sel_read_in), .row_input(comm_read_data), .index_w(bit_sel_index_w), .number_select(number_select), .selected_matrix(selected_matrix), .shift_en(matrix_shift_en), .shift_out(matrix_shift_out), .done(row_sel_done), .half_way_done(row_sel_half_way_done));
assign row_sel_en = ((state == `RD_A) && (row_sel_done == 1'b0 || done_half == 1'b1)) ? 1'b1 : 1'b0;
assign row_sel_index_valid = (state == `WR_POK_GEN || state == `RD_I)? 1'b1 : 1'b0;
assign matrix_shift_en = (row_sel_done == 1'b1 && check_done == 1'b0 && mode == `VER)? 1'b1 : 1'b0;
assign row_sel_read_in = (state == `RD_A1 && cnt <9'h4) ? 1'b1 : 1'b0;

//matrix multiplier
matrix_mul matrix_mul (.clk(clk), .resetn(resetn), .a(mul_matrix), .b(mul_vector), .e(noise_vector), .o(mul_output));
always @ (posedge clk or negedge resetn)
    if (!resetn)
        mul_vector <= 128'h0 ;
    else if (state == `IDLE)
        mul_vector <= 128'h0;
    else if (row_sel_done == 1'b1 && check_done == 1'b0 && mode == `VER)
        mul_vector <= matrix_shift_out;
    else if (state == `RD_A && mode == `GEN && global_cnt == 9'd30)
        mul_vector <= s_w;
    else if (mode == `VER && state == `RD_A)
        mul_vector <= selected_e[127:0] ^ selected_b ^ possible_error;
    else if (mode == `VER && state == `HASH1 && hash_done == 1'b1 && hash_comp == 1'b1)
        mul_vector <= selected_e[127:0] ^ selected_b ^ possible_error;
    else
        mul_vector <= mul_vector;

assign noise_vector = (mode == `VER)? 128'b0: (state == `MUL_CAL_FIRST)? selected_e[255:128] : selected_e[127:0];
assign mul_matrix = a_inverse;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        a_inverse <= 16384'b0;
    else if (a_inverse_read)
        a_inverse <= selected_matrix;
    else
        a_inverse <= a_inverse;

//identity matrix checker
always @ (posedge clk or negedge resetn)
    if (!resetn)
        check_ref <= 128'b1;
    else if (state == `IDLE)
        check_ref <= 128'b1;
    else if (mode == `VER && row_sel_done && check_cnt > 2'h1 && (state == `RD_A || state == `REC_A || state == `MUL_CAL || state == `REC_HASH || state == `RD_HASH || state == `HASH1 || state == `WR_HASH1))
        check_ref <= {check_ref[126:0], 1'b0};
    else
        check_ref <= check_ref;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        check_cnt <= 9'b0;
    else if (state == `IDLE)
        check_cnt <= 9'b0;
    else if (check_cnt == 9'd129 && mode == `VER)
        check_cnt <= check_cnt;
    else if (mode == `VER && row_sel_done && (state == `RD_A || state == `REC_A || state == `MUL_CAL || state == `REC_HASH || state == `RD_HASH || state == `HASH1 || state == `WR_HASH1))
        check_cnt <= check_cnt + 1'b1;
    else
        check_cnt <= check_cnt; 
    
assign check_done = (check_cnt == 9'd129) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        check_result <= 1'b0;
    else if (state == `IDLE && global_start_track == 1'b0 && global_start == 1'b1)
        check_result <= 1'b0;
    else if (mode == `VER && row_sel_done && check_cnt > 1'b1 && mul_output != check_ref && check_done == 1'b0 && (state == `RD_A || state == `REC_A || state == `MUL_CAL || state == `REC_HASH || state == `RD_HASH || state == `HASH1 || state == `WR_HASH1))
        check_result <= 1'b1;
    else
        check_result <= check_result;

//hash checker
always @ (posedge clk or negedge resetn)
    if (!resetn)
        hash_ref <= 256'b0;
    else if (state == `RD_HASH && cnt < 9'h2)
        hash_ref <= {hash_ref[127:0], comm_read_data};
    else
        hash_ref <= hash_ref;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        hash_check_cnt <= 9'b0;
    else if (state == `IDLE)
        hash_check_cnt <= 9'b0;
    else if (hash_comp == 1'b1 && hash_done == 1'b1 && state == `HASH1 && mode == `VER)
        hash_check_cnt <= hash_check_cnt + 1'b1;
    else
        hash_check_cnt <= hash_check_cnt;

assign hash_comp = (hash_output == hash_ref)? 1'b0 : 1'b1;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        hash_result <= 1'b0;
    else if (state == `IDLE && global_start_track == 1'b0 && global_start == 1'b1)
        hash_result <= 1'b0;
    else if (hash_comp == 1'b1 && hash_check_cnt == 9'd128)
        hash_result <= 1'b1;
    else
        hash_result <= hash_result;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        possible_error <= 128'b0;
    else if (state == `IDLE)
        possible_error <= 128'b0;
    else if (hash_check_cnt == 9'b0)
        possible_error <= 128'b0;
    else if (hash_check_cnt == 9'b1)
        possible_error <= 128'b1;
    else if (state == `HASH1 && cnt == 9'h0 && hash_comp == 1'b1 && mode == `VER && hash_done == 1'b1)
        possible_error <= {possible_error [126:0], 1'b0};
    else
        possible_error <= possible_error;

//bit expansion
bit_expand bit_expand (.clk(clk), .resetn(resetn), .en(bit_exp_en), .index_valid(bit_exp_index_valid), .index(r), .read_short_b(bit_exp_read_short_b), .short_b(bit_exp_short_b), .expanded_b(b), .done(bit_exp_done));
assign bit_exp_index_valid = row_sel_index_valid;
assign bit_exp_read_short_b = ((state == `MUL_CAL_FIRST || state ==`MUL_CAL) && (mul_cnt == 2'h2) && (mode == `GEN))? 1'b1 : 1'b0;
assign bit_exp_short_b = mul_output;
always @ (posedge clk or negedge resetn)
    if (!resetn)
        bit_exp_en <= 1'b0;
    else if (state == `BIT_EXP)
        bit_exp_en <= 1'b1;
    else if (state == `HASH1)
        bit_exp_en <= 1'b0;
    else
        bit_exp_en <= bit_exp_en;

//hash
sha256_block hash (.clk(clk), .rst(hash_reset), .H_in(H_0), .M_in(hash_msg), .input_valid(hash_input_valid), .en(hash_en), .H_out(hash_output), .output_valid(hash_done));
sha256_H_0 sha256_initial (.H_0(H_0));
assign hash_en = (state == `RD_A || state == `MUL_CAL || state == `HASH1 || state == `HASH2 || state == `BIT_EXP || state == `WR_HASH1) ? 1'b1 : 1'b0;
always @ (*)
    case(state)
        `RD_A:
            hash_input_valid <= 1'b1;

        `HASH1:
            if (cnt < 9'h2)
                hash_input_valid <= 1'b1;
            else
                hash_input_valid <= 1'b0;

        `HASH2:
            if (cnt < 9'h2)
                hash_input_valid <= 1'b1;
            else
                hash_input_valid <= 1'b0;

        default :
            hash_input_valid <= 1'b0;
    endcase

always @ (*)
    case(state)
        `RD_A:
            hash_msg <= {comm_read_data, 384'h0};

        `HASH1:
            if (mode == `GEN && cnt == 9'h0)
                hash_msg <= {b, 62'h0};
            else if (mode == `GEN && cnt == 9'h1)
                hash_msg <= {mul_vector, 384'h1};
            else if (mode == `VER && cnt == 9'h0)
                hash_msg <= {full_b, 62'h0};
            else
                hash_msg <= {mul_output, 384'h1};

        `HASH2:
            if (mode == `GEN && cnt == 9'h0)
                hash_msg <= {b, 62'h0};
            else if (mode == `GEN && cnt == 9'h1)
                hash_msg <= {mul_vector, 384'h0};
            else if (mode == `VER && cnt == 9'h0)
                hash_msg <= {full_b, 62'h0};
            else
                hash_msg <= {mul_output, 384'h0};

        default:
            hash_msg <= {comm_read_data, 384'h0};
    endcase

always @ (posedge clk or negedge resetn)
    if (!resetn)
        full_b <= 450'b0;
    else if (state == `IDLE)
        full_b <= 450'b0;
    else if (state == `RD_B)
        full_b <= comm_read_data_2;
    else
        full_b <= full_b;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        global_start_track <= 1'b0;
    else
        global_start_track <= global_start;

//FSM
always @ (posedge clk or negedge resetn)
begin
    if (!resetn)
    begin
        //reset all the registers here
        state <= `IDLE;
        cnt <= 9'h00;
        pok_resetn <= 1'b1;
    end
    else
    begin
        case (state)
            `IDLE:
            begin
                if (global_start_track == 1'b0 && global_start == 1'b1) // a rising edge of global_start
                begin
                    cnt <= 9'h00;
                    pok_resetn <= 1'b1;
                    state <= `RUN_POK;
                    bit_sel_e_en <= 1'b0;
                    bit_sel_b_en <= 1'b0;
                    global_cnt <= 9'h000;
                    done_half <= 1'b0;
                    hash_reset <= 1'b1;
                    a_inverse_read <= 1'b0;
                    mul_cnt <= 2'b0;
                end
                else
                    state <= state;
            end

            `RUN_POK: 
            begin
                if (cnt == 9'h00)
                    pok_resetn <= 1'b0;
                else
                    pok_resetn <= 1'b1;
                cnt <= cnt + 9'b1;
                if (pok_done && cnt > 9'h3)
                begin
                    cnt <= 9'h00;
                    if (mode == `GEN)
                        state <= `WR_POK_GEN;
                    else
                        state <= `WR_POK_VER;
                end
                hash_reset <= 1'b0;
            end

            `WR_POK_VER:
            begin
                state <= `SEND_CO;
                cnt <= 9'h00;
            end
            
            `WR_POK_GEN:
            begin
                state <= `SEND_CO;
                cnt <= 9'h00;
                bit_sel_e_en <= 1'b1;
            end

            `SEND_CO:
            begin
                if (data_sent && mode == `GEN)
                begin
                    state <= `REC_A;
                    cnt <= 9'h0;
                end
                else if (data_sent && mode == `VER)
                begin
                    state <= `REC_I;
                    cnt <= 9'h0;
                end
                else
                    state <= `SEND_CO;
            end

            `REC_I:
            begin
                if (data_received)
                    state <= `RD_I;
                else
                    state <= state;
            end

            `RD_I:
            begin
                state <= `REC_B;
                bit_sel_e_en <= 1'b1;
            end

            `REC_B:
            begin
                if (data_received)
                    state <= `RD_B;
                else
                    state <= state;
            end

            `RD_B:
            begin
                state <= `REC_A1;
                bit_sel_b_en <= 1'b1;
                global_cnt <= 9'h0;
            end

            `REC_A1:
            begin
                if (data_received)
                begin
                    state <= `RD_A1;
                    global_cnt <= global_cnt + 1'b1;
                    cnt <= 9'h0;
                end
                else
                    state <= state;
            end

            `RD_A1:
            begin
                if (global_cnt == 9'd32 && cnt == 9'h4)
                begin
                    state <= `REC_A;
                    global_cnt <= 9'h0;
                    a_inverse_read <= 1'b1;
                end
                else if (cnt < 9'h4)
                    state <= `RD_A1;
                else
                    state <= `REC_A1;
                cnt <= cnt + 1'b1;
            end

            `REC_A:
            begin
                if (data_received == 1'b1 && row_sel_done == 1'b1 && mode == `GEN && done_half == 1'b0)
                begin
                    state <= `MUL_CAL_FIRST;
                    done_half <= 1'b1;
                    global_cnt <= global_cnt + 1'b1;
                    cnt <= 9'h0;
                    a_inverse_read <= 1'b1;
                    mul_cnt <= 2'b0;
                end
                else if (data_received)
                begin
                    state <= `RD_A;
                    global_cnt <= global_cnt + 1'b1;
                    cnt <= 9'h0;
                    a_inverse_read <= 1'b0;
                end
                else
                begin
                    state <= state;
                    a_inverse_read <= 1'b0;
                end

            end

            `RD_A:
            begin
                if (row_sel_done == 1'b1 && mode == `GEN && done_half == 1'b0)
                begin
                    state <= `MUL_CAL_FIRST;
                    done_half <= 1'b1;
                    a_inverse_read <= 1'b1;
                    mul_cnt <= 2'b0;
                end
                else if (cnt < 9'h3)
                    state <= `RD_A;
                else if (global_cnt == 9'd113 && row_sel_done == 1'b1 && mode == `GEN)
                begin
                    state <= `MUL_CAL;
                    a_inverse_read <= 1'b1;
                    mul_cnt <= 2'b0;
                end
                else if (row_sel_done == 1'b1 && mode == `VER && global_cnt == 9'd113) 
                    state <= `REC_HASH;
                else
                    state <= `REC_A;

                if (row_sel_done == 1'b1 && mode == `GEN && done_half == 1'b0)
                    cnt <= cnt;
                else
                    cnt <= cnt + 1'b1;
            end

            `REC_HASH:
            begin
                if (data_received)
                begin
                    state <= `RD_HASH;
                    cnt <= 9'h0;
                end
                else
                begin
                    state <= state;
                end
            end

            `RD_HASH:
            begin
                if (cnt > 9'h1 && check_done == 1'b1)
                begin
                    state <= `MUL_CAL;
                    mul_cnt <= 2'b0;
                    cnt <= 9'h1;
                end
                else
                begin
                    state <= state;
                    cnt <= cnt + 1'b1;
                end
            end

            `MUL_CAL_FIRST:
            begin
                if (bit_sel_e_done == 1'b0)
                begin
                    a_inverse_read <= 1'b0;
                    mul_cnt <= 2'b0;
                    state <= `MUL_CAL_FIRST;
                end
                else if  (mul_cnt > 2'b1)
                begin
                    state <= `RD_A;
                    mul_cnt <= 2'b0;
                end
                else 
                begin
                    a_inverse_read <= 1'b0;
                    mul_cnt <= mul_cnt + 1'b1;
                    state <= state;
                end
            end

            `MUL_CAL:
            begin
                if (hash_done == 1'b0)
                begin
                    state <= `MUL_CAL;
                    mul_cnt <= 2'b0;
                    a_inverse_read <= 1'b0;
                end
                else if (mul_cnt == 2'b0)
                begin
                    a_inverse_read <= 1'b0;
                    mul_cnt <= 2'b1;
                end
                else if (mode == `GEN && mul_cnt > 2'b1)
                begin
                    state <= `BIT_EXP;
                    mul_cnt <= 2'b0;
                end
                else if (mode == `VER && hash_done == 1'b1 && mul_cnt > 2'b1) 
                begin
                    state <= `HASH1;
                    cnt <= 9'b0;
                    mul_cnt <= 2'b0;
                end
                else
                begin
                    state <= state;
                    if (mul_cnt != 2'h3)
                        mul_cnt <= mul_cnt + 1'b1;
                    else
                        mul_cnt <= mul_cnt;
                end
            end

            `BIT_EXP:
            begin
                if (bit_exp_done && hash_done)
                begin
                    state <= `HASH1;
                    cnt <= 9'h0;
                end
                else
                begin
                    state <= state;
                    cnt <= cnt + 1;
                end
            end

            `HASH1:
            begin
                if (hash_done && mode == `GEN && cnt > 9'h1) 
                begin
                    state <= `WR_HASH1;
                    cnt <= 9'h0;
                end
                else if (fault == 1'b1 && mode == `VER)
                begin
                    state <= `WR_HASH1;
                    cnt <= 9'h0;
                end
                else if (hash_done && mode == `VER && hash_comp == 1'b1 && cnt > 9'h1)
                begin
                    state <= `MUL_CAL;
                    mul_cnt <= 1'b0;
                    cnt <= 9'h0;
                end
                else if (hash_done && mode == `VER && hash_comp == 1'b0 && cnt > 9'h1)
                begin
                    state <= `WR_HASH1;
                    cnt <= 9'h0;
                end
                else
                begin
                    state <= state;
                    cnt <= cnt + 1;
                end
            end

            `HASH2:
            begin
                if (hash_done && cnt > 9'h1)
                begin
                    state <= `WR_HASH2;
                    cnt <= 9'h0;
                end
                else
                begin
                    state <= state;
                    cnt <= cnt + 1;
                end
            end

            `WR_B:
            begin
                state <= `SEND_B;
            end

            `WR_HASH1:
            begin
                if (cnt <9'h1)
                begin
                    state <= state;
                    cnt <= cnt + 9'b1;
                end
                else if (fault == 1'b1)
                begin
                    state <= `SEND_HASH;
                    cnt <= 9'h0;
                end
                else
                begin
                    state <= `HASH2;
                    cnt <= 9'b0;
                end
            end

            `WR_HASH2:
            begin
                if (cnt <9'h1)
                begin
                    state <= state;
                    cnt <= cnt + 9'b1;
                end
                else
                begin
                    state <= `SEND_HASH;
                    cnt <= 9'b0;
                end
            end

            `SEND_B:
            begin
                if (data_sent)
                    state <= `IDLE;
                else
                    state <= state;
            end

            `SEND_HASH:
            begin
                if (data_sent && mode == `GEN)
                begin
                    state <= `RED_RD;
                    cnt <= 9'h0;
                end
                else if (data_sent && mode == `VER)
                    state <= `IDLE;
                else
                    state <= state;
            end

            `RED_RD:
            begin
                if (data_received)
                    state <= `WR_B;
                else
                    state <= state;
            end

            default:
                state <= `IDLE;
        endcase
    end
end

endmodule
