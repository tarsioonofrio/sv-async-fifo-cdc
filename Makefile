SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

MODELSIM_BIN ?= /opt/intelFPGA/20.1/modelsim_ase/bin
PATH := $(MODELSIM_BIN):$(PATH)
export PATH

SIM_DIR := sim
RTL := ../rtl/sync_2ff.sv ../rtl/async_fifo.sv
TB  := ../tb/test_async_fifo.sv ../tb/assertions.sv
TOP := work.tb
LINT_RTL_SRCS := rtl/sync_2ff.sv rtl/async_fifo.sv
LINT_TB_SRCS := tb/test_async_fifo.sv tb/assertions.sv
TEST ?=
SEED ?=7
BITS ?=32
SIZE ?=16

.PHONY: build run test regress lint lint-all lint-rtl lint-tb \
	waves clean logical sim-netlist power synthesis \
	logical-env logical-run logical-run-env \
	sim-netlist-env sim-netlist-run sim-netlist-run-env \
	power-env power-run power-run-env \
	synthesis-env synthesis-run synthesis-run-env

build:
	cd $(SIM_DIR)
	if [ -d work ]; then vdel -all -lib work; fi
	vlib work
	vmap work work
	vlog -work work -svinputport=relaxed $(RTL)
	vlog -work work -svinputport=relaxed $(TB)

run:
	cd $(SIM_DIR)
	TEST="$(TEST)" SEED="$(SEED)" BITS="$(BITS)" SIZE="$(SIZE)" vsim -c -do sim.tcl

test: run

regress:
	$(MAKE) test TEST=

logical-env:
	cd "syntesis/logical"
	module purge
	module load genus > /dev/null 2>&1

logical-run:
	cd "syntesis/logical"
	rm -rf genus.cmd*
	rm -rf genus.log*
	genus -f logical_synthesis.tcl

logical-run-env:
	cd "syntesis/logical"
	module purge
	module load genus > /dev/null 2>&1
	rm -rf genus.cmd*
	rm -rf genus.log*
	genus -f logical_synthesis.tcl

logical: logical-run-env

sim-netlist-env:
	cd "syntesis/sim"
	module purge
	module load xcelium > /dev/null 2>&1

sim-netlist-run:
	cd "syntesis/sim"
	rm -rf dut.shm
	rm -rf xcelium.d
	xrun -f args.txt ../../tb/test_async_fifo.sv \
		../logical/results/gate_level/async_fifo_logic_mapped.v \
		-define GATE_LEVEL -define XRUN -run -exit

sim-netlist-run-env:
	cd "syntesis/sim"
	module purge
	module load xcelium > /dev/null 2>&1
	rm -rf dut.shm
	rm -rf xcelium.d
	xrun -f args.txt ../../tb/test_async_fifo.sv \
		../logical/results/gate_level/async_fifo_logic_mapped.v \
		-define GATE_LEVEL -define XRUN -run -exit

sim-netlist: sim-netlist-run-env

power-env:
	cd "syntesis/power"
	module purge > /dev/null 2>&1
	module load ddi

power-run:
	cd "syntesis/power"
	rm -rf genus.cmd*
	rm -rf genus.log*
	genus -f power.tcl

power-run-env:
	cd "syntesis/power"
	module purge > /dev/null 2>&1
	module load ddi
	rm -rf genus.cmd*
	rm -rf genus.log*
	genus -f power.tcl

power: power-run-env

synthesis-run: logical-run sim-netlist-run power-run

synthesis-run-env: logical-run-env sim-netlist-run-env power-run-env

synthesis: synthesis-run-env

synthesis-env: logical-env sim-netlist-env power-env

lint:
	$(MAKE) lint-rtl

lint-all:
	$(MAKE) lint-rtl
	$(MAKE) lint-tb

lint-rtl:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Wno-SYNCASYNCNET -Itb -Irtl $(LINT_RTL_SRCS) tb/assertions.sv

lint-tb:
	verilator --lint-only --timing -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Wno-SYNCASYNCNET -Itb -Irtl $(LINT_RTL_SRCS) $(LINT_TB_SRCS)

waves: build
	cd $(SIM_DIR)
	vsim -voptargs=+acc -t ps $(TOP) -do "do wave.do; run 100ns; quit -f"

clean:
	cd $(SIM_DIR)
	rm -rf work
	rm -f transcript vsim.wlf dump.vcd wlft*
