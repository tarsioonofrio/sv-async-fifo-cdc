onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/r_clk
add wave -noupdate /tb/r_rstn
add wave -noupdate /tb/write_clk
add wave -noupdate /tb/write_rst_n
add wave -noupdate /tb/read_clk
add wave -noupdate /tb/read_rst_n
add wave -noupdate /tb/p_write_en
add wave -noupdate -radix unsigned /tb/p_write_data
add wave -noupdate /tb/p_write_full
add wave -noupdate /tb/p_read_en
add wave -noupdate -radix unsigned /tb/p_read_data
add wave -noupdate /tb/p_read_empty
add wave -noupdate /tb/dut/write_clk
add wave -noupdate /tb/dut/write_rst_n
add wave -noupdate /tb/dut/p_write_en
add wave -noupdate -radix unsigned /tb/dut/p_write_data
add wave -noupdate /tb/dut/p_write_full
add wave -noupdate /tb/dut/read_clk
add wave -noupdate /tb/dut/read_rst_n
add wave -noupdate /tb/dut/p_read_en
add wave -noupdate -radix unsigned /tb/dut/p_read_data
add wave -noupdate /tb/dut/p_read_empty
add wave -noupdate -radix unsigned /tb/dut/r_write_ptr_bin
add wave -noupdate -radix unsigned /tb/dut/r_write_ptr_gray
add wave -noupdate -radix unsigned /tb/dut/r_write_ptr_gray_sync1
add wave -noupdate -radix unsigned /tb/dut/r_write_ptr_gray_sync2
add wave -noupdate -radix unsigned /tb/dut/w_write_ptr_bin_sync
add wave -noupdate -radix unsigned /tb/dut/r_read_ptr_bin
add wave -noupdate -radix unsigned /tb/dut/r_read_ptr_gray
add wave -noupdate -radix unsigned /tb/dut/r_read_ptr_gray_sync1
add wave -noupdate -radix unsigned /tb/dut/r_read_ptr_gray_sync2
add wave -noupdate -radix unsigned /tb/dut/w_read_ptr_bin_sync
add wave -noupdate /tb/dut/w_write_full
add wave -noupdate /tb/dut/w_read_empty
add wave -noupdate -radix unsigned -childformat {{{/tb/dut/r_fifo[15]} -radix unsigned} {{/tb/dut/r_fifo[14]} -radix unsigned} {{/tb/dut/r_fifo[13]} -radix unsigned} {{/tb/dut/r_fifo[12]} -radix unsigned} {{/tb/dut/r_fifo[11]} -radix unsigned} {{/tb/dut/r_fifo[10]} -radix unsigned} {{/tb/dut/r_fifo[9]} -radix unsigned} {{/tb/dut/r_fifo[8]} -radix unsigned} {{/tb/dut/r_fifo[7]} -radix unsigned} {{/tb/dut/r_fifo[6]} -radix unsigned} {{/tb/dut/r_fifo[5]} -radix unsigned} {{/tb/dut/r_fifo[4]} -radix unsigned} {{/tb/dut/r_fifo[3]} -radix unsigned} {{/tb/dut/r_fifo[2]} -radix unsigned} {{/tb/dut/r_fifo[1]} -radix unsigned} {{/tb/dut/r_fifo[0]} -radix unsigned}} -expand -subitemconfig {{/tb/dut/r_fifo[15]} {-radix unsigned} {/tb/dut/r_fifo[14]} {-radix unsigned} {/tb/dut/r_fifo[13]} {-radix unsigned} {/tb/dut/r_fifo[12]} {-radix unsigned} {/tb/dut/r_fifo[11]} {-radix unsigned} {/tb/dut/r_fifo[10]} {-radix unsigned} {/tb/dut/r_fifo[9]} {-radix unsigned} {/tb/dut/r_fifo[8]} {-radix unsigned} {/tb/dut/r_fifo[7]} {-radix unsigned} {/tb/dut/r_fifo[6]} {-radix unsigned} {/tb/dut/r_fifo[5]} {-radix unsigned} {/tb/dut/r_fifo[4]} {-radix unsigned} {/tb/dut/r_fifo[3]} {-radix unsigned} {/tb/dut/r_fifo[2]} {-radix unsigned} {/tb/dut/r_fifo[1]} {-radix unsigned} {/tb/dut/r_fifo[0]} {-radix unsigned}} /tb/dut/r_fifo
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
