/* k4 recpatch parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

char *code2rp(), *code2rpk41(), *code2rpk42();
int rp2code(), rp2codek41(), rp2codek42();

int k4recpatch_dec(lcl,count,ptr)
struct k4recpatch_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), code, i;
    static int itrk;

    ierr=0;
      
    if(ptr == NULL) {
      if(*count%2 == 0)
        ierr = -300;
      *count=-1;
      return ierr;
    }

    switch (*count%2) {
    case 1:
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr !=0 || (ierr == 0 && (itrk < 1 || itrk > 16)))
	ierr = -201;
      break;
    case 0:
      if(shm_addr->equip.rack_type==K41 || shm_addr->equip.rack_type==K41U)
	code=rp2codek41(ptr);
      else if(shm_addr->equip.rack_type==K42 ||
	      shm_addr->equip.rack_type==K42A ||
	      shm_addr->equip.rack_type==K42B ||
	      shm_addr->equip.rack_type==K42BU ||
	      shm_addr->equip.rack_type==K42C)
	code=rp2codek42(ptr);
      else
	code=rp2code(ptr);
      if(code == 0) {
	if(shm_addr->equip.rack_type==K41 || shm_addr->equip.rack_type==K41U)
	  ierr=-202;
	else if(shm_addr->equip.rack_type==K42 ||
		shm_addr->equip.rack_type==K42A ||
		shm_addr->equip.rack_type==K42B ||
		shm_addr->equip.rack_type==K42BU ||
		shm_addr->equip.rack_type==K42C)
	  ierr=-203;
	else
	  ierr=-204;
      } else
	lcl->ports[itrk-1]=code;
      break;
    default:
      *count=-1;
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void k4recpatch_enc(output,count,lcl)
char *output;
int *count;
struct k4recpatch_cmd *lcl;
{
    int i;
    static char *type;
    static int itrk, ilast;

    if(*count==1)
      ilast = -1;

    if (ilast >= 17) {
      *count= -1;
      return;
    }

    output=output+strlen(output);
    
    for(i=ilast+1;i<16;i++){
      if (lcl->ports[i]!=0){
	ilast=i;
	if(shm_addr->equip.rack_type==K41 || shm_addr->equip.rack_type==K41)
	  sprintf(output,"%2d,%3s",i+1,code2rpk41(lcl->ports[i]));
	else if(shm_addr->equip.rack_type==K42 ||
	      shm_addr->equip.rack_type==K42A ||
	      shm_addr->equip.rack_type==K42B ||
	      shm_addr->equip.rack_type==K42BU ||
	      shm_addr->equip.rack_type==K42C)
	  sprintf(output,"%2d,%3s",i+1,code2rpk42(lcl->ports[i]));
	else
	  sprintf(output,"%2d,%3s",i+1,code2rp(lcl->ports[i]));
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
