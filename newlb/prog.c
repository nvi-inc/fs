#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define INEXT_N 3
#define KENASTK_N 2
#define LFEET_N 6
#define LGEN_N 2
#define LNEWPR_N 8
#define LNEWSK_N 8
#define LPRC_N 8
#define LSTP_N 8
#define LSKD_N 8
#define LLOG_N 8
#define LEXPER_N 8
#define SYSTMP_N 32
#define LFREQV_N 90
#define FREQVC_N 15
#define LNAANT_N 8
#define LSORNA_N 10
#define IDEVANT_N 64
#define IDEVGPIB_N 64
#define IDEVLOG_N 320
#define IDEVMCB_N 64
#define HORAZ_N  4*MAX_HOR
#define HOREL_N  4*MAX_HOR
#define CWRAP_N 8
#define IDEVDS_N 64

extern struct fscom *shm_addr;

void fs_set_ibmat__(ibmat)
	int *ibmat;
	{
	  shm_addr->ibmat = *ibmat;
	}

void fs_get_ibmat__(ibmat)
	int *ibmat;
	{
	  *ibmat = shm_addr->ibmat;
	}

void fs_set_ibmcb__(ibmcb)
	int *ibmcb;
	{
	  shm_addr->ibmcb = *ibmcb;
	}

void fs_get_ibmcb__(ibmcb)
	int *ibmcb;
	{
	  *ibmcb = shm_addr->ibmcb;
	}

void fs_set_wrvolt__(wrvolt,i)
	float *wrvolt;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->wrvolt[*i-1] = wrvolt[*i-1];
	}

void fs_get_wrvolt__(wrvolt,i)
	float *wrvolt;
	int *i;
	{
	  if(*i==1||*i==2)
	    wrvolt[*i-1] = shm_addr->wrvolt[*i-1];
	}

void fs_set_itpthick__(itpthick,i)
	int *itpthick,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->itpthick[*i-1] = itpthick[*i-1];
	}

void fs_get_itpthick__(itpthick,i)
	int *itpthick,*i;
	{
	  if(*i==1||*i==2)
	    itpthick[*i-1] = shm_addr->itpthick[*i-1];
	}

void fs_set_capstan__(capstan,i)
	int *capstan,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->capstan[*i-1] = capstan[*i-1];
	}

void fs_get_capstan__(capstan,i)
	int *capstan,*i;
	{
	  if(*i==1||*i==2)
	    capstan[*i-1] = shm_addr->capstan[*i-1];
	}

void fs_set_outscsl__(outscsl,i)
	float *outscsl;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->outscsl[*i-1] = outscsl[*i-1];
	}

void fs_get_outscsl__(outscsl,i)
	float *outscsl;
	int *i;
	{
	  if(*i==1||*i==2)
	    outscsl[*i-1] = shm_addr->outscsl[*i-1];
	}

void fs_set_inscsl__(inscsl,i)
	float *inscsl;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->inscsl[*i-1] = inscsl[*i-1];
	}

void fs_get_inscsl__(inscsl,i)
	float *inscsl;
	int *i;
	{
	  if(*i==1||*i==2)
	    inscsl[*i-1] = shm_addr->inscsl[*i-1];
	}

void fs_set_outscint__(outscint,i)
	float *outscint;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->outscint[*i-1] = outscint[*i-1];
	}

void fs_get_outscint__(outscint,i)
	float *outscint;
	int *i;
	{
	  if(*i==1||*i==2)
	    outscint[*i-1] = shm_addr->outscint[*i-1];
	}

void fs_set_inscint__(inscint,i)
	float *inscint;
	int *i;
	{
	  if(*i==1||*i==2) 
	    shm_addr->inscint[*i-1] = inscint[*i-1];
	}

void fs_get_inscint__(inscint,i)
	float *inscint;
	int *i;
	{
	  if(*i==1||*i==2) 
	    inscint[*i-1] = shm_addr->inscint[*i-1];
	}

void fs_set_motorv__(motorv,i)
	float *motorv;
	int *i;
	{
	  if(*i==1||*i==2) 
	    shm_addr->motorv[*i-1] = motorv[*i-1];
	}

void fs_get_motorv__(motorv,i)
	float *motorv;
	int *i;
	{
	  if(*i==1||*i==2) 
	    motorv[*i-1] = shm_addr->motorv[*i-1];
	}

void fs_set_tempwx__(tempwx)
	float *tempwx;
	{
	  shm_addr->tempwx = *tempwx;
	}

void fs_get_tempwx__(tempwx)
	float *tempwx;
	{
	  *tempwx = shm_addr->tempwx;
	}

void fs_set_humiwx__(humiwx)
	float *humiwx;
	{
	  shm_addr->humiwx = *humiwx;
	}

void fs_get_humiwx__(humiwx)
	float *humiwx;
	{
	  *humiwx = shm_addr->humiwx;
	}

void fs_set_preswx__(preswx)
	float *preswx;
	{
	  shm_addr->preswx = *preswx;
	}

void fs_get_preswx__(preswx)
	float *preswx;
	{
	  *preswx = shm_addr->preswx;
	}

void fs_set_speedwx__(speedwx)
        float *speedwx;
        {
          shm_addr->speedwx = *speedwx;
        }

void fs_get_speedwx__(speedwx)
        float *speedwx;
        {
          *speedwx = shm_addr->speedwx;
        }

void fs_set_directionwx__(directionwx)
        int *directionwx;
        {
          shm_addr->directionwx = *directionwx;
        }

void fs_get_directionwx__(directionwx)
        int *directionwx;
        {
          *directionwx = shm_addr->directionwx;
        }

void fs_set_ep1950__(ep1950)
	float *ep1950;
	{
	  shm_addr->ep1950 = *ep1950;
	}

void fs_get_ep1950__(ep1950)
	float *ep1950;
	{
	  *ep1950 = shm_addr->ep1950;
	}

void fs_set_epoch__(epoch)
	float *epoch;
	{
	  shm_addr->epoch = *epoch;
	}

void fs_get_epoch__(epoch)
	float *epoch;
	{
	  *epoch = shm_addr->epoch;
	}

void fs_set_iclopr__(iclopr)
	long *iclopr;
	{
	  shm_addr->iclopr = *iclopr;
	}

void fs_get_iclopr__(iclopr)
	long *iclopr;
	{
	  *iclopr = shm_addr->iclopr;
	}

void fs_set_iclbox__(iclbox)
	long *iclbox;
	{
	  shm_addr->iclbox = *iclbox;
	}

void fs_get_iclbox__(iclbox)
	long *iclbox;
	{
	  *iclbox = shm_addr->iclbox;
	}

void fs_set_cablev__(cablev)
	float *cablev;
	{
	  shm_addr->cablev = *cablev;
	}

void fs_set_ra50__(ra50)
	double *ra50;
	{
	  shm_addr->ra50 = *ra50;
	}

void fs_get_ra50__(ra50)
	double *ra50;
	{
	  *ra50 = shm_addr->ra50;
	}

void fs_set_dec50__(dec50)
	double *dec50;
	{
	  shm_addr->dec50 = *dec50;
	}

void fs_get_dec50__(dec50)
	double  *dec50;
	{
	  *dec50 = shm_addr->dec50;
	}

void fs_set_radat__(radat)
	double *radat;
	{
	  shm_addr->radat = *radat;
	}

void fs_get_radat__(radat)
	double *radat;
	{
	  *radat = shm_addr->radat;
	}

