`timescale 1ns/1ps
`define DELTA 2

module tb_acc_core;

parameter IN_DATA_WIDTH = 8;
parameter DWIDTH = 16;

reg clk, reset_n;

reg [IN_DATA_WIDTH - 1 : 0] number_i;

reg valid_i;
reg run_i;

wire valid_o;
wire [DWIDTH - 1 : 0] result_o;

integer i;

always #5 clk = ~clk;

initial begin
    // initialize input
    clk       = 0;
    reset_n   = 1'b1;
    valid_i   = 1'b0;
    run_i     = 1'b0;
    number_i  = {(IN_DATA_WIDTH){1'b0}};
        
    // Reset
    #(`DELTA)
    reset_n = 1'b0;
        
    #(`DELTA)
    reset_n = 1'b1;
    
    // give vaild_i, run_i
    for (i = 1; i < 101 ; i = i + 1) begin 
        @(posedge clk);
        #(`DELTA)
        valid_i    = 1'b1;
        run_i      = 1'b1;
        number_i   = 1'b1;
    end

    @(posedge clk);
    #(`DELTA)
    valid_i  = 1'b0;
    run_i    = 1'b0;
end

acc_core#(
    .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
    .DWIDTH        ( DWIDTH )
)u_acc_core(
    .clk           ( clk           ),
    .reset_n       ( reset_n       ),
    .number_i      ( number_i      ),
    .valid_i       ( valid_i       ),
    .run_i         ( run_i         ),
    .valid_o       ( valid_o       ),
    .result_o      ( result_o      )
);

endmodule