create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];
create_clock -add -name tck_dmi -period 100.00 [get_pins tap/tap_dmi/TCK];
create_clock -add -name tck_dtmcs -period 100.00 [get_pins tap/tap_dtmcs/TCK];
create_clock -add -name tck_idcode -period 100.00 [get_pins tap/tap_idcode/DRCK];

#FIXME: Improve this later but hopefully ok for now.
#Since the JTAG clock is slow and bits 0 and 1 are properly synced, we can be a bit careless about the rest
set_false_path -from  [get_cells -regexp {tap/dtmcs_r_reg\[([2-9]|[1-9][0-9])\]}]

set_input_delay 10 [get_ports i_uart_rx]
set_output_delay -clock clk25 10 [get_ports led0]
set_output_delay -clock clk25 10 [get_ports o_uart_tx]

set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { led0 }];
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn }];

set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports i_uart_rx]
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports o_uart_tx]
