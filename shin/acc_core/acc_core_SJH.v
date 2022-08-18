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
    parameter DWIDTH = 16
)
(
    input clk, rst_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
);

reg [DWIDTH - 1 : 0]temp_result;
reg temp_valid;


    always @(posedge clk, negedge rst_n) begin
    
        
        if (!rst_n) begin
            temp_result <= {(DWIDTH){1'b0}};
       
        end else if (run_i) begin                               /*run_i가 1이 인가됐을 때, 미리 준비해야되는 동작이 있는 회로가 있을
                                                                수 있다. 허나 지금은 없으니 바로 다음 단계로 넘어간다. */
                if(valid_i) begin
            temp_result <= temp_result + number_i;                                                                         
            end

        


        end 

    end

    always @(posedge clk) begin
        if(valid_i&&run_i) begin
            temp_valid = 1'b1;
        end else begin
            temp_valid = 1'b0;
        end
    end




assign result_o = temp_result;
assign valid_o = temp_valid;
  
endmodule