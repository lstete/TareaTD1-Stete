module datapath (
    input  clk,
    input  ARST,
    input  CLEAN,
    input  acumular,       // Si tengo un 1 acá activo el acumualador capturando la multiplicación y acumulándola
    input  [3:0] dato,     // Es el número que se pondera y se acumula
    output [3:0] digito,   // Rs el dígito verificador
    output TC,             // Con esto sé cuándo le dí todos los dígitos necesarios
    output ready           // Me indica cuándo tengo el dígito verificador listo para leer
);

wire [3:0] coeficiente;
wire [7:0] acumulado, resto;
wire restar;

acumulador_ponderado acumulador(
    .clk(clk),
    .EN(acumular),
    .ARST(ARST),
    .CLEAN(CLEAN),
    .a(dato),
    .b(coeficiente),
    .acumulado(acumulado)
);

contador ponderador (
    .clk(clk),
    .ARST(ARST),
    .CLEAN(CLEAN),
    .EN(acumular),
    .count(coeficiente),
    .TC(restar)
);

resto restador (
    .clk(clk), 
    .ARST(ARST),

    .a(acumulado),
    .b(8'd11),

    .START(restar),
    .resto(resto),
    .busy(busy),
    .ready(ready)
);

assign TC = restar; // Es cuando ya sumé los 6 dígitos y la UC puede pasar al sig estado
assign digito = (resto==8'd10) ? 4'd0 : resto[3:0];

endmodule