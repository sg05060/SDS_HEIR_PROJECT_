/*
최종 doneout을 두번 늦춰주는 모듈.
최종 idleout을 내려갈때는 한번 올라갈때는 두번 늦춰줌.
*/
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

    reg done, done_n, done_nn;
    
    // 1. seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            done <= 0;       
        end else begin
            done <= done_n;   
        end 
    end

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            done_n <= 0;       
        end else begin
            done_n <= done_nn;      
        end 
    end
    
    
    // 2. comb logic
    always @(*) begin
        done_nn = done_i; 
    end
    
    assign idle_o   = read_i? 0: (write_i? 0: (done? 0:1));
    assign done_o   = done;


endmodule