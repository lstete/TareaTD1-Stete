// Este módulo entrega en la salida acumulado=acumulado+a*b
module acumulador_ponderado (
    input  clk,
    input  EN,
    input  ARST,
    input  CLEAN,
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] acumulado
);
wire [7:0] d;
// Instancio mi registro de 8 bits
registro8 acumulador(
    .clk(clk),
    .ARST(ARST),
    .LOAD(CLEAN),
    .EN(EN),
    .d_load(8'd0),
    .d(d),
    .q(acumulado)
);

assign d = acumulado + a*b; 

endmodule