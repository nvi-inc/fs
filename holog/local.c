#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

double refrw();

int local(lonpos,latpos,axis,ierr)
     double *lonpos,*latpos;
     char *axis;
     int *ierr;
{
  int it[6];
  double az,el,x,y;

  if(strncmp(shm_addr->lsorna,"azel",4)==0) {
    az=shm_addr->ra50;
    el=shm_addr->dec50;
  } else if(strncmp(shm_addr->lsorna,"xy",2)==0) {
    cnvrt2(4,shm_addr->ra50,shm_addr->dec50,&az,&el,it,0.0,shm_addr->alat,
	   shm_addr->wlong);
  } else {
    rte_time(it,it+5);
    cnvrt2(1,shm_addr->radat,shm_addr->decdat,&az,&el,it,0.0,shm_addr->alat,
	   shm_addr->wlong);
  }
  az+=shm_addr->AZOFF;
  el+=shm_addr->ELOFF;
  el+=DEG2RAD*refrw(el,20.0,50.0,950.0);
    
  cnvrt2(5,az,el,&x,&y,it,0.0,shm_addr->alat,shm_addr->wlong);

  if(strcmp(axis,"azel")==0) {
    cnvrt2(4,x,y,lonpos,latpos,it,0.0,shm_addr->alat,shm_addr->wlong);
  } else if(strcmp(axis,"hadc")==0) {
    cnvrt2(6,x,y,lonpos,latpos,it,0.0,shm_addr->alat,shm_addr->wlong);
  } else if(strcmp(axis,"xyns")==0) {
    *lonpos=x;
    *latpos=y;
  } else {
    *ierr=-40;
    return -1;
  }
  return 0;
}
