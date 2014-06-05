MAKEFILE_DIR ?= ../../../lib/Makefiles

FPGA      = $(MAKE) -C xilinx   -f $(MAKEFILE_DIR)/xilinx.mk
NCSIM     = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/ncsim.mk
ISE_SIM   = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/ise_sim.mk
VERILATOR = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/verilator.mk
IVERILOG  = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/iverilog.mk
VSIM      = $(MAKE) -C sim      -f $(MAKEFILE_DIR)/vsim.mk

CLEANEXTS = log

.PHONY: fpga bit mcs error prom fpgasim clean distclean sim lint

error:
	@echo "Please specify a target, e.g. make fpga, make sim"

bit: fpga tmpclean_xilinx

mcs: prom tmpclean_xilinx

sim:  sim_verilator

lint: lint_verilator

fpga: fpga_xilinx

prom: prom_xilinx

spi: spi_xilinx

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

%.xml: terminals.py
	diconv terminals.py $@

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
