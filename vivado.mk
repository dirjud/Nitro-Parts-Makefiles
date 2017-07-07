

CONFIG ?= config.mk
-include ../$(CONFIG)


THISMAKEFILE = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
XDC_FILES_REL = $(patsubst %, ../%, $(XDC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))
XCI_FILES_REL = $(patsubst %, ../%, $(XCI_FILES))

.PHONY: syn prj_files

syn: $(FPGA_TOP).spi


$(FPGA_TOP).spi: prj_files
	vivado -mode tcl -source $(THISMAKEFILE)vivado.tcl

prj_files:
	rm -f vfiles.txt
	touch vfiles.txt
	for f in $(SYN_FILES_REL); do \
	 echo $$f >> vfiles.txt; done
	rm -f xdcfiles.txt
	touch xdcfiles.txt
	for f in $(XDC_FILES_REL); do \
	 echo $$f >> xdcfiles.txt; done
	rm -f incpaths.txt
	touch incpaths.txt
	for d in $(INC_PATHS_REL); do \
	 echo $$d >> incpaths.txt; done
	rm -f xcifiles.txt
	touch xcifiles.txt
	for x in $(XCI_FILES_REL); do \
	 echo $$x >> xcifiles.txt; done
