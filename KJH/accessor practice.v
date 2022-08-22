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

    /* localparam */
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;

    /* Total Counter_top */
    
    //Counter_top reg
    reg [CNT_BIT - 1 : 0] cnt_val;
    reg [1:0] c_state, n_state;
    reg [CNT_BIT - 1 : 0] cnt, cnt_n;

    //Total FSM

    // cnt val capture
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            cnt_val <= 0;        
        end else if (start_run_i) begin
            cnt_val <= run_count_i;        
        end 
    end

    //Fsm seq
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    //Fsm comb
    always @(*) begin
        n_state = c_state;   
        case (c_state) 
            IDLE : begin
                if (start_run_i) begin
                    n_state = RUN;  
                end 
            end
            RUN : begin
                if (cnt == cnt_val-1) begin
                    n_state = DONE; 
                end
            end
            DONE : begin
                n_state = IDLE; 
            end
        endcase
    end

    //Total Counter

    //Counter seq 
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            cnt <= 0;
        end else begin
            cnt <= cnt_n;
        end
    end

    //Counter comb
    always @(*) begin
        cnt_n = cnt; 
        if (c_state == RUN) begin
            cnt_n = cnt + 1;
        end
    end

    assign addr_b0_o =    cnt_n;
    assign read_o    =    (c_state == RUN);
    assign ce_b0_o   =    (c_state == RUN);
    assign we_b0_o   =    0;
    assign d_b0_o    =    0;

endmodule