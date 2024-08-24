create_clock -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# main system clock (25 Mhz)
create_generated_clock -name "clk25MHz" -multiply_by 8 -divide_by 32 -source [get_ports {clk}] [get_nets {clk_gen|o_clk_pll}]
