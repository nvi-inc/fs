/* fln

   Fitting function for X coordinate including derivatives.
   Derivative with respect to the (iwitch)th parameter.
   Copied from the FORTRAN.

   Called by angle
   NRV 920311
*/

#include <math.h>
#include "../include/stparams.h"
#include "../include/stcom.h"

double fln(iwhich,x,y,pmodel)
int iwhich;
double x,y;
struct pmdl *pmodel;

{
  double cosx,cosy,cosl,sinx,siny,sinl,f;

  cosx = cos(x);
  cosy = cos(y);
  cosl = cos(pmodel->phi);
  sinx = sin(x);
  siny = sin(y);
  sinl = sin(pmodel->phi);
  f = 0.0;

  switch (iwhich-1) {
    case -1:
      if (pmodel->ipar[ 0] != 0) f=f+pmodel->pcof[0];
      if (pmodel->ipar[ 1] != 0) f=f-pmodel->pcof[1]*cosl*sinx/cosy;
      if (pmodel->ipar[ 2] != 0) f=f+pmodel->pcof[2]*siny/cosy;
      if (pmodel->ipar[ 3] != 0) f=f-pmodel->pcof[3]/cosy;
      if (pmodel->ipar[ 4] != 0) f=f+pmodel->pcof[4]*sinx*siny/cosy;
      if (pmodel->ipar[ 5] != 0) f=f-pmodel->pcof[5]*siny*cosx/cosy;
      if (pmodel->ipar[11] != 0) f=f+pmodel->pcof[11]*x;
      if (pmodel->ipar[12] != 0) f=f+pmodel->pcof[12]*cosx;
      if (pmodel->ipar[13] != 0) f=f+pmodel->pcof[13]*sinx;
      break;
    case 0:
      if (pmodel->ipar[0] != 0) f=1.0;
      break;
    case 1:
      if (pmodel->ipar[1] != 0) f=-cosl*sinx/cosy;
      break;
    case 2:
      if (pmodel->ipar[2] != 0) f= siny/cosy;
      break;
    case 3:
      if (pmodel->ipar[3] != 0) f=-1.0/cosy;
      break;
    case 4:   
      if (pmodel->ipar[4] != 0) f= (sinx*siny)/cosy;
      break;
    case 5:   
      if (pmodel->ipar[5] != 0) f=-(cosx*siny)/cosy;
      break;
    case 11:   
      if (pmodel->ipar[11] != 0) f=x;
      break;
    case 12:  
      if (pmodel->ipar[12] != 0) f=cosx;
      break;
    case 13:
      if (pmodel->ipar[13] != 0) f=sinx;
 } 
    return f;
}

