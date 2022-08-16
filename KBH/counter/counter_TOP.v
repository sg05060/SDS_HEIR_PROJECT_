module Counter_TOP #(
    parameter CNT_WIDTH = 7
    )
    (
    input clk,
    input rst_n,
    
    input start_i,
    input [CNT_WIDTH-1:0] cnt_val_i,
    
    output [CNT_WIDTH-1:0] cnt_o,
    output idle_o,
    output run_o,
    output done_o
    );

    // link counter - counter_fsm
    wire idle_w, run_w, done_w;
    wire [CNT_WIDTH-1:0] cnt_w;

    // Counter inst
    Counter #(
        .CNT_WIDTH ( CNT_WIDTH )
    )u_Counter(
        .clk    ( clk           ),
        .rst_n  ( rst_n         ),  // reset when reset or done
        .done_i ( done_w        ),
        .en     ( run_w         ),  // count start when fsm state is RUN
        .cnt_o  ( cnt_w         )   
    );
    
    // fsm inst
    Counter_fsm #(
        .CNT_WIDTH ( CNT_WIDTH )
    )u_Counter_fsm(
        .clk       ( clk       ),
        .rst_n     ( rst_n     ),
        .start_i   ( start_i   ),
        .cnt_val_i ( cnt_val_i ),
        .cnt_i     ( cnt_w     ),
        .idle_o    ( idle_w    ),
        .run_o     ( run_w     ),
        .done_o    ( done_w    )
    );

    // output logic
    assign idle_o = idle_w;
    assign run_o = run_w;
    assign done_o = done_w;
    assign cnt_o = cnt_w;

endmodule