
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
    reg [CNT_WIDTH-1:0] cnt, cnt_n, cnt_final;
    reg valid;
    reg valid_n;
    
    
    // 1. counter seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt <= {(CNT_WIDTH){1'b0}};
        end else begin
            cnt <= cnt_n;
        end
    end
    
    // 2. counter comb logic
    always @(*) begin
        cnt_n = cnt;    // prevent latch
        if (en) begin
            cnt_n = cnt + 'd1;
        end else if (done_i) begin
            cnt_n = {(CNT_WIDTH){1'b0}};
        end
    end

    // 3. valid_o logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            valid <= 1'b0;
        end else begin
            valid <= valid_n;
        end
    end
    
    // 4. vallid_o comb logic
    always @(*) begin
        valid_n = valid;    // prevent latch
        if (en) begin
            valid_n = 1'b1;
        end else if (done_i) begin
            valid_n = 1'b0;
        end
    end

    //cnt한번더 늦추기
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cnt_final <= 0;
        end else begin
            cnt_final <= cnt;
        end
    end


    // 3. output assign statement
    assign cnt_o = cnt_final;
    assign valid_o = valid;
    
endmodule