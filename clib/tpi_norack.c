/* tpi support utilities for "none" rack */
/* tpi_norack formats the buffers and runs mcbcn to get data */
/* tpput_norack stores the result in fscom and formats the output */
/* tsys_norack does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static char *lwhat[ ]={"u5","u6"};

void tpi_norack(ip,itpis_norack)                    /* sample tpi(s) */
long ip[5];                                     /* ipc array */
int itpis_norack[2]; /* detector selection array */
                      /* in order: u5, u6 */
{

  strncpy(shm_addr->user_dev1_name,"  ",2);
  strncpy(shm_addr->user_dev2_name,"  ",2);
  if(itpis_norack[0]==1) {
    strncpy(shm_addr->user_dev1_name,"u5",2);
    if(itpis_norack[1]==1)
      strncpy(shm_addr->user_dev2_name,"u6",2);
  } else if(itpis_norack[1]==1)
    strncpy(shm_addr->user_dev1_name,"u6",2);

  ip[0]=8;
  skd_run("antcn",'w',ip);
  skd_par(ip);
  
  return;
}
    
void tpput_norack(ip,itpis_norack,isub,ibuf,nch,ilen) /* put results of tpi */
long ip[5];                                    /* ipc array */
int itpis_norack[2]; /* device selection array, see tpi_norack for details */
int isub;                /* which task: 3=tpi, 4=tpical, 7=tpzero */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    unsigned *ptr;
    int i;

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 7: ptr=shm_addr->tpizero; break;
       default: ptr=shm_addr->tpi; break;    /* just being defensive */
    };

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */

    if(itpis_norack[0]==1) {
      ptr[0]=shm_addr->user_dev1_value;
      if(ptr[0] > 65534 ) {
	strcat(ibuf,"$$$$$,");
      } else {
	uns2str(ibuf,ptr[0],5);
	strcat(ibuf,",");
      }
      if(itpis_norack[1]==1) {
	ptr[1]=shm_addr->user_dev2_value;
	if(ptr[1] > 65534 ) {
	  strcat(ibuf,"$$$$$,");
	} else {
	  uns2str(ibuf,ptr[1],5);
	  strcat(ibuf,",");
	}
      }
    } else if(itpis_norack[1]==1) {
      ptr[1]=shm_addr->user_dev1_value;
      if(ptr[1] > 65534 ) {
	strcat(ibuf,"$$$$$,");
      } else {
	uns2str(ibuf,ptr[1],5);
	strcat(ibuf,",");
      }
    }

    *nch=strlen(ibuf)-1;         /* update nch counting from 1 */
                                 /* but delete the last comma */
         
    ip[2]=0;
    return;
}

void tsys_norack(itpis_norack,ibuf,nch,caltmp)
int itpis_norack[2]; /* device selection array, see tpi_norack for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
float caltmp;
{
       int i, inext;
       float tpi,tpic,tpiz;

       ibuf[*nch-1]='\0';                 /* null terminate so a STRING */
       for (i=0;i<2;i++) {
         if(itpis_norack[ i] == 1) {
           tpi=shm_addr->tpi[ i];             /* various pieces */
           tpic=shm_addr->tpical[ i];
           tpiz=shm_addr->tpizero[ i];        /* avoid overflow | div-by-0 */
           if(fabs((double)(tpic-tpi))<0.5 || tpic > 65534 || tpi > 65534)
             shm_addr->systmp[ i]=1e9;
           else
             shm_addr->systmp[ i]=(tpi-tpiz)*caltmp/(tpic-tpi);
	   inext=strlen(ibuf);
           flt2str(ibuf,shm_addr->systmp[ i],8,1);
	   if(ibuf[inext]=='$' || ibuf[inext]=='-')
	     logita(NULL,-211,"qk",lwhat[i]);
           strcat(ibuf,",");
         }
       }

       *nch=strlen(ibuf)-1;                   /* delete final comma */
       return;
}
