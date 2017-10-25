
// Includes
#include <stdlib.h>
#include "xaxidma.h"
#include "xscugic.h"
#include "dma_passthrough.h"

// Defines
#define RESET_TIMEOUT_COUNTER 10000

// Private data
typedef struct dma_passthrough_periphs
{
	XAxiDma dma_inst;
	XScuGic intc_inst;
} dma_passthrough_periphs_t;

typedef struct dma_passthrough
{
	dma_passthrough_periphs_t periphs;
	void*                     p_rcv_buf;
	void*                     p_snd_buf;
	int                       buf_length;
	int                       sample_size_bytes;
} dma_passthrough_t;

static int g_s2mm_done = 0;
static int g_mm2s_done = 0;
static int g_dma_err   = 0;

// Private functions
static void s2mm_isr(void* CallbackRef)
{

	// Local variables
	u32      irq_status;
	int      time_out;
	XAxiDma* p_dma_inst = (XAxiDma*)CallbackRef;

	// Disable interrupts
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

	// Read pending interrupts
	irq_status = XAxiDma_IntrGetIrq(p_dma_inst, XAXIDMA_DEVICE_TO_DMA);

	// Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(p_dma_inst, irq_status, XAXIDMA_DEVICE_TO_DMA);

	// If no interrupt is asserted, we do not do anything
	if (!(irq_status & XAXIDMA_IRQ_ALL_MASK))
		return;

	// If error interrupt is asserted, raise error flag, reset the
	// hardware to recover from the error, and return with no further
	// processing.
	if ((irq_status & XAXIDMA_IRQ_ERROR_MASK))
	{

		g_dma_err = 1;

		// Reset should never fail for transmit channel
		XAxiDma_Reset(p_dma_inst);

		time_out = RESET_TIMEOUT_COUNTER;
		while (time_out)
		{
			if (XAxiDma_ResetIsDone(p_dma_inst))
				break;

			time_out -= 1;
		}

		return;
	}

	// Completion interrupt asserted
	if (irq_status & XAXIDMA_IRQ_IOC_MASK)
		g_s2mm_done = 1;

	// Re-enable interrupts
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

}

static void mm2s_isr(void* CallbackRef)
{

	// Local variables
	u32 irq_status;
	int time_out;
	XAxiDma* p_dma_inst = (XAxiDma*)CallbackRef;

	// Disable interrupts
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

	// Read pending interrupts
	irq_status = XAxiDma_IntrGetIrq(p_dma_inst, XAXIDMA_DMA_TO_DEVICE);

	// Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(p_dma_inst, irq_status, XAXIDMA_DMA_TO_DEVICE);

	// If no interrupt is asserted, we do not do anything
	if (!(irq_status & XAXIDMA_IRQ_ALL_MASK))
		return;

	// If error interrupt is asserted, raise error flag, reset the
	// hardware to recover from the error, and return with no further
	// processing.
	if (irq_status & XAXIDMA_IRQ_ERROR_MASK)
	{

		g_dma_err = 1;

		// Reset could fail and hang
		XAxiDma_Reset(p_dma_inst);

		time_out = RESET_TIMEOUT_COUNTER;

		while (time_out)
		{
			if (XAxiDma_ResetIsDone(p_dma_inst))
				break;

			time_out -= 1;
		}

		return;
	}

	// If completion interrupt is asserted, then set RxDone flag
	if (irq_status & XAXIDMA_IRQ_IOC_MASK)
		g_mm2s_done = 1;

	// Re-enable interrupts
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

}

