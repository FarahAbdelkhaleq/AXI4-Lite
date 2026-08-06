# ============================================================
# Constraints.xdc
# Target: XC7A100T-FTG256-3
# Top: Top
# ============================================================


# ============================================================
# CLOCK
# ============================================================

# IMPORTANT:
# Add the real clock pin for your board here.
# Example:
# set_property PACKAGE_PIN <REAL_CLK_PIN> [get_ports ACLK]

set_property IOSTANDARD LVCMOS33 [get_ports ACLK]

# 100 MHz clock
create_clock -period 10.000 -name ACLK [get_ports ACLK]


# ============================================================
# RESET
# ============================================================

set_property IOSTANDARD LVCMOS33 [get_ports ARESETn]


# ============================================================
# CONTROL INPUTS
# ============================================================

set_property IOSTANDARD LVCMOS33 [get_ports read_flag]
set_property IOSTANDARD LVCMOS33 [get_ports write_flag]


# ============================================================
# INPUT DATA / ADDRESS
# ============================================================

set_property IOSTANDARD LVCMOS33 [get_ports WDATA_in[*]]
set_property IOSTANDARD LVCMOS33 [get_ports WADDR_in[*]]
set_property IOSTANDARD LVCMOS33 [get_ports RADDR_in[*]]

set_property IOSTANDARD LVCMOS33 [get_ports WSTRB[*]]


# ============================================================
# OUTPUT DATA
# ============================================================

set_property IOSTANDARD LVCMOS33 [get_ports RDATA_out[*]]


# ============================================================
# RESPONSES
# ============================================================

set_property IOSTANDARD LVCMOS33 [get_ports WRESP_out[*]]
set_property IOSTANDARD LVCMOS33 [get_ports RRESP_out[*]]
