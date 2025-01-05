TOP = Top_Level
TOP_FILE = $(TOP).v

PROJECT = Viterbi

STREAMPU = /home/cleroux/PROJECTS/streampu

ROOT := $(shell pwd)

CHISEL_DIR = $(ROOT)/$(PROJECT)/CHISEL
VERILATOR_DIR = $(ROOT)/$(PROJECT)/VERILATOR
VERILOG_DIR = $(ROOT)/$(PROJECT)/VERILOG/generated/$(PROJECT)
VIVADO_DIR = $(ROOT)/$(PROJECT)/VIVADO
CPP_DIR = $(ROOT)/$(PROJECT)/CPP
COMMON_VIVADO_DIR = $(ROOT)/Common/VIVADO

#COMMON_CPP := $(ROOT)/Common/streampu/
# CPP_SRC := $(VERILATOR_DIR)/CPP_TB/tb_$(PROJECT).cpp $(COMMON_CPP)/VerilatorSimulation.cpp $(COMMON_CPP)/MySource.cpp $(COMMON_CPP)/Comparator.cpp $(COMMON_CPP)/SerialPort.cpp

COMMON_CPP = $(wildcard $(ROOT)/Common/streampu/*.cpp)
CPP_SRC := $(VERILATOR_DIR)/CPP_TB/tb_$(PROJECT).cpp $(COMMON_CPP) $(wildcard $(CPP_DIR)/*.cpp)

CHISEL_MAIN = $(TOP)Main
CHISEL_SRC = $(wildcard $(CHISEL_DIR)/src/main/scala/*.scala)

BIT_STREAM = $(VIVADO_DIR)/$(PROJECT).bit

INC = "-I$(STREAMPU)/include \
	-I$(STREAMPU)/lib/rang/include \
	-I$(STREAMPU)/lib/cpptrace/include/ctrace \
	-I$(STREAMPU)/lib/cpptrace/include/cpptrace \
	-I/usr/include \
	-I$(VERILATOR_DIR)/CPP_TB \
	-I$(ROOT)/Common/streampu \
	-I$(CPP_DIR)"

.PHONY:sim
sim: waveform.vcd

.PHONY:verilate
verilate: .stamp.verilate

.PHONY:build
build: $(VERILATOR_DIR)/obj_dir/V$(TOP)

.PHONY:waves
waves: waveform.vcd
	@echo
	@echo "### WAVES ###"
	gtkwave waveform.vcd

.PHONY: bit_stream
bit_stream : $(BIT_STREAM)

$(BIT_STREAM) : .stamp.verilate
	mkdir -p $(VIVADO_DIR)
	@(cd $(VIVADO_DIR) && vivado -mode batch -source $(COMMON_VIVADO_DIR)/gen_bit_stream.tcl -tclargs $(PROJECT) $(VERILOG_DIR) $(COMMON_VIVADO_DIR))

.PHONY: fpga
fpga : $(BIT_STREAM)
	@(cd $(VIVADO_DIR) && vivado -mode batch -source $(COMMON_VIVADO_DIR)/download_bitstream.tcl -tclargs $(PROJECT).bit)

waveform.vcd: $(VERILATOR_DIR)/obj_dir/V$(TOP)
	@echo
	@echo "###################"
	@echo "### SIMULATING ###"
	@echo "###################"
	$(VERILATOR_DIR)/obj_dir/V$(TOP) +verilator+rand+reset+2 

$(VERILATOR_DIR)/obj_dir/V$(TOP): .stamp.verilate
	@echo
	@echo "####################"
	@echo "### BUILDING SIM ###"
	@echo "####################"	
	make -j10 -C $(VERILATOR_DIR)/obj_dir -f V$(TOP).mk V$(TOP)

.stamp.verilate: $(VERILOG_DIR)/$(TOP_FILE) $(CPP_SRC)
	@echo
	@echo "##################"
	@echo "### VERILATING ###"
	@echo "##################"
	mkdir -p $(VERILATOR_DIR)/obj_dir
	verilator --trace --x-assign unique --x-initial unique -cc $(VERILOG_DIR)/*.v --top-module $(TOP) --exe $(CPP_SRC) --Mdir $(VERILATOR_DIR)/obj_dir \
	-CFLAGS $(INC) \
	-LDFLAGS $(STREAMPU)/build_release/lib/libstreampu.a $(STREAMPU)/build_release/lib/cpptrace/lib/libcpptrace.a
	@touch .stamp.verilate

.PHONY:chisel 
chisel:$(VERILOG_DIR)/$(TOP_FILE) $(CHISEL_SRC)

$(VERILOG_DIR)/$(TOP_FILE): $(CHISEL_SRC)
	@$(MAKE) -j10 -C $(CHISEL_DIR) -f Makefile TOP=$(TOP) PACKAGE=$(PROJECT)

.PHONY: clean
clean:
	rm -rf $(PROJECT)/VERILATOR/.stamp.*;
	rm -rf $(PROJECT)/VERILATOR/obj_dir
	rm -rf $(PROJECT)/VERILATOR/waveform.vcd
	rm -rf $(PROJECT)/VERILOG/generated/$(PROJECT)
	rm -rf $(CHISEL_DIR)/project
	rm -rf $(CHISEL_DIR)/target
	rm -rf $(CHISEL_DIR)/.stamp
	rm $(VIVADO_DIR)/vivado*