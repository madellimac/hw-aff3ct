TOP = Top2
TOP_FILE = $(TOP).v

VER_PATH = ../VERILOG/generated/$(TOP)

CHISEL_DIR = ../CHISEL
CHISEL_MAIN = $(TOP)Main
CHISEL_SRC = $(wildcard ../CHISEL/src/main/scala/octopus/*.scala)

#SV_FILES = top.sv P2S.sv conv_encoder.sv if_module_to_socket.sv scrambler.sv P_to_S_converter.sv counter.sv if_socket_to_module.sv socket.sv fifo.sv interleaver.sv socket_controler.sv S2P.sv file_reader.sv mod.sv S_to_P_converter.sv funct.sv hamming_encoder.sv processing.sv

TB_CPP := ./CPP_TB/tb_Top.cpp ./CPP_TB/VerilatorSimulation.cpp


INC_ROOT = /usr/local/include
AFF3CT_CORE = /Users/cleroux/Documents/work/recherche/PROJECT/FEC/AFF3CT/aff3ct-core

INC = "-I$(AFF3CT_CORE)/include \
	-I$(AFF3CT_CORE)/lib/rang/include \
	-I$(AFF3CT_CORE)/lib/cpptrace/include/cpptrace \
	-I$(AFF3CT_CORE)/lib/cpptrace/include/ctrace \
	-I./CPP_TB"
# -I$(INC_ROOT)/aff3ct-3.0.2/aff3ct \
# -I$(INC_ROOT)/aff3ct-3.0.2/cli \
# -I$(INC_ROOT)/aff3ct-3.0.2/mipp \
# -I$(INC_ROOT)/aff3ct-3.0.2/rang \

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
#@touch obj_dir/V$(TOP)
	make -j10 -C obj_dir -f V$(TOP).mk V$(TOP)


.stamp.verilate: $(VER_PATH)/$(TOP_FILE) $(TB_CPP)
	@echo
	@echo "##################"
	@echo "### VERILATING ###"
	@echo "##################"
	verilator --trace --x-assign unique --x-initial unique -cc $(VER_PATH)/*.v --top-module $(TOP) --exe $(TB_CPP) \
	-CFLAGS $(INC) \
	-LDFLAGS $(AFF3CT_CORE)/build/lib/libaff3ct-core.a $(AFF3CT_CORE)/build/lib/cpptrace/lib/libcpptrace.a
# -LDFLAGS /usr/local/lib/libaff3ct-3.0.2.a 
	@touch .stamp.verilate

#.PHONY:$(VER_PATH)/$(TOP_FILE) 
$(VER_PATH)/$(TOP_FILE): $(CHISEL_SRC)
#	@$(MAKE) -j10 -C $(CHISEL_DIR) -f $(CHISEL_DIR)/Makefile TOP_MAIN=$(CHISEL_MAIN)
	@$(MAKE) -j10 -C $(CHISEL_DIR) -f $(CHISEL_DIR)/Makefile TOP=$(TOP)

.PHONY:lint
lint: $(VER_PATH)/$(TOP_FILE)
	verilator --lint-only $(VER_PATH)/$(TOP_FILE)

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
	rm -rf ../VERILOG/generated/$(TOP)
	rm -rf $(CHISEL_DIR)/project
	rm -rf $(CHISEL_DIR)/target
	rm -rf $(CHISEL_DIR)/.stamp