void fs_set_decdat__(decdat)
	double *decdat;
	{
	  shm_addr->decdat = *decdat;
	}

void fs_get_decdat__(decdat)
	double  *decdat;
	{
	  *decdat = shm_addr->decdat;
	}

void fs_set_height__(height)
	float *height;
	{
	  shm_addr->height = *height;
	}

void fs_get_height__(height)
	float  *height;
	{
	  *height = shm_addr->height;
	}

void fs_set_alat__(alat)
	double *alat;
	{
	  shm_addr->alat = *alat;
	}

void fs_get_alat__(alat)
	double  *alat;
	{
	  *alat = shm_addr->alat;
	}

void fs_set_wlong__(wlong)
	double *wlong;
	{
	  shm_addr->wlong = *wlong;
	}

void fs_get_wlong__(wlong)
	double  *wlong;
	{
	  *wlong = shm_addr->wlong;
	}

void fs_set_imodfm__(imodfm)
	int *imodfm;
	{
	  shm_addr->imodfm = *imodfm;
	}

void fs_get_imodfm__(imodfm)
	int *imodfm;
	{
	  *imodfm = shm_addr->imodfm;
	}

void fs_set_iratfm__(iratfm)
	int *iratfm;
	{
	  shm_addr->iratfm = *iratfm;
	}

void fs_get_iratfm__(iratfm)
	int *iratfm;
	{
	  *iratfm = shm_addr->iratfm;
	}

void fs_set_ispeed__(ispeed,i)
	int *ispeed,*i;
	{
	  if(*i==1)
	    shm_addr->ispeed[0] = ispeed[0];
	  else if(*i==2)
	    shm_addr->ispeed[1] = ispeed[1];
	}

void fs_get_ispeed__(ispeed,i)
	int *ispeed,*i;
	{
	  if(*i==1)
	    ispeed[0] = shm_addr->ispeed[0];
	  else if(*i==2)
	    ispeed[1] = shm_addr->ispeed[1];
	}

void fs_get_cips__(cips,i)
	long *cips,*i;
	{
	  if(*i==1)
	    cips[0] = shm_addr->cips[0];
	  else if(*i==2)
	    cips[1] = shm_addr->cips[1];
	}

void fs_set_ienatp__(ienatp,i)
	int *ienatp,*i;
	{
	  if(*i==1)
	    shm_addr->ienatp[0] = ienatp[0];
	  else if (*i==2)
	    shm_addr->ienatp[1] = ienatp[1];
	}

void fs_get_ienatp__(ienatp,i)
	int *ienatp,*i;
	{
	  if(*i==1)
	    ienatp[0] = shm_addr->ienatp[0];
	  else if (*i==2)
	    ienatp[1] = shm_addr->ienatp[1];
	}

void fs_set_idirtp__(idirtp,i)
 	int *idirtp,*i;
	{
	  if(*i==1)
	    shm_addr->idirtp[0] = idirtp[0];
	  else if (*i==2)
	    shm_addr->idirtp[1] = idirtp[1];
	}

void fs_get_idirtp__(idirtp,i)
	int *idirtp,*i;
	{
	  if(*i==1)
	    idirtp[0] = shm_addr->idirtp[0];
	  else if (*i==2)
	    idirtp[1] = shm_addr->idirtp[1];
	}

void fs_set_inp1if__(inp1if)
	int *inp1if;
	{
	  shm_addr->inp1if = *inp1if;
	}

void fs_get_inp1if__(inp1if)
	int *inp1if;
	{
	  *inp1if = shm_addr->inp1if;
	}

void fs_set_inp2if__(inp2if)
	int *inp2if;
	{
	  shm_addr->inp2if = *inp2if;
	}

void fs_get_inp2if__(inp2if)
	int *inp2if;
	{
	  *inp2if = shm_addr->inp2if;
	}

void fs_set_ionsor__(ionsor)
	int *ionsor;
	{
	  shm_addr->ionsor = *ionsor;
	}

void fs_get_ionsor__(ionsor)
	int *ionsor;
	{
	  *ionsor = shm_addr->ionsor;
	}

void fs_set_systmp__(systmp)
	float *systmp;
	{
          int i;
	  for(i=0;i<SYSTMP_N;i++)
            shm_addr->systmp[i]=*(systmp++);
	}

void fs_get_systmp__(systmp)
        float *systmp;
        {         
          memcpy(systmp,shm_addr->systmp,sizeof(shm_addr->systmp));
        }         

void fs_set_ipashd__(ipashd,i)
	int ipashd[2][2],*i;
	{
	  if(*i==1||*i==2) {
	    shm_addr->ipashd[*i-1][0]=ipashd[*i-1][0];
	    shm_addr->ipashd[*i-1][1]=ipashd[*i-1][1];
	  }
	}

void fs_get_ipashd__(ipashd,i)
	int ipashd[2][2],*i;
	{
	  if(*i==1||*i==2) {
	    ipashd[*i-1][0]=shm_addr->ipashd[*i-1][0];
	    ipashd[*i-1][1]=shm_addr->ipashd[*i-1][1];
	  }
	}

void fs_set_posnhd__(posnhd,i)
	float posnhd[2][2];
	int *i;
	{
	  if(*i==1||*i==2) {
	    shm_addr->posnhd[*i-1][0]=posnhd[*i-1][0];
	    shm_addr->posnhd[*i-1][1]=posnhd[*i-1][1];
	  }
	}

void fs_get_posnhd__(posnhd,i)
	float posnhd[2][2];
	int *i;
	{
	  if(*i==1||*i==2) {
	    posnhd[*i-1][0]=shm_addr->posnhd[*i-1][0];
	    posnhd[*i-1][1]=shm_addr->posnhd[*i-1][1];
	  }
	}

void fs_set_lfreqv__(lfreqv)
	char *lfreqv;
	{
          size_t N;
	  N = LFREQV_N;
	  memcpy(shm_addr->lfreqv,lfreqv,N);
	}

void fs_get_lfreqv__(lfreqv)
	char *lfreqv;
	{
          size_t N;
	  N = LFREQV_N;
	  memcpy(lfreqv,shm_addr->lfreqv,N);
	}

void fs_set_freqvc__(freqvc)
	float *freqvc;
	{
          size_t N;
	  N = sizeof(shm_addr->freqvc);
	  memcpy(shm_addr->freqvc,freqvc,N);
	}

void fs_get_freqvc__(freqvc)
	float *freqvc;
	{
          size_t N;
	  N =  sizeof(shm_addr->freqvc);
	  memcpy(freqvc,shm_addr->freqvc,N);
	}

void fs_set_ibwvc__(ibwvc)
	int *ibwvc;
	{
          size_t N;
	  N = sizeof(shm_addr->ibwvc);
	  memcpy(shm_addr->ibwvc,ibwvc,N);
	}

void fs_get_ibwvc__(ibwvc)
	int *ibwvc;
	{
          size_t N;
	  N =  sizeof(shm_addr->ibwvc);
	  memcpy(ibwvc,shm_addr->ibwvc,N);
	}

void fs_set_extbwvc__(extbwvc)
	float *extbwvc;
	{
          size_t N;
	  N = sizeof(shm_addr->extbwvc);
	  memcpy(shm_addr->extbwvc,extbwvc,N);
	}

void fs_get_extbwvc__(extbwvc)
	float *extbwvc;
	{
          size_t N;
	  N =  sizeof(shm_addr->extbwvc);
	  memcpy(extbwvc,shm_addr->extbwvc,N);
	}

