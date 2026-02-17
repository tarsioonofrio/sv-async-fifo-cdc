if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work


vlog -work work -svinputport=relaxed ./control.sv
vlog -work work -svinputport=relaxed ./testbench.sv
# to show FSM
# vsim -voptargs=+acc -t ps -fsmdebug -coverage -debugDB work.tb
vsim -voptargs=+acc -t ps work.tb
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1
do wave.do

run 100ns
