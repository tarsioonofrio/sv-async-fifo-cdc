##############################################################
## Logical / Physical synthesis constraints ##
##############################################################

### CONFIGS
set sdc_version 1.5
set_load_unit -femtofarads
set_time_unit -nanoseconds

### Creating the clocks of 500 MHz
set period_clock 2
create_clock -name {write_clk} -period $period_clock [get_ports {write_clk}]
create_clock -name {read_clk}  -period $period_clock [get_ports {read_clk}]

### Ignore timing analysis for asynchronous resets
set_false_path -from [get_ports {write_rst_n}]
set_false_path -from [get_ports {read_rst_n}]

### Clocks are asynchronous to each other
set_clock_groups -asynchronous -group {write_clk} -group {read_clk}

### INPUTS
set_driving_cell -lib_cell GINVD1BWP30P140 [all_inputs]

### OUTPUTS
set_load [load_of [get_lib_pins GINVMCOD8BWP30P140/I]] [all_outputs]

# Apply I/O delays only to data/control I/O ports (exclude clocks/resets)
set_input_delay -clock write_clk [expr ${period_clock}/2] \
  [get_ports {p_write_en p_write_data[*]}]
set_input_delay -clock read_clk [expr ${period_clock}/2] [get_ports {p_read_en}]
set_output_delay -clock write_clk [expr ${period_clock}/2] [get_ports {p_write_full}]
set_output_delay -clock read_clk  [expr ${period_clock}/2] \
  [get_ports {p_read_data[*] p_read_empty}]
