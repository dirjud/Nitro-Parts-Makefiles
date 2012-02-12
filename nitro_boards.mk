# Include this file. In the parent, you should define the following
# variables:
# VID=
# PID=
# FX2_FIRMWARE_DIR=
# SPI_FILE=

VID ?= 0x1fe1
#PID=
FX2_FIRMWARE_DIR ?=../firmware
#SPI_FILE = ../xilinx/UXN1230.spi


FX2_FIRMWARE = $(FX2_FIRMWARE_DIR)/build/firmware.ihx

all:
	echo You must specify a target: e.g. make fx2, make $(PID)

# converts a new Cypress board or the first ubixum device to this PID
$(PID):
	nitro -R $(FX2_FIRMWARE) -V 04b4 -P 8613 || nitro -R $(FX2_FIRMWARE) -V $(VID) -P "*"

# programs the fx2 and fx2 prom
fx2:
	make -C $(FX2_FIRMWARE_DIR)
	python -c 'from nitro_parts.Microchip import M24XX; \
from nitro_parts.Cypress import CY7C68013; \
import logging; \
logging.basicConfig(level=logging.INFO); \
dev=CY7C68013.get_dev(VID=$(VID), PID=$(PID)); \
M24XX.program_fx2_prom(dev, "$(FX2_FIRMWARE)", VID=$(VID), PID=$(PID)); \
CY7C68013.program_fx2(dev, "$(FX2_FIRMWARE)"); \
'

spi:
	python -c 'import $(PY_CLASS),logging; logging.basicConfig(level=logging.INFO); dev=$(PY_CLASS).get_dev(); dev.program_fpga_prom("$(SPI_FILE)")'

fpga:
	python -c 'import $(PY_CLASS),logging; logging.basicConfig(level=logging.INFO); dev=$(PY_CLASS).get_dev(); dev.program_fpga("$(patsubst %.spi,%.bit,$(SPI_FILE))")'

# opens this dev and drops you to an ipython shell
shell:
	if [ ! -e start.py ]; then \
	    echo "import $(PY_CLASS), logging" > start.py; \
	    echo "log = logging.getLogger(__name__)" >> start.py; \
	    echo "logging.basicConfig(level=logging.INFO)" >> start.py; \
	    echo 'dev = self = $(PY_CLASS).get_dev()' >> start.py; \
	fi
	ipython -i start.py
