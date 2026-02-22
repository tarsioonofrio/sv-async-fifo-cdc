MODELSIM_BIN ?= /opt/intelFPGA/20.1/modelsim_ase/bin
PATH := $(MODELSIM_BIN):$(PATH)
export PATH

SIM_DIR := sim
RTL := ../rtl/sync_2ff.sv ../rtl/async_fifo.sv
TB  := ../tb/test_async_fifo.sv ../tb/assertions.sv
TOP := work.tb
LINT_SRCS := rtl/sync_2ff.sv rtl/async_fifo.sv tb/test_async_fifo.sv tb/assertions.sv
TEST ?=
SEED ?=7
BITS ?=32
SIZE ?=16

.PHONY: build run test regress lint waves clean

build:
	cd $(SIM_DIR) && \
	if [ -d work ]; then vdel -all -lib work; fi && \
	vlib work && \
	vmap work work && \
	vlog -work work -svinputport=relaxed $(RTL) && \
	vlog -work work -svinputport=relaxed $(TB)

run:
	cd $(SIM_DIR) && TEST="$(TEST)" SEED="$(SEED)" BITS="$(BITS)" SIZE="$(SIZE)" vsim -c -do sim.tcl

test: run

regress:
	$(MAKE) test TEST=

lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Itb -Irtl $(LINT_SRCS)

waves: build
	cd $(SIM_DIR) && vsim -voptargs=+acc -t ps $(TOP) -do "do wave.do; run 100ns; quit -f"

clean:
	cd $(SIM_DIR) && rm -rf work && rm -f transcript vsim.wlf dump.vcd wlft*
