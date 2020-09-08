/*
 * Copyright (c) 2020 NVI, Inc.
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

// setup_ids.c
void setup_ids( );

// skd_util.c
#include <sys/ipc.h>
int skd_get( key_t key, int size);
void skd_ini( key_t key);
void skd_att( key_t key);
void skd_boss_inject_w( int *iclass, char *buffer, int length);
void skd_run( char name[5], char w, int ip[5]);
void skd_run_p( char name[5], char w, int ip[5], int *run_index);
void skd_run_arg( char name[5], char w, int ip[5], char *arg);
int skd_run_to( char name[5], char w, int ip[5], unsigned to);
void skd_par( int ip[5]);
void skd_arg_buff( char *buff, int len);
void skd_arg( int n, char *buff, int len);
int skd_chk( char name[5], int ip[5]);
int skd_end_inject_snap( char name[5], int ip[5]);
void skd_wait( char name[5], int ip[5], unsigned centisec);
void skd_end( int ip[5]);
void skd_clr( char name[5]);
int skd_rel( );
void skd_set_return_name(char *name);
int skd_clr_ret(int ip[5]);
int dad_pid( );

// str_util.c
void uns2str( char *output, unsigned uvalue, int width);
void flt2str( char *output, float fvalue, int width, int deci);
void dble2str( char *output, double fvalue, int width, int deci);
void int2str( char *output, int ivalue, int width, int zorb);
