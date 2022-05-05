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
/* status bits */

#define S_ERR	 (1 << 15)	/* error */
#define S_TIMO	 (1 << 14)	/* time out */
#define S_END	 (1 << 13)	/* END or EOS on rd */
#define S_SRQI	 (1 << 12)	/* SRQ* asserted */
#define S_CMPL	 (1 <<  8)	/* completed */
#define S_LOK	 (1 <<  7)	/* locked-out */
#define S_REM	 (1 <<  6)	/* in remote */
#define S_CIC	 (1 <<  5)	/* controller-in-charge */
#define S_ATN	 (1 <<  4)	/* ATN* asserted */
#define S_TACS	 (1 <<  3)	/* talker */
#define S_LACS	 (1 <<  2)	/* listener */

/* GPIB errors */

#define S_NGER     0            /* no error */
#define S_ECIC     1		/* not CIC */
#define S_ENOL     2		/* no listeners */
#define S_EADR     3		/* CIC and not addressed to talk or listen */
#define S_EARG     4		/* invalid argument */
#define S_ESAC     5		/* no system controller capability */
#define S_EABO     6		/* I/O cancaled */
#define S_ECAP    11		/* capability disabled */
#define S_EBUS    14		/* bus error */
#define S_ECMD    17            /* error in command */

/* serial errors */

#define S_NSER     0            /* no error */
#define S_EPAR     1		/* parity error  */
#define S_EORN     2		/* over-run on serial input*/
#define S_EOFL     3		/* serial buffer overflow */
#define S_EFRM     4		/* incorrect stop bits or BREAK */

int sib(int hpib, char *buffer, int len_in, int max_out, int timeout,
	int itime, int centisec[2]);
