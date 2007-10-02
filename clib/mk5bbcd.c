/* mk5bbcd.c make list of bbc detectors needed for VLBA5 rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5bbcd(itpis)
int itpis[28];
{
  int vc,i;

  if(shm_addr->mk5b_mode.mask.state.known == 0)
    return;

  if(shm_addr->vsi4.config.value == 0 ) { /*vlba */
    for (i=0;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=i/2;
	if(-1 < vc && vc <14)
	  itpis[vc+14]=1; /* usb */
      }
    }
    for (i=16;i<32;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-16)/2;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;  /* lsb */
      }
    }
  } else if(shm_addr->vsi4.config.value == 1 ) { /*geo */
    for (i=0;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=i/2;
	if(-1 < vc && vc <14)
	  itpis[vc+14]=1;  /* usb */
      }
    }
    for (i=16;i<18;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=0;
	if(-1 < vc && vc <14)
	  itpis[vc]=1; /*lsb*/
      }
    }
    for (i=18;i<20;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=7;
	if(-1 < vc && vc <14)
	  itpis[vc]=1; /*lsb*/
      }
    }
    for (i=20;i<31;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-20)/2+8;
	if(-1 < vc && vc <14)
	  itpis[vc+14]=1; /* usb */
      }
    }
  }
}