void fs_set_ifp2vc__(ifp2vc)
	int *ifp2vc;
	{
          size_t N;
	  N = sizeof(shm_addr->ifp2vc);
	  memcpy(shm_addr->ifp2vc,ifp2vc,N);
	}

void fs_get_ifp2vc__(ifp2vc)
	int *ifp2vc;
	{
          size_t N;
	  N =  sizeof(shm_addr->ifp2vc);
	  memcpy(ifp2vc,shm_addr->ifp2vc,N);
	}

void fs_set_lnaant__(lnaant)
	char *lnaant;
	{
          size_t N;
	  N = LNAANT_N;
	  memcpy(shm_addr->lnaant,lnaant,N);
	}

void fs_get_lnaant__(lnaant)
	char *lnaant;
	{
          size_t N;
	  N = LNAANT_N;
	  memcpy(lnaant,shm_addr->lnaant,N);
	}

void fs_set_idevgpib__(idevgpib)
	char *idevgpib;
	{
          size_t N;
	  N = IDEVGPIB_N;
	  memcpy(shm_addr->idevgpib,idevgpib,N);
	}

void fs_get_idevgpib__(idevgpib)
	char *idevgpib;
	{
          size_t N;
	  N = IDEVGPIB_N;
	  memcpy(idevgpib,shm_addr->idevgpib,N);
	}

void fs_set_idevant__(idevant)
	char *idevant;
	{
          size_t N;
	  N = IDEVANT_N;
	  memcpy(shm_addr->idevant,idevant,N);
	}

void fs_get_idevant__(idevant)
	char *idevant;
	{
          size_t N;
	  N = IDEVANT_N;
	  memcpy(idevant,shm_addr->idevant,N);
	}

void fs_set_idevlog__(idevlog)
	char *idevlog;
	{
          size_t N;
	  N = IDEVLOG_N;
	  memcpy(shm_addr->idevlog,idevlog,N);
	}

void fs_get_idevlog__(idevlog)
	char *idevlog;
	{
          size_t N;
	  N = IDEVLOG_N;
	  memcpy(idevlog,shm_addr->idevlog,N);
	}

void fs_set_idevmcb__(idevmcb)
	char *idevmcb;
	{
          size_t N;
	  N = IDEVMCB_N;
	  memcpy(shm_addr->mcb_dev,idevmcb,N);
	}

void fs_get_idevmcb__(idevmcb)
	char *idevmcb;
	{
          size_t N;
	  N = IDEVMCB_N;
	  memcpy(idevmcb,shm_addr->mcb_dev,N);
	}

void fs_set_ndevlog__(ndevlog)
	int *ndevlog;
	{
	  shm_addr->ndevlog = *ndevlog;
	}

void fs_get_ndevlog__(ndevlog)
	int *ndevlog;
	{
	  *ndevlog= shm_addr->ndevlog;
	}

void fs_set_lsorna__(lsorna)
	char *lsorna;
	{
          size_t N;
	  N = LSORNA_N;
	  memcpy(shm_addr->lsorna,lsorna,N);
	}

void fs_get_lsorna__(lsorna)
	char *lsorna;
	{
          size_t N;
	  N = LSORNA_N;
	  memcpy(lsorna,shm_addr->lsorna,N);
	}

void fs_set_azoff__(AZOFF)
	float *AZOFF;
	{
	  shm_addr->AZOFF = *AZOFF;
	}

void fs_get_azoff__(AZOFF)
	float *AZOFF;
	{
	  *AZOFF = shm_addr->AZOFF;
	}

void fs_set_lexper__(LEXPER)
	int *LEXPER;
	{
          size_t N;
	  N = LEXPER_N;
	  memcpy(shm_addr->LEXPER,LEXPER,N);
	}

void fs_get_lexper__(LEXPER)
	int *LEXPER;
	{
          size_t N;
	  N = LEXPER_N;
	  memcpy(LEXPER,shm_addr->LEXPER,N);
	}

void fs_set_inext__(INEXT)
	short *INEXT;
        
	{
          int i;
          for(i=0;i<INEXT_N;i++)
	    shm_addr->INEXT[i]=*(INEXT++);
	}

void fs_get_inext__(INEXT)
	short *INEXT;
	{
          int i;
	  for(i=0;i<INEXT_N;i++)
	    *(INEXT++)=shm_addr->INEXT[i];
	}

void fs_set_kenastk__(KENASTK,j)
	int *KENASTK;
	int *j;
        
	{
          int i;
	  if(*j==1||*j==2) 
	    for(i=0;i<KENASTK_N;i++)
	      shm_addr->KENASTK[*j-1][i]=KENASTK[(*j-1)*KENASTK_N+i];
	}

void fs_get_kenastk__(KENASTK,j)
	int *KENASTK;
	int *j;
	{
          int i;
	  if(*j==1||*j==2) 
	    for(i=0;i<KENASTK_N;i++)
	      KENASTK[(*j-1)*KENASTK_N+i]=shm_addr->KENASTK[*j-1][i];
	}

void fs_set_irdytp__(IRDYTP,i)
	int *IRDYTP,*i;
	{
	  if(*i==1)
	    shm_addr->IRDYTP[0] = IRDYTP[0];
	  else if(*i==2)
	    shm_addr->IRDYTP[1] = IRDYTP[1];
	}

void fs_get_irdytp__(IRDYTP,i)
	int *IRDYTP,*i;
	{
	  if(*i==1)
	    IRDYTP[0] = shm_addr->IRDYTP[0];
	  else if(*i==2)
	    IRDYTP[1] = shm_addr->IRDYTP[1];
	}

void fs_set_itraka__(ITRAKA,i)
	int *ITRAKA,*i;
	{
	  if(*i==1)
	    shm_addr->ITRAKA[0] = ITRAKA[0];
	  else if(*i==2)
	    shm_addr->ITRAKA[1] = ITRAKA[1];
	}

void fs_get_itraka__(ITRAKA,i)
	int *ITRAKA,*i;
	{
	  if(*i==1)
	    ITRAKA[0] = shm_addr->ITRAKA[0];
	  else if(*i==2)
	    ITRAKA[1] = shm_addr->ITRAKA[1];
	}

void fs_set_itrakb__(ITRAKB,i)
	int *ITRAKB,*i;
	{
	  if(*i==1)
	    shm_addr->ITRAKB[0] = ITRAKB[0];
	  else if(*i==2)
	    shm_addr->ITRAKB[1] = ITRAKB[1];
	}

void fs_get_itrakb__(ITRAKB,i)
	int *ITRAKB,*i;
	{
	  if(*i==1)
	    ITRAKB[0] = shm_addr->ITRAKB[0];
	  else if(*i==2)
	    ITRAKB[1] = shm_addr->ITRAKB[1];
	}

void fs_set_decoff__(DECOFF)
	float *DECOFF;
	{
	  shm_addr->DECOFF = *DECOFF;
	}

void fs_get_decoff__(DECOFF)
	float *DECOFF;
	{
	  *DECOFF = shm_addr->DECOFF;
	}

void fs_set_eloff__(ELOFF)
	float *ELOFF;
	{
	  shm_addr->ELOFF = *ELOFF;
	}

void fs_get_eloff__(ELOFF)
	float *ELOFF;
	{
	  *ELOFF = shm_addr->ELOFF;
	}

