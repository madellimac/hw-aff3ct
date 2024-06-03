TOP = Top_Level
TOP_FILE = $(TOP).v
PACKAGE = Incrementer

VER_PATH = ../VERILOG/generated/$(PACKAGE)

CHISEL_DIR = ../CHISEL
CHISEL_MAIN = $(TOP)Main
CHISEL_SRC = $(wildcard ../CHISEL/src/main/scala/$(PACKAGE)/*.scala)

TB_CPP := ./CPP_TB/tb_$(PACKAGE).cpp ./CPP_TB/VerilatorSimulation.cpp ./CPP_TB/MySource.cpp ./CPP_TB/Comparator.cpp

#AFF3CT_CORE = /Users/cleroux/Documents/work/recherche/PROJECT/FEC/AFF3CT/aff3ct-core
#AFF3CT_ROOT = /Users/cleroux/Documents/work/recherche/PROJECT/FEC/AFF3CT/aff3ct

# INC = "-I$(AFF3CT_ROOT)/include \
# 	-I$(AFF3CT_ROOT)/lib/aff3ct-core/include \
# 	-I$(AFF3CT_ROOT)/lib/rang/include \
# 	-I$(AFF3CT_ROOT)/lib/cpptrace/include/cpptrace \
# 	-I$(AFF3CT_ROOT)/lib/cpptrace/include/ctrace \
# 	-I$(AFF3CT_ROOT)/lib/MIPP/src \
# 	-I$(AFF3CT_ROOT)/lib/cli/src \
# 	-I$(AFF3CT_ROOT)/lib/MSVC/include \
# 	-I./CPP_TB"

# AFF3CT_CORE = /Users/cleroux/Documents/work/recherche/PROJECT/FEC/AFF3CT/aff3ct-core
# AFF3CT_ROOT = /Users/cleroux/Documents/work/recherche/PROJECT/HW_AFF3CT/sandbox/aff3ct

# INC = "-I$(AFF3CT_ROOT)/include \
# 	-I$(AFF3CT_ROOT)/lib/streampu/include \
# 	-I$(AFF3CT_ROOT)/lib/streampu/lib/rang/include \
# 	-I$(AFF3CT_ROOT)/lib/streampu/lib/cpptrace/include/cpptrace \
# 	-I$(AFF3CT_ROOT)/lib/streampu/lib/cpptrace/include/ctrace \
# 	-I$(AFF3CT_ROOT)/lib/MIPP/src \
# 	-I$(AFF3CT_ROOT)/lib/cli/src \
# 	-I$(AFF3CT_ROOT)/lib/MSVC/include \
# 	-I./CPP_TB"

STREAMPU = /Users/cleroux/Documents/work/recherche/PROJECT/HW_AFF3CT/sandbox/streampu

INC = "-I$(STREAMPU)/include \
	-I$(STREAMPU)/lib/rang/include \
	-I$(STREAMPU)/lib/cpptrace/include/ctrace \
	-I$(STREAMPU)/lib/cpptrace/include/cpptrace \
	-I./CPP_TB"


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

#-LDFLAGS $(AFF3CT_CORE)/build/lib/libaff3ct-core.a $(AFF3CT_CORE)/build/lib/cpptrace/lib/libcpptrace.a -LDFLAGS /usr/local/lib/libaff3ct-3.0.2.a 

.PHONY:chisel 
chisel:$(VER_PATH)/$(TOP_FILE)

$(VER_PATH)/$(TOP_FILE): $(CHISEL_SRC)
	@$(MAKE) -j10 -C $(CHISEL_DIR) -f $(CHISEL_DIR)/Makefile TOP=$(TOP) PACKAGE=$(PACKAGE)

.PHONY:lint
lint: $(VER_PATH)/$(TOP_FILE)
	verilator --lint-only $(VER_PATH)/$(TOP_FILE)

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
	rm -rf ../VERILOG/generated/$(PACKAGE)
	rm -rf $(CHISEL_DIR)/project
	rm -rf $(CHISEL_DIR)/target
	rm -rf $(CHISEL_DIR)/.stamp


