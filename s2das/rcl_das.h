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
#ifndef _RCL_DAS
#define _RCL_DAS

/* S2 DAS RCL command codes */
#define BBC_SET                   1
#define BBC_READ                  2
#define IFX_SET                   3
#define IFX_READ                  4
#define ENCODE_SET                5
#define ENCODE_READ               6
#define AGC_SET                   7
#define AGC_READ                  8
#define POWERMON_READ             9
#define TIME_SET                 12
#define TIME_READ                13
#define MODE_BW_SET              14
#define MODE_SET                 15
#define MODE_READ                16
#define FS_READ                  19
#define FS_START                 20
#define FS_STOP                  21
#define FS_HALT                  22
#define FS_STATE                 23
#define FS_LOAD                  24
#define FS_SAVE                  25
#define FS_INIT                  26
#define SOURCE_SET               27
#define SOURCE_READ              28
#define DELAY_SET                29
#define DELAY_READ               30
#define DELAYM_READ              31
#define WVFDELAYM_READ           32
#define GPSDELAYM_READ           33
#define TONEDET_SET              35   
#define TONEDET_READ             36
#define TONEDETM_READ            37
#define TPI_READ                 40
#define STATION_INFO_READ        60
#define CONSOLECMD               70
#define STATUS                   80
#define STATUS_DETAIL            81
#define STATUS_DECODE            82
#define ERROR_DECODE             83
#define DIAG                     90
#define IDENT                    97
#define PING                     98
#define VERSION                  99

/* S2 DAS response codes */
#define RESP_ERR                100
#define RESP_BBC                102
#define RESP_IFX                104
#define RESP_ENCODE             106
#define RESP_AGC                108
#define RESP_POWERMON           109
#define RESP_TIME               113
#define RESP_MODE               116
#define RESP_FS                 119
#define RESP_SOURCE             128
#define RESP_DELAY              130
#define RESP_TONEDET            136
#define RESP_TONEDETM           137
#define RESP_TPI                140
#define RESP_STATION_INFO       160
#define RESP_STATUS             180
#define RESP_STATUS_DETAIL      181
#define RESP_STATUS_DECODE      182
#define RESP_ERROR_DECODE       183
#define RESP_IDENT              197
#define RESP_VERSION            199

/* Sideband code */
#define USB  0
#define LSB  1

/* Returned code */
#define RESP_INV_CODE          -100
#define RESP_INV_BBC           -101
#define RESP_INV_STATE         -102

/* Timeout for IFADJUST */
#define RCL_TIMEOUT_IF         5000
#define RCL_TIMEOUT_FS         5000
#endif