static int init_intc(XScuGic* p_intc_inst, int intc_device_id, XAxiDma* p_dma_inst, int s2mm_intr_id, int mm2s_intr_id)
{

	// Local variables
	int             status = 0;
	XScuGic_Config* cfg_ptr;

	// Look up hardware configuration for device
	cfg_ptr = XScuGic_LookupConfig(intc_device_id);
	if (!cfg_ptr)
	{
		xil_printf("ERROR! No hardware configuration found for Interrupt Controller with device id %d.\r\n", intc_device_id);
		return DMA_PASSTHROUGH_INTC_INIT_FAIL;
	}

	// Initialize driver
	status = XScuGic_CfgInitialize(p_intc_inst, cfg_ptr, cfg_ptr->CpuBaseAddress);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of Interrupt Controller failed with %d.\r\n", status);
		return DMA_PASSTHROUGH_INTC_INIT_FAIL;
	}

	// Set interrupt priorities and trigger type
	XScuGic_SetPriorityTriggerType(p_intc_inst, s2mm_intr_id, 0xA0, 0x3);
	XScuGic_SetPriorityTriggerType(p_intc_inst, mm2s_intr_id, 0xA8, 0x3);

	// Connect handlers
	status = XScuGic_Connect(p_intc_inst, s2mm_intr_id, (Xil_InterruptHandler)s2mm_isr, p_dma_inst);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to connect s2mm_isr to the interrupt controller.\r\n", status);
		return DMA_PASSTHROUGH_INTC_INIT_FAIL;
	}
	status = XScuGic_Connect(p_intc_inst, mm2s_intr_id, (Xil_InterruptHandler)mm2s_isr, p_dma_inst);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to connect mm2s_isr to the interrupt controller.\r\n", status);
		return DMA_PASSTHROUGH_INTC_INIT_FAIL;
	}

	// Enable all interrupts
	XScuGic_Enable(p_intc_inst, s2mm_intr_id);
	XScuGic_Enable(p_intc_inst, mm2s_intr_id);

	// Initialize exception table and register the interrupt controller handler with exception table
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, p_intc_inst);

	// Enable non-critical exceptions
	Xil_ExceptionEnable();

	return DMA_PASSTHROUGH_SUCCESS;

}

static int init_dma(XAxiDma* p_dma_inst, int dma_device_id)
{

	// Local variables
	int             status = 0;
	XAxiDma_Config* cfg_ptr;

	// Look up hardware configuration for device
	cfg_ptr = XAxiDma_LookupConfig(dma_device_id);
	if (!cfg_ptr)
	{
		xil_printf("ERROR! No hardware configuration found for AXI DMA with device id %d.\r\n", dma_device_id);
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Initialize driver
	status = XAxiDma_CfgInitialize(p_dma_inst, cfg_ptr);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of AXI DMA failed with %d\r\n", status);
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Test for Scatter Gather
	if (XAxiDma_HasSg(p_dma_inst))
	{
		xil_printf("ERROR! Device configured as SG mode.\r\n");
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Reset DMA
	XAxiDma_Reset(p_dma_inst);
	while (!XAxiDma_ResetIsDone(p_dma_inst)) {}

	// Enable DMA interrupts
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

	return DMA_PASSTHROUGH_SUCCESS;

}

// Public functions
dma_passthrough_t* dma_passthrough_create(int dma_device_id, int intc_device_id, int s2mm_intr_id,
		                                  int mm2s_intr_id, int sample_size_bytes)
{

	// Local variables
	dma_passthrough_t* p_obj;
	int                status;

	// Allocate memory for DMA Accelerator object
	p_obj = (dma_passthrough_t*) malloc(sizeof(dma_passthrough_t));
	if (p_obj == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for DMA Passthrough object.\n\r");
		return NULL;
	}

	// Register and initialize peripherals
	status = init_dma(&p_obj->periphs.dma_inst, dma_device_id);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! Failed to initialize AXI DMA.\n\r");
		dma_passthrough_destroy(p_obj);
		return NULL;
	}

	status = init_intc
	(
		&p_obj->periphs.intc_inst,
		intc_device_id,
		&p_obj->periphs.dma_inst,
		s2mm_intr_id,
		mm2s_intr_id
	);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! Failed to initialize Interrupt controller.\n\r");
		dma_passthrough_destroy(p_obj);
		return NULL;
	}

	// Initialize buffer pointers
	dma_passthrough_set_rcv_buf(p_obj, NULL);
	dma_passthrough_set_snd_buf(p_obj, NULL);

	// Initialize buffer length
	dma_passthrough_set_buf_length(p_obj, 1024);

	// Initialize sample size
	dma_passthrough_set_sample_size_bytes(p_obj, sample_size_bytes);

	return p_obj;

}

void dma_passthrough_destroy(dma_passthrough_t* p_dma_passthrough_inst)
{
	free(p_dma_passthrough_inst);
}

void dma_passthrough_reset(dma_passthrough_t* p_dma_passthrough_inst)
{
	XAxiDma_Reset(&p_dma_passthrough_inst->periphs.dma_inst);
}

