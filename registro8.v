module registro8 (
    input clk,
    input ARST,
    input LOAD,
    input EN,
    input [7:0] d_load,
    input [7:0] d,
    output reg [7:0] q
);

    always @(posedge clk or posedge ARST) begin
        if (ARST) begin
            q <= 8'd0;
        end
        else if (LOAD) begin
            q <= d_load;
        end
        else if (EN) begin
            q <= d;
        end
    end

endmodule