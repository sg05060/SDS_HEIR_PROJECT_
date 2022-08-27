`timescale 1ns/1ps
`define DELTA 0.5

module Counter #(
    // parameter
    parameter CNT_WIDTH = 7 // we purpose addr 100(2^7 = 128)
    )
    (

    // special input
    input clk,
    input rst_n,
    input done_i,
    
    // control input
    input en,
    
    // output
    output [CNT_WIDTH-1:0] cnt_o,
    output valid_o
    );
    
    // Local param
    
    // declare reg type variable(cnt -> flipflop, cnt_n -> comb)
    reg [CNT_WIDTH-1:0] cnt;
    reg valid;
    
    
    // 1. counter seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt <= {(CNT_WIDTH){1'b0}};
        end else if (done_i) begin
            cnt <= {(CNT_WIDTH){1'b0}};
        end else if (en) begin
            cnt <= cnt + 'd1;
        end else begin
        end
    end
    

    // 3. valid_o logic
    // 조합회로로서 en이 1이되면 바로 valid가 1이 방출된다.
    // 즉 counter_fsm에서 run이 되자마자 바로 이 카운터는 주소값을 방출한다.
    always @(*) begin
        if (!rst_n || done_i) begin
            valid = 1'b0;
        end else if (en) begin
            valid = 1'b1;
        end else begin
            valid = 1'b0;
        end
    end
    
    /*// 4. vallid_o comb logic
    always @(*) begin
        valid_n = valid;    // prevent latch
        if (en) begin
            valid_n = 1'b1;
        end else if (done_i) begin
            valid_n = 1'b0;
        end
    end*/

    //  output assign statement
    // 써도되는 주소값을 방출하는지 확인하는 valid_o를 쓴다.
    assign cnt_o = cnt;
    assign valid_o = valid;
    
endmodule