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

module acc_core #
    (
    // parameter
    parameter IN_DATA_WIDTH = 8,
    parameter DWIDTH        = 16
    ) 
    (
    // I/O
    input clk, reset_n,
    input [IN_DATA_WIDTH - 1 : 0] number_i,

    input valid_i,
    input run_i,

    output valid_o,
    output [DWIDTH - 1 : 0] result_o
    );

    // Declare reg
    reg [DWIDTH-1:0] result, result_n;
    
    
    // 1. Accumulate seq
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            result <= {(DWIDTH){1'b0}};
        end else if (run_i) begin
            result <= {(DWIDTH){1'b0}};
        end else begin
            result <= result_n;
        end
    end
    
    // 2. Accumulate comb
    always @(*) begin
        result_n = result;
        if (valid_i) begin
            result_n = result + number_i;
        end
    end
    
    
    reg valid, valid_n;
    // 3. Valid seq
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end else if (run_i) begin
            valid <= 1'b0;
        end else begin
            valid <= valid_n;
        end
    end

    // 4. Valid comb
    always @(*) begin
        valid_n = valid_i;
    end  
    
    // // latency2 case
    // reg [1:0] valid, valid_n;
    // always @(posedge clk, negedge reset_n) begin
    //     if (!reset_n) begin
    //         valid <= 2'b00;
    //     end else if (run_i) begin
    //         valid <= 2'b00;
    //     end else begin
    //         valid <= valid_n;
    //     end
    // end
    // 
    // always @(*) begin
    //     valid_n = {valid[0], valid_i};
    // end
    
    
    // 5. Output assigment
    assign valid_o = valid;
    assign result_o = result;
  
endmodule