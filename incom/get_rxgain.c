#include <stdio.h>
#include <string.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/fs_types.h"

int get_rxgain(file,rxgain)
     char file[];
     struct rxgain_ds *rxgain;
{
  FILE *fp;
  int ierr, iread, i;
  char cdum;
  char type[11], pol0[4], pol1[4], gform[6], gtype[5], tcpol[4];
  char buff[81];

  if( (fp= fopen(file,"r"))==NULL )
    return -1;

  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-100;

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
    if(rxgain->lo[0]<0)
      return -114;
    break;
  default:
    return -115;
    break;
  }
  
  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-200;
  
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
  
  /* Line 3: FWHM */
  
  iread=sscanf(buff,"%10s %f %f",type,&rxgain->fwhm.coeff);

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
    rxgain->fwhm.coeff=1.0;
    break;
  case 2:
    rxgain->fwhm.coeff*=DEG2RAD;
    break;
  default:
    return -313;
    break;
  }

  if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0)
    return ierr-400;

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

  /* Line 6: gain curve */

  iread=sscanf(buff,"%5s %4s %f %f %f %f %f %f %f %f %f %f %1c",
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
	       &cdum);

  if(iread<3 || iread >12)
    return -611;
  
  if(strcmp("ELEV",gform)==0)
     rxgain->gain.form='e';
  else if(strcmp("ALTAZ",gform)==0)
     rxgain->gain.form='a';
  else
    return -612;

  if(strcmp("POLY",gtype)==0)
    rxgain->gain.type='p';
  else
    return -613;

  rxgain->gain.ncoeff=iread-2;

  rxgain->tcal_ntable==0;
  rxgain->tcal_npol[0]=0;
  rxgain->tcal_npol[1]=0;

  for(i=0;i<MAX_TCAL;i++) {
    if((ierr=find_next_noncomment(fp,buff,sizeof(buff)))!=0) {
      if(ierr==-1) {
	if(rxgain->tcal_ntable==0)
	  return -2;
	else
	  return 0;
      } else if(ierr!=0)
	return ierr-700;
    }

  /* Line 7 and following, Tcal tables: pol, freq, tcal */

    iread=sscanf(buff,"%3s %f %f",
		 tcpol,
		 &rxgain->tcal[i].freq,
		 &rxgain->tcal[i].tcal);

   if(iread != 3)
     return -711;
   else if(strcmp("rcp",tcpol)==0)
     rxgain->tcal[i].pol='r';
   else if(strcmp("lcp",tcpol)==0)
     rxgain->tcal[i].pol='l';
   else
     return -712;

   if(rxgain->tcal[i].pol==rxgain->pol[0])
     rxgain->tcal_npol[0]+=1;
   else if(rxgain->pol[1]!=0
	   && rxgain->tcal[i].pol==rxgain->pol[1])
     rxgain->tcal_npol[1]+=1;
   else
     return -713;

    if(rxgain->tcal[i].freq < 0.0)
      return -714;

    /* negative gain means no gain diode
     *
     *  if(rxgain->tcal[i].tcal < 0.0)
     *    return -715;
     */

    rxgain->tcal_ntable=i+1;
  }

  /* check for traling junk */
  
  ierr=find_next_noncomment(fp,buff,sizeof(buff));
  switch(ierr) {
  case -1:
    return 0;
    break;
  default:
    return ierr-10;
    break;
  }
}
