class coverage;

virtual alu_bfm bfm;


        bit [31:0]    A;
        bit [31:0]    B;
	operation_t op_set;

covergroup op_cov;

      option.name = "cg_op_cov";



coverpoint op_set {
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

      A_leg: coverpoint A {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      B_leg: coverpoint B {
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

    function new (virtual alu_bfm b);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
        bfm                  = b;
    endfunction : new


	    task execute();

      forever begin : sample_cov
         @(negedge bfm.clk);
        A = bfm.A_test;
        B = bfm.B_test;
        op_set = bfm.op_set_test;
	            op_cov.sample();
            zeros_or_ones_on_ops.sample();

      end
    endtask : execute



endclass : coverage

