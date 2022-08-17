module top_module # (
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 12,
    parameter MEM_DEPTH = 3840
) (
    input                           clk,
    input       [ADDR_WIDTH-1:0]    addr0_b0,
    input                           ce0_b0,
    input                           we0_b0,
    input       [DATA_WIDTH-1:0]    d0_b0,
    
    input                           reg_en,
    output      [DATA_WIDTH-1:0]    reg_out
);
    wire        [DATA_WIDTH-1:0]    q0_b0;
    reg         [DATA_WIDTH-1:0]    reg_data;
   
    always @(posedge clk) begin
        if(reg_en) begin
            reg_data <= q0_b0;
        end
    end

    true_dpbram
    #(
        .DWIDTH(DATA_WIDTH),
        .AWIDTH(ADDR_WIDTH),
        .MEM_SIZE(MEM_DEPTH)
    ) BRAM0_inst (
        /* Special Inputs */
        .clk(clk),

        /* for port 0 */
        .addr0_i(addr0_b0),
        .ce0_i(ce0_b0),
        .we0_i(we0_b0),
        .d0_i(d0_b0),

        /* for port 1 */
        .addr1_i(),
        .ce1_i(), // sharing with port0
        .we1_i(), // sharing
        .d1_i(),  // sharing (not used)

        /* output for port 0 */
        .q0_o(q0_b0),
        
        /* output for port 1 */
        .q1_o()
    );
    assign reg_out = reg_data;
endmodule