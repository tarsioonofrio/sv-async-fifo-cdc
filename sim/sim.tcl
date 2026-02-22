if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work


vlog -work work -svinputport=relaxed ../rtl/sync_2ff.sv
vlog -work work -svinputport=relaxed ../rtl/async_fifo.sv
vlog -work work -svinputport=relaxed ../tb/test_async_fifo.sv
vlog -work work -svinputport=relaxed ../tb/assertions.sv
# to show FSM
# vsim -voptargs=+acc -t ps -fsmdebug -coverage -debugDB work.tb
set plusargs {}
set generic_args {}
if {[info exists env(BITS)] && $env(BITS) ne ""} {
  lappend generic_args "-gBITS=$env(BITS)"
}
if {[info exists env(SIZE)] && $env(SIZE) ne ""} {
  lappend generic_args "-gSIZE=$env(SIZE)"
}
if {[info exists env(TEST)] && $env(TEST) ne ""} {
  lappend plusargs "+TEST=$env(TEST)"
}
if {[info exists env(SEED)] && $env(SEED) ne ""} {
  lappend plusargs "+SEED=$env(SEED)"
}
eval vsim -voptargs=+acc -t ps work.tb $generic_args $plusargs
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1
if {[catch {set is_batch [batch_mode]}]} {
  set is_batch 1
}
if {!$is_batch} {
  do wave.do
}

run 10000ns
