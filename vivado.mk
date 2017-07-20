#############################################################################
# Author:  Dennis Muhlestein/Lane Brooks
# Date:    07/10/2017
# License: GPL

# Desc: This is a Makefile intended to take a verilog rtl design
#       through the Xilinx Vivado synthesis to generate configuration
#       files for Xilinx FPGAs.  This file is generic and just a
#       template.  As such all design specific options such as
#       synthesis files, fpga part type, prom part type, etc should be
#       set in the top Makefile prior to including this file.
#       Alternatively, all parameters can be passed in from the
#       command line as well.
#
##############################################################################
#
# Parameter:
#   SYN_FILES - Space seperated list of files to be synthesized
#   PART      - FPGA part (see Xilinx documentation)
#   PROM      - PROM part
#   DEFS      - Space separated list of defines.  If the define has a value it should be "XYZ=ABC" formated
#
#
# Example Calling Makefile:
#
#   SYN_FILES = fpga.v fifo.v clks.v
#   PART      = xc3s1000
#   FPGA_TOP  = fpga
#   PROM      = xc18v04
#   SPI_PROM_SIZE = (in MB)
#   include vivado.mk
#############################################################################
#
# Command Line Example:
#   make -f vivado.mk  PART=xc3s1000-4fg320 SYN_FILES="fpga.v test.v" FPGA_TOP=fpga
#
##############################################################################


CONFIG ?= config.mk
-include ../$(CONFIG)


THISMAKEFILE = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
XDC_FILES_REL = $(patsubst %, ../%, $(XDC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))
XCI_FILES_REL = $(patsubst %, ../%, $(XCI_FILES))
MCS_ELF_REL = $(strip $(patsubst %, ../%, $(MCS_ELF)))

GEN_MCS = $(findstring MCS, $(DEFS))

.PHONY: syn

syn: $(FPGA_TOP).bin

$(FPGA_TOP).bin: $(FPGA_TOP).bit $(THISMAKEFILE)vivado_prom.tcl
	TOP=$(FPGA_TOP) PROM_SIZE=$(SPI_PROM_SIZE) PROM_INTERFACE=$(SPI_PROM_INTERFACE) vivado -mode tcl -source $(THISMAKEFILE)vivado_prom.tcl

$(FPGA_TOP).bit: vfiles.txt xdcfiles.txt incpaths.txt xcifiles.txt $(THISMAKEFILE)vivado.tcl
	GEN_MCS=$(GEN_MCS) MCS_ELF=$(MCS_ELF_REL) TOP=$(FPGA_TOP) PART=$(FPGA_PART) vivado -mode tcl -source $(THISMAKEFILE)vivado.tcl

vfiles.txt: $(SYN_FILES_REL)
	rm -rf defines.v
	for x in $(DEFS); do echo '`define' $$x | tr '=' ' ' >> defines.v; done
	echo defines.v > vfiles.txt
	for f in $(SYN_FILES_REL); do \
	 echo $$f >> vfiles.txt; done

xdcfiles.txt: $(XDC_FILES_REF)
	rm -f xdcfiles.txt
	touch xdcfiles.txt
	for f in $(XDC_FILES_REL); do \
	 echo $$f >> xdcfiles.txt; done

incpaths.txt: $(INC_PATHS_REF)
	rm -f incpaths.txt
	touch incpaths.txt
	for d in $(INC_PATHS_REL); do \
	 echo $$d >> incpaths.txt; done

xcifiles.txt: $(XCI_FILES_REL)
	rm -f xcifiles.txt
	touch xcifiles.txt
	for x in $(XCI_FILES_REL); do \
	 echo $$x >> xcifiles.txt; done
