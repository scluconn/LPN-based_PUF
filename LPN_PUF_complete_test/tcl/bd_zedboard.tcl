
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: dac_model
proc create_hier_cell_dac_model { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_dac_model() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA

  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst s_axi_aresetn

  # Create instance: axi_fifo_mm_s_1, and set properties
  set axi_fifo_mm_s_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_fifo_mm_s_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_1_m_axis_mm2s [get_bd_intf_pins S_AXIS_DATA] [get_bd_intf_pins axi_fifo_mm_s_1/AXI_STR_RXD]
  connect_bd_intf_net -intf_net axi_interconnect_1_m01_axi [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_fifo_mm_s_1/S_AXI]

  # Create port connections
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_fifo_mm_s_1/s_axi_aresetn]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_fifo_mm_s_1/s_axi_aclk]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: adc_model
proc create_hier_cell_adc_model { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_adc_model() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I m_axis_data_tready
  create_bd_pin -dir I -from 0 -to 0 resetn

  # Create instance: c_counter_binary_0, and set properties
  set c_counter_binary_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_0 ]
  set_property -dict [ list CONFIG.CE {true} CONFIG.Output_Width {32} CONFIG.SCLR {true}  ] $c_counter_binary_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $util_vector_logic_0

  # Create port connections
  connect_bd_net -net Op1_1 [get_bd_pins resetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins c_counter_binary_0/CLK]
  connect_bd_net -net c_counter_binary_0_Q [get_bd_pins dout] [get_bd_pins c_counter_binary_0/Q]
  connect_bd_net -net m_axis_data_tready_1 [get_bd_pins m_axis_data_tready] [get_bd_pins c_counter_binary_0/CE]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins c_counter_binary_0/SCLR] [get_bd_pins util_vector_logic_0/Res]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: rst_gen
