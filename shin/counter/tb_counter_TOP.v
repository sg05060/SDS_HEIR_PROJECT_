`timescale 1ps/1ps
`define DELTA 1
`define CLOCK_PERIOD 10

module TB_Counter_TOP #(
    parameter CNT_WIDTH = 7
    )
    (
    // No port
    // This is TB
    );
    
    
    reg clk;
    reg rst_n;
    
    reg start_i;
    reg [CNT_WIDTH-1:0] cnt_val_i;
    
    wire [CNT_WIDTH-1:0] cnt_o;
    wire done_o;

    // DUT inst
    Counter_TOP #(
        .CNT_WIDTH  ( CNT_WIDTH )
    )u_TB_Counter_TOP(
        .clk       ( clk       ),
        .rst_n     ( rst_n     ),
        .start_i   ( start_i   ),
        .cnt_val_i ( cnt_val_i ),
        .cnt_o     ( cnt_o     ),
        .done_o    ( done_o    )
    );
    
    // Clock signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    // Stimulus
    initial begin
        // initialize input
        rst_n = 1'b1;
        start_i = 1'b0;
        cnt_val_i = {(CNT_WIDTH){1'b0}};
        
        // Reset
        #(`DELTA)
        rst_n = 1'b0;
        
        #(`DELTA)
        rst_n = 1'b1;
    
        // give start and cnt_val
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b1;
        cnt_val_i = 'd100;
        
        // start and cnt_val is just maintained 1thick
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
        cnt_val_i = 'd0;
        
        repeat(120) begin
            @(posedge clk);
            cnt_val_i = 'd0;
        end
    end

endmodule