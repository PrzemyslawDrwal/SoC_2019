module alu_tester_module(alu_bfm bfm);
   import alu_pkg::*;


function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return AND;
        3'b001 : return ADD;
        3'b010 : return SUB;
        3'b011 : return OR;
        3'b100 : return RST;
        3'b101 : return ERR_CRC;
        3'b110 : return ERR_DATA;
        3'b111 : return ERR_OP;
      endcase // case (op_choice)
   endfunction : get_op

 function int get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
      else
        return $random;
   endfunction : get_data

function bit [3:0] get_crc(bit [67:0] Data, bit[3:0] crc);
        bit [67:0] d;
        bit [3:0] c;
        bit [3:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
    return newcrc;
  end
  endfunction


        bit [0:98]  data_in;
        bit [67:0]    crc_in;
        bit [31:0]    A;
        bit [31:0]    B;
       operation_t op_set;
        bit [3:0]     crc = 4'b0000;


initial begin
                repeat(500) begin : tester_main
                        op_set = get_op();
                        A = get_data();
                        B = get_data();
                        case(op_set)
                                AND : begin : case_AND
                                crc_in = {B,A,1'b1,3'b000};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b000,crc, 1'b1};
                                end
                                OR : begin : case_OR
                                crc_in = {B,A,1'b1,3'b001};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b001,crc, 1'b1};

                                end

                                ADD : begin : case_ADD
                                crc_in = {B,A,1'b1,3'b100};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b100,crc, 1'b1};

                                end
                                SUB : begin : case_SUB
                                crc_in = {B,A,1'b1,3'b101};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b101,crc, 1'b1};

                                end

                                RST : begin : case_RST

                                end
                                ERR_CRC : begin : case_ERR_CRC
                                crc_in = {B,A,1'b1,3'b001};
                                crc = get_crc(crc_in,4'b0000);
                                crc = crc + 4'b0001;
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00,B[23:16] , 1'b1};
                                data_in[22:32] = {2'b00,B[15:8] , 1'b1};
                                data_in[33:43] = {2'b00,B[7:0] , 1'b1};
                                data_in[44:54] = {2'b00,A[31:24] , 1'b1};
                                data_in[55:65] = {2'b00,A[23:16] , 1'b1};
                                data_in[66:76] = {2'b00,A[15:8] , 1'b1};
                                data_in[77:87] = {2'b00,A[7:0] , 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b011,crc, 1'b1};

                                end

                                ERR_OP : begin : case_ERR_OP
                                crc_in = {B,A,1'b1,3'b110};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b110,crc, 1'b1};

                                end
                                ERR_DATA : begin : case_ERR_DATA
                                crc_in = {B,A,1'b1,3'b111};
                                crc = get_crc(crc_in,4'b0000);
                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
                                data_in[77:87] = {2'b01, A[7:0], 1'b1};
                                data_in[88:98] = {2'b01, 1'b0,3'b111,crc, 1'b1};

                                end
                        endcase
                         bfm.send_data(data_in,op_set);

end
end

endmodule : alu_tester_module





//                repeat(50) begin : tester_main
//                        op_set = ADD;
//                        A = get_data();
//                        B = get_data();
//                                crc_in = {B,A,1'b1,3'b100};
//                                crc = get_crc(crc_in,4'b0000);
//                                data_in[0:10] = {2'b00, B[31:24], 1'b1};
//                                data_in[11:21] = {2'b00, B[23:16], 1'b1};
//                                data_in[22:32] = {2'b00, B[15:8], 1'b1};
//                                data_in[33:43] = {2'b00, B[7:0], 1'b1};
//                                data_in[44:54] = {2'b00, A[31:24], 1'b1};
//                                data_in[55:65] = {2'b00, A[23:16], 1'b1};
//                                data_in[66:76] = {2'b00, A[15:8], 1'b1};
//                                data_in[77:87] = {2'b00, A[7:0], 1'b1};
//                                data_in[88:98] = {2'b01, 1'b0,3'b100,crc, 1'b1};
//				bfm.send_data(data_in,op_set);
//
//end
//endmodule 
