`timescale 1ns/1ps
`define DELTA 1
`define CLOCK_PERIOD 10

module acc_core_tb #(
  parameter IN_DATA_WIDTH = 8,
  parameter DWIDTH = IN_DATA_WIDTH * 4
  );

  reg clk;
  reg reset_n;

  reg [IN_DATA_WIDTH - 1 : 0] number_i;

  reg valid_i;
  reg run_i;

  wire valid_o;
  wire [DWIDTH - 1 : 0] result_o;

  acc_core #(
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
    reset_n = 1'b1;
    run_i = 1'b0;
    valid_i = 1'b0;
    number_i = {(IN_DATA_WIDTH){1'b0}};

    // Reset
    #(`DELTA)
    reset_n = 1'b0;

    #(`DELTA)
    reset_n = 1'b1;
    
    
    // give valid and number
    @(posedge clk);
    #(`DELTA)
    run_i = 1'b1;
    valid_i = 1'b1;
    number_i = 8'b00000001;

    // valid is maintained for 1 thick
    @(posedge clk);
    #(`DELTA)
    valid_i = 1'b0;
    number_i = 8'b0;

    @(posedge clk);

    // give next number
    @(posedge clk);
    valid_i = 1'b1;
    number_i = 8'b00000011;

    @(posedge clk);
    #(`DELTA)
    valid_i = 1'b0;
    number_i = 8'b0;

    repeat(10) begin
      @(posedge clk);
    end

    run_i = 1'b0;
  end
endmodule