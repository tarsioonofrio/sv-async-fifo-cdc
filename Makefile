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
	waves clean logical sim-netlist power synthesis

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

logical:
	cd "syntesis /logical" && \
	rm -rf genus.cmd* && \
	rm -rf genus.log* && \
	module purge && \
	module load genus > /dev/null 2>&1 && \
	genus -f logical_synthesis.tcl

sim-netlist:
	cd "syntesis /sim" && \
	rm -rf dut.shm && \
	rm -rf xcelium.d && \
	module purge && \
	module load xcelium > /dev/null 2>&1 && \
	xrun -f args.txt ../../tb/test_async_fifo.sv \
	  ../logical/results/gate_level/async_fifo_logic_mapped.v \
	  -define GATE_LEVEL -define XRUN -run -exit

power:
	cd "syntesis /power" && \
	rm -rf genus.cmd* && \
	rm -rf genus.log* && \
	module purge > /dev/null 2>&1 && \
	module load ddi && \
	genus -f power.tcl

synthesis: logical sim-netlist power

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
	cd $(SIM_DIR) && vsim -voptargs=+acc -t ps $(TOP) -do "do wave.do; run 100ns; quit -f"

clean:
	cd $(SIM_DIR) && rm -rf work && rm -f transcript vsim.wlf dump.vcd wlft*