void dma_passthrough_set_rcv_buf(dma_passthrough_t* p_dma_passthrough_inst, void* p_rcv_buf)
{
	p_dma_passthrough_inst->p_rcv_buf = p_rcv_buf;
}

void* dma_passthrough_get_rcv_buf(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->p_rcv_buf);
}

void dma_passthrough_set_snd_buf(dma_passthrough_t* p_dma_passthrough_inst, void* p_snd_buf)
{
	p_dma_passthrough_inst->p_snd_buf = p_snd_buf;
}

void* dma_passthrough_get_snd_buf(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->p_snd_buf);
}

void dma_passthrough_set_buf_length(dma_passthrough_t* p_dma_passthrough_inst, int buf_length)
{
	p_dma_passthrough_inst->buf_length = buf_length;
}

int dma_passthrough_get_buf_length(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->buf_length);
}

void dma_passthrough_set_sample_size_bytes(dma_passthrough_t* p_dma_passthrough_inst, int sample_size_bytes)
{
	p_dma_passthrough_inst->sample_size_bytes = sample_size_bytes;
}

int dma_passthrough_get_sample_size_bytes(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->sample_size_bytes);
}

int dma_passthrough_rcv(dma_passthrough_t* p_dma_passthrough_inst)
{

		// Local variables
		int       status    = 0;
		const int num_bytes = p_dma_passthrough_inst->buf_length*p_dma_passthrough_inst->sample_size_bytes;

		// Flush cache
		#if (!DMA_PASSTHROUGH_IS_CACHE_COHERENT)
			Xil_DCacheFlushRange((int)p_dma_passthrough_inst->p_rcv_buf, num_bytes);
		#endif

		// Initialize control flags which get set by ISR
		g_s2mm_done = 0;
		g_dma_err   = 0;

		// Enable interrupts
		XAxiDma_IntrEnable(&p_dma_passthrough_inst->periphs.dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

		// Kick off S2MM transfer
		status = XAxiDma_SimpleTransfer
		(
			&p_dma_passthrough_inst->periphs.dma_inst,
			(int)p_dma_passthrough_inst->p_rcv_buf,
			num_bytes,
			XAXIDMA_DEVICE_TO_DMA
		);
		if (status != XST_SUCCESS)
		{
			xil_printf("ERROR! Failed to kick off S2MM transfer!\n\r");
			return DMA_PASSTHROUGH_XFER_FAIL;
		}

		// Wait for transfer to complete
		while (!g_s2mm_done && !g_dma_err) { /* The processor could be doing something else here while waiting for an IRQ. */ }

		// Check DMA for errors
		if (g_dma_err)
		{
			xil_printf("ERROR! AXI DMA returned an error during the S2MM transfer.\n\r");
			return DMA_PASSTHROUGH_XFER_FAIL;
		}

		return DMA_PASSTHROUGH_SUCCESS;

}

int dma_passthrough_snd(dma_passthrough_t* p_dma_passthrough_inst)
{

	// Local variables
	int       status    = 0;
	const int num_bytes = p_dma_passthrough_inst->buf_length*p_dma_passthrough_inst->sample_size_bytes;

	// Flush cache
	#if (!DMA_PASSTHROUGH_IS_CACHE_COHERENT)
		Xil_DCacheFlushRange((int)p_dma_passthrough_inst->p_snd_buf, num_bytes);
	#endif

	// Initialize control flags which get set by ISR
	g_mm2s_done = 0;
	g_dma_err   = 0;

	// Enable interrupts
	XAxiDma_IntrEnable(&p_dma_passthrough_inst->periphs.dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);

	// Kick off MM2S transfer
	status = XAxiDma_SimpleTransfer
	(
		&p_dma_passthrough_inst->periphs.dma_inst,
		(int)p_dma_passthrough_inst->p_snd_buf,
		num_bytes,
		XAXIDMA_DMA_TO_DEVICE
	);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to kick off MM2S transfer!\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	// Wait for transfer to complete
	while (!g_mm2s_done && !g_dma_err) { /* Could do something else here while waiting for an IRQ. */ }

	// Check DMA for errors
	if (g_dma_err)
	{
		xil_printf("ERROR! AXI DMA returned an error during the MM2S transfer.\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	return DMA_PASSTHROUGH_SUCCESS;

}

