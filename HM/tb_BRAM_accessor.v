`timescale 1ps/1ps
`define DELTA 1
`define CLOCK_PERIOD 10

module tb_BRAM_accessor;

    parameter CNT_BIT = 31;
    parameter DWIDTH_1 = 32;
    parameter DWIDTH_2 = 64;
    parameter AWIDTH = 8;
    parameter MEM_SIZE = 256;
    parameter IN_DATA_WIDTH = 8;

    reg clk;
    reg reset_n;
    reg start_run_i;
    reg [CNT_BIT - 1 : 0] run_count_i;
    reg [DWIDTH_1 - 1 : 0] q_b0_i;
    reg [DWIDTH_2 - 1 : 0] q_b1_i;

    wire idle_o;
    wire read_o;
    wire write_o;
    wire done_o;

    wire [AWIDTH - 1 : 0] addr_b0_o;
    wire ce_b0_o;
    wire we_b0_o;
    wire [DWIDTH_1 - 1 : 0] d_b0_o;
 
    wire [AWIDTH - 1 : 0] addr_b1_o;
    wire ce_b1_o;
    wire we_b1_o;
    wire [DWIDTH_2 - 1 : 0] d_b1_o;


     BRAM_accessor#(
        .CNT_BIT       ( CNT_BIT       ),
        .DWIDTH_1      ( DWIDTH_1      ),
        .DWIDTH_2      ( DWIDTH_2      ),
        .AWIDTH        ( AWIDTH        ),
        .MEM_SIZE      ( MEM_SIZE      ),
        .IN_DATA_WIDTH ( IN_DATA_WIDTH )
    )u_BRAM_accessor(
        .clk            ( clk         ),
        .reset_n        ( reset_n     ),
        .start_run_i    ( start_run_i ),
        .run_count_i    ( run_count_i ),
        .q_b0_i         ( q_b0_i      ),
        .q_b1_i         ( q_b1_i      ),
        .idle_o         ( idle_o      ),
        .read_o         ( read_o      ),
        .write_o        ( write_o     ),
        .done_o         ( done_o      ),
        .addr_b0_o      ( addr_b0_o   ),
        .ce_b0_o        ( ce_b0_o     ),
        .we_b0_o        ( we_b0_o     ),
        .d_b0_o         ( d_b0_o      ),
        .addr_b1_o      ( addr_b1_o   ),
        .ce_b1_o        ( ce_b1_o     ),
        .we_b1_o        ( we_b1_o     ),
        .d_b1_o         ( d_b1_o      )
    );
    
    // Clock signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    integer i;

    initial begin
        clk = 0;
        reset_n = 0;
        start_run_i = 0;
        run_count_i = {(CNT_BIT){1'b0}};
        q_b0_i = {(DWIDTH_1){1'b0}};
        q_b1_i = {(DWIDTH_2){1'b0}};
    end

    initial begin
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(posedge clk); 
        #(`DELTA)
        reset_n = 1;

        @(posedge clk); 
        #(`DELTA)
        start_run_i = 1'b1;

    end
endmodule