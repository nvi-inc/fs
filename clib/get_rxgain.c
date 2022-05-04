/*
 * Copyright (c) 2020-2021 NVI, Inc.
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
#include <string.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

int get_rxgain(file,rxgain)
     char file[];
     struct rxgain_ds *rxgain;
{
  FILE *fp;
  int ierr, iread, i;
  char type[11], pol0[4], pol1[4], gform[6], gtype[5], tcpol[4];
  char buff[256];
  float fdum;
  char *cptr;

  if( (fp= fopen(file,"r"))==NULL )
    return -11;

  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-100;

  lower(buff);

  /* Line 1: type, lomin, lomax */

  rxgain->lo[1]=-1;
  iread=sscanf(buff,"%10s %f %f",type,&rxgain->lo[0],&rxgain->lo[1]);
  
  if(iread < 1)
    return -111;
  else if(strcmp("range",type)==0)
    rxgain->type='r';
  else if(strcmp("fixed",type)==0)
    rxgain->type='f';
  else
    return -112;

  switch (iread) {
  case 3:
    if((rxgain->lo[0]>rxgain->lo[1])||rxgain->lo[0]<0)
      return -113;
    break;
  case 2:
    cptr=strtok(buff," \n\t");
    cptr=strtok(NULL," \n\t");
    cptr=strtok(NULL," \n\t");
    if(cptr!=NULL)
        return -116;
    if(rxgain->type=='r')
      return -117;
    if(rxgain->lo[0]<0)
      return -114;
    break;
  default:
    return -115;
    break;
  }

  
  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-200;
  
  lower(buff);

  /* Line 2: Update date: year, month day */
  
  iread=sscanf(buff,"%d %d %d",&rxgain->year,&rxgain->month,&rxgain->day);
  
  if(iread!=3)
    return -211;
  
  if(rxgain->year <0 || rxgain->month < 0 || rxgain->month > 12
     || rxgain->month == 0 && (rxgain->day <1 ||rxgain->day >366)
     || (rxgain->month > 0 && rxgain->month <13
	 && (rxgain->day < 1 || rxgain->day > 31)))
    return -212;
  
  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-300;
  
  lower(buff);

  /* Line 3: FWHM */
  
  iread=sscanf(buff,"%10s %f",type,&rxgain->fwhm.coeff);

  if(iread < 1)
    return -311;
  else if(strcmp("constant",type)==0)
    rxgain->fwhm.model='c';
  else if(strcmp("frequency",type)==0)
    rxgain->fwhm.model='f';
  else
    return -312;

  switch (iread) {
  case 1:
    cptr=strtok(buff," \n\t");
    cptr=strtok(NULL," \n\t");
    if(cptr!=NULL)
        return -314;
    if(rxgain->fwhm.model=='c')
      return -315;
    rxgain->fwhm.coeff=1.0;
    break;
  case 2:
    if(rxgain->fwhm.model=='c')
      rxgain->fwhm.coeff*=DEG2RAD;
    break;
  default:
    return -313;
    break;
  }

  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-400;

  lower(buff);

  /* Line 4: polarizations */

  iread=sscanf(buff,"%3s %3s",pol0,pol1);
 
   if(iread < 1)
     return -411;
   else if(strcmp("rcp",pol0)==0)
     rxgain->pol[0]='r';
   else if(strcmp("lcp",pol0)==0)
     rxgain->pol[0]='l';
   else
     return -412;

   if(iread==2)
     if(strcmp("rcp",pol1)==0)
       rxgain->pol[1]='r';
     else if(strcmp("lcp",pol1)==0)
       rxgain->pol[1]='l';
     else
       return -413;
   else
     rxgain->pol[1]=0;

  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-500;

  lower(buff);

  /* Line 5: DPFU */

  iread=sscanf(buff,"%f %f",&rxgain->dpfu[0],&rxgain->dpfu[1]);

  if(iread>=1) {
    if(rxgain->dpfu[0] <0.0 )
      return -511;
    if(iread>=2) {
      if(rxgain->dpfu[1] <0.0 )
	return -512;
    }
    if(iread==1 && rxgain->pol[1] !=0)
      return -513;
    else if(iread==2 && rxgain->pol[1] == 0)
      return -514;
  } else
    return -515;
  
  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-600;

  lower(buff);

  /* Line 6: gain curve */

  iread=sscanf(buff,"%5s %4s %f %f %f %f %f %f %f %f %f %f %f",
	       gform,gtype,
	       &rxgain->gain.coeff[0],
	       &rxgain->gain.coeff[1],
	       &rxgain->gain.coeff[2],
	       &rxgain->gain.coeff[3],
	       &rxgain->gain.coeff[4],
	       &rxgain->gain.coeff[5],
	       &rxgain->gain.coeff[6],
	       &rxgain->gain.coeff[7],
	       &rxgain->gain.coeff[8],
	       &rxgain->gain.coeff[9],
               &fdum);

  if(iread<3 || iread >12)
    return -611;
  
  if(strcmp("elev",gform)==0)
     rxgain->gain.form='e';
  else if(strcmp("altaz",gform)==0)
     rxgain->gain.form='a';
  else
    return -612;

  if(strcmp("poly",gtype)==0)
    rxgain->gain.type='p';
  else
    return -613;

  rxgain->gain.ncoeff=iread-2;

  cptr=strtok(buff," \n\t");
  for (i=0;i<iread;i++)
     cptr=strtok(NULL," \n\t");

  if(cptr!=NULL) {
      if(strstr(cptr,"opacity_corrected")!=NULL)
          rxgain->gain.opacity='y';
      else
          return -614;
  } else
      rxgain->gain.opacity='n';

  rxgain->tcal_ntable=0;
  rxgain->tcal_npol[0]=0;
  rxgain->tcal_npol[1]=0;

  while(1) {
    char pol;       /* polarization 'l' (lcp) or 'r' (rcp) */
    float freq;     /* tabular point for frequency MNz */
    float tcal;     /* cal temperature (degrees K) */

    ierr=find_next_noncomment(fp,buff,sizeof(buff));

    if(ierr==1)
      return -699;
    else if(ierr!=0)
      return ierr-700;

    lower(buff);

    if(strstr(buff,"end_tcal_table")!=NULL)
      if(rxgain->tcal_ntable==0)
	return -716;
      else
	goto trec;

  /* Line 7 and following, Tcal tables: pol, freq, tcal */

    iread=sscanf(buff,"%3s %f %f",
		 tcpol,&freq,&tcal);

    if(iread != 3)
      return -711;
    else if(strcmp("rcp",tcpol)==0)
      pol='r';
    else if(strcmp("lcp",tcpol)==0)
      pol='l';
    else
      return -712;
    
    if(pol==rxgain->pol[0])
      rxgain->tcal_npol[0]+=1;
    else if(rxgain->pol[1]!=0 && pol==rxgain->pol[1])
      rxgain->tcal_npol[1]+=1;
    else
      return -713;
    
    if(freq < 0.0)
      return -714;
    
    if( rxgain->tcal_ntable >= MAX_TCAL)
      return -715;
    
    rxgain->tcal[rxgain->tcal_ntable].pol=pol;
    rxgain->tcal[rxgain->tcal_ntable].freq=freq;
    rxgain->tcal[rxgain->tcal_ntable].tcal=tcal;
    rxgain->tcal_ntable++;
  }
  
  /* check for trec and spill table */
  
 trec:
  rxgain->trec[0]=0.0;
  rxgain->trec[1]=0.0;
    rxgain->spill_ntable=0;
    
    ierr=find_next_noncomment(fp,buff,sizeof(buff));

    if(ierr==1)
      return -799;
    else if(ierr!=0)
      return ierr-800;

    lower(buff);

    iread=sscanf(buff,"%f %f",&rxgain->trec[0],&rxgain->trec[1]);

    if(iread>=1) {
      if(rxgain->trec[0] <0.0 )
	return -811;
      if(iread>=2) {
	if(rxgain->trec[1] <0.0 )
	  return -812;
      }
      if(iread==1 && rxgain->pol[1] !=0)
	return -813;
      else if(iread==2 && rxgain->pol[1] == 0)
	return -814;
    } else
      return -815;
    
    while(1) {
      float el, tk;
      ierr=find_next_noncomment(fp,buff,sizeof(buff));

      if(ierr==1)
	return -899;
      else if(ierr!=0)
	return ierr-900;

      lower(buff);

      if(strstr(buff,"end_spillover_table")!=NULL)
	goto done;

  /* Line 9 and following, Tspill tables: el tk */

      iread=sscanf(buff,"%f %f",&el,&tk);

      if(iread != 2)
	return -911;
      
      if( rxgain->spill_ntable >= MAX_SPILL)
	return -912;

      rxgain->spill[rxgain->spill_ntable].el=el;
      rxgain->spill[rxgain->spill_ntable].tk=tk;
      rxgain->spill_ntable++;
    }
 done:

  /* check for trailing junk */
  
  ierr=find_next_noncomment(fp,buff,sizeof(buff));
  if(ierr==1) {
    if(0==fclose(fp))
      return 0;
    else
      return -12;
  } else if(ierr!=0)
    return ierr;
  else
    return -13;

}
