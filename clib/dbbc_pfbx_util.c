/* dbbc_pfbx buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"

void dbbc_pfbx_mon(output,count,lclm)
char *output;
int *count;
struct dbbc_pfbx_mon *lclm;
{
  int ind, ivalue, whole, fract;
  
  output=output+strlen(output);

  switch (*count) {
  case 16:
    if(lclm->overflow)
      strcpy(output,"OVERFLOW");
    break;
  default:
    if(*count>16)
      *count=-1;
    else
      sprintf(output,"%d.%03d",lclm->counts[*count-1]/1000,
	      lclm->counts[*count-1]%1000);
  }
  
  if(*count>0) *count++;
  return;
}

int dbbc_2_dbbc_pfbx(lclm,buff)
struct dbbc_pfbx_mon *lclm;
char *buff;
{
  int k;
  char *sptr;
  double dvalue;

  lclm->overflow=NULL!=strstr(buff,"OVERFLOW"); /* overflowed */

  sptr=strtok(buff,"=");
  if(NULL==sptr)
    return -1;

  for(k=0;k<15;k++) {
    sptr=strtok(NULL," ,");
    if(NULL==sptr || 1!=sscanf(sptr,"%lf",&dvalue))
      return -2;
    lclm->counts[k]=dvalue*1000+.5;
  }

  return 0;
}
