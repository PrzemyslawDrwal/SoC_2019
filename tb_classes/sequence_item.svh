class sequence_item extends uvm_sequence_item;

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


    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_int(A_test, UVM_ALL_ON)
        `uvm_field_int(B_test, UVM_ALL_ON)
        `uvm_field_int(C_test, UVM_ALL_ON)
        `uvm_field_int(failed, UVM_ALL_ON)
        `uvm_field_int(C_probed, UVM_ALL_ON)
        `uvm_field_int(data_out_sample, UVM_ALL_ON)
        `uvm_field_int(data_in, UVM_ALL_ON)
        `uvm_field_enum(operation_t, op_set, UVM_ALL_ON)
        `uvm_field_enum(operation_t, op_set_test, UVM_ALL_ON)
    `uvm_object_utils_end

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        sequence_item tested;
        bit same;

        if (rhs==null) `uvm_fatal(get_type_name(),
                "Tried to do comparison to a null pointer");

        if (!$cast(tested,rhs))
            same = 0;
        else
        same = super.do_compare(rhs, comparer) &&
               (tested.A == A) &&
               (tested.B == B) &&
               (tested.A_test == A_test) &&
               (tested.B_test == B_test) &&
               (tested.C_test == C_test) &&
               (tested.C_probed == C_probed) &&
               (tested.data_out_sample == data_out_sample) &&
               (tested.data_in == data_in) &&
               (tested.failed == failed) &&
               (tested.op_set == op_set) &&
               (tested.op_set_test  == op_set_test);

      return same;
   endfunction : do_compare


    function void do_copy(uvm_object rhs);
        sequence_item RHS;
        assert(rhs != null) else
            $fatal(1,"Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(RHS,rhs)) else
            $fatal(1,"Failed cast in do_copy");
        A      = RHS.A;
        B      = RHS.B;
        A_test      = RHS.A_test;
        B_test      = RHS.B_test;
        C_test      = RHS.C_test;
        C_probed      = RHS.C_probed;
        data_out_sample      = RHS.data_out_sample;
        data_in      = RHS.data_in;
        failed      = RHS.failed;
        op_set      = RHS.op_set;
        op_set_test      = RHS.op_set_test;
    endfunction : do_copy

   function string convert2string();
      string s;
      s = $sformatf("A: %32h  B: %32h A_test: %32h  B_test: %32h op_set: %s",
                        A, B, A_test, B_test, op_set.name());
      return s;
   endfunction : convert2string

endclass : sequence_item





