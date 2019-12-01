
class scoreboard extends uvm_subscriber #(shortint);
    `uvm_component_utils(scoreboard)

    virtual alu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_s) cmd_f;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase


bit [3:0] flags;
//bit failed = 1'b0;
bit [7:0] ERR_probed = 8'b00000000;
bit [3:0] flags_predicted = 4'b0000;

bit [2:0] crc_out_test;
bit [2:0] crc_out_predicted;
bit [31:0]    C_predicted;

protected function bit [3:0] decoder_FLAGS(bit [0:54] Data);
        bit [3:0] FLAGS_Decoded;
        begin
        FLAGS_Decoded[3:0] = Data[47:50];
        return FLAGS_Decoded;
end
endfunction


protected function bit [2:0] decoder_CRC_OUT(bit [0:54] Data);
        bit [2:0] CRCOUT_Decoded;
        begin
        CRCOUT_Decoded[2:0] = Data[51:53];
        return CRCOUT_Decoded;
end
endfunction



protected function bit [2:0] get_crc_out(bit [37:0] Data, bit[2:0] crc);
        bit [37:0] d;
        bit [2:0] c;
        bit [2:0] newcrc;
  begin
    d = Data;
    c = crc;
    newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
    newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
    newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
    return newcrc;
  end
  endfunction


protected function bit [7:0] decoder_ERR(bit [0:54] Data);
        bit [7:0] ERR_Decoded;
        begin
        ERR_Decoded[7:0] = Data[2:9];
        return ERR_Decoded;
end
endfunction

protected function bit [3:0] predict_flags(input bit[31:0] A,B,C,op);
        bit [3:0] flags;
        begin
                flags[0] = C[31];
                flags[1] = ~|C;
                if(op == ADD) begin
                flags[3] = (( A[31] & B[31] ) | ( A[31] & ~C[31] ) | ( B[31] & ~C[31] ));
                flags[2] = (( A[31] & B[31] & ~C[31] ) | ( ~A[31] & ~B[31] & C[31] ));
                end
                else if(op == SUB) begin
                flags[3] = (( A[31] & ~B[31] ) | ( A[31] & C[31] ) | ( ~B[31] & C[31] ));
                flags[2] = (( ~A[31] & B[31] & ~C[31] ) | ( A[31] & ~B[31] & C[31] ));
                end
                else begin
                flags[3] = 1'b0;
                flags[2] = 1'b0;
                end
        return flags;
end
endfunction

    function void write(shortint t);
        shortint predicted_result;
        command_s cmd;
	//while(cmd.op_set_test!=RST);
        if(cmd.C_probed == 1'b1) begin
                ERR_probed = decoder_ERR(cmd.data_out_sample);
                case (cmd.op_set_test)
                        OR : begin : case_OR
                                C_predicted = cmd.A_test | cmd.B_test;
                                flags = decoder_FLAGS(cmd.data_out_sample);
                                flags_predicted = predict_flags(cmd.A_test,cmd.B_test,cmd.C_test,cmd.op_set_test);
                                crc_out_predicted = get_crc_out({cmd.C_test,1'b0,flags_predicted},3'b000);
                                crc_out_test = decoder_CRC_OUT(cmd.data_out_sample);
                                if ( C_predicted != cmd.C_test || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin
                                        cmd.failed = 1'b1;
                        end
                        end
			 AND : begin : case_AND
                                C_predicted = cmd.A_test & cmd.B_test;
                                flags = decoder_FLAGS(cmd.data_out_sample);
                                flags_predicted = predict_flags(cmd.A_test,cmd.B_test,cmd.C_test,cmd.op_set_test);
                                crc_out_predicted = get_crc_out({cmd.C_test,1'b0,flags_predicted},3'b000);
                                crc_out_test = decoder_CRC_OUT(cmd.data_out_sample);
                                if ( C_predicted != cmd.C_test || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin
                                        cmd.failed = 1'b1;
                        end
                        end
                        SUB : begin : case_SUB
                                C_predicted = cmd.B_test - cmd.A_test;
                                flags = decoder_FLAGS(cmd.data_out_sample);
                                flags_predicted = predict_flags(cmd.A_test,cmd.B_test,cmd.C_test,cmd.op_set_test);
                                crc_out_predicted = get_crc_out({cmd.C_test,1'b0,flags_predicted},3'b000);
                                crc_out_test = decoder_CRC_OUT(cmd.data_out_sample);
                                if ( C_predicted != cmd.C_test || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin
                                        cmd.failed = 1'b1;
                        end
                        end
			ADD : begin : case_ADD
                                C_predicted = cmd.A_test + cmd.B_test;
                                flags = decoder_FLAGS(cmd.data_out_sample);
                                flags_predicted = predict_flags(cmd.A_test,cmd.B_test,cmd.C_test,cmd.op_set_test);
                                crc_out_predicted = get_crc_out({cmd.C_test,1'b0,flags_predicted},3'b000);
                                crc_out_test = decoder_CRC_OUT(cmd.data_out_sample);
                                if ( C_predicted != cmd.C_test || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin
                                        cmd.failed = 1'b1;
                        end
                        end
                        ERR_DATA : begin : case_ERR_DATA
                                if( ERR_probed[6] != 7'b1 )
                                        cmd.failed = 1'b1;
                        end
                        ERR_OP : begin : case_ERR_OP
                                if( ERR_probed[4] != 1'b1 )
                                        cmd.failed = 1'b1;
                        end
                        ERR_CRC : begin : case_ERR_CRC
                                if( ERR_probed[5] != 1'b1)
                                        cmd.failed = 1'b1;
                        end
                endcase
        end
        cmd.C_probed = 1'b0;
        if (cmd.failed == 1'b1)
          $error ("FAILED");

    endfunction : write

//    function void write(shortint t);
//        shortint predicted_result;
//        command_s cmd;
  //      cmd.A  = 0;
  //      cmd.B  = 0;
  //      cmd.op = no_op;
  //      do
  //          if (!cmd_f.try_get(cmd))
  //              $fatal(1, "Missing command in self checker");
  //      while ((cmd.op == no_op) || (cmd.op == rst_op));
  //      case (cmd.op)
  //          add_op: predicted_result = cmd.A + cmd.B;
  //          and_op: predicted_result = cmd.A & cmd.B;
  //          xor_op: predicted_result = cmd.A ^ cmd.B;
  //          mul_op: predicted_result = cmd.A * cmd.B;
  //      endcase // case (op_set)
  //      if (predicted_result != t)
  //          $error (
  //              "FAILED: A: %2h  B: %2h  op: %s actual result: %4h   expected: %4h",
  //              cmd.A, cmd.B, cmd.op.name(), t, predicted_result);
//    endfunction : write

endclass : scoreboard


