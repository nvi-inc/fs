/* equn2

   Equation of equinoxes to about 0.1 ms of time
*/

#include <math.h>
#include <stdio.h>
#include "../include/dpi.h"

void equn2(it,eqeq)
int it[6];
double *eqeq;
{
  double julianhi, julianlo;
  double tdb,oblm,oblt,psi,eps;

  julianhi=julda(it[4],it[5]-1900)+ 2440000.0 - 1.0;
  julianlo = ((double)it[0]*.01 + (double)it[1] + (double)it[2]*60.0 
	      + (double)it[3]*3600.0)/86400.0+0.5;
/*
  printf(" julianhi %lf julianlo %lf\n",julianhi,julianlo);
*/
  tdb=julianhi+julianlo;

  earthtilt (tdb, &oblm,&oblt,eqeq,&psi,&eps);

  *eqeq*=DPI/(double) 43200.0;
}



