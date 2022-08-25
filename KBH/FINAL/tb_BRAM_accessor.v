`timescale 1ns/1ps
`define DELTA 0.5

module tb_BRAM_accessor # (
    parameter CNT_BIT = 31, //AWIDTH랑 같아야지않나? 몰라

    /* parameter for BRAM */
    parameter DWIDTH_1 = 32,
    parameter DWIDTH_2 = 64,
    parameter AWIDTH = 8,
    parameter MEM_SIZE = 256,
    parameter IN_DATA_WIDTH = 8 //한 코어에 들어가는 데이터너비
    ) 
    (
    // This is TB
    );
    /* Special Inputs*/
    reg clk;
    reg reset_n;

    /* Signal From Register */
    reg start_run_i;
    reg [CNT_BIT - 1 : 0] run_count_i;

    /* Memory I/F output for BRAM0 */
    reg [DWIDTH_1 - 1 : 0] q_b0_i;

    /* Memory I/F Input for BRAM1 */
    reg [DWIDTH_2 - 1 : 0] q_b1_i;

    /* State_Outputs */
    wire idle_o;
    //output run_o, //custome adding
    wire read_o;
    wire write_o;
    wire done_o;

    /* Memory I/F output for BRAM0 */
    wire [AWIDTH - 1 : 0] addr_b0_o;
    wire ce_b0_o;
    wire we_b0_o;
    wire [DWIDTH_1 - 1 : 0] d_b0_o;
 
    /* Memory I/F output for BRAM1 */
    wire [AWIDTH - 1 : 0] addr_b1_o;
    wire ce_b1_o;
    wire we_b1_o;
    wire [DWIDTH_2 - 1 : 0] d_b1_o;

    // 아래 5개 레지스터는 테벤확인용도!
    reg [DWIDTH_2 - 1 : 0] written_data;
    reg [(DWIDTH_2/4)*4 - 1 : (DWIDTH_2/4)*3] written_data_sliced1;
    reg [(DWIDTH_2/4)*3 - 1 : (DWIDTH_2/4)*2] written_data_sliced2;
    reg [(DWIDTH_2/4)*2 - 1 : (DWIDTH_2/4)*1] written_data_sliced3;
    reg [(DWIDTH_2/4)*1 - 1 : (DWIDTH_2/4)*0] written_data_sliced4;


    integer i; // bram0에 데이터 넣을 때 쓸 것.
    /*integer status;
    reg [7:0] a_0, a_1, a_2, a_3;*/
    reg [DWIDTH_1 - 1 : 0] bram0[0 : MEM_SIZE - 1];
    reg [DWIDTH_2 - 1 : 0] bram1[0 : MEM_SIZE - 1];

    //클락 점핑
    always #5 clk   = ~clk;
    
    // bram0에서 가져올 때 쓸 always문
    always @(*) begin
        if(ce_b0_o) begin
            if(we_b0_o) ;
            else      q_b0_i = bram0[addr_b0_o];
        end
    end

    // bram1에 쓸 때 쓸 always문
    always @(*) begin
        if(ce_b1_o) begin
            if(we_b1_o) begin 
                bram1[addr_b1_o] = d_b1_o;

                //아래 5줄은 테벤 결과에서 확인하려고함.
                written_data  = d_b1_o; 
                written_data_sliced1 = d_b1_o[(DWIDTH_2/4)*4 - 1 : (DWIDTH_2/4)*3];
                written_data_sliced2 = d_b1_o[(DWIDTH_2/4)*3 - 1 : (DWIDTH_2/4)*2];
                written_data_sliced3 = d_b1_o[(DWIDTH_2/4)*2 - 1 : (DWIDTH_2/4)*1];
                written_data_sliced4 = d_b1_o[(DWIDTH_2/4)*1 - 1 : (DWIDTH_2/4)*0];
            end
            else      ;
        end
    end


    //초기값 설정
    initial begin
        clk         = 0;
        reset_n     = 0;

        start_run_i = 0;
        run_count_i = 0;
        
        q_b0_i = 0;
        q_b1_i = 0;

        for (i = 0; i < MEM_SIZE ; i = i + 1) begin 
            bram0[i] =     //32비트 1 3 5 7 각 사분자리에 삽입.
            'b00000001000000110000010100000111;
        end

        /*$display("Mem write to BRAM0 [%d]", $time);
        for (i = 0; i < MEM_SIZE; i = i+1) begin
            status = $fscanf(f_in_node, "%d %d %d %d \n", a_0, a_1, a_2, a_3);
            bram0_inst.bram0[i] = {a_0, a_1, a_2, a_3};
        end*/

        @(posedge clk); //간격

        @(posedge clk); 
        #(`DELTA)     
        reset_n     = 1;

        @(posedge clk); 
        #(`DELTA)       
        reset_n     = 0;
        // 리셋 완료
        @(posedge clk); 
        #(`DELTA)      
        reset_n     = 1;

        @(posedge clk); 
        #(`DELTA)
        start_run_i = 1;
        run_count_i = 255; 

        @(posedge clk); 
        #(`DELTA)
        start_run_i = 0;
        run_count_i = 0; 


    end

BRAM_accessor#(
    .CNT_BIT          ( CNT_BIT ),
    .DWIDTH_1      ( DWIDTH_1 ),
    .DWIDTH_2       ( DWIDTH_2 ),
    .AWIDTH       ( AWIDTH ),
    .MEM_SIZE    ( MEM_SIZE ),
    .IN_DATA_WIDTH     ( IN_DATA_WIDTH )
)u_BRAM_accessor(
    .clk     (  clk     ),
    .reset_n    ( reset_n    ),
    .start_run_i    (   start_run_i   ),
    .run_count_i    ( run_count_i   ),
    .q_b0_i   (    q_b0_i     ),
    .q_b1_i (    ), //안씀
    .idle_o   ( idle_o   ),
    .read_o     ( read_o    ),
    .write_o    ( write_o       ),
    .done_o   ( done_o     ),
    .addr_b0_o (  addr_b0_o ),
    .ce_b0_o     ( ce_b0_o      ),
    .we_b0_o     ( we_b0_o      ),
    .d_b0_o     (       ), //안씀
    .addr_b1_o ( addr_b1_o ),
    .ce_b1_o   ( ce_b1_o   ),
    .we_b1_o   ( we_b1_o     ),
    .d_b1_o     ( d_b1_o     )
);

    
endmodule