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
//      this module has 2 cycle latency

module acc_core
# (
    parameter IN_DATA_WIDTH = 8, // 8bit 값 계속 들어옴
    parameter DWIDTH = 16        // 256개 일 때 최대 16bit 
) 
(
    input clk, reset_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
);

    reg [DWIDTH - 1 : 0] result, result_n;
    reg valid, valid_n;

     // 1. acc_core seq code
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            result <= {(DWIDTH){1'b0}}; // reset 신호에 delay가 생기면 안좋다
        end else if (run_i) begin
            result <= {(DWIDTH){1'b0}};
        end else begin
            result <= result_n;
        end
    end

    // 2. acc_core comb code
    always @(*) begin
        result_n = result;    // prevent latch
        if (valid_i) begin
            result_n = result + number_i;
        end
    end

    // 3. valid seq code
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end else if (run_i) begin
            valid <= 1'b0;
        end else begin
            valid <= valid_n;
        end
    end
    
    // 4. valid comd code
    always @(*) begin
        valid_n = valid_i;
    end

    assign result_o = result;
    assign valid_o = valid;
  
endmodule