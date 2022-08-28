module core_controller #(
    // parameter
    parameter CNT_WIDTH = 12, // addr = 12bit
    parameter DATA_WIDTH = 32, // input data is 32bit number
    parameter CNT_BIT = 31,
    parameter IN_DATA_WIDTH = 8
    )
    (

    // special input
    input clk,
    input rst_n,

    // Top module input
    input start_run_i,

    // input controller
    input [DATA_WIDTH - 1 : 0] number_i,
    input valid_core_i,

    // output controller
    output [DATA_WIDTH - 1 : 0] result_o,
    output valid_core_o
    );

    reg [IN_DATA_WIDTH - 1 : 0] number1, number2, number3, number4;
    reg valid_1, valid_2, valid_3, valid_4;
    reg [DATA_WIDTH - 1 : 0] result, result_1, result_2, result_3, result_4;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            result <= 0;
        end else if (valid_core_i) begin
            number1 <= number_i [1 * IN_DATA_WIDTH - 1 : 0];
            number2 <= number_i [2 * IN_DATA_WIDTH - 1 : 1 * IN_DATA_WIDTH];
            number3 <= number_i [3 * IN_DATA_WIDTH - 1 : 2 * IN_DATA_WIDTH];
            number4 <= number_i [4 * IN_DATA_WIDTH - 1 : 3 * IN_DATA_WIDTH];
        end
    end

    //acc_core0
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_1(
        .clk           ( clk           ),
        .reset_n       ( rst_n       ),
        .number_i      ( number1      ),
        .valid_i       ( valid_i      ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_1       ),
        .result_o      ( result_1      )
    );

    //acc_core1
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_2(
        .clk           ( clk           ),
        .reset_n       ( rst_n       ),
        .number_i      ( number2      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_2       ),
        .result_o      ( result_2      )
    );

    //acc_core2
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_3(
        .clk           ( clk           ),
        .reset_n       ( rst_n       ),
        .number_i      ( number3      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_3       ),
        .result_o      ( result_3      )
    );

    //acc_core3
    acc_core#(
        .IN_DATA_WIDTH ( IN_DATA_WIDTH ),
        .DWIDTH        ( 2 * IN_DATA_WIDTH )
    )u_acc_core_4(
        .clk           ( clk           ),
        .reset_n       ( rst_n       ),
        .number_i      ( number4      ),
        .valid_i       ( check_w       ),
        .run_i         ( start_run_i   ),
        .valid_o       ( valid_4       ),
        .result_o      ( result_4      )
    );

    assign result_o = {result_4, result_3, result_2, result_1};
    assign valid_core_o = (valid_1 & valid_2 & valid_3 & valid_4);

endmodule