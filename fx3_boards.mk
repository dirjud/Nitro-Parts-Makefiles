# Include this file. In the parent, you should define the following
# variables:
# VID=
# PID=
# FX3_FIRMWARE_DIR=
# SPI_FILE=

.PHONY: fx3

VID ?= 0x1fe1
PID ?= 0x00f3
FX3_FIRMWARE_DIR ?=../firmware
#SPI_FILE = ../xilinx/UXN1230.spi


FX3_FIRMWARE ?= $(FX3_FIRMWARE_DIR)/main.img

include ../../../lib/Makefiles/fx2_boards.mk

# converts a new Cypress board or the first $VID device to this PID
$(PID):
	nitro -R $(FX3_FIRMWARE) -V 04b4 -P 00f3 || nitro -R $(FX3_FIRMWARE) -V $(VID) -P "*"

# programs the fx3 and fx3 prom
fx3:
#	make -C $(FX3_FIRMWARE_DIR)
	python -c 'from nitro_parts.Microchip import M24XX; \
from nitro_parts.Cypress import fx3; \
import logging; \
logging.basicConfig(level=logging.INFO); \
dev=fx3.get_dev(VID=$(VID), PID=$(PID)); \
M24XX.program_fx3_prom(dev, "$(FX3_FIRMWARE)"); \
'

