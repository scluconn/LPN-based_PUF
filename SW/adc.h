
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Xilinx
// Engineer:       bwiec
// Create Date:    29 June 2015, 11:37:03 AM
// Library Name:   Analog to Digital Converter
// File Name:      adc.h
// Target Devices: Zynq
// Tool Versions:  2015.1
// Description:    Middleware API for an ADC using the AXI DMA.
// Dependencies:
//   - dma_passthrough.h - Driver version v1.0
// Revision History:
//   - v1.0
//     * Initial release
//     * Tested on ZC702 and Zedboard
// Additional Comments:
//   - This library is intended to be used as a layer between the base xaxidma
//     driver and application software. The programming model is a frame-based
//     ADC driver that accepts a new buffer of data (via DMA) when adc_get_frame()
//     is called.
//   - Data buffer must be contiguous. Scatter gather is not supported.
//
//////////////////////////////////////////////////////////////////////////////////

#ifndef ADC_H_
#define ADC_H_

// Return types
#define ADC_SUCCESS         0
#define ADC_GPIO_INIT_FAIL -1
#define ADC_DMA_FAIL       -2

// Object forward declaration
typedef struct adc adc_t;

// Public functions

//
// adc_create - Create an ADC object.
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
//    - adc_t*:           Non-NULL pointer to adc_t object on success.
//    - NULL:             NULL if something failed.
//
adc_t* adc_create(int gpio_device_id, int dma_device_id, int intc_device_id, int s2mm_intr_id,
		          int mm2s_intr_id, int bytes_per_sample);

//
// adc_destroy - Destroy ADC object.
//
//  Arguments
//    - p_adc_inst: Pointer to adc_t object to be deallocated.
//
void adc_destroy(adc_t* p_adc_inst);

//
// adc_set_samples_per_frame - Set the number of samples per frame of data from the ADC.
//
//  Arguments
//    - p_adc_inst:        Pointer to adc_t object.
//    - samples_per_frame: Number of samples per frame of data from the ADC.
//
void adc_set_samples_per_frame(adc_t* p_adc_inst, int samples_per_frame);

//
// adc_get_samples_per_frame - Get the number of samples per frame of data from the ADC.
//
//  Arguments
//    - p_adc_inst: Pointer to adc_t object.
//
//  Return
//    - int:        Number of samples per frame of data from the ADC.
//
int adc_get_samples_per_frame(adc_t* p_adc_inst);

//
// adc_set_bytes_per_sample - Set the number of bytes per sample in the data from the
//                            ADC (i.e. tdata width).
//
//  Arguments
//    - p_adc_inst:        Pointer to adc_t object.
//    - samples_per_frame: Number of bytes per sample in the data from the ADC (i.e.
//                         tdata width).
//
void adc_set_bytes_per_sample(adc_t* p_adc_inst, int bytes_per_sample);

//
// adc_get_bytes_per_sample - Get the number of bytes per sample in the data from the
//                            ADC (i.e. tdata width).
//
//  Arguments
//    - p_adc_inst: Pointer to adc_t object.
//
//  Return
//    - int:        Number of bytes per sample in the data from the ADC (i.e. tdata
//                  width).
//
int adc_get_bytes_per_sample(adc_t* p_adc_inst);

//
// adc_enable - Enable the ADC to start streaming samples.
//
//  Arguments
//    - p_adc_inst: Pointer to the adc_t object.
//
void adc_enable(adc_t* p_adc_inst);

//
// adc_get_frame - Get the next frame of data from the ADC.
//
//  Arguments
//    - p_adc_inst: Pointer to the adc_t object.
//    - buf: Buffer containing the next frame of data from the ADC.
//
int adc_get_frame(adc_t* p_adc_inst, void* buf);

#endif /* ADC_H_ */

