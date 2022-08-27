// Module Name: BRAM_accessor
// 
// description
//      Take number from BRAM 0.
//      Then do accumulate operation using Core. Make 4 result using 4 Core
//      moudle has 3 staus: IDLE, RUN, DONE. Outside can know the state of module by checking the state(output).
//      To use 2 brams, notice the Memory I/F(Check the Timing diagram of BRAMs.)
//      The number of Data is given from the outside, run_count_i signal
//
// Flow
//      0. prepare The BRAM0 (each row have 4 numbers(32 bits))
//      1. give start_run_i signal with run_count_i
//      2. wait for done signal
//      3. Check BRAM1
//
// inputs
//      Special Inputs
//          clk: special inputs. Clock
//          reset_n: special input. reset (active low)
//
//      Signal From Controller
//          start_run_i: active high. Signal for start running the data mover.
//          run_count_i: number of data that module should take
//      
//      Memory I/F
//          q_b0_i: data that user want to write in the bram0.
//          q_b1_i: data that user want to write in the bram1.
//          
// outputs
//      State_Outputs
//          idle_o: state of module. represent idle state. also represent the right after of done_o state.
//          read_o: state of module. represent that module is read the data now.
//          write_o: state of module. reapresent that module is write the data now.
//          done_o: state of module. represent the done state. 
//      
//      Memory I/F
//          addr_b0_o/addr_b1_o: address of memory that user want to access.
//          ce_b0_o/ce_b1_o: chip enable
//          we_b0_o/we_b1_o: write enable. 0 means read mode and 1 means write mode
//          d_b0_o/d_b1_o: data that user wants to write
//

`timescale 1ns / 1ps

module BRAM_accessor 
# (
    parameter CNT_BIT = 31,

    /* parameter for BRAM */
    parameter DWIDTH_1 = 32,
    parameter DWIDTH_2 = 64,
    parameter AWIDTH = 8,
    parameter MEM_SIZE = 256,
    parameter IN_DATA_WIDTH = 8
)
(
    /* Special Inputs*/
    input clk,
    input reset_n,

    /* Signal From Register */
    input start_run_i, 
    input [CNT_BIT - 1 : 0] run_count_i, 

    /* Memory I/F Input for BRAM0 */
    input [DWIDTH_1 - 1 : 0] q_b0_i,

    /* Memory I/F Input for BRAM1 */
    input [DWIDTH_2 - 1 : 0] q_b1_i,

    /* State_Outputs */
    output idle_o,
    output read_o,
    output write_o,
    output done_o,

    /* Memory I/F output for BRAM0 */
    output [AWIDTH - 1 : 0] addr_b0_o,
    output ce_b0_o,
    output we_b0_o,
    output [DWIDTH_1 - 1 : 0] d_b0_o,
 
    /* Memory I/F output for BRAM1 */
    output [AWIDTH - 1 : 0] addr_b1_o,
    output ce_b1_o,
    output we_b1_o,
    output [DWIDTH_2 - 1 : 0] d_b1_o
);
core_controller#(
    .CNT_WIDTH   ( 12 ),
    .DATA_WIDTH  ( 32 ),
    .CNT_BIT     ( 31 ),
    .IN_DATA_WIDTH ( 8 )
)u_core_controller(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .start_run_i ( start_run_i ),
    .number_i    ( number_o    ),
    .valid_core_i     ( valid_o     ),
    .result_o    ( result_o    ),
    .valid_core_o     ( valid_core_o     )
);

  wire [AWIDTH - 1 : 0] addr_b0_w;
  wire ce_b0_w;
  wire we_b0_w;
  wire [DWIDTH_1 - 1 : 0] d_b0_w;
 
  wire [AWIDTH - 1 : 0] addr_b1_w;
  wire ce_b1_w;
  wire we_b1_w;
  wire [DWIDTH_2 - 1 : 0] d_b1_w;

  wire done_w, read_w, write_w;

input_controller#(
    .CNT_WIDTH                   ( 12 ),
    .DATA_WIDTH                  ( 32 ),
    .CNT_BIT                     ( 31 )
)u_input_controller(
    .clk                         ( clk                         ),
    .rst_n                       ( rst_n                       ),
    .q0_o                        ( q0_o                        ),
    .q1_o                        ( q1_o                        ),
    .start_run_i                 ( start_run_i                 ),
    .run_count_i                 ( run_count_i                 ),
    .read_o                      ( read_w                      ),
    .number_o                    ( number_o                    ),
    .valid_o                     ( valid_o                     ),
    .addr0_o                     ( addr_b0_w                     ),
    .ce0_o                       ( ce_b0_w                       ),
    .we0_o                       ( we_b0_w                       ),
    .d0_o                        ( d_b0_w                        ),
    .addr1_o                   ( addr1_o                     ),
    .ce1_o                       ( ce1_o                       ),
    .we1_o                       ( we1_o                       ),
    .d1_o                        ( d1_o                        )
);

output_controller#(
    .CNT_WIDTH                   ( 12 ),
    .DATA_WIDTH                  ( 32 ),
    .CNT_BIT                     ( 31 )
)u_output_controller(
    .clk                         ( clk                         ),
    .rst_n                       ( rst_n                       ),
    .q0_o                        ( q0_o                        ),
    .q1_o                        ( q1_o                        ),
    .run_count_i                 ( run_count_i                 ),
    .result_i                    ( result_i                    ),
    .valid_i                     ( valid_i                     ),
    .write_o                     ( write_w                     ),
    .done_o                      ( done_w                     ),
    .addr0_o                     ( addr_b1_w                     ),
    .ce0_o                       ( ce_b1_w                       ),
    .we0_o                       ( we_b1_w                       ),
    .d0_o                        ( d_b1_w                        ),
    .addr1_o                    ( addr1_o                     ),
    .ce1_o                       ( ce1_o                       ),
    .we1_o                       ( we1_o                       ),
    .d1_o                        ( d1_o                        )
);

// assign
  assign idle_o = start_run_i;
  assign read_o = read_w;
  assign write_o = write_w;
  assign done_o = done_w;

  assign addr_b0_o = addr_b0_w;
  assign ce_b0_o = ce_b0_w;
  assign we_b0_o = we_b0_w;
  assign d_b0_o = d_b0_w;
 
  assign addr_b1_o = addr_b1_w;
  assign ce_b1_o = ce_b1_w;
  assign we_b1_o = we_b1_w;
  assign d_b1_o = d_b1_w;

endmodule