/* vlba enable command parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
                                              /* parameter keywords */
static char *key_group[ ]={ "g0" ,"g1" ,"g2" ,"g3" };
static char *key_group2[ ]={ "g0" ,"g1" ,"g2" ,"g3" ,"g4" ,"g5" ,"g6" ,"g7"};
static char *key_d[ ]=     {"d1" ,"d2" ,"d3" ,"d4" ,"d5" ,"d6" ,"d7" ,
                            "d8" ,"d9" ,"d10","d11","d12","d13","d14",
                            "d15","d16","d17","d18","d19","d20","d21",
                            "d22","d23","d24","d25","d26","d27","d28"};

static char *key_d2[ ]=      {"d1" ,"d2" ,"d3" ,"d4" ,"d5" ,"d6" ,"d7" ,
                            "d8" ,"d9" ,"d10","d11","d12","d13","d14",
                            "d15","d16","d17","d18","d19","d20","d21",
                            "d22","d23","d24","d25","d26","d27","d28",
                             "d101" ,"d102" ,"d103" ,"d104" ,"d105" ,"d106" ,
			     "d107" ,
			     "d108" ,"d109" ,"d110","d111","d112","d113",
			     "d114",
                            "d115","d116","d117","d118","d119","d120","d121",
                            "d122","d123","d124","d125","d126","d127","d128"};

                                     /* number of elements in keyword arrays */
#define NKEY_GROUP  sizeof(key_group )/sizeof( char *)
#define NKEY_GROUP2 sizeof(key_group2)/sizeof( char *)
#define NKEY_D      sizeof(key_d     )/sizeof( char *)
#define NKEY_D2     sizeof(key_d2    )/sizeof( char *)

int venable_dec(lcl,count,ptr,indx)
struct venable_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(), ivalue;
    int odd, even;

    ierr=0;
    if(*count == 1) {
       lcl->group[0]=0;
       lcl->group[1]=0;
       lcl->group[2]=0;
       lcl->group[3]=0;
       lcl->group[4]=0;
       lcl->group[5]=0;
       lcl->group[6]=0;
       lcl->group[7]=0;
       lcl->general=1;
    };
    if(ptr != NULL) {
      if(shm_addr->equip.drive[indx]==VLBA&&
	 shm_addr->equip.drive_type[indx]!=VLBAB) {
        ierr=arg_key(ptr,key_group,NKEY_GROUP,&ivalue,0,FALSE); /* g1-4 */
        if( ierr==-100) {
           ierr=0;
           goto End;
        } else if( ierr==-200) {
           ierr=arg_key(ptr,key_d    ,NKEY_D    ,&ivalue,0,FALSE); /* mode d */
           if(ierr==0) ivalue=(ivalue/14)*2+(ivalue%2);   /* group index */
        }
        if(ierr==0 && lcl->group[ivalue]!=1)
           lcl->group[ivalue]=1; /* okay */
        else if (ierr==0)
           ierr=-300;
      } else {
        ierr=arg_key(ptr,key_group2,NKEY_GROUP2,&ivalue,0,FALSE); /* g1-4 */
        if( ierr==-100) {
           ierr=0;
           goto End;
        } else if( ierr==-200) {
           ierr=arg_key(ptr,key_d2  ,NKEY_D2   ,&ivalue,0,FALSE); /* mode d */
           if(ierr==0)
	     if(ivalue < NKEY_D) {
	       ivalue=(ivalue/14)*2+(ivalue%2);   /* group index */
	     } else {
	       ivalue-=NKEY_D;
	       ivalue=4+(ivalue/14)*2+(ivalue%2);   /* group index */
	     }
        }
        if(ierr==0 && lcl->group[ivalue]!=1)
           lcl->group[ivalue]=1; /* okay */
        else if (ierr==0)
           ierr=-300;
      }
    } else {
      if (shm_addr->wrhd_fs[indx] != 0) { /* fix odd of evenness of groups */
	odd = lcl->group[1] || lcl->group[3];
	even = lcl->group[0] || lcl->group[2];
	if (shm_addr->wrhd_fs[indx] == 1 && even && !odd) {
	  lcl->group[1]=lcl->group[0];
	  lcl->group[3]=lcl->group[2];
	  lcl->group[0]=lcl->group[2]=0;
	} else if (shm_addr->wrhd_fs[indx] == 2 && odd && !even) {
	  lcl->group[0]=lcl->group[1];
	  lcl->group[2]=lcl->group[3];
	  lcl->group[1]=lcl->group[3]=0;
	}
      }
      if((shm_addr->equip.drive[indx]==VLBA4 ||
	  (shm_addr->equip.drive[indx]==VLBA &&
	   shm_addr->equip.drive_type[indx]==VLBAB)) &&
	 shm_addr->rdhd_fs[indx] != 0) { /* fix odd of evenness of groups */
	odd = lcl->group[5] || lcl->group[7];
	even = lcl->group[4] || lcl->group[6];
	if (shm_addr->rdhd_fs[indx] == 1 && even && !odd) {
	  lcl->group[5]=lcl->group[4];
	  lcl->group[7]=lcl->group[6];
	  lcl->group[4]=lcl->group[6]=0;
	} else if (shm_addr->rdhd_fs[indx] == 2 && odd && !even) {
	  lcl->group[4]=lcl->group[5];
	  lcl->group[6]=lcl->group[7];
	  lcl->group[5]=lcl->group[7]=0;
	}
      }
      *count=-1;
    }

