package alu_pkg;

        typedef enum bit[2:0] { AND = 3'b000,
                                OR = 3'b001,
                                ADD = 3'b100,
                                SUB = 3'b101,
                                RST = 3'b010,
                                ERR_CRC = 3'b011,
                                ERR_OP = 3'b110,
                                ERR_DATA = 3'b111} operation_t;


`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "testbench.svh"



endpackage : alu_pkg
