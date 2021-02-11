post_message "Assigning pinout"

# Load Quartus II Tcl Project package
package require ::quartus::project

project_open -revision mipi-demo mipi-demo

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "NO HEAT SINK WITH STILL AIR"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON
set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS ON
# set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC_FOR_AREA ON
# set_global_assignment -name PHYSICAL_SYNTHESIS_MAP_LOGIC_TO_MEMORY_FOR_AREA ON
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
set_global_assignment -name ROUTER_CLOCKING_TOPOLOGY_ANALYSIS ON
set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING ON
set_global_assignment -name ROUTER_TIMING_OPTIMIZATION_LEVEL MAXIMUM

set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
set_global_assignment -name ENABLE_OCT_DONE OFF
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "PASSIVE SERIAL"
set_global_assignment -name USE_CONFIGURATION_DEVICE ON
set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
set_global_assignment -name CONFIGURATION_VCCIO_LEVEL AUTO
set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE 100%
set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
set_global_assignment -name IGNORE_PARTITIONS ON
# set_global_assignment -name GENERATE_RBF_FILE ON
# set_global_assignment -name GENERATE_TTF_FILE ON
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION ON
set_global_assignment -name GENERATE_JAM_FILE ON
set_global_assignment -name GENERATE_SVF_FILE ON
# set_global_assignment -name GENERATE_JBC_FILE ON
set_global_assignment -name STRATIXIII_UPDATE_MODE STANDARD
set_global_assignment -name CYCLONEIII_CONFIGURATION_DEVICE EPCS16

set_global_assignment -name ENABLE_SIGNALTAP OFF


# system signals
set_location_assignment PIN_E2 -to CLK_48MHZ
set_location_assignment PIN_E1 -to RESETn

