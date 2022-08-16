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
//    Notice
//      this module has 2 cycle latency

module acc_core
# (
    parameter IN_DATA_WIDTH = 8, // 들어오는 건 한 칸 8비트
    parameter DWIDTH = 16 // 나가는 건 한 칸에  16비트
) 
(
    input clk, reset_n,

    input [IN_DATA_WIDTH - 1 : 0] number_i, // 들어오는 값

    input valid_i,
    input run_i,

    output valid_o,         
    output [DWIDTH - 1 : 0] result_o  //더해져서 커진 값
);

    reg valid;
    reg [DWIDTH - 1 : 0] save, save_n;

    // 누산 순차회로 
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            save <= {(DWIDTH){1'b0}}; // 0으로 초기화
        end else begin 
            save <= save_n;
        end
    end

    // 누산 조합회로
    always @(*) begin
        save_n = save;    // prevent latch
        if (valid_i && run_i) begin 
            save_n = save + number_i;
        end else begin
        end
    end

    // valid_o 순차회로 
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            valid <= 0;
        end if (valid_i && run_i) begin 
            valid <= 1;
        end else begin 
            valid <= 0;
        end
    end

    // valid_o 조합회로 사용 안했습니다.
/*    always @(*) begin
        if (valid_i && run_i) begin 
            
        end else begin 
            
        end
    end */

    assign result_o = save;
    assign   valid_o = valid;

endmodule