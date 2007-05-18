#include <stdio.h> 
#include <sys/types.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

get_gain_par2(rxgain,maxrx,lo,center,diam,el,pol,fwhm,dpfu,gain,tcal,
	      trec,tspill)
     struct rxgain_ds rxgain[];
     int maxrx;
     double lo,center,diam,el;
     char pol;
     float *fwhm, *tcal, *dpfu, *gain, *trec, *tspill;
{
  int i, ir, ifirst, ilast;
  double arg;

  *fwhm=0.0;
  *dpfu=0.0;
  *tcal=0.0;
  *gain=0.0;
  *trec=0.0;
  *tspill=0.0;

  ir=-1;
  for(i=0;i<maxrx;i++) {
    if(rxgain[i].type=='f'
       && ((fabs(lo-rxgain[i].lo[0]) < 0.001)
	   ||(rxgain[i].lo[1] > 0.0
	      && fabs(lo-rxgain[i].lo[1]) < 0.001))
       ) {
      ir=i;
    }
  }
  if(ir==-1)
    for(i=0;i<maxrx;i++) {
      if(rxgain[i].type=='r'
	 && lo>rxgain[i].lo[0]-0.001
	 && lo<rxgain[i].lo[1]+0.001) {
	ir=i;
      }
    }
  if(ir==-1)
    return;
  
  if(rxgain[ir].fwhm.model=='c')
    *fwhm=rxgain[ir].fwhm.coeff;
  else if(rxgain[ir].fwhm.model=='f'
	  && center*1e6*diam > 1e-12) {
    *fwhm=1.22*299792458.0e0/(center*1e6*diam);
    *fwhm=(*fwhm)*rxgain[ir].fwhm.coeff;
  }
  
  arg=el;
  if(rxgain[ir].gain.form=='a')
    arg=90.0-arg;
    
  *gain=0.0;
  for(i=rxgain[ir].gain.ncoeff-1;i>-1;i--) {
    *gain=*gain*arg+rxgain[ir].gain.coeff[i];
  }
  switch(pol) {
  case 'r':
    /* ifchain is r */
    if(rxgain[ir].pol[0]=='r') {
      *dpfu=rxgain[ir].dpfu[0];
    } else if(rxgain[ir].pol[1]=='r') {
      *dpfu=rxgain[ir].dpfu[1];
    }
    ifirst=-1;
    ilast=-1;
    for(i=0;i<rxgain[ir].tcal_ntable;i++)
      if(rxgain[ir].tcal[i].pol=='r' &&
	 rxgain[ir].tcal[i].freq <= center)
	ifirst=i;
      else if(rxgain[ir].tcal[i].pol=='r' &&
	      center < rxgain[ir].tcal[i].freq) {
	ilast=i;
	goto interpr;
      }
  interpr:
    if(ifirst==-1 && ilast != -1)
      *tcal=rxgain[ir].tcal[ilast].tcal;
    else if(ifirst!=-1 && ilast ==-1)
      *tcal=rxgain[ir].tcal[ifirst].tcal;
    else if(ifirst!=-1 && ilast!=-1)
      *tcal=rxgain[ir].tcal[ifirst].tcal+
	(center-rxgain[ir].tcal[ifirst].freq)*
	(rxgain[ir].tcal[ilast].tcal-
	 rxgain[ir].tcal[ifirst].tcal)/
	(rxgain[ir].tcal[ilast].freq-
	 rxgain[ir].tcal[ifirst].freq);
    break;
  case 'l':
    if(rxgain[ir].pol[0]=='l') {
      *dpfu=rxgain[ir].dpfu[0];
    } else if(rxgain[ir].pol[1]=='l') {
      *dpfu=rxgain[ir].dpfu[1];
    }
    ifirst=-1;
    ilast=-1;
    for(i=0;i<rxgain[ir].tcal_ntable;i++)
      if(rxgain[ir].tcal[i].pol=='l' &&
	 rxgain[ir].tcal[i].freq <= center)
	ifirst=i;
      else if(rxgain[ir].tcal[i].pol=='l' &&
	      center < rxgain[ir].tcal[i].freq) {
	ilast=i;
	goto interpl;
      }
  interpl:
    if(ifirst==-1 && ilast != -1)
      *tcal=rxgain[ir].tcal[ilast].tcal;
    else if(ifirst!=-1 && ilast ==-1)
      *tcal=rxgain[ir].tcal[ifirst].tcal;
    else if(ifirst!=-1 && ilast!=-1)
      *tcal=rxgain[ir].tcal[ifirst].tcal+
	(center-rxgain[ir].tcal[ifirst].freq)*
	(rxgain[ir].tcal[ilast].tcal-
	 rxgain[ir].tcal[ifirst].tcal)/
	(rxgain[ir].tcal[ilast].freq-
	 rxgain[ir].tcal[ifirst].freq);
    break;
  default:
    break;
  }
  *trec=rxgain[ir].trec;

  /* iterpolate spillover */

  ifirst=-1;
  ilast=-1;
  for(i=0;i<rxgain[ir].spill_ntable;i++)
    if( rxgain[ir].spill[i].el <= el)
	ifirst=i;
      else if( el < rxgain[ir].spill[i].el) {
	ilast=i;
	goto interp_spill;
      }
  interp_spill:
  if(ifirst==-1 && ilast == -1)
    *tspill=0.0;
  else if(ifirst==-1 && ilast != -1)
    *tspill=rxgain[ir].spill[ilast].tk;
  else if(ifirst!=-1 && ilast ==-1)
    *tspill=rxgain[ir].spill[ifirst].tk;
  else if(ifirst!=-1 && ilast!=-1)
    *tspill=rxgain[ir].spill[ifirst].tk+
      (el-rxgain[ir].spill[ifirst].el)*
      (rxgain[ir].spill[ilast].tk-
       rxgain[ir].spill[ifirst].tk)/
      (rxgain[ir].spill[ilast].el-
       rxgain[ir].spill[ifirst].el);

}