# SDRAM
set_location_assignment PIN_E10 -to SDRAM_ADDR[11]
set_location_assignment PIN_B13 -to SDRAM_ADDR[10]
set_location_assignment PIN_C9  -to SDRAM_ADDR[9]
set_location_assignment PIN_E11 -to SDRAM_ADDR[8]
set_location_assignment PIN_D12 -to SDRAM_ADDR[7]
set_location_assignment PIN_D11 -to SDRAM_ADDR[6]
set_location_assignment PIN_C14 -to SDRAM_ADDR[5]
set_location_assignment PIN_D14 -to SDRAM_ADDR[4]
set_location_assignment PIN_A14 -to SDRAM_ADDR[3]
set_location_assignment PIN_A15 -to SDRAM_ADDR[2]
set_location_assignment PIN_B12 -to SDRAM_ADDR[1]
set_location_assignment PIN_A12 -to SDRAM_ADDR[0]
set_location_assignment PIN_B10 -to SDRAM_BA[1]
set_location_assignment PIN_A10 -to SDRAM_BA[0]
set_location_assignment PIN_B7  -to SDRAM_CASn
set_location_assignment PIN_E9  -to SDRAM_CKE
set_location_assignment PIN_A11 -to SDRAM_CSn
set_location_assignment PIN_B6  -to SDRAM_DQ[15]
set_location_assignment PIN_D6  -to SDRAM_DQ[14]
set_location_assignment PIN_D8  -to SDRAM_DQ[13]
set_location_assignment PIN_E6  -to SDRAM_DQ[12]
set_location_assignment PIN_E8  -to SDRAM_DQ[11]
set_location_assignment PIN_E7  -to SDRAM_DQ[10]
set_location_assignment PIN_C8  -to SDRAM_DQ[9]
set_location_assignment PIN_F8  -to SDRAM_DQ[8]
set_location_assignment PIN_A6  -to SDRAM_DQ[7]
set_location_assignment PIN_B5  -to SDRAM_DQ[6]
set_location_assignment PIN_A5  -to SDRAM_DQ[5]
set_location_assignment PIN_A4  -to SDRAM_DQ[4]
set_location_assignment PIN_A3  -to SDRAM_DQ[3]
set_location_assignment PIN_B3  -to SDRAM_DQ[2]
set_location_assignment PIN_B4  -to SDRAM_DQ[1]
set_location_assignment PIN_A2  -to SDRAM_DQ[0]
set_location_assignment PIN_F9  -to SDRAM_DQM[1]
set_location_assignment PIN_A7  -to SDRAM_DQM[0]
set_location_assignment PIN_D9  -to SDRAM_RASn
set_location_assignment PIN_B14 -to SDRAM_CLK
set_location_assignment PIN_B11 -to SDRAM_WEn
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQ[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_ADDR[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_BA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_BA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_CASn
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_CKE
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_CSn
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQM[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_DQM[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_RASn
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_WEn
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM*
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[11]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[10]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[9]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[8]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[7]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[6]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[5]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[4]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[3]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[2]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[1]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_ADDR[0]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_BA[1]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_BA[0]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_DQM[1]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_DQM[0]
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_RASn
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_CASn
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_WEn
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_CSn
# set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_CKE

# SAM D21 PINS
set_location_assignment PIN_B1  -to MKR_AREF
set_location_assignment PIN_C2  -to MKR_A[0]
set_location_assignment PIN_C3  -to MKR_A[1]
set_location_assignment PIN_C6  -to MKR_A[2]
set_location_assignment PIN_D1  -to MKR_A[3]
set_location_assignment PIN_D3  -to MKR_A[4]
set_location_assignment PIN_F3  -to MKR_A[5]
set_location_assignment PIN_G2  -to MKR_A[6]

set_location_assignment PIN_G1  -to MKR_D[0]
set_location_assignment PIN_N3  -to MKR_D[1]
set_location_assignment PIN_P3  -to MKR_D[2]
set_location_assignment PIN_R3  -to MKR_D[3]
set_location_assignment PIN_T3  -to MKR_D[4]
set_location_assignment PIN_T2  -to MKR_D[5]
set_location_assignment PIN_G16 -to MKR_D[6]
set_location_assignment PIN_G15 -to MKR_D[7]
set_location_assignment PIN_F16 -to MKR_D[8]
set_location_assignment PIN_F15 -to MKR_D[9]
set_location_assignment PIN_C16 -to MKR_D[10]
set_location_assignment PIN_C15 -to MKR_D[11]
set_location_assignment PIN_B16 -to MKR_D[12]
set_location_assignment PIN_C11 -to MKR_D[13]
set_location_assignment PIN_A13 -to MKR_D[14]
  
# Mini PCIe
set_location_assignment PIN_P8  -to PEX_PIN6
set_location_assignment PIN_L7  -to PEX_PIN8
set_location_assignment PIN_N8  -to PEX_PIN10
set_location_assignment PIN_T8  -to PEX_PIN11
set_location_assignment PIN_M8  -to PEX_PIN12
set_location_assignment PIN_R8  -to PEX_PIN13
set_location_assignment PIN_L8  -to PEX_PIN14
set_location_assignment PIN_M10 -to PEX_PIN16
set_location_assignment PIN_N12 -to PEX_PIN20
set_location_assignment PIN_T9  -to PEX_PIN23
set_location_assignment PIN_R9  -to PEX_PIN25
set_location_assignment PIN_T13 -to PEX_PIN28
set_location_assignment PIN_R12 -to PEX_PIN30
set_location_assignment PIN_A9  -to PEX_PIN31
set_location_assignment PIN_F13  -to PEX_PIN32
set_location_assignment PIN_B9  -to PEX_PIN33
set_location_assignment PIN_R13 -to PEX_PIN42
set_location_assignment PIN_P14 -to PEX_PIN44
set_location_assignment PIN_T15 -to PEX_PIN45
set_location_assignment PIN_R14 -to PEX_PIN46
set_location_assignment PIN_T14 -to PEX_PIN47
set_location_assignment PIN_F14 -to PEX_PIN48
set_location_assignment PIN_D16 -to PEX_PIN49
set_location_assignment PIN_D15 -to PEX_PIN51
set_location_assignment PIN_T12 -to PEX_RST

# NINA interface
set_location_assignment PIN_J13 -to WM_PIO32
set_location_assignment PIN_T11 -to WM_PIO1
set_location_assignment PIN_R10 -to WM_PIO2
set_location_assignment PIN_P11 -to WM_PIO3
set_location_assignment PIN_R11 -to WM_PIO4
set_location_assignment PIN_N6  -to WM_PIO5
set_location_assignment PIN_P6  -to WM_PIO7
set_location_assignment PIN_N5  -to WM_PIO8
# Blue LED: RMII_RXD0/DAC_16
# set_location_assignment PIN_T4  -to WM_PIO16
# Green LED: RMII_RXD1/DAC_17
# set_location_assignment PIN_R4  -to WM_PIO17
set_location_assignment PIN_T5  -to WM_PIO18
set_location_assignment PIN_R6 -to WM_PIO21
set_location_assignment PIN_R5 -to WM_PIO20
# RMII_MDIO
# set_location_assignment PIN_T7  -to WM_PIO24
# RMII_MDCLK
# set_location_assignment PIN_R7  -to WM_PIO25
set_location_assignment PIN_N9  -to WM_PIO27
set_location_assignment PIN_N11 -to WM_PIO28
set_location_assignment PIN_T10 -to WM_PIO29
set_location_assignment PIN_T4 -to WM_PIO31
set_location_assignment PIN_M6  -to WM_PIO34
set_location_assignment PIN_R4 -to WM_PIO35
set_instance_assignment -name IO_STANDARD "2.5 V" -to WM_PIO36
set_location_assignment PIN_N1 -to WM_PIO36
set_location_assignment PIN_E15 -to WM_TX
set_location_assignment PIN_T6  -to WM_RX
# Aliases for WM_PIO20 WM_PIO21 respectively
# set_location_assignment PIN_R5  -to WM_RTS
# set_location_assignment PIN_R6  -to WM_CTS
set_instance_assignment -name IO_STANDARD "2.5 V" -to WM_RESET
set_location_assignment PIN_R1  -to WM_RESET

# HDMI output
set_instance_assignment -name IO_STANDARD LVDS -to HDMI_TX*
set_instance_assignment -name IO_STANDARD LVDS -to HDMI_CLK*
set_location_assignment PIN_R16 -to HDMI_TX[2]
set_location_assignment PIN_K15 -to HDMI_TX[1]
set_location_assignment PIN_J15 -to HDMI_TX[0]
set_location_assignment PIN_N15 -to HDMI_CLK
set_instance_assignment -name IO_STANDARD "2.5 V" -to HDMI_SCL
set_instance_assignment -name IO_STANDARD "2.5 V" -to HDMI_SDA
set_location_assignment PIN_K5 -to HDMI_SCL
set_location_assignment PIN_L4 -to HDMI_SDA
set_location_assignment PIN_M16 -to HDMI_HPD

# MIPI input
set_instance_assignment -name FAST_INPUT_REGISTER ON -to MIPI_D*
set_instance_assignment -name IO_STANDARD LVDS -to MIPI_D*
set_instance_assignment -name IO_STANDARD LVDS -to MIPI_CLK*
set_location_assignment PIN_J2  -to MIPI_D[1]
set_location_assignment PIN_L2  -to MIPI_D[0]
# set_location_assignment PIN_J1  -to MIPI_D_N[1]
# set_location_assignment PIN_L1  -to MIPI_D_N[0]
set_location_assignment PIN_M2  -to MIPI_CLK
# set_location_assignment PIN_M1  -to MIPI_CLK_N
set_instance_assignment -name IO_STANDARD "2.5 V" -to MIPI_SCL
set_instance_assignment -name IO_STANDARD "2.5 V" -to MIPI_SDA
set_location_assignment PIN_P1  -to MIPI_SCL
set_location_assignment PIN_P2  -to MIPI_SDA
set_location_assignment PIN_M7  -to MIPI_GP[0]
set_location_assignment PIN_P9  -to MIPI_GP[1]

# misc pins
# TODO: the FPGA makers assigned HDMI SDA the name "panel_en" no idea why. Maybe open an issue about it?
# set_instance_assignment -name IO_STANDARD "2.5 V" -to panel_en
# set_location_assignment PIN_L4  -to panel_en

# Flash interface
set_location_assignment PIN_C1  -to FLASH_MOSI
set_location_assignment PIN_H2  -to FLASH_MISO
set_location_assignment PIN_H1  -to FLASH_SCK
set_location_assignment PIN_D2  -to FLASH_CS
set_location_assignment PIN_R7 -to FLASH_HOLD
set_location_assignment PIN_T7 -to FLASH_WP

# interrupt pins
set_location_assignment PIN_N2 -to SAM_INT_OUT
set_location_assignment PIN_L16 -to SAM_INT_IN
set_instance_assignment -name IO_STANDARD "2.5 V" -to SAM_INT_OUT
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to SAM_INT_IN

# dual purpose pins
set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"

# Commit assignments
export_assignments
project_close
