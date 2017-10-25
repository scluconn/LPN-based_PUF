
// Includes
#include <stdlib.h>
#include "dac.h"
#include "xgpio.h"
#include "dma_passthrough.h"

// Private data
typedef struct dac_periphs
{
	dma_passthrough_t* p_dma_passthrough_inst;
	XGpio              gpio_inst;
} dac_periphs_t;

// Object definition
typedef struct dac
{
	dac_periphs_t periphs;
	int           samples_per_frame;
	int           bytes_per_sample;
} dac_t;

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
		return DAC_GPIO_INIT_FAIL;
	}
	
	// Set value to 0 in case set some other way by previous run
	XGpio_DiscreteWrite(p_gpio_inst, 1, 0);

	return DAC_SUCCESS;

}

// Public functions
dac_t* dac_create(int gpio_device_id, int dma_device_id, int intc_device_id, int s2mm_intr_id,
		          int mm2s_intr_id, int bytes_per_sample)
{
	// Local variables
	int    status;
	dac_t* p_obj;

	// Allocate memory for DAC object
	p_obj = (dac_t*) malloc(sizeof(dac_t));
	if (p_obj == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for DAC object.\n\r");
		return NULL;
	}

	// Create DMA Passthrough object to be used by the DAC
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
		xil_printf("ERROR! Failed to create DMA Passthrough object for use by the DAC.\n\r");
		return NULL;
	}

	// Register and initialize peripherals
	status = init_gpio(&p_obj->periphs.gpio_inst, gpio_device_id);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to initialize GPIO.\n\r");
		dac_destroy(p_obj);
		return NULL;
	}

	// Initialize DAC parameters
	dac_set_samples_per_frame(p_obj, 1024);
	dac_set_bytes_per_sample(p_obj, bytes_per_sample);

	return p_obj;
}

void dac_destroy(dac_t* p_dac_inst)
{
	dma_passthrough_destroy(p_dac_inst->periphs.p_dma_passthrough_inst);
	free(p_dac_inst);
}

void dac_set_samples_per_frame(dac_t* p_dac_inst, int samples_per_frame)
{
	p_dac_inst->samples_per_frame = samples_per_frame;
	dma_passthrough_set_buf_length(p_dac_inst->periphs.p_dma_passthrough_inst, samples_per_frame);
}

int dac_get_samples_per_frame(dac_t* p_dac_inst)
{
	return (p_dac_inst->samples_per_frame);
}

void dac_set_bytes_per_sample(dac_t* p_dac_inst, int bytes_per_sample)
{
	p_dac_inst->bytes_per_sample = bytes_per_sample;
	dma_passthrough_set_sample_size_bytes(p_dac_inst->periphs.p_dma_passthrough_inst, bytes_per_sample);
}

int dac_get_bytes_per_sample(dac_t* p_dac_inst)
{
	return (p_dac_inst->bytes_per_sample);
}

void dac_enable(dac_t* p_dac_inst)
// The implementation of this function is specific to this hardware where a GPIO
// is used to emulate a data source. This function would obviously be implemented
// completely differently if there were an actual DAC in the system.
{
	// For the purposes of this demo, nothing to be done here.
}

int dac_send_frame(dac_t* p_dac_inst, void* buf)
{
	// Local variables
	int status;

	dma_passthrough_set_snd_buf(p_dac_inst->periphs.p_dma_passthrough_inst, buf);
	status = dma_passthrough_snd(p_dac_inst->periphs.p_dma_passthrough_inst);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! DMA Passthrough error occurred when trying to send data.\n\r");
		return DAC_DMA_FAIL;
	}

	return DAC_SUCCESS;

}

