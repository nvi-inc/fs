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

/* Translated from FORTRAN (w/corrections) from A. L. Berman and
 * S. T. Rockwell, JPL DSN Progress Report 42-25, 1975
 */

#include <math.h>

#define delta(ad1,ad2,bd1,bd2,zd2)  ((ad2-ad1)*exp(bd1*(zd2-bd2)))

double sbend(elr,tempdc,rhumid,presmb)
    float presmb,tempdc,rhumid;
    double elr;
{
    double a[ ]= { 0, 0.40816, 112.30 };
    double b[ ]= { 0, 0.12820, 142.88 };
    double c[ ]= { 0, 0.80000, 99.34 };
    double e[ ]= { 0, 46.625, 45.375, 4.1572, 1.4468,
        0.25391, 2.2716, -1.3465, -4.3877,
        3.1484, 4.5201, -1.8982, 0.89000 };
    double p[ ]= { 0, 760.0, 0.0 };
    double t[ ]= { 0, 273.0, 0.0 };
    double w[ ]= { 22000.0, 17.149, 4684.1, 38.450 };
    double z[ ]= { 0, 91.870, 0.0 };
    double conv = 180.0/M_PI;
    double d3,r,fp,ft,fw,u,x,sbend;
    int i;

    /* convert units */

    r=rhumid/100.;
    t[2]=tempdc+273.0;
    p[2]=(760.0/1013.3)*presmb;
    z[2]=90.0-elr*conv;

    /*  calculate corrections for pres, temp, and wetness */

    d3=1.0+delta(z[1],z[2],c[1],c[2],z[2]);
    fp=(p[2]/p[1])*(1.0-delta(p[1],p[2],a[1],a[2],z[2])/d3);
    ft=(t[1]/t[2])*(1.0-delta(t[1],t[2],b[1],b[2],z[2])/d3);
    fw=1.0+(w[0]*r*exp((w[1]*t[2]-w[2])/(t[2]-w[3]))/(t[2]*p[2]));

    /*  calculate optical refraction */

    u=(z[2]-e[1])/e[2];
    x=e[11];
    for (i=1;i<=8;i++)
        x=e[11-i]+u*x;

    /* combine factors and finish optical factor */

    sbend=ft*fp*fw*(exp(x/d3)-e[12]);

    /*  back to radians from arc seconds */

    sbend=(sbend/3600.0)/conv;
    return sbend;
}
