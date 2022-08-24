module Counter_fsm #(
    parameter CNT_WIDTH = 7
    )
    (
    input clk,
    input rst_n,
    
    input start_i,
    
    input [CNT_WIDTH-1:0] cnt_val_i,  // purpose of count
    input [CNT_WIDTH-1:0] cnt_i,      // counter counting number
    
    output idle_o,
    output run_o,
    output done_o
);

    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;
    
    
    reg [CNT_WIDTH-1:0] cnt_val;
    // 1. cnt val capture
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_val <= {(CNT_WIDTH){1'b0}};        
        end else if (start_i) begin
            cnt_val <= cnt_val_i;        
        end 
    end
    
    
    reg [1:0] c_state, n_state;
    // 2. FSM seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end
    
    // 3. FSM comb logic
    always @(*) begin
        n_state = c_state;    // prevent latch
        case (c_state) 
            IDLE : begin
                if (start_i) begin
                    n_state = RUN;  // if start_i, transition to RUN state
                end 
            end
            RUN : begin
                if (cnt_i == cnt_val - 2) begin
                    n_state = DONE; // if counter number is equal to cnt_val, transition to DONE state
                end
            end
            DONE : begin
                n_state = IDLE; // next cycle transition to IDLE
            end
        endcase
    end
    
    assign idle_o   = (c_state == IDLE);
    assign run_o    = (c_state == RUN);
    assign done_o   = (c_state == DONE);


endmodule