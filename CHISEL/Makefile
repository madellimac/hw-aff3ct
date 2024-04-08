# Generate Verilog code
TOP_MAIN ?= TopMain
#SRC = ./src/main/scala/*
SRC := $(wildcard ./src/main/scala/octopus/*.scala)

build : .stamp
	@echo

.stamp : $(SRC)
	@echo
	@echo "######################################"
	@echo "### GENERATING VERILOG FROM CHISEL ###"
	@echo "######################################"
	sbt 'runMain octopus.$(TOP_MAIN) --top-name $(TOP_MAIN)'
	@touch .stamp