proc create_hier_cell_rst_gen { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_rst_gen() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 -type rst aux_reset_in
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -from 0 -to 0 -type rst interconnect_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir I -type clk slowest_sync_clk
  create_bd_pin -dir O -from 0 -to 0 -type rst tlast_gen_resetn

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create port connections
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins interconnect_aresetn] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins tlast_gen_resetn] [get_bd_pins proc_sys_reset_1/peripheral_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins slowest_sync_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins aux_reset_in] [get_bd_pins proc_sys_reset_1/aux_reset_in]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gpio
proc create_hier_cell_gpio { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_gpio() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 9 -to 0 pkt_length
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst s_axi_aresetn
  create_bd_pin -dir O -from 0 -to 0 tlast_gen_resetn

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list CONFIG.C_ALL_OUTPUTS {0} CONFIG.C_GPIO_WIDTH {32}  ] $axi_gpio_1

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list CONFIG.DIN_FROM {9} CONFIG.DOUT_WIDTH {10}  ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list CONFIG.DIN_FROM {31} CONFIG.DIN_TO {31} CONFIG.DOUT_WIDTH {1}  ] $xlslice_1

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_1_m02_axi [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_i] [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins pkt_length] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins tlast_gen_resetn] [get_bd_pins xlslice_1/Dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: datapath
proc create_hier_cell_datapath { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_datapath() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_MM2S
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_S2MM
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_DAC
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_DMA

  # Create pins
  create_bd_pin -dir I -type clk data_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst data_resetn
  create_bd_pin -dir O -from 0 -to 0 mm2s_introut
  create_bd_pin -dir I -from 9 -to 0 pkt_length
  create_bd_pin -dir O -from 0 -to 0 s2mm_introut
  create_bd_pin -dir I -from 0 -to 0 -type rst tlast_gen_resetn

  # Create instance: adc_model
  create_hier_cell_adc_model $hier_obj adc_model

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_include_sg {0} CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_sg_length_width {23}  ] $axi_dma_1

  # Create instance: dac_model
  create_hier_cell_dac_model $hier_obj dac_model

  # Create instance: tlast_gen_0, and set properties
  set tlast_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:tlast_gen:1.0 tlast_gen_0 ]
  set_property -dict [ list CONFIG.MAX_PKT_LENGTH {1023} CONFIG.TDATA_WIDTH {32}  ] $tlast_gen_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_1_m_axis_mm2s [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins dac_model/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axi_interconnect_1_m00_axi [get_bd_intf_pins S_AXI_DMA] [get_bd_intf_pins axi_dma_1/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_interconnect_1_m01_axi [get_bd_intf_pins S_AXI_DAC] [get_bd_intf_pins dac_model/S_AXI]
  connect_bd_intf_net -intf_net s00_axi_1 [get_bd_intf_pins M_AXI_S2MM] [get_bd_intf_pins axi_dma_1/M_AXI_S2MM]
  connect_bd_intf_net -intf_net s01_axi_1 [get_bd_intf_pins M_AXI_MM2S] [get_bd_intf_pins axi_dma_1/M_AXI_MM2S]
  connect_bd_intf_net -intf_net tlast_gen_0_m_axis [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins tlast_gen_0/m_axis]

  # Create port connections
  connect_bd_net -net adc_model_dout [get_bd_pins adc_model/dout] [get_bd_pins tlast_gen_0/s_axis_tdata]
  connect_bd_net -net axi_dma_1_mm2s_introut [get_bd_pins mm2s_introut] [get_bd_pins axi_dma_1/mm2s_introut]
  connect_bd_net -net axi_dma_1_s2mm_introut [get_bd_pins s2mm_introut] [get_bd_pins axi_dma_1/s2mm_introut]
  connect_bd_net -net ctrl_Dout [get_bd_pins pkt_length] [get_bd_pins tlast_gen_0/pkt_length]
  connect_bd_net -net ctrl_peripheral_aresetn [get_bd_pins tlast_gen_resetn] [get_bd_pins adc_model/resetn] [get_bd_pins tlast_gen_0/resetn] [get_bd_pins tlast_gen_0/s_axis_tvalid]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins data_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins dac_model/s_axi_aresetn]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins data_aclk] [get_bd_pins adc_model/aclk] [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins dac_model/s_axi_aclk] [get_bd_pins tlast_gen_0/aclk]
  connect_bd_net -net tlast_gen_0_s_axis_tready [get_bd_pins adc_model/m_axis_data_tready] [get_bd_pins tlast_gen_0/s_axis_tready]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ctrl
