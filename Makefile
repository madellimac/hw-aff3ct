TOP = Top_Viterbi
TOP_FILE = $(TOP).sv

PROJECT = Viterbi

# STREAMPU = /home/cleroux/PROJECTS/streampu

AFF3CT = /home/cleroux/PROJECTS/aff3ct
STREAMPU = $(AFF3CT)/lib/streampu

ROOT := $(shell pwd)

CHISEL_DIR = $(ROOT)/$(PROJECT)/CHISEL
VERILATOR_DIR = $(ROOT)/$(PROJECT)/VERILATOR
VERILOG_DIR = $(ROOT)/$(PROJECT)/VERILOG/generated/$(PROJECT)
VIVADO_DIR = $(ROOT)/$(PROJECT)/VIVADO
CPP_DIR = $(ROOT)/$(PROJECT)/CPP
CPP_COMMON_DIR = $(ROOT)/Common/streampu
COMMON_VIVADO_DIR = $(ROOT)/Common/VIVADO

#COMMON_CPP := $(ROOT)/Common/streampu/
# CPP_SRC := $(VERILATOR_DIR)/CPP_TB/tb_$(PROJECT).cpp $(COMMON_CPP)/VerilatorSimulation.cpp $(COMMON_CPP)/MySource.cpp $(COMMON_CPP)/Comparator.cpp $(COMMON_CPP)/SerialPort.cpp

COMMON_CPP = $(wildcard $(ROOT)/Common/streampu/*.cpp)
CPP_SRC := $(VERILATOR_DIR)/CPP_TB/tb_$(PROJECT).cpp $(COMMON_CPP) $(wildcard $(CPP_DIR)/*.cpp)

CHISEL_MAIN = $(TOP)Main
CHISEL_SRC = $(wildcard $(CHISEL_DIR)/src/main/scala/*.scala)

BIT_STREAM = $(VIVADO_DIR)/$(PROJECT).bit

# INC = "-I$(STREAMPU)/include \
# 	-I$(STREAMPU)/lib/rang/include \
# 	-I$(STREAMPU)/lib/cpptrace/include/ctrace \
# 	-I$(STREAMPU)/lib/cpptrace/include/cpptrace \
#     -I/home/cleroux/PROJECTS/aff3ct/lib/streampu/include \
#     -I/home/cleroux/PROJECTS/aff3ct/lib/cli/src \
#     -I/home/cleroux/PROJECTS/aff3ct/lib/MIPP/src \
#     -I/home/cleroux/PROJECTS/aff3ct/include \
# 	-I/usr/include \
# 	-I$(VERILATOR_DIR)/CPP_TB \
# 	-I$(ROOT)/Common/streampu \
# 	-I$(CPP_DIR)"

DEF = -DAFF3CT_POLAR_BIT_PACKING
DEF += -DAFF3CT_EXT_STRINGS
# DEF += -DAFF3CT_8BIT_PREC
# DEF += -DAFF3CT_16BIT_PREC
# DEF += -DAFF3CT_32BIT_PREC
# DEF += -DAFF3CT_64BIT_PREC
DEF += -DAFF3CT_MULTI_PREC
# DEF += -DAFF3CT_CHANNEL_GSL
# DEF += -DAFF3CT_CHANNEL_MKL
# DEF += -DAFF3CT_MPI

DEF += -DSPU_COLORS
# DEF += -DSPU_STACKTRACE
DEF += -DSPU_TESTS
# DEF += -DSPU_STACKTRACE_SEGFAULT
# DEF += -DSPU_FAST
# DEF += -DSPU_HWLOC

INC = -I$(AFF3CT)/include -I$(AFF3CT)/src -I$(AFF3CT)/lib/MIPP/src -I$(AFF3CT)/lib/date/include/date -I$(AFF3CT)/lib/cli/src -I$(STREAMPU)/include -I$(STREAMPU)/src -I$(STREAMPU)/lib/rang/include -I$(STREAMPU)/lib/json/include -I/usr/include -I/$(CPP_COMMON_DIR) -I/$(CPP_DIR)
LIBS = $(AFF3CT)/build/lib/libaff3ct-3.0.2-126-ga617c48.a

ifeq ($(findstring -DSPU_STACKTRACE, $(DEF)), -DSPU_STACKTRACE)
    $(info Link with cpptrace)
    INC += -I$(STREAMPU)/lib/cpptrace/include
	LIBS += $(AFF3CT)/build/lib/streampu/lib/cpptrace/lib/libcpptrace.a
endif
ifeq ($(findstring -DSPU_HWLOC, $(DEF)), -DSPU_HWLOC)
    $(info Link with hwloc not supported (yet))
	exit(0)
endif
ifeq ($(findstring -DAFF3CT_CHANNEL_GSL, $(DEF)), -DAFF3CT_CHANNEL_GSL)
    $(info Link with gsl not supported (yet))
	exit(0)
endif
ifeq ($(findstring -DAFF3CT_CHANNEL_MKL, $(DEF)), -DAFF3CT_CHANNEL_MKL)
    $(info Link with mkl not supported (yet))
	exit(0)
endif
ifeq ($(findstring -DAFF3CT_MPI, $(DEF)), -DAFF3CT_MPI)
    $(info Link with mpi not supported (yet))
	exit(0)
endif

LIB_DIR = $(AFF3CT)/build/lib
LDFLAGS = $(foreach dir,$(LIB_DIR),-L$(dir)) $(LIBS) $(DEF)

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
	gtkwave waveform.vcd waveform.gtkw

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
	@echo $(INC)
	make -j10 -C $(VERILATOR_DIR)/obj_dir -f V$(TOP).mk V$(TOP) CXXFLAGS="$(INC)"

.stamp.verilate: $(VERILOG_DIR)/$(TOP_FILE) $(CPP_SRC)
	@echo
	@echo "##################"
	@echo "### VERILATING ###"
	@echo "##################"
	mkdir -p $(VERILATOR_DIR)/obj_dir
# 	verilator --trace --x-assign unique --x-initial unique -cc $(VERILOG_DIR)/*.sv --top-module $(TOP) --exe $(CPP_SRC) --Mdir $(VERILATOR_DIR)/obj_dir \
	-CFLAGS $(INC) -LDFLAGS $(LDFLAGS) $(STREAMPU)/build_release/lib/libstreampu.a
	verilator --trace --x-assign unique --x-initial unique -cc $(VERILOG_DIR)/*.sv --top-module $(TOP) --exe $(CPP_SRC) --Mdir $(VERILATOR_DIR)/obj_dir -CFLAGS $(INC) -LDFLAGS $(LDFLAGS)
# 	 $(STREAMPU)/build_release/lib/libstreampu.a
# -LDFLAGS $(STREAMPU)/build_release/lib/libstreampu.a $(STREAMPU)/build_release/lib/cpptrace/lib/libcpptrace.a /home/cleroux/PROJECTS/aff3ct/build/lib/libaff3ct-3.0.2-125-g0e421d4.a
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