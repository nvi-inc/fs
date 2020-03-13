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
#include <stdio.h> 
#include <sys/types.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

get_gain_par(ifchain,center,fwhm,dpfu,gain,tcal)
     int ifchain;
     double center;
     float *fwhm, *tcal, *dpfu, *gain;
{
  int i, ir, it[6], ifirst, ilast, pol;
  double az,el, arg, lo;

  *fwhm=0.0;
  *dpfu=0.0;
  *tcal=0.0;
  if(gain!=NULL)
    *gain=0.0;

  if(1 <= ifchain && ifchain <= MAX_LO) {
    lo=shm_addr->lo.lo[ifchain-1];
    pol=shm_addr->lo.pol[ifchain-1];
  } else if (MAX_LO+1 <= ifchain && ifchain <= MAX_LO+6) {
    lo=shm_addr->user_device.lo[ifchain-(1+MAX_LO)];
    pol=shm_addr->user_device.pol[ifchain-(1+MAX_LO)];
  } else
    return;

  ir=-1;
  for(i=0;i<MAX_RXGAIN;i++) {
    if(shm_addr->rxgain[i].type=='f'
       && ((fabs(lo-shm_addr->rxgain[i].lo[0])
	    < 0.001)
	   ||(shm_addr->rxgain[i].lo[1] > 0.0
	      && fabs(lo-shm_addr->rxgain[i].lo[1])
	      < 0.001))
       ) {
      ir=i;
    }
  }
  if(ir==-1)
    for(i=0;i<MAX_RXGAIN;i++) {
      if(shm_addr->rxgain[i].type=='r'
	 && lo>shm_addr->rxgain[i].lo[0]-0.001
	 && lo<shm_addr->rxgain[i].lo[1]+0.001) {
	ir=i;
      }
    }

  if(ir==-1)
    return;
  
  if(shm_addr->rxgain[ir].fwhm.model=='c')
    *fwhm=shm_addr->rxgain[ir].fwhm.coeff;
  else if(shm_addr->rxgain[ir].fwhm.model=='f'
	  && center*1e6*shm_addr->diaman > 1e-12) {
    *fwhm=1.22*299792458.0e0/(center*1e6*shm_addr->diaman);
    *fwhm=(*fwhm)*shm_addr->rxgain[ir].fwhm.coeff;
  }
  
  if(gain != NULL) {
    rte_time(it,it+5);
    cnvrt2(1,shm_addr->radat,shm_addr->decdat,&az,&el,it,0.0,shm_addr->alat,
	   shm_addr->wlong);
    
    arg=el*RAD2DEG;
    if(shm_addr->rxgain[ir].gain.form=='a')
      arg=90.0-arg;
    
    *gain=0.0;
    for(i=shm_addr->rxgain[ir].gain.ncoeff-1;i>-1;i--) {
      *gain=*gain*arg+shm_addr->rxgain[ir].gain.coeff[i];
    }
  }


  switch(pol) {
  case 1:
    /* ifchain is r */
    if(shm_addr->rxgain[ir].pol[0]=='r') {
      *dpfu=shm_addr->rxgain[ir].dpfu[0];
    } else if(shm_addr->rxgain[ir].pol[1]=='r') {
      *dpfu=shm_addr->rxgain[ir].dpfu[1];
    }
    ifirst=-1;
    ilast=-1;
    for(i=0;i<shm_addr->rxgain[ir].tcal_ntable;i++)
      if(shm_addr->rxgain[ir].tcal[i].pol=='r' &&
	 shm_addr->rxgain[ir].tcal[i].freq <= center)
	ifirst=i;
      else if(shm_addr->rxgain[ir].tcal[i].pol=='r' &&
	      center < shm_addr->rxgain[ir].tcal[i].freq) {
	ilast=i;
	goto interpr;
      }
  interpr:
    if(ifirst==-1 && ilast != -1)
      *tcal=shm_addr->rxgain[ir].tcal[ilast].tcal;
    else if(ifirst!=-1 && ilast ==-1)
      *tcal=shm_addr->rxgain[ir].tcal[ifirst].tcal;
    else if(ifirst!=-1 && ilast!=-1)
      *tcal=shm_addr->rxgain[ir].tcal[ifirst].tcal+
	(center-shm_addr->rxgain[ir].tcal[ifirst].freq)*
	(shm_addr->rxgain[ir].tcal[ilast].tcal-
	 shm_addr->rxgain[ir].tcal[ifirst].tcal)/
	(shm_addr->rxgain[ir].tcal[ilast].freq-
	 shm_addr->rxgain[ir].tcal[ifirst].freq);
    break;
  case 2:
    if(shm_addr->rxgain[ir].pol[0]=='l') {
      *dpfu=shm_addr->rxgain[ir].dpfu[0];
    } else if(shm_addr->rxgain[ir].pol[1]=='l') {
      *dpfu=shm_addr->rxgain[ir].dpfu[1];
    }
    ifirst=-1;
    ilast=-1;
    for(i=0;i<shm_addr->rxgain[ir].tcal_ntable;i++)
      if(shm_addr->rxgain[ir].tcal[i].pol=='l' &&
	 shm_addr->rxgain[ir].tcal[i].freq <= center)
	ifirst=i;
      else if(shm_addr->rxgain[ir].tcal[i].pol=='l' &&
	      center < shm_addr->rxgain[ir].tcal[i].freq) {
	ilast=i;
	goto interpl;
      }
  interpl:
    if(ifirst==-1 && ilast != -1)
      *tcal=shm_addr->rxgain[ir].tcal[ilast].tcal;
    else if(ifirst!=-1 && ilast ==-1)
      *tcal=shm_addr->rxgain[ir].tcal[ifirst].tcal;
    else if(ifirst!=-1 && ilast!=-1)
      *tcal=shm_addr->rxgain[ir].tcal[ifirst].tcal+
	(center-shm_addr->rxgain[ir].tcal[ifirst].freq)*
	(shm_addr->rxgain[ir].tcal[ilast].tcal-
	 shm_addr->rxgain[ir].tcal[ifirst].tcal)/
	(shm_addr->rxgain[ir].tcal[ilast].freq-
	 shm_addr->rxgain[ir].tcal[ifirst].freq);
    break;
  default:
    break;
  }
}