void fs_set_icaptp__(ICAPTP,i)
	int *ICAPTP,*i;
	{
	  if (*i==1)
	    shm_addr->ICAPTP[0] = ICAPTP[0];
	  else if (*i==2)
	    shm_addr->ICAPTP[1] = ICAPTP[1];
	}

void fs_get_icaptp__(ICAPTP,i)
	int *ICAPTP,*i;
	{
	  if (*i==1)
	    ICAPTP[0] = shm_addr->ICAPTP[0];
	  else if (*i==2)
	    ICAPTP[1] = shm_addr->ICAPTP[1];
        }

void fs_set_istptp__(ISTPTP,i)
	int *ISTPTP,*i;
	{
	  if (*i==1)
	    shm_addr->ISTPTP[0] = ISTPTP[0];
	  else if (*i==2)
	    shm_addr->ISTPTP[1] = ISTPTP[1];
	}

void fs_get_istptp__(ISTPTP,i)
	int *ISTPTP,*i;
	{
	  if (*i==1)
	    ISTPTP[0] = shm_addr->ISTPTP[0]; 
	  else if (*i==2)
	    ISTPTP[1] = shm_addr->ISTPTP[1]; 
        }

void fs_set_itactp__(ITACTP,i)
	int *ITACTP,*i;
	{
	  if (*i==1)
	    shm_addr->ITACTP[0] = ITACTP[0];
	  else if (*i==2)
	    shm_addr->ITACTP[1] = ITACTP[1];
	}

void fs_get_itactp__(ITACTP,i)
	int *ITACTP,*i;
	{
	  if (*i==1)
	    ITACTP[0] = shm_addr->ITACTP[0]; 
	  else if (*i==2)
	    ITACTP[1] = shm_addr->ITACTP[1]; 
        }

void fs_set_klvdt_fs__(KLVDT_FS,i)
	int *KLVDT_FS,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->klvdt_fs[*i-1] = KLVDT_FS[*i-1];
	}

void fs_get_klvdt_fs__(KLVDT_FS,i)
	int *KLVDT_FS,*i;
	{
	  if(*i==1||*i==2)
	    KLVDT_FS[*i-1] = shm_addr->klvdt_fs[*i-1];
	}

void fs_set_kecho__(KECHO)
	int *KECHO;
	{
	  shm_addr->KECHO = *KECHO;
	}

void fs_get_kecho__(KECHO)
	int *KECHO;
	{
	  *KECHO = shm_addr->KECHO;
	}

void fs_set_khalt__(KHALT)
	int *KHALT;
	{
	  shm_addr->KHALT = *KHALT;
	}

void fs_get_khalt__(KHALT)
	int *KHALT;
	{
	  *KHALT = shm_addr->KHALT;
	}

void fs_set_ichfm_cn_tm__(ichfm_cn_tm)
	int *ichfm_cn_tm;
	{
	  shm_addr->check.fm_cn_tm = *ichfm_cn_tm;
	}

void fs_get_ichfm_cn_tm__(ichfm_cn_tm)
	int *ichfm_cn_tm;
	{
	  *ichfm_cn_tm = shm_addr->check.fm_cn_tm;
	}

void fs_set_raoff__(RAOFF)
	float *RAOFF;
	{
	  shm_addr->RAOFF = *RAOFF;
	}

void fs_get_raoff__(RAOFF)
	float *RAOFF;
	{
	  *RAOFF = shm_addr->RAOFF;
	}

void fs_set_xoff__(XOFF)
	float *XOFF;
	{
	  shm_addr->XOFF = *XOFF;
	}

void fs_get_xoff__(XOFF)
	float *XOFF;
	{
	  *XOFF = shm_addr->XOFF;
	}

void fs_set_yoff__(YOFF)
	float *YOFF;
	{
	  shm_addr->YOFF = *YOFF;
	}

void fs_get_yoff__(YOFF)
	float *YOFF;
	{
	  *YOFF = shm_addr->YOFF;
	}

void fs_set_icheck__(icheck,N)
	int *icheck, *N;
	{
	  shm_addr->ICHK[*N-1] = *icheck;
	}

void fs_get_icheck__(icheck,N)
	int *icheck, *N;
	{
	  *icheck = shm_addr->ICHK[*N-1];
	}

void fs_set_ichvlba__(ichvlba,N)
	int *ichvlba, *N;
	{
         switch(*N) {
         case 1 : case 2 : case 3 : case 4 : case 5 : case 6 :
         case 7 : case 8 : case 9 : case 10 : case 11 : case 12 :
         case 13 : case 14 :
	   shm_addr->check.bbc[*N-1] = *ichvlba;
           break;
         case 15 : case 16 :
	   shm_addr->check.dist[*N-15] = *ichvlba;
           break;
         case 17 :
	   shm_addr->check.vform = *ichvlba;
           break;
         case 18 :
	   shm_addr->check.rec[0] = *ichvlba;
           break;
         case 19 :
	   shm_addr->check.rec[1] = *ichvlba;
           break;
         }
	}

void fs_get_ichvlba__(ichvlba,N)
	int *ichvlba, *N;
	{
         switch(*N) {
         case 1 : case 2 : case 3 : case 4 : case 5 : case 6 :
         case 7 : case 8 : case 9 : case 10 : case 11 : case 12 :
         case 13 : case 14 :
           *ichvlba = shm_addr->check.bbc[*N-1];
           break;
         case 15 : case 16 :
	   *ichvlba = shm_addr->check.dist[*N-15];
           break;
         case 17 :
	   *ichvlba = shm_addr->check.vform;
           break;
         case 18 :
	   *ichvlba = shm_addr->check.rec[0];
           break;
         case 19 :
	   *ichvlba = shm_addr->check.rec[1];
           break;
         default:
           *ichvlba = 0;
         }
	}

void fs_set_ichs2__(ichs2)
	int *ichs2;
	{
	  shm_addr->check.s2rec.check = *ichs2;
	}

void fs_get_ichs2__(ichs2)
	int *ichs2;
	{
	  *ichs2 = shm_addr->check.s2rec.check;
	}


void fs_set_stchk__(ichk,n)
int *ichk,*n;
{
      shm_addr->stchk[*n-1]=*ichk;
}

void fs_get_stchk__(ichk,n)
int *ichk,*n;
{
      *ichk=shm_addr->stchk[*n-1];
}

void fs_set_sterp__(sterp)
int *sterp;
{
      shm_addr->sterp=*sterp;
}

void fs_set_erchk__(erchk)
int *erchk;
{
      shm_addr->erchk=*erchk;
}

void fs_set_stcnm__(lhol,n)
char lhol[2];
int *n;
{
      memcpy(shm_addr->stcnm[*n-1],lhol,2);
}

void fs_get_stcnm__(lhol,n)
char lhol[2];
int *n;
{
      memcpy(lhol,shm_addr->stcnm[*n-1],2);
}

void fs_set_irenvc__(IRENVC)
	int *IRENVC;
	{
	  shm_addr->IRENVC = *IRENVC;
	}

void fs_get_irenvc__(IRENVC)
	int *IRENVC;
	{
	  *IRENVC = shm_addr->IRENVC;
	}

void fs_set_ilokvc__(ILOKVC)
	int *ILOKVC;
	{
	  shm_addr->ILOKVC = *ILOKVC;
	}

void fs_get_ilokvc__(ILOKVC)
	int *ILOKVC;
	{
	  *ILOKVC = shm_addr->ILOKVC;
	}

