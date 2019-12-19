
`timescale 1ns/1ps
package alu_pkg;
    import uvm_pkg::*;
`include "uvm_macros.svh"

        typedef enum bit[2:0] { AND = 3'b000,
                                OR = 3'b001,
                                ADD = 3'b100,
                                SUB = 3'b101,
                                RST = 3'b010,
                                ERR_CRC = 3'b011,
                                ERR_OP = 3'b110,
                                ERR_DATA = 3'b111} operation_t;


`include "sequence_item.svh"
    // used instead of the sequencer class
    typedef uvm_sequencer #(sequence_item) sequencer;

// sequences
`include "random_sequence.svh"
`include "minmax_sequence.svh"

// sequencer class is used by runall_sequence class for casting
//`include "sequencer.svh"

// virtual sequences
`include "runall_sequence.svh"

// can be converted into sequence items
`include "result_transaction.svh"

// testbench components (no agent here)
`include "coverage.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"

`include "env.svh"

// tests
`include "alu_base_test.svh"
`include "full_test.svh"


endpackage : alu_pkg



