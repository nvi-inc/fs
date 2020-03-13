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
/* flt

   Computes the function and derivatives for Y coordinate.
   Parameter for iwhich = 0.
   Derivative wrt the (iwhich)th parameter otherwise.
   Copied from FORTRAN.
 
*/ 

#include <math.h>
#include "../include/pmodel.h"

double flt(iwhich,x,y,pmodel)
int iwhich;
double x,y;
struct pmdl *pmodel;

{
  double f,cosx,cosy,sinx,siny,sinl,cosl,cos2x,sin2x,cos8y,sin8y;
 
  cosx=cos(x);
  cosy=cos(y);
  cos2x=cos(2.0*x);
  cos8y=cos(8.0*y);
  sinx=sin(x);
  siny=sin(y);
  sin2x=sin(2.0*x);
  sin8y=sin(8.0*y);
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
      if (pmodel->ipar[14] != 0) f=f+pmodel->pcof[14]*cos2x;
      if (pmodel->ipar[15] != 0) f=f+pmodel->pcof[15]*sin2x;
      if (pmodel->ipar[18] != 0) f=f+pmodel->pcof[18]*cos8y;
      if (pmodel->ipar[19] != 0) f=f+pmodel->pcof[19]*sin8y;
      if (pmodel->ipar[20] != 0) f=f+pmodel->pcof[20]*cosx;
      if (pmodel->ipar[21] != 0) f=f+pmodel->pcof[21]*sinx;
      if (pmodel->ipar[22] != 0) f=f+pmodel->pcof[22]*cosy/siny;
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
    case 14:   
      if (pmodel->ipar[14] != 0) f=cos2x;
      break;
    case 15:   
      if (pmodel->ipar[15] != 0) f=sin2x;
      break;
    case 18:   
      if (pmodel->ipar[18] != 0) f=cos8y;
      break;
    case 19:   
      if (pmodel->ipar[19] != 0) f=sin8y;
      break;
    case 20:   
      if (pmodel->ipar[20] != 0) f=cosx;
      break;
    case 21:   
      if (pmodel->ipar[21] != 0) f=sinx;
      break;
    case 22:   
      if (pmodel->ipar[22] != 0) f=cosy/siny;
      break;
  default:
    f=0.0;
    break;
  }
  return f;
}

