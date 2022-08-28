module counter #(
    parameter AWIDTH = 8   // 주소가 256까지니까
    )
    (
    
    input clk,
    input reset_n,        // 초기화
    input run_i,     // count 시작
    input done_i,    // count 끝

    output [AWIDTH - 1 : 0] cnt_o  // 주소값
    );
    
    // Local param
    
    // declare reg type variable(cnt -> flipflop, cnt_n -> comb)
    reg [AWIDTH - 1 : 0] cnt, cnt_n;
    // 1. counter seq logic
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            cnt <= {(AWIDTH){1'b0}};
        end else begin
            cnt <= cnt_n;
        end
    end
    
    // 2. counter comb logic
    always @(*) begin
        cnt_n = cnt;    // prevent latch
        if (run_i) begin
            cnt_n = cnt + 'd1;
        end else if (done_i) begin
            cnt_n = {(AWIDTH){1'b0}};
        end
    end

    assign cnt_o = cnt;
    
endmodule