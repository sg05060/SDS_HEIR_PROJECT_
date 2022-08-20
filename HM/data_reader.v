module data_reader
# (
  parameter DWIDTH = 32,
  parameter CNT_WIDTH = 7,
  parameter MEM_SIZE = 100,
)
(
  input clk,
  input rst_n,

  input start_i,
  input [CNT_WIDTH - 1 : 0] cnt_val_i,

  output idle_o,
  output run_o,
  output done_o,
  output [DWIDTH - 1 : 0] q_o
);

// inst
  wire [CNT_WIDTH - 1 : 0] cnt_w;
  wire run_w;

  Counter_TOP #(
    .CNT_WIDTH (CNT_WIDTH)
  ) Counter_TOP_inst0 (
      .clk,
     .rst_n,
    
      .start_i (start_i),
     .cnt_val_i (cnt_val_i),
    
     .cnt_o (cnt_w),
     .idle_o (idle_o),
     .run_o (run_w),
     .done_o (done_o)
  );

  true_dpbram #(
    .DWIDTH (DWIDTH),
    .AWIDTH (CNT_WIDTH),
    .MEM_SIZE = 3840
  ) true_dpbram_inst0 (
    .clk (clk),

    /* input for port 0 */
   .addr0_i (cnt_w),
   .ce0_i (run_w),
   .we0_i (1'b0),  // read only
   .d0_i (),

   /* input for port 1 */
   .addr1_i (),
   .ce1_i (),
   .we1_i (),
   .d1_i (),

    /* output for port 0 */
   .q0_o (q_o),
    
    /* output for port 1 */
    .q1_o ()
  );  

  assign run_o = run_w;

endmodule