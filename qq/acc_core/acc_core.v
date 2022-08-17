// Module Name: acc_core
// 
// description
//      Accumulator core. get value and accumulate it
//      give the accumulated number to output
//
// inputs
//      clk, reset_n: special inputs. Clock and negative reset
//      run_i: start signal.
//      valid_i: when it take the valid_i, finish the calculate and give result after 1 clk
//      number_i : operand (number to be accumulated)
// 
// outputs
//      valid_o: 1 tick if the result is valid
//      result_o: result.
//
// Notice
//      this module has 2 cycle latency

module acc_core # (
    parameter IN_DATA_WIDTH = 8,
    parameter DWIDTH = 16
    ) 

    (
    input clk, reset_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
    );

    reg [DWIDTH - 1 : 0] result_n, number_n;
    reg valid_n;


    //seq logic (For accumulating)
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            result_n <= {(DWIDTH){1'b0}};
        end else begin
            result_n <= number_n;
        end
    end
    
    //comb logic (For accumulating)
    always @(*) begin
        number_n = result_n;
        if(run_i) begin
            if (valid_i) begin
                number_n = result_n + number_i;
            end
        end
    end
    
    //seq logic (For validing out)
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            valid_n <= 0;
        end else if (run_i) begin
            if(valid_i) begin
                valid_n <= 1;
            end
        end else begin
            valid_n <= 0;
        end
    end
  
    assign result_o = result_n;
    assign valid_o = valid_n;

endmodule