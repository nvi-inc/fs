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
    long *ptr;
    int i, iclass, nrec, lenstart;

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 7: ptr=shm_addr->tpizero; break;
       default: ptr=shm_addr->tpi; break;    /* just being defensive */
    };

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
    lenstart=strlen(ibuf);
    iclass=0;
    nrec=0;
    if(itpis_norack[0]==1) {
      ptr[0]=shm_addr->user_dev1_value+0.5;
      strcat(ibuf,"u5,");
      if(ptr[0] > 65534 ) {
	strcat(ibuf,"$$$$$,");
      } else {
	uns2str(ibuf,ptr[0],5);
	strcat(ibuf,",");
      }
      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
      nrec=nrec+1;
      ibuf[lenstart]=0;

      if(itpis_norack[1]==1) {
	ptr[1]=shm_addr->user_dev2_value+0.5;
	strcat(ibuf,"u6,");
	if(ptr[1] > 65534 ) {
	  strcat(ibuf,"$$$$$,");
	} else {
	  uns2str(ibuf,ptr[1],5);
	  strcat(ibuf,",");
	}
      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
      nrec=nrec+1;
      ibuf[lenstart]=0;  
      }
    } else if(itpis_norack[1]==1) {
      ptr[1]=shm_addr->user_dev1_value+0.5;
      strcat(ibuf,"u6,");
      if(ptr[1] > 65534 ) {
	strcat(ibuf,"$$$$$,");
      } else {
	uns2str(ibuf,ptr[1],5);
	strcat(ibuf,",");
      }
      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
      nrec=nrec+1;
      ibuf[lenstart]=0;
    }

    ip[0]=iclass;
    ip[1]=nrec;
    ip[2]=0;
    return;

}

void tsys_norack(ip,itpis_norack,ibuf,nch,itask)
long ip[5];
int itpis_norack[2]; /* device selection array, see tpi_norack for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;
{
       int i, inext, lenstart, iclass,nrec;
       float tpi,tpic,tpiz,tpid;
       ibuf[*nch-1]='\0';                 /* null terminate so a STRING */
       for (i=0;i<2;i++) {
         if(itpis_norack[ i] == 1) {
	   if(itask==5) {
	     tpi=shm_addr->tpi[ i];             /* various pieces */
	     tpic=shm_addr->tpical[ i];
	     if(shm_addr->user_device.zero[4+i])
	       tpiz=shm_addr->tpizero[ i];
	     else
	       tpiz=0.0;
	     tpid=shm_addr->tpidiff[ i];
	     /* avoid overflow | div-by-0 */
	     if(tpid<0.5 || tpid > 65534.5 || tpi > 65534.5 || tpi < 0.5)
	       shm_addr->systmp[ i]=1e9;
	     else
	       shm_addr->systmp[ i]=(tpi-tpiz)*shm_addr->caltemps[ i]/tpid;
	     if(shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0)
	       logita(NULL,-211,"qk",lwhat[i]);
	   } else if(itask==6) {
	     shm_addr->tpidiff[i]=shm_addr->tpical[i]-shm_addr->tpi[i];
	     if(shm_addr->tpical[i]>65534.5||
		shm_addr->tpical[i]<0.5||
		shm_addr->tpi[i]>65534.5||
		shm_addr->tpi[i]<0.5)
	       shm_addr->tpidiff[i]=65535;
	   } else if(itask==10) {
	     int ierr;
	     float fwhm, epoch, dum;
	     epoch=-1.0;
	     get_tcal_fwhm(lwhat[i],&shm_addr->caltemps[i],&fwhm,
			   epoch,&dum, &dum,&dum,&ierr);
	     if(ierr!=0) {
	       ip[0]=ip[1]=0;
	       ip[2]=ierr;
	       return;
	     }
	   }
	 }
       }

       ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
       lenstart=strlen(ibuf);
       iclass=0;
       nrec=0;
       for(i=0;i<2;i++) {
	 if(itpis_norack[i]!=0) {
	   if(strlen(ibuf)>60) {
	     cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	     nrec=nrec+1;
	     ibuf[lenstart]=0;
	   }
	   strcat(ibuf,lwhat[i]);
	   strcat(ibuf,",");
	   if(itask==5) 
	     flt2str(ibuf,shm_addr->systmp[ i],8,1);
	   else if(itask==6) {
	     int2str(ibuf,shm_addr->tpidiff[i],5,0);
	   } else if(itask==10) 
	     flt2str(ibuf,shm_addr->caltemps[ i],8,3);
	   strcat(ibuf,",");
	 }
	 if(ibuf[lenstart]!=0) {
	   cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	   nrec=nrec+1;
	   ibuf[lenstart]=0;
	 }
       }

       ip[0]=iclass;
       ip[1]=nrec;
       ip[2]=0;
       return;

}
