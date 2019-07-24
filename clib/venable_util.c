/* vlba enable command parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/venable_ds.h"
#include "../include/macro.h"

                                              /* parameter keywords */
static char *key_group[ ]={ "g1" ,"g2" ,"g3" ,"g4" };
static char *key_d[ ]=     {"d1" ,"d2" ,"d3" ,"d4" ,"d5" ,"d6" ,"d7" ,
                            "d8" ,"d9" ,"d10","d11","d12","d13","d14",
                            "d15","d16","d17","d18","d19","d20","d21",
                            "d22","d23","d24","d25","d26","d27","d28"};

                                     /* number of elements in keyword arrays */
#define NKEY_GROUP sizeof(key_group)/sizeof( char *)
#define NKEY_D     sizeof(key_d    )/sizeof( char *)

int venable_dec(lcl,count,ptr)
struct venable_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(), ivalue;

    ierr=0;
    if(*count == 1) {
       lcl->group[0]=0;
       lcl->group[1]=0;
       lcl->group[2]=0;
       lcl->group[3]=0;
       lcl->general=1;
    };
    if(ptr != NULL) {
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
    } else
       *count=-1;

End:
   if(*count>0) (*count)++;
   return ierr;
}

void venable_enc(output,count,lcl)
char *output;
int *count;
struct venable_cmd *lcl;
{
    int i, icount;

    output=output+strlen(output);

    icount=0;
    for (i=0;i<4;i++) {
      if(lcl->group[ i] == 1 && lcl->general==1) icount++;
      if(icount == *count) {
        strcpy(output,key_group[i]);       /* found the *count-th group */
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
           ( (bits16on(1) & lcl->group[ 3]) << 3);
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

       return;
}
