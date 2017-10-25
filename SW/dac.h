
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Xilinx
// Engineer:       bwiec
// Create Date:    29 June 2015, 11:37:03 AM
// Library Name:   Digital to Analog Converter
// File Name:      dac.h
// Target Devices: Zynq
// Tool Versions:  2015.1
// Description:    Middleware API for a DAC using the AXI DMA.
// Dependencies:
//   - dma_passthrough.h - Driver version v1.0
// Revision History:
//   - v1.0
//     * Initial release
//     * Tested on ZC702 and Zedboard
// Additional Comments:
//   - This library is intended to be used as a layer between the base xaxidma
//     driver and application software. The programming model is a frame-based
//     DAC driver that sends a new buffer of data (via DMA) when dac_send_frame()
//     is called.
//   - Data buffer must be contiguous. Scatter gather is not supported.
//
//////////////////////////////////////////////////////////////////////////////////

#ifndef DAC_H_
#define DAC_H_

// Return types
#define DAC_SUCCESS         0
#define DAC_GPIO_INIT_FAIL -1
#define DAC_DMA_FAIL       -2

// Object forward declaration
typedef struct dac dac_t;

// Public functions

//
// dac_create - Create a DAC object.
//
//  Arguments
//    - gpio_device_id:   Device ID of the GPIO instance to use.
//    - dma_device_id:    Device ID of the DMA instance to use.
//    - intc_device_id:   Device ID of the Interrupt Controller instance to use.
//    - s2mm_intr_id:     Interrupt ID for the AXI DMA S2MM channel.
//    - mm2s_intr_id:     Interrupt ID for the AXI DMA MM2S channel.
//    - bytes_per_sample: Number of bytes per sample (i.e. tdata width).
//
//  Return
//    - dac_t*:           Non-NULL pointer to dac_t object on success.
//    - NULL:             NULL if something failed.
dac_t* dac_create(int gpio_device_id, int dma_device_id, int intc_device_id, int s2mm_intr_id,
		          int mm2s_intr_id, int bytes_per_sample);

//
// dac_destroy - Destroy DAC object.
//
//  Arguments
//    - p_dac_inst: Pointer to dac_t object to be deallocated.
//
void dac_destroy(dac_t* p_dac_inst);

//
// dac_set_samples_per_frame - Set the number of samples per frame of data to the DAC.
//
//  Arguments
//    - p_dac_inst:        Pointer to dac_t object.
//    - samples_per_frame: Number of samples per frame of data to the DAC.
//
void dac_set_samples_per_frame(dac_t* p_dac_inst, int samples_per_frame);

//
// dac_get_samples_per_frame - Get the number of samples per frame of data to the DAC.
//
//  Arguments
//    - p_dac_inst: Pointer to dac_t object.
//
//  Return
//    - int:        Number of samples per frame of data to the DAC.
//
int dac_get_samples_per_frame(dac_t* p_dac_inst);

//
// dac_set_bytes_per_sample - Set the number of bytes per sample in the data to the
//                            DAC (i.e. tdata width).
//
//  Arguments
//    - p_dac_inst:        Pointer to dac_t object.
//    - samples_per_frame: Number of bytes per sample in the data to the DAC (i.e.
//                         tdata width).
//
void dac_set_bytes_per_sample(dac_t* p_dac_inst, int bytes_per_sample);

//
// dac_get_bytes_per_sample - Get the number of bytes per sample in the data to the
//                            DAC (i.e. tdata width).
//
//  Arguments
//    - p_dac_inst: Pointer to dac_t object.
//
//  Return
//    - int:        Number of bytes per sample in the data to the DAC (i.e. tdata
//                  width).
//
int dac_get_bytes_per_sample(dac_t* p_dac_inst);

//
// dac_enable - Enable the DAC to start streaming samples.
//
//  Arguments
//    - p_dac_inst: Pointer to the dac_t object.
//
void dac_enable(dac_t* p_dac_inst);

//
// dac_send_frame - Send the next frame of data to the DAC.
//
//  Arguments
//    - p_dac_inst: Pointer to the dac_t object.
//    - buf: Buffer containing the next frame of data to the DAC.
//
int dac_send_frame(dac_t* p_dac_inst, void* buf);

#endif /* DAC_H_ */

