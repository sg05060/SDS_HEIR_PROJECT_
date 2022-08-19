// Module Name: BRAM_accessor
// 
// description
//      Take number from BRAM 0.
//      Then do accumulate operation using Core. Make 4 result using 4 Core
//      moudle has 3 staus: IDLE, RUN, DONE. Outside can know the state of module by checking the state(output).
//      To use 2 brams, notice the Memory I/F(Check the Timing diagram of BRAMs.)
//      The number of address(4 numbers per one address) is given from the outside, run_count_i signal
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
//          run_count_i: number of rows that module should take
//      
//      Memory I/F
//          q_b0_i: data that user want to read from the bram0.
//          q_b1_i: data that user want to read from the bram1.
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
//          ce_b0_o/ce_b1_o: chip enable        //when enable??????
//          we_b0_o/we_b1_o: write enable. 0 means read mode and 1 means write mode
//          d_b0_o/d_b1_o: data that user wants to write
//

`timescale 1ns / 1ps

module BRAM_accessor 
# (
    parameter CNT_BIT = 31,    

    /* parameter for BRAM */
    parameter DWIDTH_1 = 32,
    parameter DWIDTH_2 = 128,
    parameter AWIDTH = 8,
    parameter MEM_SIZE =256,
    parameter IN_DATA_WIDTH = 8
)
(
    /* Special Inputs*/
    input clk,
    input reset_n,

    /* Signal From Register */
    input start_run_i, 
    input [CNT_BIT - 1 : 0] run_count_i,    //number of rows to be accessed

    /* Memory I/F Input from BRAM1 */
    input [DWIDTH_1 - 1 : 0] q_b0_i,

    /* Memory I/F Input from BRAM1 */
    input [DWIDTH_2 - 1 : 0] q_b1_i,

    /* State_Outputs */
    output idle_o,
    output read_o,
    output write_o,
    output done_o,

    /* Memory I/F output for BRAM0 */
    output [AWIDTH - 1 : 0] addr_b0_o,
    output reg ce_b0_o,
    output we_b0_o,
    output [DWIDTH_1 - 1 : 0] d_b0_o,
 
    /* Memory I/F output for BRAM1 */
    output [AWIDTH - 1 : 0] addr_b1_o,
    output reg ce_b1_o,
    output we_b1_o,
    output [DWIDTH_2 - 1 : 0] d_b1_o
);

reg [1 : 0] c_read_state;
reg [1 : 0] n_read_state;

reg [1 : 0] c_write_state;
reg [1 : 0] n_write_state;

localparam IDLE = 2'b00;
localparam RUN = 2'b01;
localparam DONE = 2'b10;

reg [CNT_BIT - 1 : 0] count_n;   //capture run_count_i (= how many rows to extract) and assign it to count_n

always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        count_n <= 0;
    end else if(start_run_i) begin
        count_n <= run_count_i;
    end

end
// read counter 
reg [CNT_BIT - 1 : 0] r_cnt, r_cnt_n;


always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        r_cnt <= 0;
    end else begin
        r_cnt <= r_cnt_n;
    end
end


always@(*)begin
    
    if(start_run_i == 1'b1) begin
        ce_b0_o = 1'b1;   //why
        r_cnt_n = r_cnt + 1; 
    end else begin
        r_cnt_n = r_cnt;
    end
end

assign addr_b0_o = r_cnt;  // address for bram0 to read data in bram0



// read FSM
always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        c_read_state <= IDLE;
    end else begin
        c_read_state <= n_read_state;
    end
end

always@(*) begin
    n_read_state = IDLE;
    case(c_read_state)
    IDLE: begin
        if(start_run_i)begin
            n_read_state = RUN;
        end
    end

    RUN: begin
        if( r_cnt == count_n - 1) begin
            n_read_state = DONE;   
        end 
    end

    DONE: begin
        n_read_state = IDLE;
    end
    endcase
end



//SPLIT DATA from BRAM0 by 4 because there are 4 acc_cores.
reg [DWIDTH_1 - 1 : 0] Q_b0; 
reg [IN_DATA_WIDTH - 1 : 0] number_i_1, number_i_2,number_i_3,number_i_4;   //32 bit DATA will be splitted by 8 bit 4 numbers.
wire valid_o;

always@(posedge clk or negedge reset_n) begin
    Q_b0 <= q_b0_i;
    number_i_1 <= Q_b0[4*IN_DATA_WIDTH - 1 : 3*IN_DATA_WIDTH];
    number_i_2 <= Q_b0[3*IN_DATA_WIDTH - 1 : 2*IN_DATA_WIDTH];
    number_i_3 <= Q_b0[2*IN_DATA_WIDTH - 1 : IN_DATA_WIDTH];
    number_i_4 <= Q_b0[IN_DATA_WIDTH- 1 : 0];                   //31 ~ 24 23~16  15~8  7~0
end

reg [DWIDTH_1 -1 : 0] result1, result2, result3, result4;  
reg valid1, valid2, valid3, valid4;


acc_core core1( .clk(clk), .reset_n(reset_n), .number_i(number_i_1), .valid_i(), .run_i(start_run_i), .valid_o(valid1), .result_o(result1));
acc_core core2( .clk(clk), .reset_n(reset_n), .number_i(number_i_2), .valid_i(), .run_i(start_run_i), .valid_o(valid2), .result_o(result2));
acc_core core3( .clk(clk), .reset_n(reset_n), .number_i(number_i_3), .valid_i(), .run_i(start_run_i), .valid_o(valid3), .result_o(result3));
acc_core core4( .clk(clk), .reset_n(reset_n), .number_i(number_i_4), .valid_i(), .run_i(start_run_i), .valid_o(valid4), .result_o(result4));

assign valid_o = valid1 & valid2 & valid3 & valid4;
assign d_b1_o = {result1, result2, result3, result4};

// write counter  "" when counting start??? " "
reg [CNT_BIT - 1 : 0] w_cnt, w_cnt_n;


always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        w_cnt <= 0;
    end else begin
        w_cnt <= w_cnt_n;
    end
end


always@(*)begin
    if(start_run_i == 1'b1 && valid_o == 1'b1) begin   //after core's 1 clk latency
       ce_b1_o = 1'b1;
       w_cnt_n = w_cnt + 1; 
       end else begin
        w_cnt_n = w_cnt;
    end
end

assign  addr_b1_o = w_cnt;  //address for bram1 to write data in bram1

// write FSM
always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        c_write_state <= IDLE;
    end else begin
        c_write_state <= n_write_state;
    end
end

always@(*) begin
    n_write_state = IDLE;
    case(c_write_state)
    IDLE: begin
        if(start_run_i && valid_o == 1'b1)begin
            n_write_state = RUN;
        end
    end

    RUN: begin
        if(w_cnt == count_n - 1 && valid_o == 1'b1) begin        // because acc_core's result is calculated after 1 cycle = 1cycle latency?
            n_write_state = DONE; 
        end 
    end

    DONE: begin
        n_write_state = IDLE;
    end
    endcase
end
    
assign idle_o = (c_read_state == IDLE && c_write_state == IDLE);
assign read_o = (c_read_state == RUN);
assign write_o = (c_write_state == RUN);
assign done_o = (c_write_state == DONE);

assign we_b0_o = !(c_read_state == RUN);   //when read state => write enable for bram0 should be 0.
assign we_b1_o = (c_write_state == RUN);    //when write state=> write enable for bram1 should be 1.



endmodule