proc create_hier_cell_ctrl { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_ctrl() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DAC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_DMA_MM2S
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_DMA_S2MM

  # Create pins
  create_bd_pin -dir O -type clk ctrl_aclk
  create_bd_pin -dir O -from 0 -to 0 -type rst ctrl_resetn
  create_bd_pin -dir I -from 0 -to 0 dma_mm2s_irq
  create_bd_pin -dir I -from 0 -to 0 dma_s2mm_irq
  create_bd_pin -dir O -from 9 -to 0 pkt_length
  create_bd_pin -dir O -from 0 -to 0 -type rst tlast_gen_resetn

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list CONFIG.NUM_MI {3}  ] $axi_interconnect_1

  # Create instance: axi_interconnect_2, and set properties
  set axi_interconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_2 ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_interconnect_2

  # Create instance: gpio
  create_hier_cell_gpio $hier_obj gpio

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.preset {ZedBoard}  ] $processing_system7_0

  # Create instance: rst_gen
  create_hier_cell_rst_gen $hier_obj rst_gen

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_1_m00_axi [get_bd_intf_pins M_AXI_DMA] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_m01_axi [get_bd_intf_pins M_AXI_DAC] [get_bd_intf_pins axi_interconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_m02_axi [get_bd_intf_pins axi_interconnect_1/M02_AXI] [get_bd_intf_pins gpio/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_2_M00_AXI [get_bd_intf_pins axi_interconnect_2/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net s00_axi_1 [get_bd_intf_pins S_AXI_DMA_S2MM] [get_bd_intf_pins axi_interconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net s01_axi_1 [get_bd_intf_pins S_AXI_DMA_MM2S] [get_bd_intf_pins axi_interconnect_2/S01_AXI]

  # Create port connections
  connect_bd_net -net In0_1 [get_bd_pins dma_mm2s_irq] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net In1_1 [get_bd_pins dma_s2mm_irq] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_2/ARESETN] [get_bd_pins axi_interconnect_2/M00_ARESETN] [get_bd_pins axi_interconnect_2/S00_ARESETN] [get_bd_pins axi_interconnect_2/S01_ARESETN] [get_bd_pins rst_gen/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins ctrl_resetn] [get_bd_pins gpio/s_axi_aresetn] [get_bd_pins rst_gen/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins tlast_gen_resetn] [get_bd_pins rst_gen/tlast_gen_resetn]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_gen/ext_reset_in]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins ctrl_aclk] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_2/ACLK] [get_bd_pins axi_interconnect_2/M00_ACLK] [get_bd_pins axi_interconnect_2/S00_ACLK] [get_bd_pins axi_interconnect_2/S01_ACLK] [get_bd_pins gpio/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins rst_gen/slowest_sync_clk]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins pkt_length] [get_bd_pins gpio/pkt_length]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins gpio/tlast_gen_resetn] [get_bd_pins rst_gen/aux_reset_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: ctrl
  create_hier_cell_ctrl [current_bd_instance .] ctrl

  # Create instance: datapath
  create_hier_cell_datapath [current_bd_instance .] datapath

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_1_m00_axi [get_bd_intf_pins ctrl/M_AXI_DMA] [get_bd_intf_pins datapath/S_AXI_DMA]
  connect_bd_intf_net -intf_net axi_interconnect_1_m01_axi [get_bd_intf_pins ctrl/M_AXI_DAC] [get_bd_intf_pins datapath/S_AXI_DAC]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ctrl/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ctrl/FIXED_IO]
  connect_bd_intf_net -intf_net s00_axi_1 [get_bd_intf_pins ctrl/S_AXI_DMA_S2MM] [get_bd_intf_pins datapath/M_AXI_S2MM]
  connect_bd_intf_net -intf_net s01_axi_1 [get_bd_intf_pins ctrl/S_AXI_DMA_MM2S] [get_bd_intf_pins datapath/M_AXI_MM2S]


  #################################################
  #Added by CJ


#delete old blocks
delete_bd_objs [get_bd_intf_nets datapath/tlast_gen_0_m_axis] [get_bd_nets datapath/ctrl_Dout] [get_bd_nets datapath/tlast_gen_0_s_axis_tready] [get_bd_nets datapath/adc_model_dout] [get_bd_cells datapath/tlast_gen_0]
delete_bd_objs [get_bd_intf_nets datapath/axi_interconnect_1_m01_axi] [get_bd_intf_nets datapath/axi_dma_1_m_axis_mm2s] [get_bd_cells datapath/dac_model]
delete_bd_objs [get_bd_nets datapath/ctrl_peripheral_aresetn] [get_bd_cells datapath/adc_model]

#add repos
#Notice: PLEASE MODIFY THE FOLLOWING DIRECTORIES ACCORDINGLY
set_property  ip_repo_paths  {d:/GitHub/LPN_PUF_open_source/LPN_PUF_complete_test/lib d:/GitHub/LPN_PUF_open_source/RO d:/GitHub/LPN_PUF_open_source/system D:/GitHub/LPN_PUF_open_source/TRNG} [current_project]
update_ip_catalog

#add blocks
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:system:1.0 datapath/system_0
create_bd_cell -type ip -vlnv xilinx.com:user:trng_wrapper:1.0 datapath/trng_wrapper_0
create_bd_cell -type ip -vlnv xilinx.com:user:ro_pair_wrapper:1.0 datapath/ro_pair_wrapper_0
endgroup

