onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/rstn
add wave -noupdate /tb/wr_clk
add wave -noupdate /tb/wr_rst_n
add wave -noupdate /tb/rd_clk
add wave -noupdate /tb/rd_rst_n
add wave -noupdate /tb/wr_en
add wave -noupdate -radix unsigned /tb/wr_data
add wave -noupdate /tb/wr_full
add wave -noupdate /tb/rd_en
add wave -noupdate -radix unsigned /tb/rd_data
add wave -noupdate /tb/rd_empty
add wave -noupdate /tb/dut/wr_clk
add wave -noupdate /tb/dut/wr_rst_n
add wave -noupdate /tb/dut/wr_en
add wave -noupdate -radix unsigned /tb/dut/wr_data
add wave -noupdate /tb/dut/wr_full
add wave -noupdate /tb/dut/rd_clk
add wave -noupdate /tb/dut/rd_rst_n
add wave -noupdate /tb/dut/rd_en
add wave -noupdate -radix unsigned /tb/dut/rd_data
add wave -noupdate /tb/dut/rd_empty
add wave -noupdate -radix unsigned /tb/dut/wr_ptr_bin
add wave -noupdate -radix unsigned /tb/dut/wr_ptr_gray
add wave -noupdate -radix unsigned /tb/dut/wr_ptr_gray_sync1
add wave -noupdate -radix unsigned /tb/dut/wr_ptr_gray_sync2
add wave -noupdate -radix unsigned /tb/dut/wr_ptr_bin_sync
add wave -noupdate -radix unsigned /tb/dut/rd_ptr_bin
add wave -noupdate -radix unsigned /tb/dut/rd_ptr_gray
add wave -noupdate -radix unsigned /tb/dut/rd_ptr_gray_sync1
add wave -noupdate -radix unsigned /tb/dut/rd_ptr_gray_sync2
add wave -noupdate -radix unsigned /tb/dut/rd_ptr_bin_sync
add wave -noupdate /tb/dut/logic_wr_full
add wave -noupdate /tb/dut/logic_rd_empty
add wave -noupdate -radix unsigned /tb/dut/fifo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 403
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
WaveRestoreZoom {0 ps} {39127 ps}
