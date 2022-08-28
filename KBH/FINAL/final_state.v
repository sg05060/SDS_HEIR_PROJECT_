
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
    
    // 아래는 디버깅과정을 지나다 보니 매우 괴랄해졌습니다.. ㅠㅠ

    // BA의 최종 아웃풋인 read_o와 write_o는 정확한 값이다.
    // 즉 정확히 읽을(쓸) 때 켜지고 안 읽을(쓸) 때 조금(관성지연) 뒤에 바로 0이 된다.
    // 따라서 idle과 done은 후순위 인자로서 배정하고 read와 write을 통해 배정한다.
    // 어차피 reset은 write와 read와 done에서 0으로 만들어 주기 때문에 idle은 reset에 종속이다.
    // 정확하게 counter_fsm에서 done 1로 뜰 때 read가 끝나며 그 다음 클락에 write가 끝난다. (관성지연 고려)
    assign #2 idle_o   = read_i? 0: (write_i? 0: (done? 0:1));

    // write가 끝날 때, 즉 counter_fsm의 done이 1로 뜬 바로 다음 클락에 최종 done_o 값을 1로 되게 하려했으나
    // write가 counter_fsm의 done이 1로 뜨고 그 다음클락보다 조금 늦게 0으로 내려가서
    // done에도 아래와 같은 회로를 심었다.
    assign #2 done_o   = read_i? 0: (write_i? 0: done);


endmodule