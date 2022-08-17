`timescale 1ps/1ps
`define DELTA 2

module tb_acc_core;

    parameter IN_DATA_WIDTH = 8;
    parameter DWIDTH = 16;

    reg clk;
    reg reset_n;
    reg [IN_DATA_WIDTH - 1 : 0] number_i;
    reg valid_i;
    reg run_i;

    wire valid_o;
    wire [DWIDTH - 1 : 0] result_o;

    integer i;

    always #5 clk   = ~clk;

    initial begin
        clk       = 0;
        reset_n   = 0;
        number_i  = {(IN_DATA_WIDTH){1'b0}};
        valid_i   = 0;
        run_i     = 0;
    end

    initial begin
        repeat(4)
            @(posedge clk);
        
        //special input active
        @(posedge clk); 
        #(`DELTA)
        reset_n = 1;
        
        //Activate
        @(posedge clk); 
        #(`DELTA)
        run_i = 1;
        valid_i = 1;

        //accumulating
        for(i = 1; i <= 100; i=i+1) begin
            @(posedge clk); 
            #(`DELTA)
            number_i = i;
        end

        //Finish acivating
        @(posedge clk); 
        #(`DELTA)
        run_i = 0;
        valid_i = 0;
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