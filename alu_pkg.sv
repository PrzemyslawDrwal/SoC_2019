
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


    typedef struct packed {
        bit [31:0] B_test;
        bit [31:0] A_test;
        bit [31:0] B;
        bit [31:0] A;
        operation_t op_set_test;
        operation_t op_set;
        bit [31:0]    C_test;
        bit failed;
        bit C_probed;
        bit [0:54] data_out_sample;
        bit [0:98]  data_in;
    } command_s;



`include "coverage.svh"
`include "base_tester.svh"
`include "random_tester.svh"
`include "add_tester.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"

`include "env.svh"

`include "random_test.svh"
`include "add_test.svh"

endpackage : alu_pkg



