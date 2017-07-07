
# FOR XML
# as long as terminals.py is your source and
# the xml is named the same as the project path,
# you shouldn't have to do anything.
# XML_DEPS is an optional list of path/part.xml files that should
# be build before the current project.

MAKEFILE_DIR ?= ../../../lib/Makefiles
XML_DIR ?= ../../../parts
DI_FILE ?= terminals.py
PRJ_NAME ?= $(shell basename `pwd`)
PRJ_PATH ?= $(shell basename $$(dirname `pwd`))/$(PRJ_NAME)
XML_INSTALL := $(XML_DIR)/$(PRJ_PATH)/$(PRJ_NAME).xml
XML_DEPS ?=

FPGA      = $(MAKE) -C xilinx   -f $(MAKEFILE_DIR)/xilinx.mk
NCSIM     = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/ncsim.mk
ISE_SIM   = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/ise_sim.mk
VERILATOR = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/verilator.mk
IVERILOG  = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/iverilog.mk
VSIM      = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/vsim.mk
VIVADO	  = $(MAKE) -C vivado   -f $(MAKEFILE_DIR)/vivado.mk

CLEANEXTS = log

.PHONY: fpga bit mcs error prom fpgasim clean distclean sim lint syn

error:
	@echo "Please specify a target, e.g. make fpga, make sim"

bit: fpga tmpclean_xilinx

mcs: prom tmpclean_xilinx

sim:  sim_verilator

lint: lint_verilator

fpga: fpga_xilinx

prom: prom_xilinx

spi: spi_xilinx

syn: syn_vivado

fpgasim: fpgasim_xilinx

%_isim:
	$(ISE_SIM) $*

%_xilinx:
	$(FPGA) $*

%_ncsim:
	$(NCSIM) $*

%_verilator:
	$(VERILATOR) $*

%_iverilog:
	$(IVERILOG) $*

%_vsim:
	$(VSIM) $*

%_vivado:
	$(VIVADO) $*

ifeq (,$(XML_DEPS))
 XML_DEPENDS=
else
 XML_DEPENDS=xml_deps
endif
# add xml_deps only if xml depends on actual other xml files
$(XML_INSTALL): $(DI_FILE) $(XML_DEPENDS)
	mkdir -p $(XML_DIR)/$(PRJ_PATH)
	diconv $< $@

xml_deps:
	@for dep in $(XML_DEPS); do \
	 make -C ../../`dirname $$dep` xml; \
	done

xml: $(XML_INSTALL)
.PHONY: xml xml_deps


mostlyclean:
	-for dir in $(CLEAN_DIRS); do make -C $$dir clean; done
	-for file in $(CLEAN_FILES); do rm -rf $$file; done

clean: mostlyclean
	-$(FPGA) clean
	-$(NCSIM)  clean
	-$(VERILATOR)  clean
	-for file in $(CLEANEXTS); do rm -f *.$$file; done
	-rm -rf *~

distclean: mostlyclean
	-$(FPGA) distclean
	-$(NCSIM)  distclean
	-$(VERILATOR)  distclean
	-for file in $(CLEANEXTS); do rm -f *.$$file; done
	-find -L ./ -type f -name "*~" -exec rm -rf {} \;
	-find -L ./ -type f -name "*.pyc" -exec rm -rf {} \;
