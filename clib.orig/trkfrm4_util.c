/* trkfrm4_util.c mark IV trkfrm parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

char *code2bsfo();
int bsfo2code();

int trkfrm4_dec(lcl,count,ptr)
struct form4_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), code, i;
    static int itrk;

    ierr=0;

    if(ptr == NULL) {
      if(*count%2 == 0)
	ierr = -304;
      *count=-1;
      return ierr;
    }

    switch (*count%2) {
    case 1:
      if(lcl->last == 1) {
	for(i=0;i<64;i++)
	  lcl->codes[i]=-1;
	lcl->last=0;
      }
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr == 0 && (itrk < 2 || (itrk > 33 && itrk < 102) || itrk > 133))
	ierr = -200;
      break;
    case 0:
      code=bsfo2code(ptr);
      if(code < -1)
	ierr=-299+code;
      else {
	if(itrk < 34)
	  lcl->codes[itrk-2]=code;
	else
	  lcl->codes[itrk-102+32]=code;
      }
      break;
    default:
      *count=-1;
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void trkfrm4_enc(output,count,lcl)
char *output;
int *count;
struct form4_cmd *lcl;
{
    int i;
    static int itrk, ilast;

    if(*count==1)
      ilast = -1;

    if (ilast >= 64) {
      *count= -1;
      return;
    }

    output=output+strlen(output);
    
    for(i=ilast+1;i<64;i++){
      if (i<32)
	 itrk=2+i;
      else
	itrk=100+i-30;
      if (lcl->codes[i]!=-1){
	ilast=i;
	sprintf(output,"%3d,%6s",itrk,code2bsfo(lcl->codes[i]));
	goto done;
      }
    }
    if(ilast==-1)
      strcpy(output,"DISABLED");

    *count=-1;
    return;

  done:
   if(*count>0)
     *count++;

   return;
}
