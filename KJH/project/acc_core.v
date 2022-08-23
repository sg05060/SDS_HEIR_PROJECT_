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

module acc_core
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
    reg                  r_valid;
    reg [DWIDTH - 1 : 0] r_result;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= 1'b0;
        end else begin
            r_valid <= valid_i;
        end
    end


    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_result <= 0;
        end else if(run_i) begin
            r_result <= 0;
        end else if(valid_i) begin
            r_result <= r_result + number_i;
        end
    end

    // assign valid_o  = r_valid[1];
    assign valid_o = r_valid;
    assign result_o = r_result;
endmodule