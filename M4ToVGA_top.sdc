## Generated SDC file "M4ToVGA_top.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Fri Nov 20 21:37:15 2020"

##
## DEVICE  "EP4CE6E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {external_clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {external_clock}]
create_clock -name {m4_dotclk} -period 1.000 -waveform { 0.000 0.500 } [get_ports {m4_dotclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 74 -divide_by 147 -master_clock {external_clock} [get_pins {inst|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {m4_dotclk}] -rise_to [get_clocks {m4_dotclk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {m4_dotclk}] -fall_to [get_clocks {m4_dotclk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {m4_dotclk}] -rise_to [get_clocks {m4_dotclk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {m4_dotclk}] -fall_to [get_clocks {m4_dotclk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

