/* rollform_util.c mark IV rollform parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int rollform_dec(lcl,count,ptr)
struct form4_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, arg_key(), code, i, j, irhd, ihd;
    static int istk, itrk;

    ierr=0;

    if(ptr == NULL) {
      if(*count < 3)
	ierr = -304;
      *count=-1;
      return ierr;
    }

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,&istk,1,FALSE);
      if(ierr == 0 && (istk < 1 || istk > 2))
	ierr = -200;
      break;
    case 2:
      ierr=arg_int(ptr,&ihd,1,FALSE);
      if(ierr == 0 && (ihd < 2 || ihd > 33))
	ierr = -200;
      itrk=(istk-1)*32+ihd-2;
      for (i=0;i<16;i++)
	lcl->roll[i][itrk]=-2;
      break;
    default:
      if(*count > 18) {
	ierr = -301;
	goto done;
      }
      ierr=arg_int(ptr,&irhd,1,FALSE);
      if(ierr == 0 && (irhd != -1 && (irhd < 2 || irhd > 33))) {
	ierr = -203;
	goto done;
      } else if(ierr==-100)
	ierr =arg_int(ptr,&irhd,-2,TRUE);
      if(ierr!=0) {
	ierr-=3;
	goto done;
      } else if(irhd != -2) {
	lcl->roll[*count-3][itrk]=irhd;
	
	if(lcl->start_map == -1 ||*count-3 < lcl->start_map )
	  lcl->start_map=*count-3;
     
	if(lcl->end_map == -1 ||*count-3 > lcl->end_map )
	  lcl->end_map=*count-3;
      }
    }

   if(ierr!=0)
     ierr-=*count;
 done:
   if(*count>0)
     (*count)++;

   return ierr;
}

void rollform_enc(output,count,lcl)
char *output;
int *count;
struct form4_cmd *lcl;
{
    int i, j, itrk, istk, ihd, ind, lst;
    static int ilast;

    if(*count==1)
      ilast = -1;

    if (*count > 64 || ilast >= 63) {
      *count= -1;
      return;
    }

    output=output+strlen(output);
    
    for(i=ilast+1;i<64;i++){
      if(i<16)
	ind=i*2;
      else if(i<32)
	ind=1+(i-16)*2;
      else if(i<48)
	ind=32+(i-32)*2;
      else
	ind=33+(i-48)*2;
      lst=-1;
      for(j=15;j>-1;j--)
	if(lcl->roll[j][ind]!=-2) {
	  lst=j;
	  break;
	}
      if (lst!=-1){
	ilast=i;
	if (ind<32) {
	  istk=1;
	  ihd=2+ind;
	} else {
	  istk=2;
	  ihd=ind-30;
	}
	sprintf(output,"%1d,%2d",istk,ihd);
	for (j=0;j<lst+1;j++) {
	  if(lcl->roll[j][ind] != -2)
	    sprintf(output+strlen(output),",%2d",lcl->roll[j][ind]);
	  else
	    sprintf(output+strlen(output),",  ");
	}
	goto done;
      }
    }

    if(ilast==-1) {
      if(*count==1) {
	strcpy(output,"DISABLED");
	ilast=63;
      }
    } else
      *count=-1;

 done:
    if(*count>0)
      *count++;

    return;
}
