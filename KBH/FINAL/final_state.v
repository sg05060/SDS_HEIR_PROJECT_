/*
최종 doneout을 두번 늦춰주는 모듈.
최종 idleout을 내려갈때는 한번 올라갈때는 두번 늦춰줌.
*/
`timescale 1ns/1ps
`define DELTA 0.5
module final_state
    (
    input clk,
    input rst_n,
    
    input read_i,
    input write_i,
    input idle_i,
    input done_i,

    output idle_o,
    output done_o
);

    reg done, done_n;
    
    // 1. seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            done <= 0;       
        end else begin
            done <= done_n;   
        end 
    end

    // 2. comb logic
    always @(*) begin
        done_n = done_i; 
    end
    
    assign #2 idle_o   = read_i? 0: (write_i? 0: (done? 0:1));
    assign #2 done_o   = read_i? 0: (write_i? 0: done);


endmodule