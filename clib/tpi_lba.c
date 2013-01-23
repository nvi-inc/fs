/* tpi support utilities for LBA rack */
/* tpi_lba formats the buffers and runs mcbcn to get data */
/* tpput_lba stores the result in fscom and formats the output */
/* tsys_lba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

long lba_tpi_from_level(unsigned short level);

static char ch[ ]={"123456789abcdef"};
static char *lwhat[ ]={
"p1","p2","p3","p4","p5","p6","p7","p8","p9","pa","pb","pc","pd","pe","pf"};

void tpi_lba(ip,itpis_lba)                    /* sample tpi(s) */
long ip[5];                                     /* ipc array */
int itpis_lba[2*MAX_DAS]; /* detector selection array */
                      /* in order: ifp1...ifp16, value: 0=don't use, 1=use */
{
    struct ds_cmd lcl;
    int i;

    lcl.type = DS_MON;

    ip[0]=1;
    for (i=1;i<5;i++) ip[i]=0;

    for (i=0;i<2*shm_addr->n_das;i++) {
      if(1==itpis_lba[i]) {
        strcpy(lcl.mnem,shm_addr->das[i/2].ds_mnem);
        lcl.cmd = 160 + (i%2 * 32) + 29;
        dscon_snd(&lcl,ip);
      }
    }

    run_dscon(ip);

    return;
}

void tpput_lba(ip,itpis_lba,isubin,ibuf,nch,ilen) /* put results of tpi */
long ip[5];                                    /* ipc array */
int itpis_lba[2*MAX_DAS]; /* device selection array, see tpi_lba for details */
int isubin;                /* which task: 3=tpi, 4=tpical */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    struct ds_mon lclm;
    long *ptr;
    int i,j,iclass,nrec,lenstart,isub,ierr;

    isub=abs(isubin);

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       default: ptr=shm_addr->tpi; break;    /* just being defensive */
    };

    ierr=0;
    for (i=0;i<2*shm_addr->n_das;i++) {
       if(itpis_lba[i] == 1) {
         if (dscon_rcv(&lclm,ip)) {
           if (shm_addr->das[i/2].ifp[0].initialised)
             shm_addr->das[i/2].ifp[0].initialised = -1;
           if (shm_addr->das[i/2].ifp[1].initialised)
             shm_addr->das[i/2].ifp[1].initialised = -1;
           ierr=1;
           ptr[i]=lclm.resp;
         } else {
           ptr[i]=lba_tpi_from_level(lclm.data.value);
         }
       }
    }
    if (ierr) {
       cls_clr(ip[0]);
       ip[0]=ip[1]=0;
       ip[2]=-401;
       memcpy(ip+3,"qk",2);
       return;
    }

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
    lenstart=strlen(ibuf);
    iclass=0;
    nrec=0;
    for(j=-1;j<4;j++) {
      for (i=0;i<2*shm_addr->n_das;i++) {
	if(itpis_lba[ i] == 1 && shm_addr->das[i/2].ifp[i%2].source==j) {
	  if(strlen(ibuf)>60) {
	    if(isubin > 0) {
	      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	      nrec=nrec+1;
	    } else {
	      ibuf[strlen(ibuf)-1]=0;
	      logit(ibuf,0,NULL);
	    }
	    ibuf[lenstart]=0;
	  }
	  strcat(ibuf,lwhat[i]);
	  strcat(ibuf,",");
	  if(ptr[i] >65534) {
	    strcat(ibuf,"$$$$$,");
	  } else {
	    int2str(ibuf,ptr[i],5);
	    strcat(ibuf,",");
	  }
	}
      }
      if(ibuf[lenstart]!=0) {
	if(isubin > 0) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	} else {
	  ibuf[strlen(ibuf)-1]=0;
	  logit(ibuf,0,NULL);
	}
	ibuf[lenstart]=0;
      }
    }
    ip[0]=iclass;
    ip[1]=nrec;
    ip[2]=0;
    return;
}

void tsys_lba(ip,itpis_lba,ibuf,nch,itask)
long ip[5];                                    /* ipc array */
int itpis_lba[2*MAX_DAS]; /* device selection array, see tpi_lba for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;
{
  int i,j, inext,iclass,nrec, lenstart;
  float tpi,tpic,tpiz,tpid;

  for (i=0;i<2*shm_addr->n_das;i++) {
    if(itpis_lba[ i] == 1) {
      if(itask==5) {
        int kskip;
        kskip=
	  (shm_addr->das[i/2].ifp[i%2].source<0||shm_addr->das[i/2].ifp[i%2].source>3);
        tpi=shm_addr->tpi[ i];             /* various pieces */
        tpic=shm_addr->tpical[ i];
        tpiz=shm_addr->tpizero[ i]=0;
        tpid=shm_addr->tpidiff[ i];

        if(kskip)		 /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
        else if(tpid<0.5 || tpid > 65534.5 || tpi > 65534.5 || tpi < 0.5 )
 	  shm_addr->systmp[ i]=1e9;
        else {
	  shm_addr->systmp[ i]=(tpi-tpiz)*shm_addr->caltemps[ i]/tpid;
        }
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
  for(j=-1;j<4;j++) {
    for (i=0;i<2*shm_addr->n_das;i++) {
      if(itpis_lba[ i] == 1 && shm_addr->das[i/2].ifp[i%2].source==j) {
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
	  int2str(ibuf,shm_addr->tpidiff[i],5);
	} else if(itask==10)
	  flt2str(ibuf,shm_addr->caltemps[ i],8,3);

	strcat(ibuf,",");
      }
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