void fs_set_tpivc__(TPIVC,i)
	unsigned long *TPIVC;
	int *i;
	{
	  if(*i >0 && *i < 16)
	    shm_addr->TPIVC[*i-1] = TPIVC[*i-1];
	}

void fs_get_tpivc__(TPIVC,i)
	unsigned long *TPIVC;
	int *i;
	{
	  if(*i >0 && *i < 16)
	    TPIVC[*i-1] = shm_addr->TPIVC[*i-1];
	}
void fs_set_mifd_tpi__(MIFD_TPI,i)
	unsigned long *MIFD_TPI;
	int *i;
	{
	  if(*i >0 && *i < 4)
	    shm_addr->mifd_tpi[*i-1] = MIFD_TPI[*i-1];
	}

void fs_get_mifd_tpi__(MIFD_TPI,i)
	long *MIFD_TPI;
	int *i;
	{
	  if(*i >0 && *i < 4)
	    MIFD_TPI[*i-1] = shm_addr->mifd_tpi[*i-1];
	}
void fs_set_bbc_tpi__(bbc_tpi,i)
	unsigned long bbc_tpi[2];
	int *i;
	{
	  if(*i >0 && *i < 15) {
	    shm_addr->bbc_tpi[*i-1][0] = bbc_tpi[0];
	    shm_addr->bbc_tpi[*i-1][1] = bbc_tpi[1];
	  }
	}

void fs_get_bbc_tpi__(bbc_tpi,i)
	unsigned long bbc_tpi[2];
	int *i;
	{
	  if(*i >0 && *i < 15) {
	    bbc_tpi[0] = shm_addr->bbc_tpi[*i-1][0];
	    bbc_tpi[1] = shm_addr->bbc_tpi[*i-1][1];
	  }
	}
void fs_set_vifd_tpi__(VIFD_TPI,i)
	unsigned long *VIFD_TPI;
	int *i;
	{
	  if(*i >0 && *i < 5)
	    shm_addr->vifd_tpi[*i-1] = VIFD_TPI[*i-1];
	}

void fs_get_vifd_tpi__(VIFD_TPI,i)
	long *VIFD_TPI;
	int *i;
	{
	  if(*i >0 && *i < 5)
	    VIFD_TPI[*i-1] = shm_addr->vifd_tpi[*i-1];
	}

void fs_set_llog__(LLOG)
	int *LLOG;
	{
          size_t N;
	  N = LLOG_N;
	  memcpy(shm_addr->LLOG,LLOG,N);
	}

void fs_get_llog__(LLOG)
	int *LLOG;
	{
          size_t N;
	  N = LLOG_N;
	  memcpy(LLOG,shm_addr->LLOG,N);
	}

void fs_set_lfeet_fs__(LFEET_FS,i)
	char *LFEET_FS;
	int *i;
	{
          size_t N;
	  N = LFEET_N;
	  if(*i==1 || *i==2) 
	    memcpy(shm_addr->LFEET_FS[*i-1],LFEET_FS+(*i-1)*N,N);
	}

void fs_get_lfeet_fs__(LFEET_FS,i)
	char *LFEET_FS;
	int *i;
	{
          size_t N;
	  N = LFEET_N;
	  if(*i==1 || *i==2) 
	    memcpy(LFEET_FS+(*i-1)*N,shm_addr->LFEET_FS[*i-1],N);
	}

void fs_set_lgen__(lgen,j)
	short *lgen;
	int *j;
	{
	  int i;

	  if(*j==1|| *j==2)
	    for (i=0;i<LGEN_N;i++)
	      shm_addr->lgen[*j-1][i]=lgen[(*j-1)*LGEN_N+i];
	}

void fs_get_lgen__(lgen,j)
	short *lgen;
	int *j;
	{
	  int i;
	  if(*j==1|| *j==2)
	    for (i=0;i<LGEN_N;i++)
	      lgen[(*j-1)*LGEN_N+i]=shm_addr->lgen[*j-1][i];
	}

void fs_set_lnewpr__(LNEWPR)
	int *LNEWPR;
	{
          size_t N;
	  N = LNEWPR_N;
	  memcpy(shm_addr->LNEWPR,LNEWPR,N);
	}

void fs_get_lnewpr__(LNEWPR)
	int *LNEWPR;
	{
          size_t N;
	  N = LNEWPR_N;
	  memcpy(LNEWPR,shm_addr->LNEWPR,N);
	}

void fs_set_lnewsk__(LNEWSK)
	int *LNEWSK;
	{
          size_t N;
	  N = LNEWSK_N;
          memcpy(shm_addr->LNEWSK, LNEWSK, N);
	}

void fs_get_lnewsk__(LNEWSK)
	int *LNEWSK;
	{
          size_t N;
	  N = LNEWSK_N;
	  memcpy(LNEWSK,shm_addr->LNEWSK,N);
	}

void fs_set_lprc__(LPRC)
	int *LPRC;
	{
          size_t N;
	  N = LPRC_N;
	  memcpy(shm_addr->LPRC,LPRC,N);
	}

void fs_get_lprc__(LPRC)
	int *LPRC;
	{
          size_t N;
	  N = LPRC_N;
	  memcpy(LPRC,shm_addr->LPRC,N);
	}

void fs_set_lstp__(LSTP)
	int *LSTP;
	{
          size_t N;
	  N = LSTP_N;
	  memcpy(shm_addr->LSTP,LSTP,N);
	}

void fs_get_lstp__(LSTP)
	int *LSTP;
	{
          size_t N;
	  N = LSTP_N;
	  memcpy(LSTP,shm_addr->LSTP,N);
	}

void fs_set_hwid__(hwid)
	int *hwid;
	{
          shm_addr->hwid = 0xff & *hwid;
        }

void fs_get_hwid__(hwid)
	int *hwid;
	{
          *hwid = shm_addr->hwid;
	}

void fs_set_lskd__(LSKD)
	int *LSKD;
	{
          size_t N;
          N = LSKD_N;
          memcpy(shm_addr->LSKD,LSKD,N);
        }

void fs_get_lskd__(LSKD)
	int *LSKD;
	{
          size_t N;
          N = LSKD_N;
          memcpy(LSKD,shm_addr->LSKD,N);
	}

void fs_set_rack__(rack)
	int *rack;
	{
	  shm_addr->equip.rack = *rack;
	}

void fs_get_rack__(rack)
	int *rack;
	{
	  *rack = shm_addr->equip.rack;
	}

void fs_set_rack_type__(rack_type)
	int *rack_type;
	{
	  shm_addr->equip.rack_type = *rack_type;
	}

void fs_get_rack_type__(rack_type)
	int *rack_type;
	{
	  *rack_type = shm_addr->equip.rack_type;
	}

void fs_set_drive__(drive)
	int *drive;
	{
	  shm_addr->equip.drive[0] = drive[0];
	  shm_addr->equip.drive[1] = drive[1];
	}

void fs_get_drive__(drive)
	int *drive;
	{
	  drive[0] = shm_addr->equip.drive[0];
	  drive[1] = shm_addr->equip.drive[1];
	}

void fs_set_drive_type__(drive_type)
	int *drive_type;
	{
	  shm_addr->equip.drive_type[0] = drive_type[0];
	  shm_addr->equip.drive_type[1] = drive_type[1];
	}

void fs_get_drive_type__(drive_type)
	int *drive_type;
	{
	  drive_type[0] = shm_addr->equip.drive_type[0];
	  drive_type[1] = shm_addr->equip.drive_type[1];
	}

void fs_set_met__(wx_met)
        int *wx_met;
        {
          shm_addr->equip.wx_met = *wx_met;
        }

