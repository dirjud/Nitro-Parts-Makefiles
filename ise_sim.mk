##############################################################################
# Author:  Lane Brooks
# Date:    04/28/2006
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with ise sim.  This file is generic and just a
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
#   ISE_SIM_ARGS  = testIO
#   ISE_SIM_FILES = 
############################################################################# 
# This file gets called in the sim directory
#

# fuese command and path
FUSE=fuse

SIM_TOP_MODULE=

# Check for and include local Makefiles for any project specific
# targets check for a local config file
-include ../config.mk

# Add relative path to all files and paths
SIM_FILES_REL = $(patsubst %, ../%, $(SIM_FILES)) $(patsubst %, ../%, $(ISE_SIM_FILES))
SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))


SIM_FLAGS = $(patsubst %, -d %, $(SIM_DEFS)) $(patsubst %, -i %,$(INC_PATHS_REL)) -incremental
LIB_ARGS  = $(patsubst %,-L %,$(SIM_LIBS)) 


.PHONY: sim

compile: $(SIM_TOP_MODULE).exe

# This target copies the file to have an .so file, which is necessary
# when making it a shared object like a python module.
#%.exe: obj_dir/V$(TOP_MODULE)
#	cp obj_dir/V$(TOP_MODULE) V$(TOP_MODULE).so

# This target verilates and builds the simulation
%.exe: $(SIM_FILES_REL) $(SYN_FILES_REL) $(INC_FILES_REL)
	rm -rf $*.prj 
	for x in $(SIM_FILES_REL) $(SYN_FILES_REL) $(ISE_SIM_FILES_REL); do echo verilog work $$x >> $*.prj; done
	echo verilog work $$XILINX/verilog/src/glbl.v >> $*.prj
	$(FUSE) $(SIM_TOP_MODULE) glbl $(ISE_SIM_ARGS) $(SIM_FLAGS) $(LIB_ARGS) -prj $*.prj -o $@

#       fuse work.sim_tb_top work.glbl -prj mig_32.prj -L unisims_ver -L secureip -o mig_32

isim.tcl:
	if [ -e isim.tcl ]; then \
		echo "isim.tcl exists. Not recreating"; \
	else \
		echo '#wave add / -r' > isim.tcl; \
		echo "run all" >> isim.tcl; \
	fi

sim: $(SIM_TOP_MODULE).exe isim.tcl
	./$(SIM_TOP_MODULE).exe -tclbatch isim.tcl

clean:
	rm -rf *.prj isim *.log *.exe

distclean: clean
	-find ./ -type f -name "*~" -exec rm -rf {} \;

