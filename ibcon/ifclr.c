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
/* 
 * this command is issued if the interface has a handshaking problem.
 * the board will be put back on line, and the interface clear signal
 * will be issued. The next hpib access should complete successfully
 *
 * HISTORY
 * 	DMV  941213	inital version of reset code
*/

#ifdef CONFIG_GPIB
#ifdef NI_DRIVER
#include <sys/ugpib.h>
#else
#include <ib.h>
#include <ibP.h>
#endif
#else
extern int ibsta;
extern int iberr;
extern int ibcnt;
#endif

#define	IBCODE		300

extern int ID_hpib;

void ifclr_(error,ipcode)

int *error;
int *ipcode;

{
	*error = 0;
	*ipcode = 0;
/*
	ibonl(ID_hpib,1);
	if ((ibsta & (ERR|TIMO)) != 0)
	{
	  *error = -(IBCODE + iberr);
	  memcpy((char *)ipcode,"IO",2);
	  return;
	}
	ibsic(ID_hpib); 
	if ((ibsta & (ERR|TIMO)) != 0)
	{
	  *error = -(IBCODE + iberr);
	  memcpy((char *)ipcode,"IS",2);
	  return;
	}
*/
}

