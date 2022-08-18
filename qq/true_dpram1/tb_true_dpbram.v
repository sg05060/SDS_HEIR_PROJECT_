`timescale 1ns/1ps
`define DELTA 2

module tb_true_dpbram;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 8;
    parameter MEM_DEPTH = 512;

    reg                         clk;
    reg     [ADDR_WIDTH-1:0]    addr0_b0;
    reg                         ce0_b0;
    reg                         we0_b0;
    reg     [DATA_WIDTH-1:0]    d0_b0;
    
    wire    [DATA_WIDTH-1:0]    q0_b0;


    always #5 clk   = ~clk;

    initial begin
        clk         = 0;
        addr0_b0    = {(ADDR_WIDTH){1'b0}};
        ce0_b0      = 0;
        we0_b0      = 0;
        d0_b0       = {(DATA_WIDTH){1'b0}};
    end

    initial begin
        // Write operation
        repeat(5)
            @(posedge clk);
            //first, write data to addr = 0xFF
            #(`DELTA)
                addr0_b0    = 8'h01;
                ce0_b0      = 1;
                we0_b0      = 1;
                d0_b0       = 32'h0001;

            //Second, write data to addr = 0xAA
        @(posedge clk);    
            #(`DELTA)
                addr0_b0    = 8'h02;
                ce0_b0      = 1;
                we0_b0      = 1;
                d0_b0       = 32'h0002;

        // After write, disenable chip enable.
        @(posedge clk);
            #(`DELTA)
                ce0_b0      = 0;
                we0_b0      = 0;

        // read operation
        repeat(5)
            @(posedge clk);
        // first, read data from addr = 0xFF
        #(`DELTA)
            addr0_b0    = 8'h01;
            ce0_b0      = 1;
            we0_b0      = 0;

        // Second, read data from addr = 0xAA
        @(posedge clk);    
            #(`DELTA)
                addr0_b0    = 8'h02;
                ce0_b0      = 1;
                we0_b0      = 0;
        
        // After read, disenable chip enable.
        @(posedge clk);
            #(`DELTA)
                ce0_b0      = 0;
                we0_b0      = 0;
        

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
endmodule