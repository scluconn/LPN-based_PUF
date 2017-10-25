# Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
# Use of this source code is governed by a MIT-style
# license that can be found in the LICENSE file.
#
# Author: Chenglu Jin at <chenglu.jin@uconn.edu>
#
# This is the tcl file to automate ModelSim simulation.
# To run: source tb.tcl 

quit -sim
vlib work
vlog *.v
vsim system_tb
view wave
do wave.do
run 60000ns
