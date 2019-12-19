class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)
    sequence_item command;

        bit [31:0]    iA;
        bit [31:0]    iB;
        rand operation_t iop_set;

 
 protected function int get_data();
      bit zero_ones;
      zero_ones = $random;
      if (zero_ones == 1'b0)
        return 32'h00000000;
      else 
        return 32'hFFFFFFFF;
   endfunction : get_data


    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_MINMAX", "", UVM_MEDIUM)
	iA = get_data();
	iB = get_data();
        `uvm_do_with(command, {op_set == iop_set; A == iA; B == iB;})
    endtask : body



endclass : minmax_sequence
