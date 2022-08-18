module final_state
    (
    input clk,
    input rst_n,
    
    input idle_i,
    input done_i,

    output idle_o,
    output done_o
);

    reg idle, idle_n;
    reg done, done_n;
    
    // 1. seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            idle <= 1;
            done <= 0;       
        end else begin
            idle <= idle_n;
            done <= done_n;   
        end 
    end
    
    
    // 2. comb logic
    always @(*) begin
        idle_n = idle_i;
        done_n = done_i; 
    end
    
    assign idle_o   = idle;
    assign done_o   = done;


endmodule