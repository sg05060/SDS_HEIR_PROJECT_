module check (
    input clk,
    input rst_n,

    input check_i,
    input done_i,

    output check_o
);

    reg check, check_n;

    //check seq
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            check <= 1'b0;
        end else begin
            check <= check_n;
        end
    end

    //check comb
    always @(*) begin
        check_n = check;
        if (check_i) begin
            check_n = 1'b1;
        end else if (done_i) begin
            check_n = 1'b0;
        end
    end

    assign check_o = check;

endmodule