End:
   if(*count>0) (*count)++;
   return ierr;
}

void venable_enc(output,count,lcl,indx)
char *output;
int *count,indx;
struct venable_cmd *lcl;
{
    int i, icount,iend;

    output=output+strlen(output);

    icount=0;
    iend=4;
    if(shm_addr->equip.drive[indx]==VLBA4 ||
	 (shm_addr->equip.drive[indx]==VLBA &&
	  shm_addr->equip.drive_type[indx]==VLBAB))
      iend=8;
    for (i=0;i<iend;i++) {
      if(lcl->group[ i] == 1 && lcl->general==1) icount++;
      if(icount == *count) {
        strcpy(output,key_group2[i]);       /* found the *count-th group */
        break;
      }
    }
    if(icount<*count)
      if(*count == 1) 
        strcpy(output,"disabled");
      else
        *count=-1;           /* not that many groups */
      
    if(*count>0) *count++;
    return;
}

void venable80mc(data,lcl)
unsigned *data;
struct venable_cmd *lcl;
{

   *data=0;
   return;
}

void venable81mc(data,lcl)
unsigned *data;
struct venable_cmd *lcl;
{
   if(lcl->general == 1)
      *data=
           ( (bits16on(1) & lcl->group[ 0]) << 0) |
           ( (bits16on(1) & lcl->group[ 1]) << 1) |
           ( (bits16on(1) & lcl->group[ 2]) << 2) |
           ( (bits16on(1) & lcl->group[ 3]) << 3) |
           ( (bits16on(1) & lcl->group[ 4]) << 4) |
           ( (bits16on(1) & lcl->group[ 5]) << 5) |
           ( (bits16on(1) & lcl->group[ 6]) << 6) |
           ( (bits16on(1) & lcl->group[ 7]) << 7);
   else
     *data=0;
   return;
}
void mc80venable(lcl, data)
struct venable_cmd *lcl;
unsigned data;
{
       if((0xFF & data) == 0) lcl->general=1;

       return;
}
void mc81venable(lcl, data)
struct venable_cmd *lcl;
unsigned data;
{
/* Mk3 track number = VLBA rec track number - 3 */

       lcl->group[ 0] = bits16on(1) & (data >> 0);
       lcl->group[ 1] = bits16on(1) & (data >> 1);
       lcl->group[ 2] = bits16on(1) & (data >> 2);
       lcl->group[ 3] = bits16on(1) & (data >> 3);
       lcl->group[ 4] = bits16on(1) & (data >> 4);
       lcl->group[ 5] = bits16on(1) & (data >> 5);
       lcl->group[ 6] = bits16on(1) & (data >> 6);
       lcl->group[ 7] = bits16on(1) & (data >> 7);

       return;
}

