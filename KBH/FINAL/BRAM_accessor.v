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
    

    wire idle_o_from_FSM;
    wire run_o_from_FSM;
    wire done_o_from_FSM;

    wire [AWIDTH - 1 : 0] cnt_o_from_counter;
    wire valid_o_from_counter;

            // 4개의 코어에서 나오는 valid_o값들을 and로 묶을 것임.
    wire [3:0] valid_o_from_acc_core_complete_sliced;
    wire valid_o_from_acc_core_complete;

    //counter_fsm의 done신호를 두클락딜레이시킬거임.
    reg done_delay, done_delay_n, done_delay_nn; //쓰기에 쓸 딜레이된 던 값

        // 데이터 쓰는 곳에 쓸 주소값 딜레이
    reg [AWIDTH - 1 : 0] cnt, cnt_n, cnt_nn; //쓰기에 쓸 딜레이된 주소값

    reg core_run; // 카운터가 bram0에 주는 ce신호보다 1클락 딜레이된 신호

    Counter_fsm#(
        .CNT_WIDTH ( AWIDTH ) // 31비트 줬더니 오류떴음.  
        //31비트자리랑 8비트짜리 비교는 원래 잘 안되나??
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

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            done_delay <= 0;
            done_delay_n <= 0;
        end else begin
            done_delay <= done_delay_n;
            done_delay_n <= done_delay_nn;
        end
    end

    always @(*) begin
        done_delay_nn = done_o_from_FSM;    
    end


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

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            cnt <= 0;
            cnt_n <= 0;
        end else begin
            cnt <= cnt_n;
            cnt_n <= cnt_nn;
        end
    end

    always @(*) begin
        cnt_nn = cnt_o_from_counter;    
    end
    
    // 카운터가 bram0에 주는 ce신호보다 1클락 딜레이된 신호
    //즉 bram0에 add, ce, we를 주고 q값을 돌려받기까지 시간이 걸리기때문.
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            core_run <= 0;
        end else begin
            core_run <= valid_o_from_counter;
        end
    end

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
                .valid_i       ( core_run     ),
                .run_i         ( start_run_i         ),
                .valid_o       ( valid_o_from_acc_core_complete_sliced[i]   ),
                .result_o      ( d_b1_o[(DWIDTH_2/(DWIDTH_1/IN_DATA_WIDTH))*(i+1) -1
                                :(DWIDTH_2/(DWIDTH_1/IN_DATA_WIDTH))*i]) // final output
            );
        end
    endgenerate


    // 4개의 코어에서 나오는 valid_o값들을 and로 묶을 것임.
    assign valid_o_from_acc_core_complete = (valid_o_from_acc_core_complete_sliced[3]
                                        && valid_o_from_acc_core_complete_sliced[2]
                                        && valid_o_from_acc_core_complete_sliced[1]
                                        && valid_o_from_acc_core_complete_sliced[0]);


    assign read_o = valid_o_from_counter;
    assign write_o = valid_o_from_acc_core_complete;
    assign done_o = done_delay; // 위에서 counter_fsm 의 done신호 2번 지연시킨것.
    //idle_o는 위의 세 개가 모두 0일 때 1이다.
    //어차피 위의 세 개가 clk와 reset_n에 종속이기 때문에 상관없다.
    assign idle_o = valid_o_from_counter? 0: (valid_o_from_acc_core_complete? 0: (done_delay? 0:1));

    /* Memory I/F output for BRAM0 */
    assign addr_b0_o = cnt_o_from_counter;
    assign ce_b0_o = valid_o_from_counter;
    assign we_b0_o = 0; // read only
    //assign d_bo_0 = 안함 
    //읽어온 값(q)은 위에 인스트에서 처리

    /* Memory I/F output for BRAM1 */
    assign addr_b1_o = cnt; //딜레이된 주소값
    assign ce_b1_o = valid_o_from_acc_core_complete;
    assign we_b1_o = 1; //wirte only
    //쓸 값(d)은 위에 인스트에서 처리

endmodule