#make connection
connect_bd_net [get_bd_pins datapath/data_aclk] [get_bd_pins datapath/trng_wrapper_0/clk]
connect_bd_net [get_bd_pins datapath/data_aclk] [get_bd_pins datapath/system_0/clk]
connect_bd_net [get_bd_pins datapath/data_aclk] [get_bd_pins datapath/ro_pair_wrapper_0/clk]
connect_bd_net [get_bd_pins datapath/data_resetn] [get_bd_pins datapath/trng_wrapper_0/resetn]
connect_bd_net [get_bd_pins datapath/data_resetn] [get_bd_pins datapath/system_0/resetn]
connect_bd_net [get_bd_pins datapath/system_0/pok_resetn] [get_bd_pins datapath/ro_pair_wrapper_0/resetn]
connect_bd_net [get_bd_pins datapath/ro_pair_wrapper_0/e] [get_bd_pins datapath/system_0/e]
connect_bd_net [get_bd_pins datapath/ro_pair_wrapper_0/r] [get_bd_pins datapath/system_0/r]
connect_bd_net [get_bd_pins datapath/ro_pair_wrapper_0/done] [get_bd_pins datapath/system_0/pok_done]
connect_bd_net [get_bd_pins datapath/trng_wrapper_0/random_num] [get_bd_pins datapath/system_0/s_w]
connect_bd_intf_net [get_bd_intf_pins datapath/axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins datapath/system_0/data_in]
connect_bd_intf_net [get_bd_intf_pins datapath/system_0/data_out] [get_bd_intf_pins datapath/axi_dma_1/S_AXIS_S2MM]

create_bd_port -dir I mode
create_bd_port -dir I global_start
create_bd_port -dir O check_result
create_bd_port -dir O hash_result
connect_bd_net [get_bd_ports global_start] [get_bd_pins datapath/system_0/global_start]
connect_bd_net [get_bd_ports mode] [get_bd_pins datapath/system_0/mode]
connect_bd_net [get_bd_ports check_result] [get_bd_pins datapath/system_0/check_result]
connect_bd_net [get_bd_ports hash_result] [get_bd_pins datapath/system_0/hash_result]

startgroup
set_property -dict [list CONFIG.c_m_axi_mm2s_data_width {128} CONFIG.c_m_axis_mm2s_tdata_width {128} CONFIG.c_m_axi_s2mm_data_width {128} CONFIG.c_s2mm_burst_size {4} CONFIG.c_addr_width {32} CONFIG.c_include_mm2s_dre {0} CONFIG.c_mm2s_burst_size {4}] [get_bd_cells datapath/axi_dma_1]
endgroup


  #################################################

  # Create port connections
  connect_bd_net -net In0_1 [get_bd_pins ctrl/dma_mm2s_irq] [get_bd_pins datapath/mm2s_introut]
  connect_bd_net -net In1_1 [get_bd_pins ctrl/dma_s2mm_irq] [get_bd_pins datapath/s2mm_introut]
  connect_bd_net -net ctrl_Dout [get_bd_pins ctrl/pkt_length] [get_bd_pins datapath/pkt_length]
  connect_bd_net -net ctrl_peripheral_aresetn [get_bd_pins ctrl/tlast_gen_resetn] [get_bd_pins datapath/tlast_gen_resetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins ctrl/ctrl_resetn] [get_bd_pins datapath/data_resetn]
  connect_bd_net -net processing_system7_1_fclk_clk0 [get_bd_pins ctrl/ctrl_aclk] [get_bd_pins datapath/data_aclk]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces ctrl/processing_system7_0/Data] [get_bd_addr_segs datapath/axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces ctrl/processing_system7_0/Data] [get_bd_addr_segs ctrl/gpio/axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces datapath/axi_dma_1/Data_MM2S] [get_bd_addr_segs ctrl/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces datapath/axi_dma_1/Data_S2MM] [get_bd_addr_segs ctrl/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM

  # Restore current instance
  current_bd_instance $oldCurInst

  #######################################################
  #Added by CJ
add_files -fileset constrs_1 -norecurse my_xdc.xdc
add_files -fileset constrs_1 -norecurse ro_450_LUT.xdc
######################################################

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
