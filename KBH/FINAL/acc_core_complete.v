// Module Name: acc_core
// 
// description
//      Accumulator core. get value and accumulate it
//      give the accumulated number to output
//
// inputs
//      clk, reset_n: special inputs. Clock and negative reset
//      run_i: start signal.
//      valid_i: when it take the vlaid_i, finish the calculate and give result after 1 clk
//      number_i : operand (number to be accumulated)
// 
// outputs
//      valid_o: 1 tick if the result is valid
//      result_o: result.
//
// Notice
//      this module has 2(1) cycle latency
`timescale 1ns/1ps
`define DELTA 0.5

module acc_core_complete
# (
    parameter IN_DATA_WIDTH = 8,  
    parameter DWIDTH = 16 // 256 MEM Size -> log2(256) = 8, 8 + 8 = 16
) 
(
    input clk, reset_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
);

    // 2 cycle latency
    /*
    reg [1 : 0]          r_valid;
    reg [DWIDTH - 1 : 0] r_result;

    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= 2'b0;
        end else if(run_i) begin
            r_valid <= 2'b0;
        end else begin
            r_valid <= {r_valid[0], valid_i};
        end
    end
    */

    // 1 cycle latency
    reg                  r_valid, r_valid_n;
    reg [DWIDTH - 1 : 0] r_result, r_result_n;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= 1'b0;
            r_valid_n <= 1'b0; // 얘도 와이어로서가 아닌 레지스터로서 과거 valid_i값을 저장할 것임.
        end else begin
            r_valid <= r_valid_n;
        end
    end

    always @(*) begin
        r_valid_n = valid_i;
    end


    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_result <= 0;
        end else begin
            r_result <= r_result_n;
        end
    end

    always @ (*) begin 
        r_result_n = r_result;
        if(run_i) begin
            r_result_n = 0;
        end else if(r_valid_n) begin
            r_result_n = r_result + number_i;
        end else if(r_valid_n == 0 && r_valid == 1) begin // valid_i가 0으로 내려와도 한클락은 누산 더 함.
            r_result_n = r_result + number_i;
        end else begin
            r_result = r_result;
        end
    end


    // assign valid_o  = r_valid[1];
    assign valid_o = r_valid;
    assign result_o = r_result;
endmodule