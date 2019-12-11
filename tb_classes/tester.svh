
class tester extends uvm_component;
   `uvm_component_utils (tester)

   uvm_put_port #(random_command_tran) command_port;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

//        bit [0:98]  data_in;
        bit [67:0]    crc_in;
//	 operation_t op_set;
        bit [3:0]     crc = 4'b0000;




   task run_phase(uvm_phase phase);
      random_command_tran  command;

      phase.raise_objection(this);

      command = new("command");
      command.op_set = RST;
      command_port.put(command);

      repeat (1000) begin
         command = random_command_tran::type_id::create("command");
         assert(command.randomize());
                        case(command.op_set)
                                AND : begin : case_AND
                                crc_in = {command.B,command.A,1'b1,3'b000};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b00, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b000,crc, 1'b1};

                                end

				OR : begin : case_OR
                                crc_in = {command.B,command.A,1'b1,3'b001};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b00, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b001,crc, 1'b1};

                                end

                                ADD : begin : case_ADD
                                crc_in = {command.B,command.A,1'b1,3'b100};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b00, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b100,crc, 1'b1};

                                end


                                SUB : begin : case_SUB
                                crc_in = {command.B,command.A,1'b1,3'b101};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b00, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b101,crc, 1'b1};

                                end

                                RST : begin : case_RST


                                end

                                ERR_CRC : begin : case_ERR_CRC
                                crc_in = {command.B,command.A,1'b1,3'b001};
                                crc = get_crc(crc_in,4'b0000);
                                crc = crc + 4'b0001;
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00,command.B[23:16] , 1'b1};
                                command.data_in[22:32] = {2'b00,command.B[15:8] , 1'b1};
                                command.data_in[33:43] = {2'b00,command.B[7:0] , 1'b1};
                                command.data_in[44:54] = {2'b00,command.A[31:24] , 1'b1};
                                command.data_in[55:65] = {2'b00,command.A[23:16] , 1'b1};
                                command.data_in[66:76] = {2'b00,command.A[15:8] , 1'b1};
                                command.data_in[77:87] = {2'b00,command.A[7:0] , 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b011,crc, 1'b1};

                                end

                                ERR_OP : begin : case_ERR_OP
                                crc_in = {command.B,command.A,1'b1,3'b110};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b00, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b110,crc, 1'b1};

                                end

ERR_DATA : begin : case_ERR_DATA
                                crc_in = {command.B,command.A,1'b1,3'b111};
                                crc = get_crc(crc_in,4'b0000);
                                command.data_in[0:10] = {2'b00, command.B[31:24], 1'b1};
                                command.data_in[11:21] = {2'b00, command.B[23:16], 1'b1};
                                command.data_in[22:32] = {2'b00, command.B[15:8], 1'b1};
                                command.data_in[33:43] = {2'b00, command.B[7:0], 1'b1};
                                command.data_in[44:54] = {2'b00, command.A[31:24], 1'b1};
                                command.data_in[55:65] = {2'b00, command.A[23:16], 1'b1};
                                command.data_in[66:76] = {2'b00, command.A[15:8], 1'b1};
                                command.data_in[77:87] = {2'b01, command.A[7:0], 1'b1};
                                command.data_in[88:98] = {2'b01, 1'b0,3'b111,crc, 1'b1};

                                end
                        endcase
	
         command_port.put(command);
      end


      #500;
      phase.drop_objection(this);
	$finish;
   endtask : run_phase



protected function bit [3:0] get_crc(bit [67:0] Data, bit[3:0] crc);
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




endclass : tester
