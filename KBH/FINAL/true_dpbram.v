// Module Name: true_dpbram
// 
// discription
//      2 - port dpbram. Module gets control signal from oiutside and 
//      WRITE data to memory or READ DATA fromm Memory.
//      2 - port means it has 2 addr port, enable port, output port ...etc
//      so user can write and read data simultaneously or W/R only.
//
// inputs
//      clk: special inputs. Clock
//      addr0_i/addr1_i: address of memory that user want to access(both W/R)
//      ce0_i/ce1_i: chip enable
//      we0_i/we1_i: write enable. 0 means read mode and 1 means write mode
//      d0_i/d1_i: data that user wants to write
// 
// outputs
//      q0_o/q1_o: port that read data goes out
//

`timescale 1 ns / 1 ps
module true_dpbram
#(
    parameter DWIDTH = 16,
    parameter AWIDTH = 12,
    parameter MEM_SIZE = 3840
)

(
    /* Special Inputs */
    input clk,

    /* input for port 0 */
    input [AWIDTH - 1 : 0] addr0_i,
    input ce0_i,
    input we0_i,
    input [DWIDTH - 1 : 0] d0_i,

    /* input for port 1 */
    input [AWIDTH - 1 : 0] addr1_i,
    input ce1_i,
    input we1_i,
    input [DWIDTH - 1 : 0] d1_i,

    /* output for port 0 */
    output reg [DWIDTH - 1 : 0] q0_o,
    
    /* output for port 1 */
    output reg [DWIDTH - 1 : 0] q1_o
);

    /* Making Block Memory*/
    (* ram_style = "block" *)reg [DWIDTH - 1 : 0] ram[0 : MEM_SIZE - 1];

    reg [DWIDTH - 1 : 0] save1, save2;
    reg [DWIDTH - 1 : 0] save3, save4;
    // always block for port0
    always @(posedge clk) begin
        ram[addr0_i] <= save1;
        q0_o <= save2;
        
    end

    always @(*) begin
        if(ce0_i) begin
            if(we0_i) save1 = d0_i;
            else      save2 = ram[addr0_i];
        end
    end


    // always block for port1
    always @(posedge clk) begin
        ram[addr1_i] <= save3;
        q1_o <= save4;
        
    end

    always @(*) begin
        if(ce1_i) begin
            if(we1_i) save3 = d1_i;
            else      save4 = ram[addr1_i];
        end
    end
endmodule