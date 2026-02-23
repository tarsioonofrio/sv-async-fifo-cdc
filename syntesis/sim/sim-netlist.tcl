if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work

vlog -work work -svinputport=relaxed /pdk/tsmc/PDK28/PDK_TSMC28_bv/tcbn28hpcplusbwp30p140_190a/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140_110a/tcbn28hpcplusbwp30p140.v
vlog -work work -svinputport=relaxed ../logical/results/gate_level/async_fifo_logic_mapped.v
vlog -work work -svinputport=relaxed ../../tb/test_async_fifo.sv
# to show FSM
# vsim -voptargs=+acc -t ns -fsmdebug -coverage -debugDB work.tb
vsim -voptargs=+acc -t ns work.tb
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1
do wave.do

# all blocks
#run 50000ns
# run 2000ns
# 4 blocks
#run 4000ns
# one line
# run 7000ns
# run -all

run 10000ns

# coverage report -output report.txt -srcfile=* -assert -directive -cvg -codeAll
