create_ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 -module_name axi_cdc -dir .
set_property -dict [list \
			CONFIG.DATA_WIDTH {64} \
			CONFIG.ID_WIDTH   {4} \
			CONFIG.ACLK_ASYNC {0} \
			CONFIG.ACLK_RATIO {1:4}] [get_ips axi_cdc]
