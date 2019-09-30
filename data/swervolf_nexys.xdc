create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]
create_clock -period 100.000 -name tck_dmi -add [get_pins tap/tap_dmi/TCK]
create_clock -period 100.000 -name tck_dtmcs -add [get_pins tap/tap_dtmcs/TCK]
create_clock -period 100.000 -name tck_idcode -add [get_pins tap/tap_idcode/DRCK]

#FIXME: Improve this later but hopefully ok for now.
#Since the JTAG clock is slow and bits 0 and 1 are properly synced, we can be a bit careless about the rest
set_false_path -from [get_cells -regexp {tap/dtmcs_r_reg\[([2-9]|[1-9][0-9])\]}]
set_false_path -from [get_clocks tck_dtmcs] -to [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT0]]

set_false_path -from [get_cells ddr2/serial_tx_reg]

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]

set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports led0]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports rstn]

set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports sw0]

set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports o_flash_mosi]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports i_flash_miso]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports o_flash_cs_n];

set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports o_sd_sclk];
set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports o_sd_mosi];
set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports i_sd_miso];
set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports o_sd_cs_n];

set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports io_ethmac_md]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports o_ethmac_mdc]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports o_phy_rstn]
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {i_rmii_rxd[1]}]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {i_rmii_rxd[0]}]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports i_rmii_rxerr]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {o_rmii_txd[0]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {o_rmii_txd[1]}]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports o_rmii_txen]
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports i_rmii_crsdv]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports o_phy_clk]

set_input_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -min -add_delay 3.000 [get_ports {i_rmii_rxd[*]}]
set_input_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -max -add_delay 15.000 [get_ports {i_rmii_rxd[*]}]
set_input_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -min -add_delay 3.000 [get_ports i_rmii_crsdv]
set_input_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -max -add_delay 15.000 [get_ports i_rmii_crsdv]

set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -min -add_delay -1.500 [get_ports {o_rmii_txd[*]}]
set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -max -add_delay 5.000 [get_ports {o_rmii_txd[*]}]
set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -min -add_delay -1.500 [get_ports o_phy_rstn]
set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -max -add_delay 5.000 [get_ports o_phy_rstn]
set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -min -add_delay -1.500 [get_ports o_rmii_txen]
set_output_delay -clock [get_clocks -of_objects [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1]] -max -add_delay 5.000 [get_ports o_rmii_txen]

create_generated_clock -name mii_to_rmii_0_inst/U0/rmii2mac_rx_clk -source [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1] -divide_by 2 [get_pins mii_to_rmii_0_inst/U0/rmii2mac_rx_clk_bi_reg/Q]
create_generated_clock -name mii_to_rmii_0_inst/U0/rmii2mac_tx_clk -source [get_pins clk_gen/PLLE2_BASE_inst/CLKOUT1] -divide_by 2 [get_pins mii_to_rmii_0_inst/U0/rmii2mac_tx_clk_bi_reg/Q]
