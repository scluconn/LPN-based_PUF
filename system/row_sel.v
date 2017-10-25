// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This module receives matrix A row by row and selects 128 rows to feed into
// the multipler in the latter stage. 
// This module can be used both in Gen and Ver.

module row_sel (clk, resetn, en, index_valid, read_in, row_input, index_w, number_select, selected_matrix, shift_en, shift_out, done, half_way_done);
input clk;
input resetn;
input en;
input index_valid;
input read_in;
input [127:0] row_input;
input [449:0] index_w;
input [8:0] number_select;
output reg [16383:0] selected_matrix;
input shift_en;
output [127:0] shift_out;
output done;
output half_way_done;

reg [449:0] index;
reg [8:0] cnt;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        selected_matrix <= 16384'h0;
    else if (read_in == 1'b1)
        selected_matrix <= {selected_matrix[16255:0], row_input};
    else if (en == 1 && index[449] == 1'b1 && cnt != number_select)
        selected_matrix <= {selected_matrix[16255:0], row_input};
    else if (shift_en == 1)
        selected_matrix <= {1'b0, selected_matrix[16383:16257], 1'b0, selected_matrix[16255:16129], 1'b0, selected_matrix[16127:16001], 1'b0, selected_matrix[15999:15873], 1'b0, selected_matrix[15871:15745], 1'b0, selected_matrix[15743:15617], 1'b0, selected_matrix[15615:15489], 1'b0, selected_matrix[15487:15361], 1'b0, selected_matrix[15359:15233], 1'b0, selected_matrix[15231:15105], 1'b0, selected_matrix[15103:14977], 1'b0, selected_matrix[14975:14849], 1'b0, selected_matrix[14847:14721], 1'b0, selected_matrix[14719:14593], 1'b0, selected_matrix[14591:14465], 1'b0, selected_matrix[14463:14337], 1'b0, selected_matrix[14335:14209], 1'b0, selected_matrix[14207:14081], 1'b0, selected_matrix[14079:13953], 1'b0, selected_matrix[13951:13825], 1'b0, selected_matrix[13823:13697], 1'b0, selected_matrix[13695:13569], 1'b0, selected_matrix[13567:13441], 1'b0, selected_matrix[13439:13313], 1'b0, selected_matrix[13311:13185], 1'b0, selected_matrix[13183:13057], 1'b0, selected_matrix[13055:12929], 1'b0, selected_matrix[12927:12801], 1'b0, selected_matrix[12799:12673], 1'b0, selected_matrix[12671:12545], 1'b0, selected_matrix[12543:12417], 1'b0, selected_matrix[12415:12289], 1'b0, selected_matrix[12287:12161], 1'b0, selected_matrix[12159:12033], 1'b0, selected_matrix[12031:11905], 1'b0, selected_matrix[11903:11777], 1'b0, selected_matrix[11775:11649], 1'b0, selected_matrix[11647:11521], 1'b0, selected_matrix[11519:11393], 1'b0, selected_matrix[11391:11265], 1'b0, selected_matrix[11263:11137], 1'b0, selected_matrix[11135:11009], 1'b0, selected_matrix[11007:10881], 1'b0, selected_matrix[10879:10753], 1'b0, selected_matrix[10751:10625], 1'b0, selected_matrix[10623:10497], 1'b0, selected_matrix[10495:10369], 1'b0, selected_matrix[10367:10241], 1'b0, selected_matrix[10239:10113], 1'b0, selected_matrix[10111:9985], 1'b0, selected_matrix[9983:9857], 1'b0, selected_matrix[9855:9729], 1'b0, selected_matrix[9727:9601], 1'b0, selected_matrix[9599:9473], 1'b0, selected_matrix[9471:9345], 1'b0, selected_matrix[9343:9217], 1'b0, selected_matrix[9215:9089], 1'b0, selected_matrix[9087:8961], 1'b0, selected_matrix[8959:8833], 1'b0, selected_matrix[8831:8705], 1'b0, selected_matrix[8703:8577], 1'b0, selected_matrix[8575:8449], 1'b0, selected_matrix[8447:8321], 1'b0, selected_matrix[8319:8193], 1'b0, selected_matrix[8191:8065], 1'b0, selected_matrix[8063:7937], 1'b0, selected_matrix[7935:7809], 1'b0, selected_matrix[7807:7681], 1'b0, selected_matrix[7679:7553], 1'b0, selected_matrix[7551:7425], 1'b0, selected_matrix[7423:7297], 1'b0, selected_matrix[7295:7169], 1'b0, selected_matrix[7167:7041], 1'b0, selected_matrix[7039:6913], 1'b0, selected_matrix[6911:6785], 1'b0, selected_matrix[6783:6657], 1'b0, selected_matrix[6655:6529], 1'b0, selected_matrix[6527:6401], 1'b0, selected_matrix[6399:6273], 1'b0, selected_matrix[6271:6145], 1'b0, selected_matrix[6143:6017], 1'b0, selected_matrix[6015:5889], 1'b0, selected_matrix[5887:5761], 1'b0, selected_matrix[5759:5633], 1'b0, selected_matrix[5631:5505], 1'b0, selected_matrix[5503:5377], 1'b0, selected_matrix[5375:5249], 1'b0, selected_matrix[5247:5121], 1'b0, selected_matrix[5119:4993], 1'b0, selected_matrix[4991:4865], 1'b0, selected_matrix[4863:4737], 1'b0, selected_matrix[4735:4609], 1'b0, selected_matrix[4607:4481], 1'b0, selected_matrix[4479:4353], 1'b0, selected_matrix[4351:4225], 1'b0, selected_matrix[4223:4097], 1'b0, selected_matrix[4095:3969], 1'b0, selected_matrix[3967:3841], 1'b0, selected_matrix[3839:3713], 1'b0, selected_matrix[3711:3585], 1'b0, selected_matrix[3583:3457], 1'b0, selected_matrix[3455:3329], 1'b0, selected_matrix[3327:3201], 1'b0, selected_matrix[3199:3073], 1'b0, selected_matrix[3071:2945], 1'b0, selected_matrix[2943:2817], 1'b0, selected_matrix[2815:2689], 1'b0, selected_matrix[2687:2561], 1'b0, selected_matrix[2559:2433], 1'b0, selected_matrix[2431:2305], 1'b0, selected_matrix[2303:2177], 1'b0, selected_matrix[2175:2049], 1'b0, selected_matrix[2047:1921], 1'b0, selected_matrix[1919:1793], 1'b0, selected_matrix[1791:1665], 1'b0, selected_matrix[1663:1537], 1'b0, selected_matrix[1535:1409], 1'b0, selected_matrix[1407:1281], 1'b0, selected_matrix[1279:1153], 1'b0, selected_matrix[1151:1025], 1'b0, selected_matrix[1023:897], 1'b0, selected_matrix[895:769], 1'b0, selected_matrix[767:641], 1'b0, selected_matrix[639:513], 1'b0, selected_matrix[511:385], 1'b0, selected_matrix[383:257], 1'b0, selected_matrix[255:129], 1'b0, selected_matrix[127:1]};
    else
        selected_matrix <= selected_matrix;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        index <= 450'b0;
    else if (index_valid == 1'b1)
        index <= index_w;
    else if (en)
        index <= {index[448:0],1'b0};
    else
        index <= index;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        cnt <= 9'b0;
    else if (index_valid == 1'b1)
        cnt <= 9'b0;
    else if (en == 1 && index[449] == 1'b1  && cnt < number_select)
        cnt <= cnt + 1;
    else
        cnt <= cnt;

assign done = (cnt == 9'd128 || cnt == 9'd256) ? 1'b1 : 1'b0;
assign half_way_done = (cnt == 9'd127 && index[449] == 1'b1) ? 1'b1 : 1'b0;
assign shift_out = {selected_matrix[16256], selected_matrix[16128], selected_matrix[16000], selected_matrix[15872], selected_matrix[15744], selected_matrix[15616], selected_matrix[15488], selected_matrix[15360], selected_matrix[15232], selected_matrix[15104], selected_matrix[14976], selected_matrix[14848], selected_matrix[14720], selected_matrix[14592], selected_matrix[14464], selected_matrix[14336], selected_matrix[14208], selected_matrix[14080], selected_matrix[13952], selected_matrix[13824], selected_matrix[13696], selected_matrix[13568], selected_matrix[13440], selected_matrix[13312], selected_matrix[13184], selected_matrix[13056], selected_matrix[12928], selected_matrix[12800], selected_matrix[12672], selected_matrix[12544], selected_matrix[12416], selected_matrix[12288], selected_matrix[12160], selected_matrix[12032], selected_matrix[11904], selected_matrix[11776], selected_matrix[11648], selected_matrix[11520], selected_matrix[11392], selected_matrix[11264], selected_matrix[11136], selected_matrix[11008], selected_matrix[10880], selected_matrix[10752], selected_matrix[10624], selected_matrix[10496], selected_matrix[10368], selected_matrix[10240], selected_matrix[10112], selected_matrix[9984], selected_matrix[9856], selected_matrix[9728], selected_matrix[9600], selected_matrix[9472], selected_matrix[9344], selected_matrix[9216], selected_matrix[9088], selected_matrix[8960], selected_matrix[8832], selected_matrix[8704], selected_matrix[8576], selected_matrix[8448], selected_matrix[8320], selected_matrix[8192], selected_matrix[8064], selected_matrix[7936], selected_matrix[7808], selected_matrix[7680], selected_matrix[7552], selected_matrix[7424], selected_matrix[7296], selected_matrix[7168], selected_matrix[7040], selected_matrix[6912], selected_matrix[6784], selected_matrix[6656], selected_matrix[6528], selected_matrix[6400], selected_matrix[6272], selected_matrix[6144], selected_matrix[6016], selected_matrix[5888], selected_matrix[5760], selected_matrix[5632], selected_matrix[5504], selected_matrix[5376], selected_matrix[5248], selected_matrix[5120], selected_matrix[4992], selected_matrix[4864], selected_matrix[4736], selected_matrix[4608], selected_matrix[4480], selected_matrix[4352], selected_matrix[4224], selected_matrix[4096], selected_matrix[3968], selected_matrix[3840], selected_matrix[3712], selected_matrix[3584], selected_matrix[3456], selected_matrix[3328], selected_matrix[3200], selected_matrix[3072], selected_matrix[2944], selected_matrix[2816], selected_matrix[2688], selected_matrix[2560], selected_matrix[2432], selected_matrix[2304], selected_matrix[2176], selected_matrix[2048], selected_matrix[1920], selected_matrix[1792], selected_matrix[1664], selected_matrix[1536], selected_matrix[1408], selected_matrix[1280], selected_matrix[1152], selected_matrix[1024], selected_matrix[896], selected_matrix[768], selected_matrix[640], selected_matrix[512], selected_matrix[384], selected_matrix[256], selected_matrix[128], selected_matrix[0]};

endmodule

