##############################################################################
# Author:  Lane Brooks
# Date:    04/28/2006
# License: GPL
# Desc:    This is a Makefile intended to take a verilog rtl design and
#          simulate it with verilator.  This file is generic and just a
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
#   SIM_DEPS  - Additional optional targets from other files that need made when the sim is made
#
# Example "../config.mk" Makefile:
#
#   SIM_FILES = testbench.v
#   SYN_FILES = fpga.v fifo.v clks.v
#   SIM_LIBS  = /opt/xilinx/ise/verilog/unisyms
#   SIM_DEFS  = GATES ASYNC_RESET
#   VERILATOR_ARGS  = testIO
#   VERILATOR_FILES = 
############################################################################# 
# This file gets called in the sim directory
#

# verilator command and path
VERILATOR=verilator

# verilator cpp file
VERILATOR_CPP_FILE=tb.cpp
SIM_TOP_MODULE=pcb

VERILATOR_CPPFLAGS=-I ../ -fPIC -I`python -c 'import  distutils.sysconfig; print distutils.sysconfig.get_python_inc()'` -I`python -c 'import numpy; print \"/\".join(numpy.__file__.split(\"/\")[:-1])+\"/core/include\"'` -I `python -c 'import os, nitro; print os.path.join ( os.path.split( nitro.__file__ )[0], "include" )'`
VERILATOR_LDDFLAGS="`python -c 'import distutils.sysconfig as x; print x.get_config_var(\"LIBS\"), x.get_config_var(\"BLDLIBRARY\")'` -shared -lnitro"


# Check for and include local Makefiles for any project specific
# targets check for a local config file
CONFIG ?= config.mk
-include $(patsubst %, ../%, $(CONFIG))

# Add relative path to all files and paths
SIM_FILES_REL = $(patsubst %, ../%, $(SIM_FILES)) $(patsubst %, ../%, $(VERILATOR_FILES))
SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))


SIM_FLAGS = $(patsubst %, +define+%, $(SIM_DEFS) $(DEFS)) $(patsubst %, +incdir+%,$(INC_PATHS_REL)) $(VERILATOR_ARGS) 
LIB_ARGS  = +libext+.v $(patsubst %,-y %,$(SIM_LIBS)) 

#LIB_ARGS  = +libext+.v $(patsubst %,-y %,$(SIM_LIBS))
#SIM_FLAGS = +ncaccess+rw +define+SIM $(patsubst %, +define+%, $(SIM_DEFS)) $(patsubst %, +%, $(SIM_ARGS))

.PHONY: lint sim

sim: V$(SIM_TOP_MODULE).so $(SIM_DEPS)

# This target copies the file to have an .so file, which is necessary
# when making it a shared object like a python module.
V$(SIM_TOP_MODULE).so: obj_dir/V$(SIM_TOP_MODULE)
	cp obj_dir/V$(SIM_TOP_MODULE) V$(SIM_TOP_MODULE).so

# This target verilates and builds the simulation
obj_dir/V$(SIM_TOP_MODULE): $(SIM_FILES_REL) $(SYN_FILES_REL) $(INC_FILES_REL) 
	$(VERILATOR) -Od -Wno-PINMISSING --trace  --cc $(SIM_FLAGS) $(LIB_ARGS) $(VERILATOR_ARGS) $(SIM_FILES_REL) $(SYN_FILES_REL) --exe $(VERILATOR_CPP_FILE)
	make -C obj_dir -f V$(SIM_TOP_MODULE).mk V$(SIM_TOP_MODULE) \
	USER_CPPFLAGS="$(VERILATOR_CPPFLAGS)" \
	USER_LDFLAGS=$(VERILATOR_LDDFLAGS)



lint: $(SIM_FILES_REL) $(SYN_FILES_REL) $(INC_FILES_REL)
	$(VERILATOR) --lint-only $(SIM_FLAGS) $(LIB_ARGS) $(SIM_FILES_REL) $(SYN_FILES_REL)

clean:
	rm -rf obj_dir
	rm -f V$(SIM_TOP_MODULE).so
	rm -f *.pyc *.vcd

distclean: clean
	-find ./ -type f -name "*~" -exec rm -rf {} \;

