// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This file contains some functions that are required for matrix operations.
//
#include "matrix.h"

#define DATA_CORRECT 0
#define DATA_INCORRECT -1

void reorder_matrix (int* square_matrix)
{
	int i, j;
	int temp;
	for (i = 0; i < 128; i++)
	{
		for (j = 0; j < 2; j++)
		{
			temp = square_matrix[4*i+j];
			square_matrix[4*i+j] = square_matrix[4*i+3-j];
			square_matrix[4*i+3-j] = temp;
		}
	}
}

void generate_random_matrix(int * a, int matrix_size) {
	int temp1, temp2, temp3, temp4;
	int i;

	for (i = 0; i < matrix_size; i++) {
		temp1 = rand() % 256;
		temp2 = rand() % 256;
		temp3 = rand() % 256;
		temp4 = rand() % 256;
		a[i] = (temp1 << 24) ^ (temp2 << 16) ^ (temp3 << 8) ^ temp4;
	}
}

void xor_row(int * a, int* b) //a = a ^ b
{
	int i;
	for (i = 0; i < 4; i++) {
		a[i] = a[i] ^ b[i];
	}
}

void swap_row(int* a, int*b) // a = b; b = a
{
	int i;
	int temp;
	for (i = 0; i < 4; i++) {
		temp = a[i];
		a[i] = b[i];
		b[i] = temp;
	}
}

int find_inverse_matrix(int* a, int* result_matrix) {
	//Create a new matrix based on the selected index
	int i, j, flag, k;

	//create an identity matrix
	//clear it
	for (i = 0; i < 512; i++) {
		result_matrix[i] = 0;
	}
	//add elements
	for (j = 0; j < 128; j++) {
		i = (j / 32) + j * 4;
		result_matrix[i] = (0x80000000 >> (j % 32));
	}

	for (j = 0; j < 128; j++) {
		i = (j / 32) +  j* 4;
		if ((a[i] & (0x80000000 >> (j % 32))) != 0) {
			for (k = (i % 4); k < 512; k = k + 4) {
				if (((a[k] & (0x80000000 >> (j % 32))) != 0)
						&& (k != i)) {
					xor_row(&a[(k / 4) * 4], &a[(i / 4) * 4]);
					xor_row(&result_matrix[(k / 4) * 4],
							&result_matrix[(i / 4) * 4]);
				}
			}
		} else {
			flag = 1;
			for (k = i ; k < 512; k = k + 4) {
				if ((a[k] & (0x80000000 >> (j % 32))) != 0) {
					flag = 0;
					swap_row(&a[(k / 4) * 4],
							&a[(i / 4) * 4]);
					swap_row(&result_matrix[(k / 4) * 4],
							&result_matrix[(i / 4) * 4]);
					break;
				}
			}
			if (flag == 1) {
				return DATA_INCORRECT;
			}
			for (k = (i % 4); k < 512; k = k + 4) {
				if (((a[k] & (0x80000000 >> (j % 32))) != 0)
						&& (k != i)) {
					xor_row(&a[(k / 4) * 4], &a[(i / 4) * 4]);
					xor_row(&result_matrix[(k / 4) * 4],
							&result_matrix[(i / 4) * 4]);
				}
			}
		}
	}
	return DATA_CORRECT;
}
