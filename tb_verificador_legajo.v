`timescale 1ns/1ps

module tb_verificador_legajo;

    // Declaro las señales que van a las entradas del módulo como reg
    reg clk;
    reg ARST;
    reg START;
    reg VALID;
    reg [3:0] a;

    // Declaro las señales que vienen de las salidas del módulo (tipo wire)
    wire [3:0] digito; 
    wire busy;
    wire done;

    // Instancio el módulo a probar
    verificador_legajo UUT ( 
        .clk(clk), 
        .arst(ARST),
        .start(START),  
        .valid(VALID),
        .dato(a), 
        .busy(busy), 
        .done(done), 
        .verificador(digito)
    ); 

    // Genero clock invierto clk cada 10 unidades de tiempo
    always #10 clk = ~clk; // es decir que un ciclo completo es de 20 unidades, como dice la consigna

    initial begin
        // Configuración para GTKWave
        $dumpfile("tb_verificador_legajo.vcd");
        $dumpvars(0, tb_verificador_legajo);

        // Estado inicial de las entradas
        clk=1'b0;
        ARST=1'b0;
        START=1'b0;
        VALID=1'b0;
        a=4'd0;

        // Espera con reset activo
        #40;
        ARST = 1'b1;
        #20;
        ARST=1'b0;
        START=1'b1; // Pulsp de start
        #20;
        START=1'b0;
        #20;
        VALID = 1'b1; //  Dejo valid en 1 así toma todos los dígitos de una para ahorrar espacio,
        START = 1'b0; // ya probé con pulsos de start fuera de lugar y espacios entre valid y funciona.

        /* 
         Quise hacer un for con registros en hexa pero esta forma de acomodarla implica pensar menos.
      
         Realizo tres ejemplos, uno con resto 10, uno con resto 0 y otro con dígito distinto de 0.
         Aprovecho que mi legajo es un caso de resto 10 en el que el circuito hace la selección de pasarlo a 0
        
        */
        
        //171.465-0 es mi legajo
        //   1          7          1          4          6          5
        a=4'd1;#20;a=4'd7;#20;a=4'd1;#20;a=4'd4;#20;a=4'd6;#20;a=4'd5;#20;
        VALID = 1'b0;
        // Espero a que la FSM termine y levante ready
        wait(done == 1'b1);
        // Espero un instante para leer el dato estable
        #30;

        START=1'b1;#20;START=1'b0;#20;VALID=1'b1;START=1'b0;  // Pulso de start sin reset para ver si la mde limpia los registros
        
        //123-456-0 ejemplo 1 de la tarea
        //   1          2          3          4          5          6
        a=4'd1;#20;a=4'd2;#20;a=4'd3;#20;a=4'd4;#20;a=4'd5;#20;a=4'd6;#20;
        VALID = 1'b0;wait(done == 1'b1);#30;

        START=1'b1;#20;START=1'b0;#20;VALID=1'b1;START=1'b0;

        //111.111-5 ejemplo 3 de la tarea
        //   1          1          1          1          1          1
        a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;
        VALID = 1'b0;wait(done == 1'b1);#30;

        $finish;
    end

endmodule