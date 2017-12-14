##############################################################################
# Author:  Lane Brooks
# Date:    07/10/2017
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with Xilinx vivado sim.  This file is generic and just a
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
#   VSIM_ARGS  = testIO
#   VSIM_FILES =
#############################################################################
# This file gets called in the sim directory
#

# Check for and include local Makefiles for any project specific
# targets check for a local config file
-include ../config.mk

# Add relative path to all files and paths
SIM_FILES_REL = $(patsubst %, ../%, $(SIM_FILES)) $(patsubst %, ../%, $(XSIM_FILES))
SIM_VHDL_REL  = $(patsubst %, ../%, $(XSIM_VHDL))
SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))


SIM_FLAGS = $(patsubst %, -d %, $(SIM_DEFS)) $(patsubst %, -d %, $(DEFS)) $(patsubst %, -i %,$(INC_PATHS_REL))
LIB_ARGS  = $(patsubst %,-L %,$(SIM_LIBS))

VIVADO ?= /opt/Xilinx/Vivado/2017.3

.PHONY: sim genmem


# This target creates the project file for simulation
xsim_vlog_files.prj: $(SIM_FILES_REL) $(SYN_FILES_REL) $(INC_FILES_REL)
	@rm -rf $@
	@for x in $(SIM_FILES_REL) $(SYN_FILES_REL) $(ISE_SIM_FILES_REL); do \
	  if [[ "$$x" != *".vhd" ]]; then \
	    echo verilog work $$x >> $@; \
	  fi \
	done
	@echo verilog work $$XILINX_VIVADO/data/verilog/src/glbl.v >> $@
	@echo "nosort" >> $@

xsim_vhdl_files.prj: $(SIM_VHDL_REL) $(INC_FILES_REL)
	@rm -rf $@
	@for x in $(SIM_FILES_REL) $(SYN_FILES_REL) $(ISE_SIM_FILES_REL); do \
	  if [[ "$$x" == *".vhd" ]]; then \
	    echo vhdl work $$x >> $@; \
	  fi \
	done
	@for x in $(SIM_VHDL_REL); do echo vhdl work "$$x" >> $@; done
	echo "nosort" >> $@

vsim.tcl:
	if [ -e isim.tcl ]; then \
		echo "isim.tcl exists. Not recreating"; \
	else \
		echo '#wave add / -r' > isim.tcl; \
		echo "run all" >> isim.tcl; \
	fi


xsim.dir/xsim_test/xsim.dbg: xsim_vlog_files.prj xsim_vhdl_files.prj xsim.ini
	xvlog -m64 --relax --prj xsim_vlog_files.prj $(SIM_FLAGS)
	xvhdl -m64 --relax --prj xsim_vhdl_files.prj
	xelab work.isim_tests work.glbl -m64 -relax -L unisims_ver -L secureip $(LIB_ARGS) -s xsim_test -debug typical


xsim.ini: $(VIVADO)/data/xsim/ip/xsim_ip.ini
	cp $< $@

sim: xsim.dir/xsim_test/xsim.dbg $(SIM_DEPS)
	xsim -g --view xsim_database.wcfg -t xsim_options.tcl -wdb xsim_database.wdb xsim_test
