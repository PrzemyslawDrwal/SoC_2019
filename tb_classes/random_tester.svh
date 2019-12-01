class random_tester extends base_tester;
   `uvm_component_utils (random_tester)



virtual function operation_t get_op();
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


 virtual function int get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
      else
        return $random;
   endfunction : get_data


   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : random_tester

