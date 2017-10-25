// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This is the header file for lpn.c
//
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include "matrix.h"
#include "platform.h"

#define DATA_CORRECT       0
#define DATA_INCORRECT    -1

void convert_integer_to_bool (int* input_array, bool* output_array);

int index_intersect (bool* index1, bool*  index2, bool* output_index, int NUM_RO, int selected_ro);

int skip_row_sel (bool* selected_index, bool* index_before_sel, int sel_num);

void select_matrix(int* a, int * selected_matrix, bool* index, int num_selection, int num_ro);

void convert_bool_to_integer (bool* input_array, int* output_array);

void clean_index_gen (bool* index);
