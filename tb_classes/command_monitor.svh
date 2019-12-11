class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual alu_bfm bfm;

    uvm_analysis_port #(random_command_tran) ap;

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        alu_agent_config alu_agent_config_h;

        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");

        alu_agent_config_h.bfm.command_monitor_h = this;

        ap = new("ap",this);

    endfunction : build_phase


    function void write_to_monitor(bit [31:0] B_test, bit [31:0] A_test, bit [31:0] B, bit [31:0] A, operation_t op_set_test, operation_t op_set, bit [31:0] C_test, bit failed, bit C_probed, bit [0:54] data_out_sample, bit [0:98]  data_in );
        random_command_tran cmd;
        `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %2h  B: %2h  op_set: %s",A, B, op_set.name()), UVM_HIGH);
        cmd    = new("cmd");
        cmd.B_test = B_test;
        cmd.A_test = A_test;
        cmd.B = B;
        cmd.A = A;
        cmd.op_set_test = cmd.op_set_test;
        cmd.op_set = op_set;
        cmd.C_test = C_test;
        cmd.failed = failed;
        cmd.C_probed = C_probed;
        cmd.data_out_sample = data_out_sample;
        cmd.data_in = data_in;
        ap.write(cmd);
    endfunction : write_to_monitor
endclass : command_monitor