void fs_get_met__(wx_met)
        int *wx_met;
        {
          *wx_met = shm_addr->equip.wx_met;
        }

void fs_set_iskdtpsd__(iskdtpsd,i)
	int *iskdtpsd,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->iskdtpsd[*i-1] = iskdtpsd[*i-1];
	}

void fs_get_iskdtpsd__(iskdtpsd,i)
	int *iskdtpsd,*i;
	{
	  if(*i==1||*i==2)
	    iskdtpsd[*i-1] = shm_addr->iskdtpsd[*i-1];
	}

void fs_set_imaxtpsd__(imaxtpsd,i)
	int *imaxtpsd,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->imaxtpsd[*i-1] = imaxtpsd[*i-1];
	}

void fs_get_imaxtpsd__(imaxtpsd,i)
	int *imaxtpsd,*i;
	{
	  if(*i==1||*i==2)
	    imaxtpsd[*i-1] = shm_addr->imaxtpsd[*i-1];
	}

void fs_set_freqlo__(freqlo,N)
	int *N;
        double *freqlo;
	{
	  shm_addr->lo.lo[*N] = *freqlo;
	}

void fs_get_freqlo__(freqlo,N)
	int *N;
	double *freqlo;
	{
	  *freqlo = shm_addr->lo.lo[*N];
	}

void fs_set_sblo__(sblo,N)
	int *N;
        int *sblo;
	{
	  shm_addr->lo.sideband[*N] = *sblo;
	}

void fs_get_sblo__(sblo,N)
	int *N;
	int *sblo;
	{
	  *sblo = shm_addr->lo.sideband[*N];
	}

void fs_get_diaman__(diaman)
	float *diaman;
	{
	  *diaman = shm_addr->diaman;
	}

void fs_set_diaman__(diaman)
        float *diaman;
	{
	  shm_addr->diaman = *diaman;
	}

void fs_get_slew1__(slew1)
	float *slew1;
	{
	  *slew1 = shm_addr->slew1;
	}

void fs_set_slew1__(slew1)
        float *slew1;
	{
	  shm_addr->slew1 = *slew1;
	}

void fs_get_slew2__(slew2)
	float *slew2;
	{
	  *slew2 = shm_addr->slew2;
	}

void fs_set_slew2__(slew2)
        float *slew2;
	{
	  shm_addr->slew2 = *slew2;
	}

void fs_get_uplim1__(uplim1)
	float *uplim1;
	{
	  *uplim1 = shm_addr->uplim1;
	}

void fs_set_uplim1__(uplim1)
        float *uplim1;
	{
	  shm_addr->uplim1 = *uplim1;
	}

void fs_get_uplim2__(uplim2)
	float *uplim2;
	{
	  *uplim2 = shm_addr->uplim2;
	}

void fs_set_uplim2__(uplim2)
        float *uplim2;
	{
	  shm_addr->uplim2 = *uplim2;
	}

void fs_get_lolim1__(lolim1)
	float *lolim1;
	{
	  *lolim1 = shm_addr->lolim1;
	}

void fs_set_lolim1__(lolim1)
        float *lolim1;
	{
	  shm_addr->lolim1 = *lolim1;
	}

void fs_get_lolim2__(lolim2)
	float *lolim2;
	{
	  *lolim2 = shm_addr->lolim2;
	}

void fs_set_lolim2__(lolim2)
        float *lolim2;
	{
	  shm_addr->lolim2 = *lolim2;
	}

void fs_get_i70kch__(i70kch)
        int *i70kch;
        {
          *i70kch = shm_addr->i70kch;
        }

void fs_set_i70kch__(i70kch)
        int *i70kch;
	{
	  shm_addr->i70kch = *i70kch;
	}

void fs_get_i20kch__(i20kch)
        int *i20kch;
        {
          *i20kch = shm_addr->i20kch;
        }

void fs_set_i20kch__(i20kch)
        int *i20kch;
	{
	  shm_addr->i20kch = *i20kch;
	}

void fs_get_time_coeff__(secs_off,epoch,offset,rate,span,model)
        long *secs_off,*epoch,*offset,*span;
	float *rate;
	char *model;
	{
		int index;

		*secs_off = shm_addr->time.secs_off;
		index = 01 & shm_addr->time.index;
		*epoch = shm_addr->time.epoch[index];
		*offset = shm_addr->time.offset[index];
		*rate = shm_addr->time.rate[index];
		*span = shm_addr->time.span[index];
                *model = shm_addr->time.model;
	}

void fs_set_time_coeff__(secs_off,epoch,offset,rate,span,model)
        long *secs_off,*epoch,*offset,*span;
	float *rate;
	char *model;
	{
		int index;

		shm_addr->time.secs_off = *secs_off;
		index = 01 & ~shm_addr->time.index;
		shm_addr->time.epoch[index] = *epoch;
		shm_addr->time.offset[index] = *offset;
		shm_addr->time.rate[index] = *rate;
		shm_addr->time.span[index] = *span;
                shm_addr->time.model = *model;
		shm_addr->time.index = index;
	}

void fs_get_vgroup__(vgroup,i)
     int *vgroup,*i;
{
  if(*i==1 || *i==2) {
    vgroup[0] = shm_addr->venable[*i-1].group[0];
    vgroup[1] = shm_addr->venable[*i-1].group[1];
    vgroup[2] = shm_addr->venable[*i-1].group[2];
    vgroup[3] = shm_addr->venable[*i-1].group[3];
    vgroup[4] = shm_addr->venable[*i-1].group[4];
    vgroup[5] = shm_addr->venable[*i-1].group[5];
    vgroup[6] = shm_addr->venable[*i-1].group[6];
    vgroup[7] = shm_addr->venable[*i-1].group[7];
  }
}

void fs_get_vfmenablehi__(vfmenablehi)
        int *vfmenablehi;
	{
	  *vfmenablehi = shm_addr->vform.enable.high;
	}

void fs_get_vfmenablelo__(vfmenablelo)
        int *vfmenablelo;
	{
	  *vfmenablelo = shm_addr->vform.enable.low;
	}

void fs_get_fm4enable__(fm4enable)
        long fm4enable[];
	{
	  fm4enable[0] = shm_addr->form4.enable[0];
	  fm4enable[1] = shm_addr->form4.enable[1];
	}

void fs_get_vrepro_equalizer__(equalizer,n,i)
        int *equalizer,*n,*i;
	{
	  if(*i==1||*i==2)
	    *equalizer = shm_addr->vrepro[*i-1].equalizer[*n-1];
	}

void fs_set_horaz__(HORAZ)
	float *HORAZ;
	{
          size_t N;
          N = HORAZ_N;
          memcpy(shm_addr->horaz,HORAZ,N);
        }

void fs_get_horaz__(HORAZ)
	float *HORAZ;
	{
          size_t N;
          N = HORAZ_N;
          memcpy(HORAZ,shm_addr->horaz,N);
	}


void fs_set_horel__(HOREL)
	float *HOREL;
	{
          size_t N;
          N = HOREL_N;
          memcpy(shm_addr->horel,HOREL,N);
        }

void fs_get_horel__(HOREL)
	float *HOREL;
	{
          size_t N;
          N = HOREL_N;
          memcpy(HOREL,shm_addr->horel,N);
	}

void fs_get_bbc_source__(source,n)
	int *source, *n;
	{
          *source=shm_addr->bbc[*n-1].source;
	}

