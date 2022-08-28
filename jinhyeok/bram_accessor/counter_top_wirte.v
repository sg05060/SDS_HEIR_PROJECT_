module counter_top_write #(
    parameter AWIDTH = 8,
    parameter CNT_BIT = 31
    )
    (
    input clk,
    input reset_n,
    
    input start_i,
    input [CNT_BIT - 1 : 0] cnt_val_i,
    
    output [AWIDTH - 1 : 0] cnt_o,
    output write_idle_o,
    output write_run_o,
    output write_done_o
    );

    // link counter - counter_fsm
    wire write_idle_w, write_run_w, write_done_w;
    wire [AWIDTH - 1 : 0] cnt_w;

    // Counter inst
    counter_read #(
        .AWIDTH ( AWIDTH )
    )u_Counter(
        .clk            ( clk           ),
        .reset_n        ( reset_n       ),  // reset when reset or done
        .write_run_i     ( write_run_w    ),  // count start when fsm state is RUN
        .write_done_i    ( write_done_w   ),
        .cnt_o          ( cnt_w         )   
    );
    
    // fsm inst
    counter_fsm_read #(
        .CNT_BIT ( CNT_BIT )
    )u_Counter_fsm(
        .clk            ( clk         ),
        .reset_n        ( reset_n     ),
        .start_i        ( start_i     ),
        .cnt_val_i      ( cnt_val_i   ),
        .cnt_i          ( cnt_w       ),
        .write_run_o     ( write_run_w  ),
        .write_idle_o    ( write_idle_w ),
        .write_done_o    ( write_done_w )
    );

    // output logic
    assign write_idle_o = write_idle_w;
    assign write_run_o = write_run_w;
    assign write_done_o = write_done_w;
    assign cnt_o = cnt_w;

endmodule