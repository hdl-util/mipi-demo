set_time_format -unit ns -decimal_places 3
#create_clock -name MIPI_CLK -period 15.38 [get_ports {MIPI_CLK}]
create_clock -name CLK_48MHZ -period "48.0 MHz" [get_ports {CLK_48MHZ}]
create_generated_clock -name SDRAM_CLK -source [get_pins mem_pll|altpll_component|auto_generated|pll1|clk[0]] [get_ports {SDRAM_CLK}]

derive_pll_clocks
derive_clock_uncertainty

set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_A*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_D*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_R*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CA*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CK*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CS*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_W*]
set_output_delay -max 1.5 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_BA*]

set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_A*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_D*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_R*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CA*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CK*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_CS*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_W*]
set_output_delay -min -0.8 -clock [get_clocks SDRAM_CLK]  [get_ports SDRAM_BA*]


# set_false_path -from [get_clocks {MIPI_CLK}] -to [get_clocks {mem_pll|altpll_component|auto_generated|pll1|clk[2]}]
# set_false_path -from [get_clocks {mem_pll|altpll_component|auto_generated|pll1|clk[2]}] -to [get_clocks {MIPI_CLK}]
