
// Includes
#include <stdlib.h>
#include "adc.h"
#include "xgpio.h"
#include "dma_passthrough.h"

// Private data
typedef struct adc_periphs
{
	dma_passthrough_t* p_dma_passthrough_inst;
	XGpio              gpio_inst;
} adc_periphs_t;

// Object definition
typedef struct adc
{
	adc_periphs_t periphs;
	int           samples_per_frame;
	int           bytes_per_sample;
} adc_t;

// Private functions
static int init_gpio(XGpio* p_gpio_inst, int gpio_device_id)
{

	// Local variables
	int status = 0;

	// Initialize driver
	status = XGpio_Initialize(p_gpio_inst, gpio_device_id);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of AXI GPIO instance failed.\n\r");
		return ADC_GPIO_INIT_FAIL;
	}

	// Set value to 0 in case set some other way by previous run
	XGpio_DiscreteWrite(p_gpio_inst, 1, 0);

	return ADC_SUCCESS;

}

// Public functions
adc_t* adc_create(int gpio_device_id, int dma_device_id, int intc_device_id, int s2mm_intr_id,
		          int mm2s_intr_id, int bytes_per_sample)
{

	// Local variables
	int    status;
	adc_t* p_obj;

	// Allocate memory for ADC object
	p_obj = (adc_t*) malloc(sizeof(adc_t));
	if (p_obj == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for ADC object.\n\r");
		return NULL;
	}

	// Create DMA Passthrough object to be used by the ADC
	p_obj->periphs.p_dma_passthrough_inst = dma_passthrough_create
	(
		dma_device_id,
		intc_device_id,
		s2mm_intr_id,
		mm2s_intr_id,
		bytes_per_sample
	);
	if (p_obj->periphs.p_dma_passthrough_inst == NULL)
	{
		xil_printf("ERROR! Failed to create DMA Passthrough object for use by the ADC.\n\r");
		return NULL;
	}

	// Register and initialize peripherals
	status = init_gpio(&p_obj->periphs.gpio_inst, gpio_device_id);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to initialize GPIO.\n\r");
		adc_destroy(p_obj);
		return NULL;
	}

	// Initialize ADC parameters
	adc_set_samples_per_frame(p_obj, 1024);
	adc_set_bytes_per_sample(p_obj, bytes_per_sample);

	return p_obj;

}

void adc_destroy(adc_t* p_adc_inst)
{
	dma_passthrough_destroy(p_adc_inst->periphs.p_dma_passthrough_inst);
	free(p_adc_inst);
}

void adc_set_samples_per_frame(adc_t* p_adc_inst, int samples_per_frame)
{
	p_adc_inst->samples_per_frame = samples_per_frame;
	dma_passthrough_set_buf_length(p_adc_inst->periphs.p_dma_passthrough_inst, samples_per_frame);
}

int adc_get_samples_per_frame(adc_t* p_adc_inst)
{
	return (p_adc_inst->samples_per_frame);
}

void adc_set_bytes_per_sample(adc_t* p_adc_inst, int bytes_per_sample)
{
	p_adc_inst->bytes_per_sample = bytes_per_sample;
	dma_passthrough_set_sample_size_bytes(p_adc_inst->periphs.p_dma_passthrough_inst, bytes_per_sample);
}

int adc_get_bytes_per_sample(adc_t* p_adc_inst)
{
	return (p_adc_inst->bytes_per_sample);
}

void adc_enable(adc_t* p_adc_inst)
// The implementation of this function is specific to this hardware where a GPIO
// is used to emulate a data source. This function would obviously be implemented
// completely differently if there were an actual ADC in the system.
{
	dma_passthrough_reset(p_adc_inst->periphs.p_dma_passthrough_inst); // Reset DMA to flush those 4 extra samples that are accepted before DMA configuration
	XGpio_DiscreteSet(&p_adc_inst->periphs.gpio_inst, 1, adc_get_samples_per_frame(p_adc_inst));     // Assert the reset on the hardware counter
	XGpio_DiscreteSet(&p_adc_inst->periphs.gpio_inst, 1, 0x80000000);     // Release the reset on the hardware counter
}

int adc_get_frame(adc_t* p_adc_inst, void* buf)
{

	// Local variables
	int status;

	dma_passthrough_set_rcv_buf(p_adc_inst->periphs.p_dma_passthrough_inst, buf);
	status = dma_passthrough_rcv(p_adc_inst->periphs.p_dma_passthrough_inst);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! DMA Passthrough error occurred when trying to get data.\n\r");
		return ADC_DMA_FAIL;
	}

	return ADC_SUCCESS;

}

