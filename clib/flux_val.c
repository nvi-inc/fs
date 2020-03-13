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
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/flux_ds.h"

float flux_val(name,flux,nu,epoch,fwhm,corr,size)
     char *name;
     struct flux_ds flux[MAX_FLUX];    
     double nu,epoch;
     float fwhm,*corr,*size;
{
  int i;
  float lognu,logflux,fluxv;
  float fac0,fac1,fac2,fac4,fac5,fac;

  fluxv=1.0;
  *corr=1.0;
  *size=0.0;
  
  for(i=0;i<MAX_FLUX;i++){
    if((flux+i)->name[0]==0)
      return fluxv/ *corr;
		    
    if(strcmp(name,(flux+i)->name)==0
       && nu >= (flux+i)->fmin && nu <= (flux+i)->fmax) {
      lognu=log10(nu);
      logflux=(flux+i)->fcoeff[0]+lognu*(flux+i)->fcoeff[1]
	+lognu*lognu*(flux+i)->fcoeff[2];
      fluxv=pow(10.0,logflux);
      if(strcmp("casa",(flux+i)->name)==0) {
	float dflux;
	if ((flux+i)->fcoeff[0] > 5.7){  /*entry is for discredited 1977 flux*/

	  dflux = 1 - ( (0.97 - 0.30*(lognu-3)) /100.0);
	  fluxv*= pow(10.0,(epoch-1980.0)*log10(dflux));
	} else {                         /*entry for preliminary 2006 flux*/
         dflux = 1 - ( 0.65  /100.0);
         fluxv*= pow(10.0,(epoch-2006.0)*log10(dflux));
       }
      }
      if((flux+i)->model=='g') {
	fac1=(flux+i)->mcoeff[1]/fwhm;
	fac2=(flux+i)->mcoeff[2]/fwhm;
	fac4=(flux+i)->mcoeff[4]/fwhm;
	fac5=(flux+i)->mcoeff[5]/fwhm;
	*corr=(flux+i)->mcoeff[0]*sqrt((1.0+fac1*fac1)*(1.0+fac2*fac2))
	  +(flux+i)->mcoeff[3]*sqrt((1.0+fac4*fac4)*(1.0+fac5*fac5));
      } else if((flux+i)->model=='d') {
	fac0=(flux+i)->mcoeff[0]/fwhm;
	fac=log(2.0)*fac0*fac0;
	*corr=fac/(1.-exp(-fac));
      } else if((flux+i)->model=='2') {
	fac0=((flux+i)->mcoeff[0]*.5)/fwhm;
	*corr=exp(4.0*log(2.0)*fac0*fac0);
      } else
	*corr=1.0;
      *size=(flux+i)->size;
    }
  }

  return fluxv/ *corr;
}

