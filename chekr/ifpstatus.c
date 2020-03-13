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
/* chekr LBA ifp status routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void ifpstatus_(lwho,n_ifp)
char *lwho;
int  *n_ifp;
{
  unsigned char chan, n_das;
  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i, ierr;

  n_das = (*n_ifp-1) / 2;
  chan = (*n_ifp-1) % 2;

  if (n_das!=shm_addr->m_das || !shm_addr->das[n_das].ifp[chan].initialised)
	 return;

  /* All requests are directed to common DAS dataset address */
  lcl.type = DS_MON;
  strcpy(lcl.mnem,shm_addr->das[n_das].ds_mnem);

  /* Queue required dataset monitor requests */
  for (i=0; i<5; i++) ip[i]=0;

  /* Fine Tuner Thresholds and Threshold Counters */
  for (i=8; i<12; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	dscon_snd(&lcl,ip);
  }
  /* Fine Tuner Flags */
  lcl.cmd = 160 + (chan * 32) + 14;
  dscon_snd(&lcl,ip);
  /* Band Splitter Thresholds, Thres, Offset & Level Counters and Flags */
  for (i=24; i<31; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	dscon_snd(&lcl,ip);
  }
  
  /* Transmit to DAS via DSCON dataset driver */
  nsem_take("fsctl",0);
  run_dscon(ip);
  nsem_put("fsctl");

  /* Interpret response data */
  for (i=6; i<18; i++) {
	if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return;
	}
	switch (i) {
	   case 6:
		shm_addr->das[n_das].ifp[chan].ft.usb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 7:
		shm_addr->das[n_das].ifp[chan].ft.lsb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 8:
		shm_addr->das[n_das].ifp[chan].ft.usb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 9:
		shm_addr->das[n_das].ifp[chan].ft.lsb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 10:
		shm_addr->das[n_das].ifp[chan].processing =
			(lclm.data.value & 0x01);
		break;
	   case 11:
		shm_addr->das[n_das].ifp[chan].bs.usb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 12:
		shm_addr->das[n_das].ifp[chan].bs.lsb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 13:
		shm_addr->das[n_das].ifp[chan].bs.usb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 14:
		shm_addr->das[n_das].ifp[chan].bs.lsb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 15:
		shm_addr->das[n_das].ifp[chan].bs.offset.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 16:
		shm_addr->das[n_das].ifp[chan].bs.level.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 17:
		shm_addr->das[n_das].ifp[chan].clk_err =
			((lclm.data.value & 0x10) == 0x10);
		shm_addr->das[n_das].ifp[chan].blank =
			((lclm.data.value & 0x08) == 0x08);
		shm_addr->das[n_das].ifp[chan].processing &=
			(lclm.data.value & 0x01);
		break;
	}
  }
  return;
}
