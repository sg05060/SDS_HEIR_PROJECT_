`timescale 1ns/1ps
`define DELTA 1
`define IN_DATA_WIDTH 8
`define DWIDTH  16
`define CLOCK_PERIOD 6


module tb_acc_core(

);
    
reg clk;
reg rst_n;

reg [`IN_DATA_WIDTH - 1 : 0] number_i;
reg valid_i;
reg run_i;

wire valid_o;
wire [`DWIDTH - 1 : 0] result_o;

integer i;

//clock
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
       number_i = {(`IN_DATA_WIDTH){1'b0}};
       valid_i = 1'b0;
       run_i = 1'b0;
        
        // Reset
        #(`DELTA)
        rst_n = 1'b0;
        
        #(`DELTA)
        rst_n = 1'b1;
    
        // give vaild, run and number_i
        @(posedge clk);
        #(`DELTA)
        valid_i = 1'b1;
        run_i = 1'b1;
        
        //숫자 하나씩 주기
        
        for(i=1; i<= 100; i=i+1) begin
            @(posedge clk);
        #(`DELTA)
            number_i = i;
        end

        @(posedge clk);
        #(`DELTA)
        valid_i = 1'b0;

        @(posedge clk);
        #(`DELTA)
        run_i = 1'b0;
        
    

    end


acc_core #(
    .IN_DATA_WIDTH ( `IN_DATA_WIDTH ),
    .DWIDTH (`DWIDTH)
)u_acc_core(
    .clk      ( clk      ),
    .rst_n  ( rst_n  ),
    .number_i ( number_i ),
    .valid_i  ( valid_i  ),
    .run_i    ( run_i    ),
    .valid_o  ( valid_o  ),
    .result_o  ( result_o  )
);

endmodule