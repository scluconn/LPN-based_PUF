#-----------------------------------------------------------
# dma_ex_interrupt.tcl
#-----------------------------------------------------------

#-----------------------------------------------------------
# User-editable parameters
#-----------------------------------------------------------
# target_board can be: zedboard, zc702
#set target_board zc702
set target_board zedboard

#-----------------------------------------------------------
# Constant parameters
#-----------------------------------------------------------
set proj_name dma_ex_interrupt
set design_ver v0_1
set underscore _
set design_name_full "$proj_name$underscore$design_ver"
puts "NOTE: This file must be executed from the project's 'tcl' directory"
puts "NOTE: Generating design targeting $target_board. You can change the target_board variable in $proj_name.tcl to target another board."

#-----------------------------------------------------------
# Archive existing design if it already exists
#-----------------------------------------------------------
puts "NOTE: Archive existing $design_name_full design if it exists"
set format_date [clock format [clock seconds] -format %Y%m%d_%H%m]
set date_suffix $underscore$format_date
if { [file exists "../proj/$design_name_full"] == 1 } { 
  puts "Moving existing $design_name_full to time-stamped suffix $design_name_full$date_suffix"
  file rename "../proj/$design_name_full" "../proj/$design_name_full$date_suffix"
} else {
  file mkdir ../proj
}

#-----------------------------------------------------------
# Create project
#-----------------------------------------------------------
puts "Creating project for $design_name_full..."
if { $target_board == "zedboard" } {
	set target_part xc7z020clg484-1
	set board_property em.avnet.com:zed:part0:1.3
} elseif { $target_board == "zc702" } {
	set target_part xc7z020clg484-1
	set board_property xilinx.com:zc702:part0:1.2
} else {
	puts "ERROR! Selected board is not supported."
	exit
}
create_project $design_name_full "../proj/$design_name_full" -part $target_part
set_property board $board_property [current_project]

#-----------------------------------------------------------
# Add HDL IP repositories
#-----------------------------------------------------------
set_property ip_repo_paths "../lib" [current_fileset]
update_ip_catalog -rebuild

#-----------------------------------------------------------
# Create BD source
#-----------------------------------------------------------
puts "Creating block diagram..."
source "./bd_$target_board.tcl"
make_wrapper -files [get_files "../proj/$design_name_full/$design_name_full.srcs/sources_1/bd/design_1/design_1.bd"] -top
import_files -force -norecurse "../proj/$design_name_full/$design_name_full.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v"

#-----------------------------------------------------------
# Generate bitstream
#-----------------------------------------------------------
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

#-----------------------------------------------------------
# Export hardware for SDK
#-----------------------------------------------------------
file mkdir "../proj/$design_name_full/$design_name_full.sdk"
file copy -force "../proj/$design_name_full/$design_name_full.runs/impl_1/design_1_wrapper.sysdef" "../proj/$design_name_full/$design_name_full.sdk/design_1_wrapper.hdf"

