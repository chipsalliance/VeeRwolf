set_global_assignment -name VERILOG_CU_MODE MFCU
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE AREA"
*
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (Verilog)"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation

set_global_assignment -name GENERATE_COMPRESSED_SOF ON
set_global_assignment -name AUTO_RESTART_CONFIGURATION OFF
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "AVST X8"
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF
set_global_assignment -name USE_CONF_DONE SDM_IO12
set_global_assignment -name USE_HPS_COLD_RESET SDM_IO7
set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL

set_global_assignment -name ERROR_ON_WARNINGS_PARSING_SDC_ON_RTL_CONSTRAINTS ON
set_global_assignment -name ERROR_ON_WARNINGS_LOADING_SDC_ON_RTL_CONSTRAINTS ON
set_global_assignment -name RTL_SDC_FILE src/veerwolf_0.7.5/data/agilex5.sdc

# Clock
set_location_assignment PIN_D8 -to clk -comment IOBANK_6C
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to clk -entity veerwolf_agilex

# Reset PB SW11 HPS_COLD_RESETn Bank 5B 3.3V
set_location_assignment PIN_BM109 -to rstn -comment IOBANK_5B
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to rstn -entity veerwolf_agilex

# UART RX
set_location_assignment PIN_CJ2 -to i_uart_rx -comment IOBANK_6B
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_uart_rx -entity veerwolf_agilex

# UART TX
set_location_assignment PIN_CK4 -to o_uart_tx -comment IOBANK_6B
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to o_uart_tx -entity veerwolf_agilex

# GPIO (inputs)
# User PB Bank 6A 3.3V
set_location_assignment PIN_BK31 -to i_sw[0] -comment IOBANK_6A
set_location_assignment PIN_BP22 -to i_sw[1] -comment IOBANK_6A
set_location_assignment PIN_BK28 -to i_sw[2] -comment IOBANK_6A
set_location_assignment PIN_BR22 -to i_sw[3] -comment IOBANK_6A
# User SW Bank 6A 3.3V
set_location_assignment PIN_CH12 -to i_sw[4] -comment IOBANK_6A
set_location_assignment PIN_BU22 -to i_sw[5] -comment IOBANK_6A
set_location_assignment PIN_BW19 -to i_sw[6] -comment IOBANK_6A
set_location_assignment PIN_BH28 -to i_sw[7] -comment IOBANK_6A
# MAX SPARE Bank 5A 3.3V
set_location_assignment PIN_CD134 -to i_sw[8] -comment IOBANK_5A
set_location_assignment PIN_CD135 -to i_sw[9] -comment IOBANK_5A
set_location_assignment PIN_CG134 -to i_sw[10] -comment IOBANK_5A
set_location_assignment PIN_CH132 -to i_sw[11] -comment IOBANK_5A
# HSIO SW24 Bank 2AT 1.1V
set_location_assignment PIN_BE93 -to i_sw[12] -comment IOBANK_2A_T
set_location_assignment PIN_BE79 -to i_sw[13] -comment IOBANK_2A_T
set_location_assignment PIN_BF83 -to i_sw[14] -comment IOBANK_2A_T
set_location_assignment PIN_BE83 -to i_sw[15] -comment IOBANK_2A_T

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[0] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[1] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[2] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[3] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[4] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[5] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[6] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[7] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[9] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[10] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_sw[11] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to i_sw[12] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to i_sw[13] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to i_sw[14] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to i_sw[15] -entity veerwolf_agilex


# GPIO (outputs)
# User LED Bank 2AT 1.1V
set_location_assignment PIN_BM59 -to o_led[0] -comment IOBANK_2A_T
set_location_assignment PIN_BH59 -to o_led[1] -comment IOBANK_2A_T
set_location_assignment PIN_BH62 -to o_led[2] -comment IOBANK_2A_T
set_location_assignment PIN_BK59 -to o_led[3] -comment IOBANK_2A_T
# FMC LA Bank 3BT 1.2V
set_location_assignment PIN_B42 -to o_led[4] -comment IOBANK_3B_B
set_location_assignment PIN_A45 -to o_led[5] -comment IOBANK_3B_B
set_location_assignment PIN_A48 -to o_led[6] -comment IOBANK_3B_B
set_location_assignment PIN_B45 -to o_led[7] -comment IOBANK_3B_B
set_location_assignment PIN_A51 -to o_led[8] -comment IOBANK_3B_B
set_location_assignment PIN_B51 -to o_led[9] -comment IOBANK_3B_B
set_location_assignment PIN_B54 -to o_led[10] -comment IOBANK_3B_B
set_location_assignment PIN_A54 -to o_led[11] -comment IOBANK_3B_B
set_location_assignment PIN_B60 -to o_led[12] -comment IOBANK_3B_B
set_location_assignment PIN_A63 -to o_led[13] -comment IOBANK_3B_B
set_location_assignment PIN_A60 -to o_led[14] -comment IOBANK_3B_B
set_location_assignment PIN_B56 -to o_led[15] -comment IOBANK_3B_B

set_instance_assignment -name IO_STANDARD "1.1-V" -to o_led[0] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to o_led[1] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to o_led[2] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.1-V" -to o_led[3] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[8] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[9] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[10] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[11] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[12] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[13] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[14] -entity veerwolf_agilex
set_instance_assignment -name IO_STANDARD "1.2-V" -to o_led[15] -entity veerwolf_agilex