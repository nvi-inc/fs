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
/* fln

   Fitting function for X coordinate including derivatives.
   Derivative with respect to the (iwitch)th parameter.
   Copied from FORTRAN.

*/

#include <math.h>
#include "../include/pmodel.h"

double fln(iwhich,x,y,pmodel)
int iwhich;
double x,y;
struct pmdl *pmodel;

{
  double cosx,cosy,cosl,sinx,siny,sinl,f,cos2x,sin2x;

  cosx = cos(x);
  cosy = cos(y);
  cosl = cos(pmodel->phi);
  sinx = sin(x);
  siny = sin(y);
  cos2x = cos(2.*x);
  sin2x = sin(2.*x);
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
      if (pmodel->ipar[16] != 0) f=f+pmodel->pcof[16]*cos2x;
      if (pmodel->ipar[17] != 0) f=f+pmodel->pcof[17]*sin2x;
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
      break;
    case 16:
      if (pmodel->ipar[16] != 0) f=cos2x;
      break;
    case 17:
      if (pmodel->ipar[17] != 0) f=sin2x;
      break;
  default:
    f=0.0;
    break;
 } 
    return f;
}

