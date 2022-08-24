module counter_fsm_read #(
    parameter CNT_BIT = 31  //run_count_i 가 31bit 이다.
    )
    (
    input clk,
    input reset_n,
    
    input start_i,
    
    input [CNT_BIT - 1  :0] cnt_val_i,  // purpose of count
    input [CNT_BIT - 1 : 0] cnt_i,      // counter counting number
    
    output read_idle_o,
    output read_run_o,
    output read_done_o,
    output valid_o
);

    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;
    
    
    reg [CNT_BIT - 1 : 0] cnt_val;
    // 1. cnt val capture
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            cnt_val <= {(CNT_BIT){1'b0}};        
        end else if (start_i) begin
            cnt_val <= cnt_val_i;        
        end 
    end
    
    
    reg [1:0] c_state, n_state;
    // 2. FSM seq logic
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
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
                if (cnt_i == cnt_val - 1) begin
                    n_state = DONE; // if counter number is equal to cnt_val, transition to DONE state
                end
            end
            DONE : begin
                n_state = IDLE; // next cycle transition to IDLE
            end
        endcase
    end
    
    reg valid, valid_n;
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end else if (n_state == RUN) begin
            valid <= 1'b1;
        end else begin
            valid <= valid_n;
        end
    end

    always @(*) begin
        valid_n = 1'b0;
    end

    assign read_idle_o   = (c_state == IDLE);
    assign read_run_o    = (c_state == RUN);
    assign read_done_o   = (c_state == DONE);
    assign valid_o       = valid;

endmodule