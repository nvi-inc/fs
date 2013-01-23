/* mk5dbbcd.c make list of bbc detectors needed for DBBC rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5dbbcd(itpis)
int itpis[MAX_DBBC_BBC*2];
{
  int vc,i;

  if(shm_addr->mk5b_mode.mask.state.known == 0)
    return;

  if(shm_addr->dbbcform.mode==0 || shm_addr->dbbcform.mode==2 ) { /*(w)astro */
    for (i=0;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=i/2;
	if(-1 < vc && vc <8)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
    for (i=16;i<32;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-16)/2;
	if(-1 < vc && vc <8)
	  itpis[vc]=1;  /* lsb */
      }
    }
  } else if(shm_addr->dbbcform.mode==4 ) { /* lba */
    for (i=0;i<4;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=i/2;
	if(-1 < vc && vc <8)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
    for (i=4;i<8;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=(i-4)/2+4;
	if(-1 < vc && vc <8)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
    for (i=9;i<12;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=(i-8)/2+2;
	if(-1 < vc && vc <8)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
    for (i=12;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)){
	vc=(i-12)/2+6;
	if(-1 < vc && vc <8)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
    for (i=16;i<20;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-16)/2;
	if(-1 < vc && vc <8)
	  itpis[vc]=1;  /* lsb */
      }
    }
    for (i=20;i<24;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-20)/2+4;
	if(-1 < vc && vc <8)
	  itpis[vc]=1;  /* lsb */
      }
    }
    for (i=24;i<28;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-24)/2+2;
	if(-1 < vc && vc <8)
	  itpis[vc]=1;  /* lsb */
      }
    }
    for (i=28;i<32;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-28)/2+6;
	if(-1 < vc && vc <8)
	  itpis[vc]=1;  /* lsb */
      }
    }
  } else if(shm_addr->dbbcform.mode == 1 ) { /*geo */
    for (i=0;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=i/2;
	if(-1 < vc && vc <14)
	  itpis[vc+MAX_DBBC_BBC]=1;  /* usb */
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
    for (i=20;i<32;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-20)/2+8;
	if(-1 < vc && vc <14)
	  itpis[vc+MAX_DBBC_BBC]=1; /* usb */
      }
    }
  }
}

