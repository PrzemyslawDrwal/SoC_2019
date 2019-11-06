module top;

  import   alu_pkg::*;
`include "alu_macros.svh"

   
	mtm_Alu DUT (.clk(bfm.clk), .rst_n(bfm.rst_n), .sin(bfm.sin), .sout(bfm.sout));

alu_bfm     bfm();

   testbench    testbench_h;


   initial begin
      testbench_h = new(bfm);
      testbench_h.execute();
   end



endmodule : top
