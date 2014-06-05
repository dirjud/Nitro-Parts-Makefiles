##############################################################################
# Author:  Dennis Muhlestein 
# Date:    06/02/2014
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with modelsim.  This file is generic and just a
#          template.  As such all design specific options such as source files,
#          library paths, options, etc, should be set in a top Makefile prior
#          to including this file.  Alternatively, all parameters can be passed
#          in from the command line as well.
#
##############################################################################
#
# Parameter:
#   SIM_FILES - Space seperated list of Simulation files
#   SYN_FILES - Space seperated list of RTL files
#   SIM_LIBS  - Space seperated list of library paths to include for simulation
#   SIM_DEFS  - Space seperated list of `defines that should be set for sim
#   SIM_ARGS  - Space seperated list of args for $test$plusargs("arg") options
#
# Example "../config.mk" Makefile:
#
#   SIM_FILES = testbench.v
#   SYN_FILES = fpga.v fifo.v clks.v
#   SIM_LIBS  = unisims_ver secureip 
#   SIM_DEFS  = GATES ASYNC_RESET
#   VSE_SIM_FILES =  (anything just for vsim)
#   VSIM_TOP_MODULE = vsim_tb_top
############################################################################# 
# This file gets called in the sim directory
#

SIM_TOP_MODULE ?= vsim_tb_top

# Check for and include local Makefiles for any project specific
# targets check for a local config file
-include ../config.mk

# Add relative path to all files and paths
SIM_FILES_REL = $(patsubst %, ../%, $(SIM_FILES)) $(patsubst %, ../%, $(VSIM_SIM_FILES))
SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))


COMPILE_FLAGS = $(patsubst %, +define+%, $(SIM_DEFS))
COMPILE_INCS = $(patsubst %, +incdir+%, $(INC_PATHS_REL))
LIB_ARGS  = $(patsubst %,-L %,$(SIM_LIBS)) 


.PHONY: sim


sim:
	if [ ! -d work ] || [ ! -e work/_vmake ]; then \
		vlib work; \
	fi
	fail=0; \
	for file in $(SYN_FILES_REL) $(SIM_FILES_REL) ; do \
	  vlog $(COMPILE_INCS) $(COMPILE_FLAGS) $$file || fail=1;  \
	  if [ $$fail -eq 1 ]; then \
	   break; \
	  fi \
    done; \
	if [ $$fail -ne 1 ]; then \
	 vlog $(XILINX)/verilog/src/glbl.v; \
	 vsim -t ps -c $(VSIM_TOP_MODULE) $(LIB_ARGS) work.glbl -do "run -all" ; \
	fi

clean:
	@echo "TODO - clean vsim files"
