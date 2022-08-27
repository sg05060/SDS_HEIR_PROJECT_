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
    parameter IN_DATA_WIDTH = 8,
    parameter DWIDTH = IN_DATA_WIDTH * 4
)
(
    input clk, reset_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
);
    reg [DWIDTH - 1 : 0] temp, temp_n;  // storage to accumulated value
    reg valid;  // 1 when finish calculate

    //temp = temp + number_i
    // 1 acc seq logic
    always @(posedge clk, negedge reset_n) begin
      if (!reset_n) begin
        temp <= {(DWIDTH){1'b0}};
        valid <= 0;
      end else begin
        temp <= temp_n;
      end
    end

    // 2. acc comb logic
    always @(*) begin
        temp_n = temp;    // prevent latch
        valid = 0;
        if (valid_i && run_i) begin
            temp_n = temp + number_i;
            valid = 1;
        end
    end

    assign result_o = temp_n;
    assign valid_o = valid;

endmodule