##############################################################################
# Author:  Lane Brooks
# Date:    04/28/2006
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with ncverilog.  This file is generic and just a
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
# Example Calling Makefile:
#
#   SIM_FILES = testbench.v
#   SYN_FILES = fpga.v fifo.v clks.v
#   SIM_LIBS  = /opt/xilinx/ise/verilog/unisyms
#   SIM_DEFS  = GATES ASYNC_RESET
#   SIM_ARGS  = testIO
#   include ncsim.mk
############################################################################# 
#
# This file gets called relative to the ncsim directory

LIB_ARGS  = +libext+.v $(patsubst %,-y %,$(SIM_LIBS)) 
SIM_FLAGS = +ncaccess+rw +define+SIM $(patsubst %, +define+%, $(SIM_DEFS)) $(patsubst %, +%, $(SIM_ARGS))

.PHONY: sim simc

# include the local Makefile for project for any project specific targets
-include Makefile

sim: $(SIM_FILES) $(SYN_FILES) $(INCLUDE_FILES)
ifdef SIM_LD_LIBRARY_PATH
	make -C $(SIM_LD_LIBRARY_PATH)
	LD_LIBRARY_PATH=$(SIM_LD_LIBRARY_PATH) \
	ncverilog $(SIM_FLAGS) $(LIB_ARGS) $(INCLUDE_FILES) $(SIM_FILES) $(SYN_FILES)
else
	ncverilog $(SIM_FLAGS) $(LIB_ARGS) $(INCLUDE_FILES) $(SIM_FILES) $(SYN_FILES)
endif

simc: $(SIM_FILES) $(SYN_FILES) $(INCLUDE_FILES)
ifdef SIM_LD_LIBRARY_PATH
	make -C $(SIM_LD_LIBRARY_PATH)
	LD_LIBRARY_PATH=$(SIM_LD_LIBRARY_PATH) \
	ncverilog -c $(SIM_FLAGS) $(LIB_ARGS) $(INCLUDE_FILES) $(SIM_FILES) $(SYN_FILES)
else
	ncverilog -c $(SIM_FLAGS) $(LIB_ARGS) $(INCLUDE_FILES) $(SIM_FILES) $(SYN_FILES)
endif

clean:
	rm -f *~ *.dat *.log *.key
	rm -rf INCA_libs
	rm -rf waves.shm

distclean: clean
	-find ./ -type f -name "*~" -exec rm -rf {} \;

