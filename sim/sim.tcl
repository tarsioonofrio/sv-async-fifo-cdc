if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work

set use_coverage 0
if {[info exists env(COVERAGE)] && $env(COVERAGE) ne "" && $env(COVERAGE) ne "0"} {
  set use_coverage 1
}

if {$use_coverage} {
  vlog -work work -cover bcesft -svinputport=relaxed ../rtl/sync_2ff.sv
  vlog -work work -cover bcesft -svinputport=relaxed ../rtl/async_fifo.sv
  vlog -work work -cover bcesft -svinputport=relaxed ../tb/test_async_fifo.sv
  vlog -work work -cover bcesft -svinputport=relaxed ../tb/assertions.sv
} else {
  vlog -work work -svinputport=relaxed ../rtl/sync_2ff.sv
  vlog -work work -svinputport=relaxed ../rtl/async_fifo.sv
  vlog -work work -svinputport=relaxed ../tb/test_async_fifo.sv
  vlog -work work -svinputport=relaxed ../tb/assertions.sv
}
# to show FSM
# vsim -voptargs=+acc -t ps -fsmdebug -coverage -debugDB work.tb
quietly set generic_args {}
if {[info exists env(BITS)] && $env(BITS) ne ""} {
  quietly lappend generic_args "-gBITS=$env(BITS)"
}
if {[info exists env(SIZE)] && $env(SIZE) ne ""} {
  quietly lappend generic_args "-gSIZE=$env(SIZE)"
}
if {[info exists env(TEST)] && $env(TEST) ne ""} {
  quietly lappend generic_args "-gNAME=$env(TEST)"
}
if {[info exists env(SEED)] && $env(SEED) ne ""} {
  quietly lappend generic_args "-gSEED=$env(SEED)"
}
if {$use_coverage} {
  eval vsim -coverage -voptargs=+acc -t ps work.tb $generic_args
  coverage save -onexit coverage.ucdb
} else {
  eval vsim -voptargs=+acc -t ps work.tb $generic_args
}
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1
if {[catch {set is_batch [batch_mode]}]} {
  set is_batch 1
}
if {!$is_batch} {
  do wave.do
}

run 10000ns
