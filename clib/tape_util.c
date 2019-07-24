/* vlba tape buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/macro.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

                                              /* parameter keywords */
static char *key_set[ ]={ "off", "low" };

                                     /* number of elements in keyword arrays */
#define NKEY_SET sizeof(key_set)/sizeof( char *)

int tape_dec(lcl,count,ptr)
struct tape_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key();
    int feet;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,key_set,NKEY_SET,&lcl->set,1,TRUE);
        break;
      case 2:
         if (ptr==NULL || *ptr == '\0') 
           lcl->reset = -1;
         else if (0==strcmp(ptr,"reset"))
           lcl->reset = 0x00;
         else {
            feet = atoi(ptr);
            if ((feet < 0 || feet > 65535) || (ptr[0] < '0' || ptr[0] > '9'))
              ierr = -200;
            else {
              lcl->reset = feet;
            }
          }
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void tape_enc(output,count,lcl)
char *output;
int *count;
struct tape_cmd *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue=lcl->set;
        if(ivalue>=0 && ivalue <NKEY_SET )
          strcpy(output,key_set[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}

void tape_mon(output,count,lcl)
char *output;
int *count;
struct tape_mon *lcl;
{
    int ind;
    int itemp;
    double outvac;
    char feet[6];
    void int2str(); 
    void flt2str();

    output=output+strlen(output);

    switch (*count) {
      case 1:
        int2str(output,lcl->foot,-5,1); 
        feet[0]='\0';
        int2str(feet,lcl->foot,-5,1); 
        memcpy(shm_addr->LFEET_FS,feet,5);
        break;
      case 2:
        if (lcl->sense==0x01) 
          sprintf(output,"low");
        else
          sprintf(output,"off");
        break;
      case 3: /* tape moving: capstan */
        if ((lcl->stat & 0x2) == 0) {
          sprintf(output,"stopped"); 
          shm_addr->ICAPTP = 0;
        }
        else {
          sprintf(output,"moving");
          shm_addr->ICAPTP = 1;
        }
        break;
      case 4: /* tape moving and not ramping: tach */
        if (((lcl->stat & 0x2) == 0x2) && ((lcl->stat & 0x8) == 0))
          sprintf(output,"locked");
        else
          sprintf(output,"unlocked");
        break;
      case 5:  /* vacuum ok? */
        if ((lcl->stat & 0x40) == 0) {
          sprintf(output,"notready");
          shm_addr->IRDYTP = 1;
        }
        else {
          sprintf(output,"ready");
          shm_addr->IRDYTP = 0;
        }
        break;
      case 6:
        outvac=(double)lcl->vacuum;
        outvac = outvac*shm_addr->outscsl + shm_addr->outscint;
        flt2str(output,outvac,4,1);
        break;
      case 7:
        sprintf(output,"%d",bits16on(16) & lcl->chassis);
        break;
      case 8:
        if (lcl->error==0) 
          strcpy(output,"okay");
        else
          sprintf(output,"%04.4x",bits16on(16) & lcl->error);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void tapeb6mc(data,lcl)
unsigned *data;
struct tape_cmd *lcl;
{

   *data= bits16on(1) & lcl->set;

   return;
}

void tapeb8mc(data,lcl)
unsigned *data;
struct tape_cmd *lcl;
{

   *data= bits16on(16) & lcl->reset;

   return;
}

void mcb6tape(lcl, data)
struct tape_cmd *lcl;
unsigned data;
{

       lcl->set =  (data & bits16on(1));

       return;
}

void mc30tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->foot =  (data & bits16on(16));

       return;
}

void mc33tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->sense =  (data & bits16on(1));

       return;
}

void mc57tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->vacuum =  (data & bits16on(12));

       return;
}

void mc72tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->chassis =  (data & bits16on(16));

       return;
}

void mc73tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->stat =  (data & bits16on(16));

       return;
}

void mc74tape(lcl, data)
struct tape_mon *lcl;
unsigned data;
{

       lcl->error =  (data & bits16on(16));

       return;
}
