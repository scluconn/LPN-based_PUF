// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Contact: Chenglu Jin at <chenglu.jin@uconn.edu>
// 
// This is the main file of the software computation in LPN-based PUF FPGA
// implementation. 
//
// Includes
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xuartps_hw.h"
#include "xil_cache.h"
#include "adc.h"
#include "dac.h"
#include "matrix.h"
#include "lpn.h"
#include <stdbool.h>

// Defines
#define SAMPLES_PER_FRAME  16
#define DATA_CORRECT       0
#define DATA_INCORRECT    -1
#define matrix_size       1800
#define selected_matrix_size 512
#define NUM_RO            450
#define selected_ro       128

// Main entry point
int main()
{
	int     status;
	// Local variables
	adc_t*  p_adc_inst;
	dac_t*  p_dac_inst;
    bool combined_index[NUM_RO];
    bool   index_gen[NUM_RO];
    bool   index_ver[NUM_RO];
	int     rcv_buf[SAMPLES_PER_FRAME];
	int 	test_send_buf[SAMPLES_PER_FRAME];
    int  b_vector[SAMPLES_PER_FRAME];
    int hash_vector[SAMPLES_PER_FRAME];
	int matrix_a[matrix_size];
	int selected_matrix[selected_matrix_size];
	int inv_matrix[selected_matrix_size];
    int i;
    int j;
    int k;
	int     ii = 0;

	// Setup UART and caches
    init_platform();
    xil_printf("\fHello World!\n\r");

    // Create ADC object
    p_adc_inst = adc_create
    (
    	XPAR_GPIO_0_DEVICE_ID,
    	XPAR_AXIDMA_0_DEVICE_ID,
    	XPAR_PS7_SCUGIC_0_DEVICE_ID,
    	XPAR_FABRIC_DATAPATH_AXI_DMA_1_S2MM_INTROUT_INTR,
    	XPAR_FABRIC_DATAPATH_AXI_DMA_1_MM2S_INTROUT_INTR,
    	sizeof(int)
    );
    if (p_adc_inst == NULL)
    {
    	xil_printf("ERROR! Failed to create ADC instance.\n\r");
    	return DATA_INCORRECT;
    }

    // Create DAC object
    p_dac_inst = dac_create
    (
    	XPAR_GPIO_0_DEVICE_ID,
    	XPAR_AXIDMA_0_DEVICE_ID,
    	XPAR_PS7_SCUGIC_0_DEVICE_ID,
    	XPAR_FABRIC_DATAPATH_AXI_DMA_1_S2MM_INTROUT_INTR,
    	XPAR_FABRIC_DATAPATH_AXI_DMA_1_MM2S_INTROUT_INTR,
    	sizeof(int)
    );
    if (p_dac_inst == NULL)
    {
    	xil_printf("ERROR! Failed to create DAC instance.\n\r");
    	return DATA_INCORRECT;
    }

    // Set the desired parameters for the ADC/DAC objects
     adc_set_bytes_per_sample(p_adc_inst, sizeof(int));
     dac_set_bytes_per_sample(p_dac_inst, sizeof(int));
     adc_set_samples_per_frame(p_adc_inst, SAMPLES_PER_FRAME);
     dac_set_samples_per_frame(p_dac_inst, SAMPLES_PER_FRAME);

 	// Make sure the buffers are clear before we populate it (generally don't need to do this, but for proving the DMA working, we do it anyway)
 	memset(rcv_buf, 0, SAMPLES_PER_FRAME*sizeof(int));
 	memset(test_send_buf, 0, SAMPLES_PER_FRAME*sizeof(int));

	// Enable/initialize and dac
	adc_enable(p_adc_inst);
	dac_enable(p_dac_inst);

    //Generate Random Matrix A with size of 128 columns and 450 rows, each row is stored in four words. 
	generate_random_matrix(matrix_a, matrix_size);
    
	// Process data
	for (ii = 0; 1; ii++)
	{
		xil_printf("**********************************************************************\n\r");
		xil_printf("Run %d started.\n\r", ii);
		xil_printf("**********************************************************************\n\r");


		xil_printf("CRP Geneneration.\n\r");

		// Get new frame from ADC
		status = adc_get_frame(p_adc_inst, rcv_buf);
		if (status != ADC_SUCCESS)
		{
			xil_printf("ERROR! Failed to get a new frame of data from the POK.\n\r");
			return DATA_INCORRECT;
		}
//		xil_printf("Got index\n\r");

        convert_integer_to_bool (rcv_buf, index_gen);


        clean_index_gen (index_gen);


		for (i = 0; i < 113; i++)
		{
			// Send processed data frame out to DAC
			status = dac_send_frame(p_dac_inst, &matrix_a[i*16]);
			if (status != DAC_SUCCESS)
			{
				xil_printf("ERROR! Failed to send the processed data frame out to the DAC.\n\r");
				return DATA_INCORRECT;
			}
		}

//		xil_printf("Sent A\n\r");


		// Get new frame from ADC
		status = adc_get_frame(p_adc_inst, hash_vector);
		if (status != ADC_SUCCESS)
		{
			xil_printf("ERROR! Failed to get a new frame of data from the HASH.\n\r");
			return DATA_INCORRECT;
		}

//		xil_printf("Got Hash\n\r");



		status = dac_send_frame(p_dac_inst, test_send_buf);


		// Get new frame from ADC
		status = adc_get_frame(p_adc_inst, b_vector);


		if (status != ADC_SUCCESS)
		{
			xil_printf("ERROR! Failed to get a new frame of data from the B.\n\r");
			return DATA_INCORRECT;
		}

//		xil_printf("Got B\n\r");



		xil_printf("h1:");

		for (i = 0; i < 8; i++)
			{
				xil_printf("%x", hash_vector[i]);
			}

		xil_printf("\n\rh0:");

		for (i = 8; i < 16; i++)
			{
				xil_printf("%x", hash_vector[i]);
			}

		xil_printf("\n\rB:");
		for (j = 0; j < 16; j++)
		{
			xil_printf("%x", b_vector[j]);
		}


		xil_printf("\n\r**********************************************************************\n\r");
		xil_printf("Gen of Run %d is completed. Press any key to conduct Ver.\n\r", ii);
		xil_printf("**********************************************************************\n\r");
		XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);

        //VERIFICATION
		xil_printf("CRP Verification.\n\r");

		status = adc_get_frame(p_adc_inst, rcv_buf);
		if (status != ADC_SUCCESS)
		{
			xil_printf("ERROR! Failed to get a new frame of data from the POK.\n\r");
			return DATA_INCORRECT;
		}
//		xil_printf("Got index\n\r");

        convert_integer_to_bool (rcv_buf, index_ver);

        index_intersect (index_ver,  index_gen, combined_index, 450, 128);

        status = DATA_INCORRECT;
        while (status)
        {
            status = skip_row_sel (index_ver, combined_index, 128);
            if (status == DATA_INCORRECT)
            {
                return DATA_INCORRECT;
            }
            else
            {
                select_matrix( matrix_a, selected_matrix, index_ver, 128, 450);

                reorder_matrix(selected_matrix);
                status = find_inverse_matrix(selected_matrix, inv_matrix);
            }
        }
//		xil_printf("Inverse A\n\r");
		reorder_matrix(inv_matrix);

        convert_bool_to_integer (index_ver, test_send_buf);

        //send index
        status = dac_send_frame(p_dac_inst, test_send_buf);
		if (status != DAC_SUCCESS)
		{
			xil_printf("ERROR! Failed to send the index out to the DAC.\n\r");
			return DATA_INCORRECT;
		}

        //send B
        status = dac_send_frame(p_dac_inst, b_vector);
		if (status != DAC_SUCCESS)
		{
			xil_printf("ERROR! Failed to send B out to the DAC.\n\r");
			return DATA_INCORRECT;
		}
//		xil_printf("Sent B\n\r");

		//inverse matrix
		for (i = 0; i < 32; i++)
		{
	        status = dac_send_frame(p_dac_inst, &inv_matrix[i*16]);
			if (status != DAC_SUCCESS)
			{
				xil_printf("ERROR! Failed to send the inverse matrix out to the DAC.\n\r");
				return DATA_INCORRECT;
			}
		}

//		xil_printf("Sent inverse matrix\n\r");


		for (i = 0; i < 113; i++)
		{
	        status = dac_send_frame(p_dac_inst, &matrix_a[i*16]);


	        if (status != DAC_SUCCESS)
			{
				xil_printf("ERROR! Failed to send matrix a out to the DAC.\n\r");
				return DATA_INCORRECT;
			}

		}

//		xil_printf("Sent matrix A\n\r");

		for (k = 0; k < 8; k++)
		{
			test_send_buf[k] = hash_vector[k];
			test_send_buf[k+8] = 0;
		}

	    status = dac_send_frame(p_dac_inst, test_send_buf);
		if (status != DAC_SUCCESS)
		{
			xil_printf("ERROR! Failed to send hash out to the DAC.\n\r");
			return DATA_INCORRECT;
		}
//		xil_printf("Sent h1\n\r");

		status = adc_get_frame(p_adc_inst, rcv_buf);
		if (status != ADC_SUCCESS)
		{
			xil_printf("ERROR! Failed to get a new frame of data from the POK.\n\r");
			return DATA_INCORRECT;
		}
//		xil_printf("Got hash\n\r");


		xil_printf("ref response: ");
		for (k = 8; k < 16; k++)
		{
			xil_printf("%x", hash_vector[k]);
		}

		xil_printf("\n\rnew response: ");

		for (k = 8; k < 16; k++)
		{
			xil_printf("%x", rcv_buf[k]);
		}

		xil_printf("\n\r");

		xil_printf("\n\r**********************************************************************\n\r");
		xil_printf("Ver of Run %d is completed. Press any key to conduct the next run.\n\r", ii);
		xil_printf("Run %d is completed. Press any key to conduct the next run.\n\r", ii);
		xil_printf("**********************************************************************\n\r");
		XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);
	}

	adc_destroy(p_adc_inst);
	dac_destroy(p_dac_inst);

    return DATA_CORRECT;
}
