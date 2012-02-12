##############################################################################
# Author:  Lane Brooks
# Date:    04/15/2010
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with iverilog.  This file is generic and just a
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
#   SIM_LIBS  = /opt/xilinx/ise/verilog/unisyms
#   SIM_DEFS  = GATES ASYNC_RESET
#   IVERILOG_ARGS  = testIO
#   IVERILOG_FILES = 
############################################################################# 
# This file gets called in the sim directory
#


# Check for and include local Makefiles for any project specific
# targets check for a local config file
-include ../config.mk

# Add relative path to all files and paths
SIM_FILES_REL = $(patsubst %, ../%, $(SIM_FILES)) $(patsubst %, ../%, $(IVERILOG_FILES))
SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))


SIM_FLAGS = -D iverilog $(patsubst %, -D%, $(SIM_DEFS)) $(patsubst %, -I%,$(INC_PATHS_REL)) $(IVERILOG_ARGS) 
LIB_ARGS  = -Y.v $(patsubst %,-y %,$(SIM_LIBS)) 


.PHONY: lint sim

sim: $(SIM_TOP_MODULE).vvp

IVERILOG=iverilog

# This target verilates and builds the simulation
$(SIM_TOP_MODULE).vvp: $(SIM_FILES_REL) $(SYN_FILES_REL) $(INC_FILES_REL) $(VERILATOR_FILES_REL)
	$(IVERILOG) -o $@ $(SIM_FLAGS) $(SIM_FILES_REL) $(SYN_FILES_REL)

	echo Run 'vvp sim/$@' to execute your sim

lint:


clean:
	rm -f $(SIM_TOP_MODULE).iverilog

