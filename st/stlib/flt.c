/* flt

   Computes the function and derivatives for Y coordinate.
   Parameter for iwhich = 0.
   Derivative wrt the (iwhich)th parameter otherwise.
   Copied from the FORTRAN.
 
   Called by: angle
   NRV 920311
*/ 

#include <math.h>
#include "../include/stparams.h"
#include "../include/stcom.h"

double flt(iwhich,x,y,pmodel)
int iwhich;
double x,y;
struct pmdl *pmodel;

{
  double f,cosx,cosy,sinx,siny,sinl,cosl;
 
  cosx=cos(x);
  cosy=cos(y);
  sinx=sin(x);
  siny=sin(y);
  sinl=sin(pmodel->phi);
  cosl=cos(pmodel->phi);
  f=0.0;
 
  switch (iwhich-1) {
    case -1:
      if (pmodel->ipar[ 4] != 0) f=f+pmodel->pcof[4]*cosx;
      if (pmodel->ipar[ 5] != 0) f=f+pmodel->pcof[5]*sinx;
      if (pmodel->ipar[ 6] != 0) f=f+pmodel->pcof[6];
      if (pmodel->ipar[ 7] != 0) f=f-pmodel->pcof[7]*(cosl*siny*cosx-sinl*cosy);
      if (pmodel->ipar[ 8] != 0) f=f+pmodel->pcof[8]*y;
      if (pmodel->ipar[ 9] != 0) f=f+pmodel->pcof[9]*cosy;
      if (pmodel->ipar[10] != 0) f=f+pmodel->pcof[10]*siny;
      break;
    case 4:
      if (pmodel->ipar[ 4] != 0) f=cosx;
      break;
    case 5:   
      if (pmodel->ipar[ 5] != 0) f=sinx;
      break;
    case 6:   
      if (pmodel->ipar[ 6] != 0) f=1.0;
      break;
    case 7:   
      if (pmodel->ipar[ 7] != 0) f=-(cosl*siny*cosx-sinl*cosy);
      break;
    case 8:   
      if (pmodel->ipar[ 8] != 0) f=y;
      break;
    case 9:   
      if (pmodel->ipar[ 9] != 0) f=cosy;
      break;
    case 10:   
      if (pmodel->ipar[10] != 0) f=siny;
      break;
  }
  return f;
}

