class minmax_command_tran extends random_command_tran;
   `uvm_object_utils(minmax_command_tran)

   constraint data_non_random { A dist {32'h00:=1,32'hFF:=1};
                     B dist {32'h00:=1,32'hFF:=1};}


   function new(string name="");super.new(name);endfunction
endclass : minmax_command_tran

