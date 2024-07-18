module counter #(
    parameter  END=15,
    parameter WIDTH=4
)(
    input wire clk,
    input wire rst,
    input wire cnt_inc,
    output wire cnt_end,
    output reg[WIDTH-1:0] cnt
);
    assign cnt_end = (cnt == END);

    always @(negedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else if(cnt_end) cnt <= 0;
        else if (cnt_inc) cnt <= cnt + 1;
        else if (!cnt_inc) cnt <= 0;//debounce中需要
    end
endmodule