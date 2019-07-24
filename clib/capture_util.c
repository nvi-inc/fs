/* vlba capture parsing utilities */

static char *key_chan[ ]={ "at1","at2","at3","aaux","bt1","bt2","bt3","baux"};

#define NKEY_CHAN sizeof(key_chan)/sizeof( char *)

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/capture_ds.h"

void capture_mon(output,count,lcl)
char *output;
int *count;
struct capture_mon *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue=lcl->qa.chan;
        if((ivalue>=0 && ivalue <NKEY_CHAN) && (lcl->qa.drive == 1))
          strcpy(output,key_chan[ivalue]);
        else
          strcpy(output,BAD_VALUE);
      case 2:
        sprintf(output,"%04.4x",0xFFFF & lcl->general.word1);
        break;
      case 3:
        sprintf(output,"%04.4x",0xFFFF & lcl->general.word2);
        break;
      case 4:
        sprintf(output,"%04.4x",0xFFFF & lcl->time.word3);
        break;
      case 5:
        sprintf(output,"%04.4x",0xFFFF & lcl->time.word4);
        break;
      default:
        *count=-1;
        break;
   }
   if(*count > 0) *count++;
   return;
}

void mc48capture(lcl, data)
struct capture_mon *lcl;
unsigned data;
{
    lcl->general.word1=0xFFFF & data;
    return;
}

void mc49capture(lcl, data)
struct capture_mon *lcl;
unsigned data;
{
    lcl->general.word2=0xFFFF & data;
    return;
}

void mc4Acapture(lcl, data)
struct capture_mon *lcl;
unsigned data;
{
    lcl->time.word3=0xFFFF & data;
    return;
}

void mc4Bcapture(lcl, data)
struct capture_mon *lcl;
unsigned data;
{
    lcl->time.word4=0xFFFF & data;
    return;
}
