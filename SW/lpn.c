// Copyright [2017] [Secure Computation Lab at UConn]. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
//
// Author: Chenglu Jin at <chenglu.jin@uconn.edu>
//
// This file contains some functions that are required for constructing or 
// solving LPN problem.

#include "lpn.h"

int skip_row_sel (bool* selected_index, bool* index_before_sel, int sel_num)
{
    int i, j;
    int cnt = 0;
    for (i = 0; i < 450; i++)
    {
        if (index_before_sel[i] == 1)
        {
            cnt++;
        }
        selected_index[i] = 0;
    }
    if (cnt < sel_num)
    {
        return DATA_INCORRECT;
    }
    else
    {
        i = 0;
        j = rand() % (cnt - sel_num);
        for (; j < 450 ; j++)
        {
            if (index_before_sel[j] == 1)
            {
                selected_index[j] = 1;
                i++;
                if (i == sel_num)
                    break;
            }
        }
        return DATA_CORRECT;
    }
}


int index_intersect (bool* index1, bool*  index2, bool* output_index, int NUM_RO, int selected_ro)
{
    int i,j;

    j = 0;
    for (i = 0; i < NUM_RO; i ++)
    {
        output_index[i] = 0;
    }

    for ( i =0; i < NUM_RO; i++)
    {
        if (index1[i] & index2[i])
        {
            output_index[i] = 1;
            j++;
        }
    }
    if (j >=  selected_ro)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

int skip_select_e (bool * e_vector, bool* selected_e_vector, bool*  index , bool* selected_index, int NUM_RO, int selected_ro, int skip_num)
{
    int i,j;
    int skip_cnt = 0;

    for(i = 0; i < NUM_RO; i++)
    {
        selected_index[i] = 0;
    }

    j = 0;
    for ( i =0; i < NUM_RO; i++)
    {
        if (index[i] == 1)
        {
            skip_cnt++;
            if (skip_cnt > skip_num)
            {
                selected_e_vector[j] = e_vector[i];
                j++;
                selected_index[i] = 1;
            }
        }
        if (j ==  selected_ro)
        {
            return DATA_CORRECT;
        }
    }
    return DATA_INCORRECT;
}

void select_matrix(int* a, int * selected_matrix, bool* index, int num_selection, int num_ro)
{
	int i, j;
	int cnt = 0;
	for (i = 0; i < num_ro; i = i + 1) {
		if (index[i] == 1) 
        {
			for (j = 0; j < 4; j++) {
				selected_matrix[cnt *4 + j] = a[i*4 + j];
			}
			cnt ++;
			if (cnt == num_selection)
            {
				break;
            }
		}
	}
}

void clean_index_gen (bool* index)
{
    int i, j;
    j = 0;
    int flag = 0;
    for (i = 0; i < 450; i++)
    {
        if (flag == 0 && index[i] == 1)
        {
            j++;
        }
        if (flag == 1)
        {
            index[i] = 0;
        }
        if (j == 256)
        {
            flag = 1;
        }
    }
}

//specific for converting 450 bits in 512 bit long message to 450 bool variables.
void convert_integer_to_bool (int* input_array, bool* output_array)
{
    int i, j, k, bound_j, bound_k;
    int temp_int;
    bool temp;
    for (i = 0; i < 4; i++)
    {
        if (i == 3)
            bound_j = 0;
        else
            bound_j = -1;
        for (j = 3; j > bound_j ; j--)
        {
            if (i == 3 && j == 1)
                bound_k = 2;
            else
                bound_k = 32;
            for (k = 0; k < bound_k; k++)
            {
                temp_int = input_array[4*i+j];
                temp_int = temp_int & (0x80000000>>k);
                temp_int = temp_int >> (31-k);
                temp = (bool) temp_int;
                output_array[128*i+(3-j)*32+k] = temp;
            }
        }
    }
    return;
}

//specific for converting 450 bool variables to 450 bits in 512 bit long message .
void convert_bool_to_integer (bool* input_array, int* output_array)
{
    int i, j, bound_j;
    int temp_int;

    for (i = 0; i <15; i++)
    {
        if (i == 14)
            bound_j = 2;
        else
            bound_j = 32;

        temp_int = 0;
        for (j = 0; j <bound_j; j++)
        {
            temp_int = ((temp_int << 1) + input_array[i*32+j]);
        }
        if (i == 14)
            temp_int = temp_int << 30;

        if (i == 0)
            output_array[3] = temp_int;
        else if (i == 1)
            output_array[2] = temp_int;
        else if (i == 2)
            output_array[1] = temp_int;
        else if (i == 3)
            output_array[0] = temp_int;
        else if (i == 4)
            output_array[7] = temp_int;
        else if (i == 5)
            output_array[6] = temp_int;
        else if (i == 6)
            output_array[5] = temp_int;
        else if (i == 7)
            output_array[4] = temp_int;
        else if (i == 8)
            output_array[11] = temp_int;
        else if (i == 9)
            output_array[10] = temp_int;
        else if (i == 10)
            output_array[9] = temp_int;
        else if (i == 11)
            output_array[8] = temp_int;
        else if (i == 12)
            output_array[15] = temp_int;
        else if (i == 13)
            output_array[14] = temp_int;
        else if (i == 14)
            output_array[13] = temp_int;
    }
    output_array[12] = 0;

    return;
}