void fs_get_wrhd_fs__(wrhd_fs,i)
        int *wrhd_fs,*i;
        {
	  if(*i==1)
	    wrhd_fs[0] = shm_addr->wrhd_fs[0];
	  else if (*i==2)
	    wrhd_fs[1] = shm_addr->wrhd_fs[1];
        }

void fs_set_wrhd_fs__(wrhd_fs,i)
        int *wrhd_fs,*i;
	{
	  if(*i==1)
	    shm_addr->wrhd_fs[0] = wrhd_fs[0];
	  else if (*i==2)
	    shm_addr->wrhd_fs[1] = wrhd_fs[1];
	}

void fs_get_rdhd_fs__(rdhd_fs,i)
        int *rdhd_fs,*i;
        {
	  if(*i==1)
	    rdhd_fs[0] = shm_addr->rdhd_fs[0];
	  else if (*i==2)
	    rdhd_fs[1] = shm_addr->rdhd_fs[1];
        }

void fs_set_rdhd_fs__(rdhd_fs,i)
        int *rdhd_fs,*i;
	{
	  if(*i==1)
	    shm_addr->rdhd_fs[0] = rdhd_fs[0];
	  else if (*i==2)
	    shm_addr->rdhd_fs[1] = rdhd_fs[1];
	}

void fs_get_vfm_xpnt__(vfm_xpnt)
        int *vfm_xpnt;
        {
          *vfm_xpnt = shm_addr->vfm_xpnt;
        }

void fs_set_vfm_xpnt__(vfm_xpnt)
        int *vfm_xpnt;
	{
	  shm_addr->vfm_xpnt = *vfm_xpnt;
	}

void fs_set_cwrap__(cwrap)
	char *cwrap;
	{
          size_t N;
	  N = CWRAP_N;
	  memcpy(shm_addr->cwrap,cwrap,N);
	}

void fs_get_cwrap__(cwrap)
	char *cwrap;
	{
          size_t N;
	  N = CWRAP_N;
	  memcpy(cwrap,shm_addr->cwrap,N);
	}

void fs_set_vacsw__(vacsw,i)
	int *vacsw,*i;
	{
	  if(*i==1)
	    shm_addr->vacsw[0] = vacsw[0];
	  else if (*i==2)
	    shm_addr->vacsw[1] = vacsw[1];
	}

void fs_get_vacsw__(vacsw,i)
	int *vacsw,*i;
	{
	  if(*i==1)
	    vacsw[0] = shm_addr->vacsw[0];
	  else if (*i==2)
	    vacsw[1] = shm_addr->vacsw[1];
	}

void fs_set_motorv2__(motorv2,i)
	float *motorv2;
	int *i;
	{
	  if(*i==1||*i==2) 
	    shm_addr->motorv2[*i-1] = motorv2[*i-1];
	}

void fs_get_motorv2__(motorv2,i)
	float *motorv2;
	int *i;
	{
	  if(*i==1||*i==2) 
	    motorv2[*i-1] = shm_addr->motorv2[*i-1];
	}

void fs_set_itpthick2__(itpthick2,i)
	int *itpthick2,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->itpthick2[*i-1] = itpthick2[*i-1];
	}

void fs_get_itpthick2__(itpthick2,i)
	int *itpthick2,*i;
	{
	  if(*i==1||*i==2)
	    itpthick2[*i-1] = shm_addr->itpthick2[*i-1];
	}

void fs_set_thin__(thin,i)
	int *thin,*i;
	{
	  if(*i==1)
	    shm_addr->thin[0] = thin[0];
	  else if (*i==2)
	    shm_addr->thin[1] = thin[1];
	}

void fs_get_thin__(thin,i)
	int *thin,*i;
	{
	  if(*i==1)
	    thin[0] = shm_addr->thin[0];
	  else if (*i==2)
	    thin[1] = shm_addr->thin[1];
	}

void fs_set_vac4__(vac4,i)
	int *vac4,*i;
	{
	  if(*i==1)
	    shm_addr->vac4[0] = vac4[0];
	  else if (*i==2)
	    shm_addr->vac4[1] = vac4[1];
	}

void fs_get_vac4__(vac4,i)
	int *vac4,*i;
	{
	  if(*i==1)
	    vac4[0] = shm_addr->vac4[0];
	  else if (*i==2)
	    vac4[1] = shm_addr->vac4[1];
	}

void fs_set_wrvolt2__(wrvolt2,i)
	float *wrvolt2;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->wrvolt2[*i-1] = wrvolt2[*i-1];
	}

void fs_get_wrvolt2__(wrvolt2,i)
	float *wrvolt2;
	int *i;
	{
	  if(*i==1||*i==2)
	    wrvolt2[*i-1] = shm_addr->wrvolt2[*i-1];
	}

void fs_set_wrvolt4__(wrvolt4,i)
	float *wrvolt4;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->wrvolt4[*i-1] = wrvolt4[*i-1];
	}

void fs_get_wrvolt4__(wrvolt4,i)
	float *wrvolt4;
	int *i;
	{
	  if(*i==1||*i==2)
	    wrvolt4[*i-1] = shm_addr->wrvolt4[*i-1];
	}

void fs_set_wrvolt42__(wrvolt42,i)
	float *wrvolt42;
	int *i;
	{
	  if(*i==1||*i==2)
	    shm_addr->wrvolt42[*i-1] = wrvolt42[*i-1];
	}

void fs_get_wrvolt42__(wrvolt42,i)
	float *wrvolt42;
	int *i;
	{
	  if(*i==1||*i==2)
	    wrvolt42[*i-1] = shm_addr->wrvolt42[*i-1];
	}

void fs_set_user_dev1_name__(user_dev1_name)
	char *user_dev1_name;
	{
	  memcpy(shm_addr->user_dev1_name,user_dev1_name,2);
	}

void fs_get_user_dev1_name__(user_dev1_name)
	char *user_dev1_name;
	{
	  memcpy(user_dev1_name,shm_addr->user_dev1_name,2);
	}

void fs_set_user_dev2_name__(user_dev2_name)
	char *user_dev2_name;
	{
	  memcpy(shm_addr->user_dev2_name,user_dev2_name,2);
	}

void fs_get_user_dev2_name__(user_dev2_name)
	char *user_dev2_name;
	{
	  memcpy(user_dev2_name,shm_addr->user_dev2_name,2);
	}

void fs_set_user_dev1_value__(user_dev1_value)
	double *user_dev1_value;
	{
	  shm_addr->user_dev1_value = *user_dev1_value;
	}

void fs_get_user_dev1_value__(user_dev1_value)
	double  *user_dev1_value;
	{
	  *user_dev1_value = shm_addr->user_dev1_value;
	}

void fs_set_user_dev2_value__(user_dev2_value)
	double *user_dev2_value;
	{
	  shm_addr->user_dev2_value = *user_dev2_value;
	}

void fs_get_user_dev2_value__(user_dev2_value)
	double  *user_dev2_value;
	{
	  *user_dev2_value = shm_addr->user_dev2_value;
	}

void fs_set_freqif3__(freqif3)
	long *freqif3;
	{
	  shm_addr->freqif3 = *freqif3;
	}

void fs_get_freqif3__(freqif3)
	long *freqif3;
	{
	  *freqif3 = shm_addr->freqif3;
	}

void fs_set_imixif3__(imixif3)
	int *imixif3;
	{
	  shm_addr->imixif3 = *imixif3;
	}

