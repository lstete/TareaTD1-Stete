module resto (
    input  clk, 
    input  START, ARST,
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] resto,
    output reg busy, ready
);

localparam     IDLE   = 3'd0,
               LOAD   = 3'd1,
               RESTAR = 3'd2,
               FINISH = 3'd3;
reg [2:0] estado_actual, estado_futuro;

// Bloque secuencial
always@(posedge clk, posedge ARST) begin
    if(ARST) begin
        estado_actual <= IDLE;
    end else begin
        estado_actual <= estado_futuro;
    end
end
// Instancio dos registros para el resto y para b
reg L_Resto, E_Resto;
reg [7:0] d_Resto;

registro8 resto_reg(.clk(clk), .ARST(ARST), .LOAD(L_Resto), .EN(E_Resto), .d_load(a), .d(d_Resto), .q(resto));

reg L_B;
wire [7:0] q_B;

registro8 b_reg(.clk(clk), .ARST(ARST), .LOAD(L_B), .EN(1'b0), .d_load(b), .d(8'd0), .q(q_B));

// Bloque de estado futuro
always@(*) begin
    estado_futuro = IDLE; // pongo como caso default que vaya a IDLE
    L_Resto = 1'b0;
    L_B     = 1'b0; // Pongo los LOAD en 0
    E_Resto = 1'b0; // Pongo ENABLE del resto en 0
    busy    = 1'b1; // Pongo busy en 1
    ready   = 1'b0; // Pongo ready en 0
    d_Resto = 8'd0; // el resto por default es 0, lo dejo para no inducir un latch
    case (estado_actual)
    IDLE: begin
        if (START) begin
            estado_futuro = LOAD;
        end
        busy    = 1'b0;
    end
    LOAD: begin
        L_Resto = 1'b1;
        L_B     = 1'b1; // Pongo los LOAD en 1
        busy = 1'b1;
        estado_futuro = RESTAR;
    end
    RESTAR: begin
        if (q_B == 8'd0 || resto < q_B) begin
            estado_futuro = FINISH;
        end else begin
            d_Resto       = resto - q_B;
            E_Resto       = 1'b1;
            estado_futuro = RESTAR;
        end
    end
    FINISH: begin
        busy = 1'b0;
        ready = 1'b1;
        estado_futuro= IDLE;
    end
    default: begin
        estado_futuro = IDLE;
    end
    endcase
end

endmodule