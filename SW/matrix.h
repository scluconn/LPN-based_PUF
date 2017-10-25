// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is the header file for matrix.c
//
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

void generate_random_matrix(int * , int);

int find_inverse_matrix(int* , int* );

void matrix_multiplication(int * a, bool * b, bool *c);

void xor_vector (bool * a, bool *b, bool* c, int size);

void reorder_matrix (int* square_matrix);
