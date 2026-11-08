module contador (
    input clk,
    input ARST,
    input EN,
    input CLEAN,
    output reg [3:0]count,
    output TC
);

always @(posedge clk, posedge ARST) begin
    if (ARST) begin
        count <= 4'd7;
    end else if(CLEAN) begin
        count <= 4'd7;
    end else if(EN) begin
        if (count == 4'd2) begin
            count<=7;
        end else begin
            count <= count - 1;
        end
    end
end

assign TC = (count == 4'd2) && EN;

endmodule