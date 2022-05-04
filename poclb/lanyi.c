/*
 * Copyright (c) 2021 NVI, Inc.
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

double lanyi(double elr, double tempdc, double rhumid, double presmb)
{
  /* Lanyi refraction
   *
   * From G. Lanyi, 24 March 1989, JPL IOM 335.3-89-026, with corrections
   *
   * input:
   *   elr    - elevation angle, unrefracted, radians
   *   tempc  - temperature, degrees C
   *   rhumid - relative humidty, 0-100%
   *   presmb - pressure, millibars
   *
   * output:
   *   return value - refraction correction (add to elr), radians
   *
   * 0.5 mdeg error above 6 degrees
   * not meant to be used below 4 degrees
   * +3 mdeg error at 4 degrees
   * factor of 3 too large at 0 degrees
   *
   * result agrees with Table 2 to 5+ decimal places
   */

  static const double R = 6.378e6;
  double RH0,p0,T0, E;
  double hd, hw;
  double T0c, p0w, p0d;
  double X0d, X0w, X0;
  double Zdry, Zwet;
  double Gd, Gw, alphaE;
  double F, deltaE;

  p0=presmb;
  T0=273.16+tempdc;
  RH0=rhumid/100.0;
  E = elr;

  hd = 0.86 * 8.567e3 * T0/292; /* 1e3 was missing, it has to be meters */
  hw = 2.4e3;

  T0c = T0 - 273.16;
  p0w = 6.11*RH0*exp( 17.27*T0c/(237.3+T0c) );
  p0d = p0 - p0w;

  X0d = 77.6e-6 * p0d/T0;
  X0w = ( 377.6e-3/T0 + 64.8e-6 )*p0w/T0;
  X0 = X0d + X0w;

  Zdry = 0.22768e-2*p0d;    /* e-2 is missing in original memo, per CSJ --
                               it has to be ~2.3 meters at ~1000 mb */
  Zwet =  X0w*hw;

  Gd = 1/sqrt( 1 - pow(cos(E)/(1 + hd/R),2.0) );
  Gw = 1/sqrt( 1 - pow(cos(E)/(1 + hw/R),2.0) );
  alphaE = ( Zdry*pow(Gd,3.0) + Zwet*pow(Gw,3.0) )*sin(E)/R;

  F=1/( 1 + 0.5*( sqrt( 1 + 2.0*( X0 - alphaE )/pow(tan(E),2.0) ) - 1 ) );
  deltaE = F*( X0 - alphaE )/tan(E);


  return deltaE;
}
