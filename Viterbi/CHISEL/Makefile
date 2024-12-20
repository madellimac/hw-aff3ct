# Generate Verilog code
TOP ?= my_top_default
TOP_MAIN = $(TOP)Main
PACKAGE ?= my_package_default

# SRC := $(wildcard ./src/main/scala/$(PROJECT)/*.scala)

build : .stamp
	@echo

.stamp : $(SRC)
	@echo
	@echo "######################################"
	@echo "### GENERATING VERILOG FROM CHISEL ###"
	@echo "######################################"
#	sbt -Dtarget=../VERILOG/generated/$(TOP) 'runMain octopus.$(TOP_MAIN) --top-name $(TOP_MAIN)'
	sbt 'runMain $(PACKAGE).$(TOP_MAIN) --top-name $(TOP_MAIN)'
	@touch .stamp
