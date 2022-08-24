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
// Memory I/F
//
//
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

    // wire of read_counter_top
    wire r_idle_w;
    wire r_run_w;
    wire r_done_w;
    wire [CNT_BIT - 1 : 0] r_cnt_w;

    //read counter inst
    Counter#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter_read(
        .clk    ( clk     ),
        .rst_n  ( reset_n ),
        .en     ( r_run_w ),
        .cnt_o  ( r_cnt_w )
    );

    //read counter_fsm inst
    Counter_fsm#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter_fsm_read(
        .clk       ( clk         ),
        .rst_n     ( reset_n     ),
        .start_i   ( start_run_i ),
        .cnt_val_i ( run_count_i ),
        .cnt_i     ( r_cnt_w     ),
        .idle_o    ( r_idle_w    ),
        .run_o     ( r_run_w     ),
        .done_o    ( r_done_w    )
    );

    // wire of check
    wire check_w;

    // check inst
    check u_check(
        .clk     ( clk      ),
        .rst_n   ( reset_n  ),
        .check_i ( r_run_w  ),
        .done_i  ( r_done_w ),
        .check_o ( check_w  )
    );

    //assign of bram0
    assign addr_b0_o = r_cnt_w;
    assign ce_b0_o = check_w;
    assign we_b0_o = 0;
    assign d_b0_o = 0;


    //acc_core
    reg [DWIDTH_1 - 1 : 0] number_n;
    reg [IN_DATA_WIDTH - 1 : 0] number_1, number_2, number_3, number_4;

    /* seperate number by 4, 32 = 8 + 8 + 8 + 8 */
    //acc_core seq
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            number_n <= 0;
        end else begin
            number_n <= q_b0_i;
            number_1 <= number_n [1 * IN_DATA_WIDTH - 1 : 0];
            number_2 <= number_n [2 * IN_DATA_WIDTH - 1 : 1 * IN_DATA_WIDTH];
            number_3 <= number_n [3 * IN_DATA_WIDTH - 1 : 2 * IN_DATA_WIDTH];
            number_4 <= number_n [4 * IN_DATA_WIDTH - 1 : 3 * IN_DATA_WIDTH];
        end        
    end

    wire valid_1, valid_2, valid_3, valid_4;
    wire [2 * IN_DATA_WIDTH -1 : 0] result_1, result_2, result_3, result_4;
    wire total_valid_o;

    //acc_core_first
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_1(
        .clk           ( clk           ),
        .reset_n       ( reset_n       ),
        .number_i      ( number_1      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_1       ),
        .result_o      ( result_1      )
    );

    //acc_core_second
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_2(
        .clk           ( clk           ),
        .reset_n       ( reset_n       ),
        .number_i      ( number_2      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_2       ),
        .result_o      ( result_2      )
    );

    //acc_core_third
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_3(
        .clk           ( clk           ),
        .reset_n       ( reset_n       ),
        .number_i      ( number_3      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_3       ),
        .result_o      ( result_3      )
    );

    //acc_core_fourth
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_4(
        .clk           ( clk           ),
        .reset_n       ( reset_n       ),
        .number_i      ( number_4      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_4       ),
        .result_o      ( result_4      )
    );

    assign total_valid_o = (valid_1 & valid_2 & valid_3 & valid_4);

    wire w_idle_w;
    wire w_run_w;
    wire w_done_w;
    wire [CNT_BIT - 1 : 0] w_cnt_w;

    //write counter inst
    Counter#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter_write(
        .clk    ( clk     ),
        .rst_n  ( reset_n ),
        .en     ( w_run_w ),
        .cnt_o  ( w_cnt_w )
    );

    //read counter_fsm inst
    Counter_fsm#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter_fsm_write(
        .clk       ( clk          ),
        .rst_n     ( reset_n      ),
        .start_i   ( total_valid_o),
        .cnt_val_i ( run_count_i  ),
        .cnt_i     ( w_cnt_w      ),
        .idle_o    ( w_idle_w     ),
        .run_o     ( w_run_w      ),
        .done_o    ( w_done_w     )
    );

    assign addr_b1_o = w_cnt_w;
    assign ce_b1_o = total_valid_o;
    assign we_b1_o = 1;
    assign d_b1_o = {result_4, result_3, result_2, result_1};

    assign idle_o = r_idle_w;
    assign read_o = check_w;
    assign write_o = total_valid_o;
    assign done_o = w_done_w;


endmodule