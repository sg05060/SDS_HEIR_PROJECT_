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

`timescale 1ns/1ps
`define DELTA 0.5

module BRAM_accessor 
# (
    parameter CNT_BIT = 31, //AWIDTH랑 같아야지않나? 몰라

    /* parameter for BRAM */
    parameter DWIDTH_1 = 32,
    parameter DWIDTH_2 = 64,
    parameter AWIDTH = 8,
    parameter MEM_SIZE = 256,
    parameter IN_DATA_WIDTH = 8 //한 코어에 들어가는 데이터너비
)
(
    /* Special Inputs*/
    input clk,
    input reset_n,

    /* Signal From Register */
    input start_run_i, 
    input [CNT_BIT - 1 : 0] run_count_i, //***CNT_BIT이 31이라 오류일수도

    /* Memory I/F Input for BRAM0 */
    input [DWIDTH_1 - 1 : 0] q_b0_i,

    /* Memory I/F Input for BRAM1 */
    input [DWIDTH_2 - 1 : 0] q_b1_i,

    /* State_Outputs */
    output idle_o,
    //output run_o, //custome adding
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
    
    reg [AWIDTH - 1 : 0] cnt, cnt_n; //쓰기에 쓸 딜레이된 주소값

    wire idle_o_from_FSM;
    wire run_o_from_FSM;
    wire done_o_from_FSM;

    wire [AWIDTH - 1 : 0] cnt_o_from_counter;
    wire valid_o_from_counter;
    wire valid_o_from_acc_core_complete;

    // 데이터 쓰는 곳에 쓸 주소값 딜레이
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            cnt <= 0;
        end else begin
            cnt <= cnt_n;
        end
    end

    always @(*) begin
        cnt_n = cnt_o_from_counter;    
    end
    

    Counter_fsm#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter_fsm(
        .clk       ( clk       ),
        .rst_n     ( reset_n     ),
        .start_i   ( start_run_i   ),
        .cnt_val_i ( run_count_i ),
        .cnt_i     ( cnt_o_from_counter     ),
        .idle_o    ( idle_o_from_FSM    ),
        .run_o     ( run_o_from_FSM     ),
        .done_o    ( done_o_from_FSM    )
    );

    Counter#(
        .CNT_WIDTH ( AWIDTH )
    )u_Counter(
        .clk      ( clk    ),
        .rst_n    ( reset_n  ),
        .done_i   ( done_o_from_FSM ),
        .en       ( run_o_from_FSM ),
        .cnt_o    ( cnt_o_from_counter  ),
        .valid_o  ( valid_o_from_counter  )
    );

    final_state u_final_state(
        .clk    ( clk    ),
        .rst_n  ( reset_n  ),
        .read_i ( valid_o_from_counter ),
        .write_i (valid_o_from_acc_core_complete),
        .idle_i ( idle_o_from_FSM ),
        .done_i ( done_o_from_FSM ),
        .idle_o ( idle_o ), // final output
        .done_o  ( done_o  ) // final output
    );

    genvar i;
    generate
        for (i = 0; i < (DWIDTH_1/IN_DATA_WIDTH); i = i + 1) begin : gen_acc_loop
            acc_core_complete#(
                .IN_DATA_WIDTH ( DWIDTH_1/4 ),
                .DWIDTH        ( DWIDTH_2/4 ) 
            )u_acc_core_complete(
                .clk           ( clk           ),
                .reset_n       ( reset_n       ),
                .number_i      ( q_b0_i[(IN_DATA_WIDTH)*(i+1) -1
                                :(IN_DATA_WIDTH)*i]),
                .valid_i       ( valid_o_from_counter     ),
                .run_i         ( start_run_i         ),
                .valid_o       ( valid_o_from_acc_core_complete   ),
                .result_o      ( d_b1_o[(DWIDTH_2/(DWIDTH_1/IN_DATA_WIDTH))*(i+1) -1
                                :(DWIDTH_2/(DWIDTH_1/IN_DATA_WIDTH))*i]) // final output
            );
        end
    endgenerate




    assign #2 read_o = valid_o_from_counter;
    assign #2 write_o = valid_o_from_acc_core_complete;

    /* Memory I/F output for BRAM0 */
    assign #2 addr_b0_o = cnt_o_from_counter;
    assign #2 ce_b0_o = valid_o_from_counter;
    assign #2 we_b0_o = 0; // read only
    //assign d_bo_0 = 안함 
    //읽어온 값(q)은 위에 인스트에서 처리

    /* Memory I/F output for BRAM1 */
    assign #2 addr_b1_o = cnt; //딜레이된 주소값
    assign #2 ce_b1_o = valid_o_from_acc_core_complete;
    assign #2 we_b1_o = 1; //wirte only
    //쓸 값(d)은 위에 인스트에서 처리

endmodule