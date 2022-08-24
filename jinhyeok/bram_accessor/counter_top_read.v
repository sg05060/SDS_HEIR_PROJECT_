module counter_top_read #(
    parameter AWIDTH = 8,
    parameter CNT_BIT = 31
    )
    (
    input clk,
    input reset_n,
    
    input start_i,
    input [CNT_BIT - 1 : 0] cnt_val_i,
    
    output [AWIDTH - 1 : 0] cnt_o,
    output read_idle_o,
    output read_run_o,
    output read_done_o,
    output valid_o
    );

    // link counter - counter_fsm
    wire read_idle_w, read_run_w, read_done_w, valid_w;
    wire [AWIDTH - 1 : 0] cnt_w;

    // Counter inst
    counter_read #(
        .AWIDTH ( AWIDTH )
    )u_counter_read(
        .clk            ( clk           ),
        .reset_n        ( reset_n       ),  // reset when reset or done
        .read_run_i     ( read_run_w    ),  // count start when fsm state is RUN
        .read_done_i    ( read_done_w   ),
        .cnt_o          ( cnt_w         )   
    );
    
    // fsm inst
    counter_fsm_read #(
        .CNT_BIT ( CNT_BIT )
    )u_counter_fsm_read(
        .clk            ( clk         ),
        .reset_n        ( reset_n     ),
        .start_i        ( start_i     ),
        .cnt_val_i      ( cnt_val_i   ),
        .cnt_i          ( cnt_w       ),
        .read_run_o     ( read_run_w  ),
        .read_idle_o    ( read_idle_w ),
        .read_done_o    ( read_done_w ),
        .valid_o        ( valid_w     )
    );

    // output logic
    assign read_idle_o = read_idle_w;
    assign read_run_o = read_run_w;
    assign read_done_o = read_done_w;
    assign cnt_o = cnt_w;
    assign valid_o = valid_w;

endmodule