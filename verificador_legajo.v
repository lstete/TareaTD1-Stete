module verificador_legajo ( 
input  wire clk, 
input  wire arst,
input  wire start,  
input  wire valid,
input  wire [3:0] dato, 
output wire  busy, 
output wire  done, 
output wire  [3:0] verificador
); 

// SEÑALES DE CONTROL
wire clean;
wire acumular;
// SEÑALES DE ESTADO
wire TC;
wire ready;

datapath datapath (
    .clk(clk),
    .ARST(arst),
    .CLEAN(clean),
    .acumular(acumular),       // Si tengo un 1 acá activo el acumualador capturando la multiplicación y acumulándola
    .dato(dato),           // Es el número que se pondera y se acumula
    .digito(verificador),  // Rs el dígito verificador
    .TC(TC),                 // Con esto sé cuándo le dí todos los dígitos necesarios
    .ready(ready)           // Me indica cuándo tengo el dígito verificador listo para leer
);

UC UC( 
    .clk(clk), 
    .ARST(arst),
    .START(start),
    .VALID(valid),
    .restando(TC),
    .ready(ready),
    .clean(clean),
    .acumular(acumular),
    .busy(busy),
    .done(done)
);

endmodule