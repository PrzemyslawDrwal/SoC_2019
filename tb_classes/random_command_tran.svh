/*
   Copyright 2013 Ray Salemi

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
class random_command_tran extends uvm_transaction;
   `uvm_object_utils(random_command_tran)
        rand bit [31:0] B;
        rand bit [31:0] A;
	rand operation_t op_set;
	operation_t op_set_test;
        bit [31:0] B_test;
        bit [31:0] A_test;
        bit [31:0]    C_test;
        bit failed;
        bit C_probed;
        bit [0:54] data_out_sample;
        bit [0:98]  data_in;


   constraint data { A dist {32'h00:=1, [32'h01 : 32'hFE]:=1, 32'hFF:=1};
                     B dist {32'h00:=1, [32'h01 : 32'hFE]:=1, 32'hFF:=1};} 
   
   

   function void do_copy(uvm_object rhs);
      random_command_tran copied_transaction_h;

      if(rhs == null) 
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")
      
      super.do_copy(rhs); // copy all parent class data

      if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

      A = copied_transaction_h.A;
      B = copied_transaction_h.B;
      A_test = copied_transaction_h.A_test;
      B_test = copied_transaction_h.B_test;
      op_set = copied_transaction_h.op_set;
      op_set_test = copied_transaction_h.op_set_test;
      op_set_test = copied_transaction_h.op_set_test;
      failed = copied_transaction_h.failed;
      C_probed = copied_transaction_h.C_probed;
      C_test = copied_transaction_h.C_test;
      data_out_sample = copied_transaction_h.data_out_sample;
      data_in = copied_transaction_h.data_in;

   endfunction : do_copy

   function random_command_tran clone_me();
      random_command_tran clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      random_command_tran compared_transaction_h;
      bit   same;
      
      if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(compared_transaction_h,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (compared_transaction_h.A == A) &&
               (compared_transaction_h.B == B) &&
               (compared_transaction_h.A_test == A_test) &&
               (compared_transaction_h.B_test == B_test) &&
               (compared_transaction_h.C_test == C_test) &&
               (compared_transaction_h.C_probed == C_probed) &&
               (compared_transaction_h.data_out_sample == data_out_sample) &&
               (compared_transaction_h.data_in == data_in) &&
               (compared_transaction_h.failed == failed) &&
               (compared_transaction_h.op_set == op_set) &&
               (compared_transaction_h.op_set_test  == op_set_test);
               
      return same;
   endfunction : do_compare


   function string convert2string();
      string s;
      s = $sformatf("A: %8h  B: %8h A_test: %8h  B_test: %8h op_set: %s",
                        A, B, A_test, B_test, op_set.name());
      return s;
   endfunction : convert2string

   function new (string name = "");
      super.new(name);
   endfunction : new

endclass : random_command_tran

      
        
