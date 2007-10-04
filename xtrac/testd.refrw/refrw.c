/* refrw

   Compute refraction correction given surface weather input.
   Copied from FORTRAN.
*/

#include <math.h>
#include <stdio.h>
#include "/usr2/fs/include/dpi.h"

#define MAX(a,b) ((a > b) ? a : b)

static double p[5]={0.458675e1, 
                    0.322009e0, 
                    0.103452e-1,
                    0.274777e-3,
                    0.157115e-5};
static double cvt = 1.33289;
static double a = 40;
static double b = 2.7;
static double c = 4.0;
static double d = 42.5;
static double e = 0.4;
static double f = 2.64;
static double g = .57295787e-4;

double refrw_(delin,tempc,humi,pres)
double delin;
float tempc,humi,pres;

{
  double el,rhumi,dewpt,x,pp,tempk,sn;
  double aphi,ang,dele,bphi,ref;
  int i;

  el = MAX(1.0,delin*RAD2DEG);
/*
  fprintf(stderr,"REFRW: el=%f\n",el);
*/

/* Compute SN (surface refractivity)
*/
  rhumi = (100.0-humi)*0.9;
  dewpt = tempc-rhumi*(-.136667+rhumi*1.33333e-3+tempc*1.5e-3);
/*
  fprintf(stderr,"REFRW: dewpt=%f\n",dewpt);
*/
  x = dewpt;
  pp = p[0];
  for (i=1; i<5; i++) {
    pp += x*p[i];
    x += dewpt;
  }
/*
  fprintf(stderr,"REFRW: tempk,cvt,pp,sn=%f %f %f %f\n",tempk,cvt,pp,sn);
*/
  tempk = tempc + 273.0;
  sn = 77.6*(pres+(4810.0*cvt*pp)/tempk)/tempk;

/* Compute refraction at elevation
*/
/*
  fprintf(stderr,"REFRW: el,b,c= %f %f %f\n",el,b,c);
*/
  aphi = a/pow((el+b),c);
  ang = (90-el)*DEG2RAD;
  dele = -d/pow((el+e),f);
  bphi = g*(sin(ang)/cos(ang)+dele);
  if (el < 0.01) bphi = g*(1.0+dele);
  return (bphi*sn-aphi)*DEG2RAD;
  
}