void fs_get_imixif3__(imixif3)
	int *imixif3;
	{
	  *imixif3 = shm_addr->imixif3;
	}

void fs_set_reccpu__(reccpu,i)
	int *reccpu,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->reccpu[*i-1] = reccpu[*i-1];
	}

void fs_get_reccpu__(reccpu,i)
	int *reccpu,*i;
	{
	  if(*i==1||*i==2)
	    reccpu[*i-1] = shm_addr->reccpu[*i-1];
	}

void fs_get_select__(select)
     int *select;
{
  *select=shm_addr->select;
}
void fs_set_select__(select)
     int *select;
{
  shm_addr->select=*select;
}
void fs_set_knewtape__(knewtape,i)
	int *knewtape,*i;
	{
	  if(*i==1||*i==2)
	    shm_addr->knewtape[*i-1] = knewtape[*i-1];
	}

void fs_get_knewtape__(knewtape,i)
	int *knewtape,*i;
	{
	  if(*i==1||*i==2)
	    knewtape[*i-1] = shm_addr->knewtape[*i-1];
	}

void fs_get_ihdmndel__(ihdmndel,i)
	int *ihdmndel,*i;
	{
	  if(*i==1||*i==2)
	    ihdmndel[*i-1] = shm_addr->ihdmndel[*i-1];
	}

void fs_set_ihdmndel__(ihdmndel,i)
        int *ihdmndel,*i;
        {
	  if(*i==1||*i==2)
	    shm_addr->ihdmndel[*i-1] = ihdmndel[*i-1];
        }


void fs_set_iat1if__(iat1if)
        int *iat1if;
        {
          shm_addr->iat1if = *iat1if;
        }

void fs_get_iat1if__(iat1if)
        int *iat1if;
        {
          *iat1if = shm_addr->iat1if;

        }
void fs_set_iat2if__(iat2if)
        int *iat2if;
        {
          shm_addr->iat2if = *iat2if;
        }

void fs_get_iat2if__(iat2if)
        int *iat2if;
        {
          *iat2if = shm_addr->iat2if;
        }

void fs_set_iat3if__(iat3if)
        int *iat3if;
        {
          shm_addr->iat3if= *iat3if;
        }

void fs_get_iat3if__(iat3if)
        int *iat3if;
        {
          *iat3if = shm_addr->iat3if;
        }

void fs_set_ifd_set__(ifd_set)
        int *ifd_set;
        {
          shm_addr->ifd_set= *ifd_set;
        }

void fs_get_ifd_set__(ifd_set)
        int *ifd_set;
        {
          *ifd_set = shm_addr->ifd_set;
        }
void fs_set_if3_set__(if3_set)
        int *if3_set;
        {
          shm_addr->if3_set= *if3_set;
        }

void fs_get_if3_set__(if3_set)
        int *if3_set;
        {
          *if3_set = shm_addr->if3_set;
        }

void fs_set_cablevl__(cablevl)
	float *cablevl;
	{
	  shm_addr->cablevl = *cablevl;
	}

void fs_set_imk4fmv__(imk4fmv)
	int *imk4fmv;
	{
	  shm_addr->imk4fmv = *imk4fmv;
	}

void fs_get_imk4fmv__(imk4fmv)
        int *imk4fmv;
        {
          *imk4fmv = shm_addr->imk4fmv;
        }
void fs_set_itpivc__(itpivc)
	int *itpivc;
	{
          size_t N;
	  N = sizeof(shm_addr->ITPIVC);
	  memcpy(shm_addr->ITPIVC,itpivc,N);
	}

void fs_get_itpivc__(itpivc)
	int *itpivc;
	{
          size_t N;
	  N =  sizeof(shm_addr->ITPIVC);
	  memcpy(itpivc,shm_addr->ITPIVC,N);
	}

void fs_set_iapdflg__(iapdflg)
	int *iapdflg;
	{
	  shm_addr->iapdflg = *iapdflg;
	}

void fs_get_iapdflg__(iapdflg)
        int *iapdflg;
        {
          *iapdflg = shm_addr->iapdflg;
        }

void fs_set_iswif3_fs__(iswif3_fs)
	int *iswif3_fs;
	{
          size_t N;
	  N =  sizeof(shm_addr->iswif3_fs);
	  memcpy(shm_addr->iswif3_fs,iswif3_fs,N);
	}

void fs_get_iswif3_fs__(iswif3_fs)
	int *iswif3_fs;
	{
          size_t N;
	  N =  sizeof(shm_addr->iswif3_fs);
	  memcpy(iswif3_fs,shm_addr->iswif3_fs,N);
	}

void fs_set_ipcalif3__(ipcalif3)
	int *ipcalif3;
	{
	  shm_addr->ipcalif3=*ipcalif3;
	}

void fs_get_ipcalif3__(ipcalif3)
	int *ipcalif3;
	{
	  *ipcalif3=shm_addr->ipcalif3;
	}

void fs_set_ibds__(ibds)
	int *ibds;
	{
	  shm_addr->ibds = *ibds;
	}

void fs_get_ibds__(ibds)
	int *ibds;
	{
	  *ibds = shm_addr->ibds;
	}

void fs_set_idevds__(idevds)
	char *idevds;
	{
	  size_t N;
	  N = IDEVDS_N;
	  memcpy(shm_addr->ds_dev,idevds,N);
	}

void fs_get_idevds__(idevds)
	char *idevds;
 	{
	  size_t N;
	  N = IDEVDS_N;
	  memcpy(idevds,shm_addr->ds_dev,N);
	}

void fs_set_ndas__(ndas)
	int *ndas;
	{
	  shm_addr->n_das = *ndas;
	}

void fs_get_ndas__(ndas)
	int *ndas;
	{
	  *ndas = shm_addr->n_das;
	}

void fs_set_idasfilt__(idasfilt)
	int *idasfilt;
	{
	  shm_addr->lba_image_reject_filters = *idasfilt;
	}

void fs_get_idasfilt__(idasfilt)
	int *idasfilt;
	{
	  *idasfilt = shm_addr->lba_image_reject_filters;
	}

void fs_set_idasbits__(idasbits)
	int *idasbits;
	{
	  shm_addr->lba_digital_input_format = *idasbits;
	}

void fs_get_idasbits__(idasbits)
	int *idasbits;
	{
	  *idasbits = shm_addr->lba_digital_input_format;
	}

void fs_set_ichlba__(ichlba,N)
	int *ichlba, *N;
	{
	  shm_addr->check.ifp[*N-1] = *ichlba;
	}

void fs_get_ichlba__(ichlba,N)
	int *ichlba, *N;
	{
	  *ichlba = shm_addr->check.ifp[*N-1];
	}

void fs_set_ifp_tpi__(ifp_tpi,i)
	unsigned long ifp_tpi;
	int *i;
	{
	  if(*i >0 && *i < 2*MAX_DAS+1) {
	    shm_addr->ifp_tpi[*i-1] = ifp_tpi;
	  }
	}

void fs_get_ifp_tpi__(ifp_tpi,i)
	unsigned long ifp_tpi;
	int *i;
	{
	  if(*i >0 && *i < 2*MAX_DAS+1) {
	    ifp_tpi = shm_addr->ifp_tpi[*i-1];
	  }
	}
void fs_set_logchg__(logchg)
	long *logchg;
	{
	  shm_addr->logchg = *logchg;
	}

void fs_get_logchg__(logchg)
	long *logchg;
	{
	  *logchg = shm_addr->logchg;
	}

