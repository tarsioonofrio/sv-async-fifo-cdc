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
add wave -noupdate -radix unsigned /tb/rd_data
add wave -noupdate /tb/rd_empty
add wave -noupdate /tb/clk
add wave -noupdate /tb/rstn
add wave -noupdate /tb/dut/wr_clk
add wave -noupdate /tb/dut/wr_rst_n
add wave -noupdate /tb/dut/wr_en
add wave -noupdate -radix unsigned -childformat {{{/tb/dut/wr_data[31]} -radix unsigned} {{/tb/dut/wr_data[30]} -radix unsigned} {{/tb/dut/wr_data[29]} -radix unsigned} {{/tb/dut/wr_data[28]} -radix unsigned} {{/tb/dut/wr_data[27]} -radix unsigned} {{/tb/dut/wr_data[26]} -radix unsigned} {{/tb/dut/wr_data[25]} -radix unsigned} {{/tb/dut/wr_data[24]} -radix unsigned} {{/tb/dut/wr_data[23]} -radix unsigned} {{/tb/dut/wr_data[22]} -radix unsigned} {{/tb/dut/wr_data[21]} -radix unsigned} {{/tb/dut/wr_data[20]} -radix unsigned} {{/tb/dut/wr_data[19]} -radix unsigned} {{/tb/dut/wr_data[18]} -radix unsigned} {{/tb/dut/wr_data[17]} -radix unsigned} {{/tb/dut/wr_data[16]} -radix unsigned} {{/tb/dut/wr_data[15]} -radix unsigned} {{/tb/dut/wr_data[14]} -radix unsigned} {{/tb/dut/wr_data[13]} -radix unsigned} {{/tb/dut/wr_data[12]} -radix unsigned} {{/tb/dut/wr_data[11]} -radix unsigned} {{/tb/dut/wr_data[10]} -radix unsigned} {{/tb/dut/wr_data[9]} -radix unsigned} {{/tb/dut/wr_data[8]} -radix unsigned} {{/tb/dut/wr_data[7]} -radix unsigned} {{/tb/dut/wr_data[6]} -radix unsigned} {{/tb/dut/wr_data[5]} -radix unsigned} {{/tb/dut/wr_data[4]} -radix unsigned} {{/tb/dut/wr_data[3]} -radix unsigned} {{/tb/dut/wr_data[2]} -radix unsigned} {{/tb/dut/wr_data[1]} -radix unsigned} {{/tb/dut/wr_data[0]} -radix unsigned}} -subitemconfig {{/tb/dut/wr_data[31]} {-height 16 -radix unsigned} {/tb/dut/wr_data[30]} {-height 16 -radix unsigned} {/tb/dut/wr_data[29]} {-height 16 -radix unsigned} {/tb/dut/wr_data[28]} {-height 16 -radix unsigned} {/tb/dut/wr_data[27]} {-height 16 -radix unsigned} {/tb/dut/wr_data[26]} {-height 16 -radix unsigned} {/tb/dut/wr_data[25]} {-height 16 -radix unsigned} {/tb/dut/wr_data[24]} {-height 16 -radix unsigned} {/tb/dut/wr_data[23]} {-height 16 -radix unsigned} {/tb/dut/wr_data[22]} {-height 16 -radix unsigned} {/tb/dut/wr_data[21]} {-height 16 -radix unsigned} {/tb/dut/wr_data[20]} {-height 16 -radix unsigned} {/tb/dut/wr_data[19]} {-height 16 -radix unsigned} {/tb/dut/wr_data[18]} {-height 16 -radix unsigned} {/tb/dut/wr_data[17]} {-height 16 -radix unsigned} {/tb/dut/wr_data[16]} {-height 16 -radix unsigned} {/tb/dut/wr_data[15]} {-height 16 -radix unsigned} {/tb/dut/wr_data[14]} {-height 16 -radix unsigned} {/tb/dut/wr_data[13]} {-height 16 -radix unsigned} {/tb/dut/wr_data[12]} {-height 16 -radix unsigned} {/tb/dut/wr_data[11]} {-height 16 -radix unsigned} {/tb/dut/wr_data[10]} {-height 16 -radix unsigned} {/tb/dut/wr_data[9]} {-height 16 -radix unsigned} {/tb/dut/wr_data[8]} {-height 16 -radix unsigned} {/tb/dut/wr_data[7]} {-height 16 -radix unsigned} {/tb/dut/wr_data[6]} {-height 16 -radix unsigned} {/tb/dut/wr_data[5]} {-height 16 -radix unsigned} {/tb/dut/wr_data[4]} {-height 16 -radix unsigned} {/tb/dut/wr_data[3]} {-height 16 -radix unsigned} {/tb/dut/wr_data[2]} {-height 16 -radix unsigned} {/tb/dut/wr_data[1]} {-height 16 -radix unsigned} {/tb/dut/wr_data[0]} {-height 16 -radix unsigned}} /tb/dut/wr_data
add wave -noupdate /tb/dut/wr_full
add wave -noupdate /tb/dut/rd_clk
add wave -noupdate /tb/dut/rd_rst_n
add wave -noupdate /tb/dut/rd_en
add wave -noupdate -radix unsigned /tb/dut/rd_data
add wave -noupdate /tb/dut/rd_empty
add wave -noupdate -radix unsigned /tb/dut/wr_ptr
add wave -noupdate -radix unsigned /tb/dut/rd_ptr
add wave -noupdate /tb/dut/logic_wr_full
add wave -noupdate /tb/dut/logic_rd_empty
add wave -noupdate -radix unsigned -childformat {{{/tb/dut/wr_fifo[31]} -radix unsigned} {{/tb/dut/wr_fifo[30]} -radix unsigned} {{/tb/dut/wr_fifo[29]} -radix unsigned} {{/tb/dut/wr_fifo[28]} -radix unsigned} {{/tb/dut/wr_fifo[27]} -radix unsigned} {{/tb/dut/wr_fifo[26]} -radix unsigned} {{/tb/dut/wr_fifo[25]} -radix unsigned} {{/tb/dut/wr_fifo[24]} -radix unsigned} {{/tb/dut/wr_fifo[23]} -radix unsigned} {{/tb/dut/wr_fifo[22]} -radix unsigned} {{/tb/dut/wr_fifo[21]} -radix unsigned} {{/tb/dut/wr_fifo[20]} -radix unsigned} {{/tb/dut/wr_fifo[19]} -radix unsigned} {{/tb/dut/wr_fifo[18]} -radix unsigned} {{/tb/dut/wr_fifo[17]} -radix unsigned} {{/tb/dut/wr_fifo[16]} -radix unsigned} {{/tb/dut/wr_fifo[15]} -radix unsigned} {{/tb/dut/wr_fifo[14]} -radix unsigned} {{/tb/dut/wr_fifo[13]} -radix unsigned} {{/tb/dut/wr_fifo[12]} -radix unsigned} {{/tb/dut/wr_fifo[11]} -radix unsigned} {{/tb/dut/wr_fifo[10]} -radix unsigned} {{/tb/dut/wr_fifo[9]} -radix unsigned} {{/tb/dut/wr_fifo[8]} -radix unsigned} {{/tb/dut/wr_fifo[7]} -radix unsigned} {{/tb/dut/wr_fifo[6]} -radix unsigned} {{/tb/dut/wr_fifo[5]} -radix unsigned} {{/tb/dut/wr_fifo[4]} -radix unsigned} {{/tb/dut/wr_fifo[3]} -radix unsigned} {{/tb/dut/wr_fifo[2]} -radix unsigned} {{/tb/dut/wr_fifo[1]} -radix unsigned} {{/tb/dut/wr_fifo[0]} -radix unsigned}} -expand -subitemconfig {{/tb/dut/wr_fifo[31]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[30]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[29]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[28]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[27]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[26]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[25]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[24]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[23]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[22]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[21]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[20]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[19]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[18]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[17]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[16]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[15]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[14]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[13]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[12]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[11]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[10]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[9]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[8]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[7]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[6]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[5]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[4]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[3]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[2]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[1]} {-height 16 -radix unsigned} {/tb/dut/wr_fifo[0]} {-height 16 -radix unsigned}} /tb/dut/wr_fifo
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
