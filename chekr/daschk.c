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
/* das chekr routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void daschk_(imod,icherr,ierr)
int *imod;
int icherr[];
int *ierr;
{
  int ind;
  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i;

  ind=(*imod-1)/2;

  if (!shm_addr->das[ind].ifp[0].initialised &&
      !shm_addr->das[ind].ifp[1].initialised)
	return;

  /* All requests are directed to common DAS dataset address */
  lcl.type = DS_MON;
  strcpy(lcl.mnem,shm_addr->das[ind].ds_mnem);

  /* Queue required dataset monitor requests */
  for (i=0; i<5; i++) ip[i]=0;
  /* Supply Voltages +5V (IFP1,2) -5.2V, +9V, -9V, +15V, -15V */
  for (i=8; i<15; i++) {
	lcl.cmd = i;
	dscon_snd(&lcl,ip);
  }
  
  /* Transmit to DAS via AT_DS dataset driver */
  nsem_take("fsctl",0);
  run_dscon(ip);
  nsem_put("fsctl",0);

  /* Interpret response data */
  for (i=0; i<7; i++) {
	if ((*ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[ind].ifp[0].initialised)
		  shm_addr->das[ind].ifp[0].initialised = -1;
		if (shm_addr->das[ind].ifp[1].initialised)
		  shm_addr->das[ind].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		if (*ierr>0) *ierr = -720;
		return;
	}
	switch (i) {
	   case 0:
		shm_addr->das[ind].voltage_p5V_ifp1 =
			((float)(lclm.data.value - 2048)) / 4096 * 25.0;
		break;
	   case 1:
		shm_addr->das[ind].voltage_p5V_ifp2 =
			((float)(lclm.data.value - 2048)) / 4096 * 25.0;
		break;
	   case 2:
		shm_addr->das[ind].voltage_m5d2V =
			((float)(lclm.data.value - 2048)) / 4096 * 26.0;
		break;
	   case 3:
		shm_addr->das[ind].voltage_p9V =
			((float)(lclm.data.value - 2048)) / 4096 * 45.0;
		break;
	   case 4:
		shm_addr->das[ind].voltage_m9V =
			((float)(lclm.data.value - 2048)) / 4096 * 45.0;
		break;
	   case 5:
		shm_addr->das[ind].voltage_p15V =
			((float)(lclm.data.value - 2048)) / 4096 * 75.0;
		break;
	   case 6:
		shm_addr->das[ind].voltage_m15V =
			((float)(lclm.data.value - 2048)) / 4096 * 75.0;
		break;
	}
  }

  /* Check Voltages and Temps */
  icherr[0]=(fabs(shm_addr->das[ind].voltage_p5V_ifp1-5.)/5.*100>=DAS_V_TOLER);
  icherr[1]=(fabs(shm_addr->das[ind].voltage_p5V_ifp2-5.)/5.*100>=DAS_V_TOLER);
  icherr[2]=(fabs(shm_addr->das[ind].voltage_m5d2V+5.2)/5.2*100>=DAS_V_TOLER);
  icherr[3]=(fabs(shm_addr->das[ind].voltage_p9V-9.0)/9.0*100>=DAS_V_TOLER);
  icherr[4]=(fabs(shm_addr->das[ind].voltage_m9V+9.0)/9.0*100>= DAS_V_TOLER);
  icherr[5]=(fabs(shm_addr->das[ind].voltage_p15V-15.0)/15.0*100>=DAS_V_TOLER);
  icherr[6]=(fabs(shm_addr->das[ind].voltage_m15V+15.0)/15.0*100>=DAS_V_TOLER);

  return;
}
