# Include this file. In the parent, you should define the following
# variables:
# VID=
# PID=
# FX2_FIRMWARE_DIR=
# SPI_FILE=

VID ?= 0x1fe1
#PID=
FX3_FIRMWARE_DIR ?=../firmware
#SPI_FILE = ../xilinx/UXN1230.spi


FX3_FIRMWARE ?= $(FX3_FIRMWARE_DIR)/main.img

include ../../../lib/Makefiles/fx2_boards.mk

# converts a new Cypress board or the first $VID device to this PID
$(PID):
	nitro -R $(FX3_FIRMWARE) -V 04b4 -P 00f3 || nitro -R $(FX3_FIRMWARE) -V $(VID) -P "*"

# programs the fx2 and fx2 prom
fx3:
	make -C $(FX3_FIRMWARE_DIR)
	python -c 'from nitro_parts.Microchip import M24XX; \
from nitro_parts.Cypress import CY7C68013; \
import logging; \
logging.basicConfig(level=logging.INFO); \
dev=CY7C68013.get_dev(VID=$(VID), PID=$(PID)); \
M24XX.program_fx2_prom(dev, "$(FX2_FIRMWARE)", VID=$(VID), PID=$(PID)); \
CY7C68013.program_fx2(dev, "$(FX2_FIRMWARE)"); \
'

