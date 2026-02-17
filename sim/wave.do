onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/wr_clk
add wave -noupdate /tb/wr_rst_n
add wave -noupdate /tb/wr_en
add wave -noupdate -radix unsigned /tb/wr_data
add wave -noupdate /tb/wr_full
add wave -noupdate /tb/rd_clk
add wave -noupdate /tb/rd_rst_n
add wave -noupdate /tb/rd_en
add wave -noupdate /tb/rd_data
add wave -noupdate /tb/rd_empty
add wave -noupdate /tb/clk
add wave -noupdate /tb/rstn
add wave -noupdate /tb/dut/wr_clk
add wave -noupdate /tb/dut/wr_rst_n
add wave -noupdate /tb/dut/wr_en
add wave -noupdate -radix unsigned /tb/dut/wr_data
add wave -noupdate /tb/dut/wr_full
add wave -noupdate /tb/dut/rd_clk
add wave -noupdate /tb/dut/rd_rst_n
add wave -noupdate /tb/dut/rd_en
add wave -noupdate /tb/dut/rd_data
add wave -noupdate /tb/dut/rd_empty
add wave -noupdate -radix unsigned /tb/dut/wr_fifo
add wave -noupdate -radix unsigned /tb/dut/wr_ptr
add wave -noupdate -radix unsigned /tb/dut/rd_ptr
add wave -noupdate /tb/dut/logic_wr_full
add wave -noupdate /tb/dut/logic_rd_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 187
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {66368 ps}
