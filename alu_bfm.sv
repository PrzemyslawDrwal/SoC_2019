interface alu_bfm;
   import alu_pkg::*;


        bit [0:54] data_out_sample;
        bit [0:98]  data_in_sample;
        bit C_probed = 1'b0;
        bit queue_in [$:98];
        bit queue_out [$:54];

        bit clk;
        bit rst_n;
        bit sin=1'b1;
        bit sout;

	operation_t op_set;

	bit [31:0] B_test;
        bit [31:0] A_test;
        bit [3:0] CRC_test;
        operation_t op_set_test;
	bit [31:0]    C_test;

function bit [31:0] decoder_C(bit [0:54] Data);
        bit [31:0] C_Decoded;
        begin
        C_Decoded[31:24] = Data[2:9];
        C_Decoded[23:16] = Data[13:20];
        C_Decoded[15:8] = Data[24:31];
        C_Decoded[7:0] = Data[35:42];
        return C_Decoded;
end
endfunction


function bit [31:0] decoder_B(bit [0:98] Data);
        bit [31:0] B_Decoded;
        begin
        B_Decoded[31:24] = Data[2:9];
        B_Decoded[23:16] = Data[13:20];
        B_Decoded[15:8] = Data[24:31];
        B_Decoded[7:0] = Data[35:42];
        return B_Decoded;
end
endfunction


function bit [31:0] decoder_A(bit [0:98] Data);
        bit [31:0] A_Decoded;
        begin
        A_Decoded[31:24] = Data[46:53];
        A_Decoded[23:16] = Data[57:64];
        A_Decoded[15:8] = Data[68:75];
        A_Decoded[7:0] = Data[79:86];
        return A_Decoded;
end
endfunction



   always @(posedge clk) begin : probe_out
        @(negedge sout)
                for (int l = 0; l<55; l++) begin
                        @(negedge clk)
                        queue_out.push_back(sout);
        end
        data_out_sample = { >> {queue_out}};
        queue_out.delete();
        C_test = decoder_C(data_out_sample);
        C_probed = 1'b1;
   end : probe_out


 always @(posedge clk) begin : probe_in
        @(negedge sin)
                for (int d = 0; d<99; d++) begin
                        @(negedge clk)
                        queue_in.push_back(sin);
        end
        data_in_sample = { >> {queue_in}};
        queue_in.delete();
        B_test = decoder_B(data_in_sample);
        A_test = decoder_A(data_in_sample);
        CRC_test = decoder_CRC(data_in_sample);
        op_set_test = decoder_OP(data_in_sample);
   end : probe_in


   always @(posedge clk) begin : probe_rst
        if( rst_n == 0)
                op_set_test = RST;
        end : probe_rst

function bit [2:0] decoder_OP(bit [0:98] Data);
        bit [2:0] OP_Decoded;
        begin
        OP_Decoded = Data[91:93];
        return OP_Decoded;
end
endfunction


function bit [3:0] decoder_CRC(bit [0:98] Data);
        bit [3:0] CRC_Decoded;
        begin
        CRC_Decoded = Data[94:97];
        return CRC_Decoded;
end
endfunction


//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end



task send_data(input bit [0:98]  i_data_in, input operation_t i_op_set  );
	if (i_op_set != RST ) begin
                for (int i = 0; i<99; i++)
                        @(negedge clk)
                        #1
                        sin <= i_data_in[i];
                for (int ii = 0; ii<99; ii++)
                        @(negedge clk)
                        #1
                        sin <= 1'b1;
        end


        if (i_op_set == RST) begin

                @(negedge clk)
                rst_n = 1'b0;
                @(negedge clk)
                rst_n = 1'b1;
        end
     

   endtask : send_data



endinterface 

