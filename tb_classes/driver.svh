
class driver extends uvm_component;
   `uvm_component_utils(driver)

   virtual alu_bfm bfm;

   uvm_get_port #(random_command_tran) command_port;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
   function void build_phase(uvm_phase phase);

      alu_agent_config alu_agent_config_h;

      if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
        `uvm_fatal("DRIVER", "Failed to get config");

      bfm = alu_agent_config_h.bfm;

      command_port = new("command_port",this);

   endfunction : build_phase

    task run_phase(uvm_phase phase);

        random_command_tran    command;
        forever begin : command_loop
            command_port.get(command);
            bfm.send_data(command.data_in,command.op_set);
        end : command_loop
    endtask : run_phase


endclass : driver
                                                                                                                                     

