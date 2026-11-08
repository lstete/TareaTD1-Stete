module UC( 
    input  wire clk, 
    input  wire ARST,
    input  wire START,
    input  wire VALID,
    input  wire restando,
    input  wire ready,
    output reg  clean,
    output reg  acumular,
    output reg  busy,
    output reg  done);

localparam     IDLE   = 3'd0,
               LOAD   = 3'd1,
               ESPERAR_DATO = 3'd2,
               ESPERAR_DIGITO = 3'd3;
reg [2:0] estado_actual, estado_futuro;

// Bloque secuencial
always@(posedge clk, posedge ARST) begin
    if(ARST) begin
        estado_actual <= IDLE;
    end else begin
        estado_actual <= estado_futuro;
    end
end

always@(*) begin
    estado_futuro = IDLE; // pongo como caso default que vaya a IDLE
    busy = 1'b0;
    done = 1'b0;        // Pongo los LOAD en 0
    acumular = 1'b0;    // Pongo ENABLE del resto en 0
    clean = 1'b0;       
    case (estado_actual)
    IDLE: begin
        if (START) begin
            estado_futuro = LOAD;
        end
        busy    = 1'b0;
    end
    LOAD: begin
        clean = 1'b1;
        busy = 1'b1;
        estado_futuro = ESPERAR_DATO;
    end
    ESPERAR_DATO: begin
        busy=1'b1;
        if (VALID) begin
            acumular = 1'b1;                   
            if (restando) begin                 
                estado_futuro = ESPERAR_DIGITO; 
            end else begin
                estado_futuro = ESPERAR_DATO;
            end
        end else begin
            estado_futuro = ESPERAR_DATO;
        end
    end

    ESPERAR_DIGITO: begin
        busy = 1'b1;
        if(ready==1'b1) begin
            done = 1'b1;
            busy = 1'b0;
            estado_futuro=IDLE;
        end else begin
            estado_futuro=ESPERAR_DIGITO;
        end
    end
    default: begin
        estado_futuro = IDLE;
    end
    endcase
end

endmodule