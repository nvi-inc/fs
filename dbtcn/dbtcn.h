/*
 * Copyright (c) 2020, 2022, 2023 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

int open_mcast(char mcast_addr[], int mcast_port, char mcast_if[], int *error_no);
int get_if_addr(char *name, char **address, int *error_no);
ssize_t read_mcast(int sock, char buf[], size_t buf_size, int it[6],
        int centisec[6], int data_valid);
void calc_ts( dbbc3_ddc_multicast_t *t, struct dbbc3_tsys_cycle *cycle,
        int cont_cal);
void update_shm( dbbc3_ddc_multicast_t *t, struct dbbc3_tsys_cycle *cycle,
        int it[6], int centisec[6]);
void log_mcast(dbbc3_ddc_multicast_t *t, struct dbbc3_tsys_cycle *cycle,
        int cont_cal, int *count, int samples, int logging, int tsys_request);
void version_check( dbbc3_ddc_multicast_t *t);
void perform_swaps( dbbc3_ddc_multicast_t *t);
void smooth_ts( struct dbbc3_tsys_cycle *cycle, int reset, int samples,
        int filter, float if_param[MAX_DBBC3_IF]);
void time_check( struct dbbc3_tsys_cycle *cycle);
