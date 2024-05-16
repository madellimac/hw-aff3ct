# Generate Verilog code
TOP ?= Top
TOP_MAIN = $(TOP)Main
#SRC = ./src/main/scala/*
SRC := $(wildcard ./src/main/scala/octopus/*.scala)

build : .stamp
	@echo

.stamp : $(SRC)
	@echo
	@echo "######################################"
	@echo "### GENERATING VERILOG FROM CHISEL ###"
	@echo "######################################"
#	sbt -Dtarget=../VERILOG/generated/$(TOP) 'runMain octopus.$(TOP_MAIN) --top-name $(TOP_MAIN)'
	sbt 'runMain octopus.$(TOP_MAIN) --top-name $(TOP_MAIN)'
	@touch .stamp
