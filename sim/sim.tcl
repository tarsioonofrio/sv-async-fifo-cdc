if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work


vlog -work work -svinputport=relaxed ../rtl/sync_2ff.sv
vlog -work work -svinputport=relaxed ../rtl/async_fifo.sv
vlog -work work -svinputport=relaxed ../tb/test_async_fifo.sv
vlog -work work -svinputport=relaxed ../tb/assertions.sv
# to show FSM
# vsim -voptargs=+acc -t ps -fsmdebug -coverage -debugDB work.tb
vsim -voptargs=+acc -t ps work.tb
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1
if {[catch {set is_batch [batch_mode]}]} {
  set is_batch 1
}
if {!$is_batch} {
  do wave.do
}

run 100ns
