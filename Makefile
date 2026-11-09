# Testbench a simular
TB ?= tb_verificador_legajo

# Herramientas
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# Directorios
SRC_DIR   = .
BUILD_DIR = work

# Archivos fuente
SOURCES = $(filter-out $(SRC_DIR)/tb_%.v, $(wildcard $(SRC_DIR)/*.v)) $(SRC_DIR)/$(TB).v

# Archivos generados
SIM = $(BUILD_DIR)/$(TB).vvp
VCD = $(TB).vcd

.PHONY: all compile run view clean

all: run


# Crear directorio de trabajo
$(BUILD_DIR):
ifeq ($(OS),Windows_NT)
	if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
else
	mkdir -p $(BUILD_DIR)
endif


# Compilar
compile: $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $(SIM) -s $(TB) $(SOURCES)


# Ejecutar simulación
run: compile
	$(VVP) $(SIM)


# Abrir GTKWave
view: run
	$(GTKWAVE) $(VCD)


# Eliminar archivos generados
clean:
ifeq ($(OS),Windows_NT)
	del /f /q *.vcd 2>nul || exit 0
	rmdir /s /q $(BUILD_DIR) 2>nul || exit 0
else
	rm -rf $(BUILD_DIR)
	rm -f *.vcd
endif