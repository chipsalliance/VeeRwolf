create_ip -name mii_to_rmii -vendor xilinx.com -library ip -version 2.0 -module_name mii_to_rmii_0
set_property -dict [list CONFIG.C_SPEED_100 {0} CONFIG.C_FIXED_SPEED {1} CONFIG.C_INCLUDE_BUF {1}] [get_ips mii_to_rmii_0]
#set_property -dict [list CONFIG.C_SPEED_100 {1} CONFIG.C_FIXED_SPEED {1}] [get_ips mii_to_rmii_0]
generate_target all [get_files  ./swervolf_0.srcs/sources_1/ip/mii_to_rmii_0_2/mii_to_rmii_0.xci]
