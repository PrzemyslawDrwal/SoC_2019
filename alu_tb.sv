module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

	typedef enum bit[2:0] { AND = 3'b000,
				OR = 3'b001,
				ADD = 3'b100,
				SUB = 3'b101,
				RST = 3'b010,
				ERR_CRC = 3'b011,
				ERR_OP = 3'b110,
				ERR_DATA = 3'b111} operation_t;



	bit [31:0]    A;
	bit [31:0]    B;
	bit [31:0]    C;
	bit [67:0]    crc_in;
	bit [3:0]     crc = 4'b0000;
	bit [2:0]     crc_out = 3'b000;
	bit clk; 
	bit rst_n; 
	bit sin=1'b1;   
	bit sout;
	operation_t op_set;
	int i = 0;

	bit queue_in [$:98];		
	bit queue_out [$:54]; 		
	bit [0:98]  data_in;
	bit [0:54] data_out_sample;
	bit [0:98]  data_in_sample;
	bit [31:0]    C_predicted;
	bit C_probed = 1'b0;	
	bit [7:0] ERR_probed = 8'b00000000;
	bit [3:0] flags_predicted = 4'b0000;

mtm_Alu DUT (.clk, .rst_n, .sin, .sout);

//A1 - Test all operation

//
//A3 - Test reset after all operation
//
//A4 - Test two operation in row 
//
//A5 - Error CRC code
//
//A6 - Error OP code
//
//A7 - Error DATA format 



	bit [31:0] B_test;
	bit [31:0] A_test;
	bit [3:0] CRC_test;
	operation_t op_set_test;
	bit [2:0] crc_out_test;
	bit [2:0] crc_out_predicted;


   always @(posedge clk) begin : probe_out
	@(negedge sout)
		for (int l = 0; l<55; l++) begin
			@(negedge clk)
			queue_out.push_back(sout);
	end
	data_out_sample = { >> {queue_out}};	
	queue_out.delete(); 
	C = decoder_C(data_out_sample); 
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


   covergroup op_cov;

      option.name = "cg_op_cov";

	


      coverpoint op_set_test {
         // #A1 test all operations
         bins A1_single_operation[] = {[AND:SUB]};

         // #A2 test all operations after reset
         bins A2_rst_operation[] = ( RST=> [AND:SUB]);

         // #A3 test reset after all operations
         bins A3_operation_rst[] = ([AND:SUB] => RST);

         // #A4 two operation in row 
         bins A4_two_operations[] = ([AND:SUB] [* 2]);

         // #A5 Error CRC code
         bins A5_two_operations[] = {ERR_CRC};

         // #A6 Error OP code
         bins A6_two_operations[] = {ERR_OP};

	 // #A7 Error DATA code
         bins A7_two_operations[] = {ERR_DATA};

         // #A8 Test reset after all errors
         bins A8_two_operations[] = ([ERR_CRC:ERR_DATA] => RST );

         // #A9 Test reset after all errors
         bins A9_two_operations[] = (RST => [ERR_CRC:ERR_DATA] );
	// 
      }

   endgroup




   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {RST};
      }

      A_leg: coverpoint A_test {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      B_leg: coverpoint B_test {
    	 bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }
   
         // #B1 simulate all zero input for all the operations
      B_op_0_F:  cross A_leg, B_leg, all_ops {
	      
         bins B1_add_0 = binsof (all_ops) intersect {ADD} &&
                       (binsof (B_leg.zeros) || binsof (B_leg.zeros));

         bins B1_and_0 = binsof (all_ops) intersect {AND} &&
                       (binsof (A_leg.zeros) || binsof (B_leg.zeros));

         bins B1_sub_0 = binsof (all_ops) intersect {SUB} &&
                       (binsof (A_leg.zeros) || binsof (B_leg.zeros));

         bins B1_or_0 = binsof (all_ops) intersect {OR} &&
                       (binsof (A_leg.zeros) || binsof (B_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_add_All_F = binsof (all_ops) intersect {ADD} &&
                       (binsof (A_leg.ones) || binsof (B_leg.ones));

         bins B2_and_All_F = binsof (all_ops) intersect {AND} &&
                       (binsof (A_leg.ones) || binsof (B_leg.ones));

         bins B2_sub_All_F = binsof (all_ops) intersect {SUB} &&
                       (binsof (A_leg.ones) || binsof (B_leg.ones));

         bins B2_or_All_F = binsof (all_ops) intersect {OR} &&
                       (binsof (A_leg.ones) || binsof (B_leg.ones));


         ignore_bins others_only =
                                  binsof(A_leg.others) && binsof(B_leg.others);

      }

	endgroup   



   op_cov oc;
   zeros_or_ones_on_ops c_0_F;

   initial begin : coverage
   
      oc = new();
      c_0_F = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_0_F.sample();
      end
   end : coverage




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

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

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
//        3'b000 : return AND;
//        3'b001 : return AND;
//        3'b010 : return AND;
//        3'b011 : return AND;
//        3'b100 : return OR;
//        3'b101 : return OR;
//        3'b110 : return OR;
//        3'b111 : return OR;
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
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


function bit [3:0] predict_flags(input bit[31:0] A,B,C); 
	bit [3:0] flags;
	begin
		flags[0] = C[31];
		flags[1] = ~|C;
		if(op_set_test == ADD) begin
		flags[3] = (( A[31] & B[31] ) | ( A[31] & ~C[31] ) | ( B[31] & ~C[31] ));
		flags[2] = (( A[31] & B[31] & ~C[31] ) | ( ~A[31] & ~B[31] & C[31] ));
		end
		else if(op_set_test == SUB) begin
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

function bit [2:0] get_crc_out(bit [37:0] Data, bit[2:0] crc);
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


function bit [7:0] decoder_ERR(bit [0:54] Data);
	bit [7:0] ERR_Decoded;
	begin
	ERR_Decoded[7:0] = Data[2:9];	
	return ERR_Decoded;
end
endfunction

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



//------------------------
// Tester mainop_set_test

	initial begin : tester
		rst_n = 1'b0;		
		@(negedge clk);
		@(negedge clk);
		rst_n = 1'b1;
		
		repeat(5000) begin : tester_main
			@(negedge clk);
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
	if (op_set != RST ) begin		
		for (i = 0; i<99; i++)
			@(negedge clk)
			#1
			sin <= data_in[i];
		for (int ii = 0; ii<99; ii++)
			@(negedge clk)
			#1
			sin <= 1'b1;
	end
	

	if (op_set == RST) begin

		@(negedge clk)
		rst_n = 1'b0;
		@(negedge clk)
		rst_n = 1'b1;
	end	
	end
          $display ("PASSED");
$finish;
end

bit failed = 1'b0;		
	

function bit [3:0] decoder_FLAGS(bit [0:54] Data);
	bit [3:0] FLAGS_Decoded;
	begin
	FLAGS_Decoded[3:0] = Data[47:50];	
	return FLAGS_Decoded;
end
endfunction


function bit [2:0] decoder_CRC_OUT(bit [0:54] Data);
	bit [2:0] CRCOUT_Decoded;
	begin
	CRCOUT_Decoded[2:0] = Data[51:53];	
	return CRCOUT_Decoded;
end
endfunction


bit [3:0] flags;
bit [2:0] crc_out_test_probe;

always @(posedge clk) begin : scoreboard
	if(C_probed == 1'b1) begin
		ERR_probed = decoder_ERR(data_out_sample); 
		case (op_set_test)   
			OR : begin : case_OR
				C_predicted = A_test | B_test;					
				flags = decoder_FLAGS(data_out_sample);
				flags_predicted = predict_flags(A_test,B_test,C); 
				crc_out_predicted = get_crc_out({C,1'b0,flags_predicted},3'b000);
				crc_out_test = decoder_CRC_OUT(data_out_sample); 
				if ( C_predicted != C || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin 
					failed = 1'b1; 
			end
			end
			AND : begin : case_AND
				C_predicted = A_test & B_test;					
				flags = decoder_FLAGS(data_out_sample);
				flags_predicted = predict_flags(A_test,B_test,C); 
				crc_out_predicted = get_crc_out({C,1'b0,flags_predicted},3'b000);
				crc_out_test = decoder_CRC_OUT(data_out_sample); 
				if ( C_predicted != C || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin 
					failed = 1'b1; 
			end
			end
			SUB : begin : case_SUB
				C_predicted = B_test - A_test;					
				flags = decoder_FLAGS(data_out_sample);
				flags_predicted = predict_flags(A_test,B_test,C); 
				crc_out_predicted = get_crc_out({C,1'b0,flags_predicted},3'b000);
				crc_out_test = decoder_CRC_OUT(data_out_sample); 
				if ( C_predicted != C || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin 
					failed = 1'b1; 
			end
			end
			ADD : begin : case_ADD
				C_predicted = A_test + B_test;					
				flags = decoder_FLAGS(data_out_sample);
				flags_predicted = predict_flags(A_test,B_test,C); 
				crc_out_predicted = get_crc_out({C,1'b0,flags_predicted},3'b000);
				crc_out_test = decoder_CRC_OUT(data_out_sample); 
				if ( C_predicted != C || flags_predicted != flags || crc_out_predicted != crc_out_test ) begin 
					failed = 1'b1; 
			end
			end
			ERR_DATA : begin : case_ERR_DATA
				if( ERR_probed[6] != 7'b1 )
					failed = 1'b1; 
			end
			ERR_OP : begin : case_ERR_OP
				if( ERR_probed[4] != 1'b1 )
					failed = 1'b1; 
			end
			ERR_CRC : begin : case_ERR_CRC
				if( ERR_probed[5] != 1'b1)
					failed = 1'b1; 
			end
		endcase
	end
	C_probed = 1'b0;
        if (failed == 1'b1)
          $error ("FAILED");
end : scoreboard
			
			



		
endmodule

