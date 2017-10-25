# Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
# Use of this source code is governed by a MIT-style
# license that can be found in the LICENSE file.
#
# Author: Chenglu Jin at <chenglu.jin@uconn.edu>

set_property PACKAGE_PIN F22 [get_ports {mode}];  # "SW0"
set_property PACKAGE_PIN G22 [get_ports {global_start}];  # "SW1"
set_property PACKAGE_PIN T21 [get_ports {check_result}];  # "LED1"
set_property PACKAGE_PIN U22 [get_ports {hash_result}];  # "LED2"
set_property iostandard LVCMOS15 [get_ports {mode}]
set_property iostandard LVCMOS15 [get_ports {global_start}]
set_property iostandard LVCMOS15 [get_ports {check_result}]
set_property iostandard LVCMOS15 [get_ports {hash_result}]

