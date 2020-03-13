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
/* header file for ds SNAP command data structure etc.*/

#define DS_MON	0	/* AT_DS monitor request - see ds_cmd.type */
#define DS_CMD	1	/* AT_DS command request */

struct ds_cmd {	/* Standard ds SNAP command structure */
    unsigned short type;	/* command type : 0=MON, 1=CMD */
    char mnem[3];		/* dataset mnemonic: 2 chars */
    unsigned short cmd;		/* dataset command: 0..511 */
    unsigned short data;	/* data for AT_DS CMD request */
};

#pragma pack(1)
struct ds_mon {	/* Standard ds SNAP response structure */
    unsigned short resp;		/* response type ACK/BEL/NAK/NUL */
    union ds_ret {
        unsigned short value;		/* monitor response data */
        struct regs {
            unsigned char error;	/* error register response */
            unsigned char warning;	/* warning register response */
        } reg;
    } data;
};
#pragma pack()
