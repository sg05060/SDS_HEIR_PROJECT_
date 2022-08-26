module output_controller #(
    // parameter
    parameter CNT_WIDTH = 12, // addr = 12bit
    parameter DATA_WIDTH = 32, // input data is 32bit number
    parameter CNT_BIT = 31
    )
    (

    // special input
    input clk,
    input rst_n,
    
    // BRAM input ( input port is unused )
    input [DATA_WIDTH - 1 : 0] q0_o,
    input [DATA_WIDTH - 1 : 0] q1_o, 

    // Top module input
    input [CNT_BIT - 1 : 0] run_count_i,    
    
    // Core controller input
    input [DATA_WIDTH - 1 : 0] result_i,
    input valid_i,

    // Top module output
    output reg write_o,
    output reg done_o,
    


    // BRAM output
    output [CNT_WIDTH - 1 : 0] addr0_o,
    output ce0_o,
    output we0_o,
    output [DATA_WIDTH - 1 : 0] d0_o, 

    /* input for port 1 */
    // port1 is unused
    output [CNT_WIDTH - 1 : 0] addr1_o,
    output ce1_o,
    output we1_o,
    output [DATA_WIDTH - 1 : 0] d1_o
    );

    
    
    // Local param
    
    // declare reg type variable(cnt -> flipflop, cnt_n -> comb)
    reg [CNT_WIDTH - 1 : 0] cnt, cnt_n;

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
        write_o = 0;
        done_o = 0;
        if (valid_i) begin
          cnt_n = cnt + 'd1;
          write_o = 1;
        end
        if (cnt_n == run_count_i - 1) begin
          write_o = 0;
          done_o = 1;
        end
        /*end else if (done_i) begin
            cnt = {(CNT_WIDTH){1'b0}};
        end*/
    end
    
    // 3. output assign statement
    assign addr0_o = cnt;
    assign d0_o = result_i;
    assign ce0_o = write_o;
    
endmodule