TOP = Top_Level
TOP_FILE = $(TOP).v
PACKAGE = Viterbi

VER_PATH = ../VERILOG/generated/$(PACKAGE)

CHISEL_DIR = ../CHISEL
CHISEL_MAIN = $(TOP)Main
CHISEL_SRC = $(wildcard ../CHISEL/src/main/scala/$(PACKAGE)/*.scala)

BIT_STREAM = ../VIVADO/$(PACKAGE).bit

TB_CPP := ./CPP_TB/tb_$(PACKAGE).cpp ./CPP_TB/VerilatorSimulation.cpp ./CPP_TB/MySource.cpp ./CPP_TB/Comparator.cpp ./CPP_TB/SerialPort.cpp

# STREAMPU = /Users/cleroux/Documents/work/recherche/PROJECT/HW_AFF3CT/sandbox/streampu
STREAMPU = /home/cleroux/PROJECTS/streampu

INC = "-I$(STREAMPU)/include \
	-I$(STREAMPU)/lib/rang/include \
	-I$(STREAMPU)/lib/cpptrace/include/ctrace \
	-I$(STREAMPU)/lib/cpptrace/include/cpptrace \
	-I/usr/include \
	-I./CPP_TB"

#-I/opt/homebrew/Cellar/boost/1.85.0/include \

.PHONY:sim
sim: waveform.vcd

.PHONY:verilate
verilate: .stamp.verilate

.PHONY:build
build: obj_dir/V$(TOP)

.PHONY:waves
waves: waveform.vcd
	@echo
	@echo "### WAVES ###"
	gtkwave waveform.vcd

.PHONY: bit_stream
bit_stream : $(BIT_STREAM)

$(BIT_STREAM) : .stamp.verilate
	@(cd ../VIVADO && vivado -mode batch -source ../VIVADO/gen_bit_stream.tcl -tclargs $(PACKAGE))

.PHONY: fpga
fpga : $(BIT_STREAM)
	@(cd ../VIVADO && vivado -mode batch -source ../VIVADO/download_bitstream.tcl -tclargs $(BIT_STREAM))

waveform.vcd: ./obj_dir/V$(TOP)
	@echo
	@echo "###################"
	@echo "### SIMULATING ###"
	@echo "###################"
	./obj_dir/V$(TOP) +verilator+rand+reset+2 

./obj_dir/V$(TOP): .stamp.verilate
	@echo
	@echo "####################"
	@echo "### BUILDING SIM ###"
	@echo "####################"
	make -j10 -C obj_dir -f V$(TOP).mk V$(TOP)


.stamp.verilate: $(VER_PATH)/$(TOP_FILE) $(TB_CPP)
	@echo
	@echo "##################"
	@echo "### VERILATING ###"
	@echo "##################"
	verilator --trace --x-assign unique --x-initial unique -cc $(VER_PATH)/*.v --top-module $(TOP) --exe $(TB_CPP) \
	-CFLAGS $(INC) \
	-LDFLAGS $(STREAMPU)/build_release/lib/libstreampu.a $(STREAMPU)/build_release/lib/cpptrace/lib/libcpptrace.a
	@touch .stamp.verilate

.PHONY:chisel 
chisel:$(VER_PATH)/$(TOP_FILE) $(CHISEL_SRC)

$(VER_PATH)/$(TOP_FILE): $(CHISEL_SRC)
	@$(MAKE) -j10 -C $(CHISEL_DIR) -f $(CHISEL_DIR)/Makefile TOP=$(TOP) PACKAGE=$(PACKAGE)

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
	rm -rf ../VERILOG/generated/$(PACKAGE)
	rm -rf $(CHISEL_DIR)/project
	rm -rf $(CHISEL_DIR)/target
	rm -rf $(CHISEL_DIR)/.stamp
	rm ../VIVADO/vivado*


