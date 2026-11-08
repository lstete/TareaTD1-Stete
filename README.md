# Verificador de Legajo

## 1. Información General

* **Alumno:** Leonel Stete
* **Legajo:** 171.465-0
* **Materia:** Técnicas Digitales 1
* **Institución:** Universidad Tecnológica Nacional - Facultad Regional Buenos Aires (UTN FRBA)

El presente trabajo consiste en el diseño e implementación en Verilog de un circuito secuencial sincrónico que calcula el dígito verificador de los legajos universitarios de 6 dígitos decimales. El algoritmo realiza una suma ponderada decreciente de los dígitos con coeficientes del 7 al 2:

A dicha suma se le calcula el resto de la división entera por 11 mediante un restador iterativo. El resto coincide con el dígito verificador en todos los casos menos cuando es 10, en ese caso, el dígito queda en 0.

### Diagrama en Bloque del Módulo Top

![Diagrama del Módulo Top](<Esquema/Módulo.png>)


A nivel top es el módulo propuesto por la actividad y a nivel interno es cómo se me ocurrió manejar la UC y el datapath, hay una aclaración de las posibles variaciones en la descripción del datapath.
Únicamente uní la UC con el datapath y expuse las salidas y entradas necesarias. 

### Cronogramas Temporales de Referencia

![Cronograma de Señal 1](<Esquema/SEÑAL 1.png>)

![Cronograma de Señales 2 y 3](<Esquema/SEÑAL 2 Y 3.png>)

Funciona según lo esperado, también realicé pruebas para probar casos de posible error o más reales donde valid no siempre llega de forma sucesiva, de todas formas el caso que más miedo me daba era el en el que valid llegaba seguido, pues la acumulación se tenía que hacer consecutiva.
No los agregué al TB para no extenderlo.

## 2. Descripción de Módulos

### 2.1. verificador_legajo (Top)
```verilog
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
```

 Es el módulo con la estructura propuesta por la tarea, mantuve todo exceptuando las salidas que las pasé de reg a wire.

### 2.2. UC (Unidad de Control)

```verilog
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
    output reg  done
);
```

 Es una máquina de estados que tiene como entrada los valores del módulo top: start y valid, pero además usa las señales de estado restando y ready para saber cuándo se recibió el 6to dígito y cuándo el calculador de restos iterativo terminó de restar. 

#### Diagrama de estados (provisto por la documentación de TerosHDL)

![Diagrama de estados UC](<Esquema/fsm_UC_00.svg>) 

### 2.3. datapath

```verilog
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
```

 Este módulo reúne los circuitos que generan operaciones, similar a una ALU, recibe señales de control que le dicen qué operacion hacer y la entrega, si se le da un pulso, toma el dato del módulo top y lo va acumululando, en este caso decidí que haga automáticamente la resta.
  Una alternativa pudo haber sido que tenga una señal de estado que dé la cuenta del contador así la UC sabe por dónde va y decide cuándo restar con otra señal. Pero me pareció más simple así.

### 2.4. acumulador_ponderado

```verilog
module acumulador_ponderado (
    input  clk,
    input  EN,
    input  ARST,
    input  CLEAN,
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] acumulado
);
```

Este módulo resultó sencillo de implementar en verilog, constó en instanciar el registro de 8 bits que diseñé exponiendo el arst y dándole la opción de clean, en este caso poniendo en 1 la señal de load que tiene un 0 fijo. Pude haber cambiado el EN a acumular pero en el momento no se me ocurrió.

### 2.5. contador

```verilog
module contador (
    input clk,
    input ARST,
    input EN,
    input CLEAN,
    output reg [3:0]count,
    output TC
);
```

Es simplemente un contador de 7 a 2 que lo uso para controlar por cuál dígito voy pero a su vez me sirve como dígito ponderador, de otro modo tendría que haber hecho un contador de 0 a 5 por ejemplo y asignar un mux que decida cuál es el valor en cada caso. 

### 2.6. resto

```verilog
module resto (
    input  clk, 
    input  START, ARST,
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] resto,
    output reg busy, ready
);
```

Este es el módulo que más me costó porque fue con la primera MdE que practiqué, instancio dos registros de 8 bits, pude haberlo hecho con un segundo registro de 4 bits sabiendo que siempre haría la división por 11, pero me pareció buena idea hacerlo un poco más genérico.
Es una MdE que cuando recibe START captura a y b, solo que a como es el número a restar, queda en resto. Y se le va aplicando sucesivas restas hasta que el resto sea menor que b. 
Por otro lado notifica cuándo está trabajando y cuándo terminó. 

#### Diagrama de estados (provisto por la documentación de TerosHDL)

![Diagrama de estados resto](<Esquema/fsm_resto_00.svg>) 


### 2.7. registro8

```verilog
module registro8 (
    input clk,
    input ARST,
    input LOAD,
    input EN,
    input [7:0] d_load,
    input [7:0] d,
    output reg [7:0] q
);
```

Para poder entenderlo mejor hice un módulo de registro para instanciarlo las veces que lo necesite, porque cuando hacía la MdE de resto me confundía tener la parte secuencial de los estados más la de los registros. Y fue una opción que me terminó resultando muy cómoda.

## 3. Análisis del Diseño

### a. ¿Cuál es la máxima suma ponderada y cuántos bits requiere el acumulador?

La máxima suma ponderada se da cuando todos los dígitos son 9, por ende:
suma máxima = 9*(7+6+5+4+3+2) = 243
Así que con 8 bits me alcanza, pudiendo representar hasta el 255

### b. ¿Cuál es la máxima cantidad de restas necesarias para obtener el resto?

Teniendo en cuenta que el máximo es 243, al dividir por 11 se le puede aplicar una cantidad de 22 restas, legajos más chicos requerirán menos restas por ende se calcularán más rápido.

### c. ¿Cómo garantiza que el sexto dígito quede incluido en el cálculo?

 De hecho me topé con el problema porque tengo el TC del contador como salida combinacional que es válido cuando mi contador llega a 2. No era un problema hasta que lo usé en la UC y si TC era 1, pasaba al siguiente estado, el problema es que generaba el pulso de valid después de la comparación.
 Asi que lo solucioné cambiando el orden de la comparación. Primero se hace el valid y en ese mismo estado se compara si hay que ir al siguiente estado o no.

### d. ¿Qué registros conservan su valor cuando valid = 0 durante la recepción?

En principio el registro de estado, que guarda en qué estado está la MdE. Después el contador del acumulador y el acumulador. Si valid es 0 ya después del 6to dígito, intervienen los registros del restador.

### e. ¿Por qué los restos 0 y 10 producen el mismo dígito verificador?

No entendí muy bien la pregunta, entiendo que es para mantener la idea de un solo dígito y que en decimal coincida la unidad 0 y no recurrir a dos dígitos o asignar el 10 a otro valor random, pero que sería igual en términos prácticos. Porque en binario 10 es 1010 así que sí requiere una selección para que en ese caso entregue 0000 y no es simplemente recortar bits en todos los casos.
