#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define INEXT_N 3
#define KENASTK_N 2
#define LFEET_N 5
#define LGEN_N 4
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

void fs_set_wrvolt__(wrvolt)
	float *wrvolt;
	{
	  shm_addr->wrvolt = *wrvolt;
	}

void fs_get_wrvolt__(wrvolt)
	float *wrvolt;
	{
	  *wrvolt = shm_addr->wrvolt;
	}

void fs_set_itpthick__(itpthick)
	int *itpthick;
	{
	  shm_addr->itpthick = *itpthick;
	}

void fs_get_itpthick__(itpthick)
	int *itpthick;
	{
	  *itpthick = shm_addr->itpthick;
	}

void fs_set_capstan__(capstan)
	int *capstan;
	{
	  shm_addr->capstan = *capstan;
	}

void fs_get_capstan__(capstan)
	int *capstan;
	{
	  *capstan = shm_addr->capstan;
	}

void fs_set_outscsl__(outscsl)
	float *outscsl;
	{
	  shm_addr->outscsl = *outscsl;
	}

void fs_get_outscsl__(outscsl)
	float *outscsl;
	{
	  *outscsl = shm_addr->outscsl;
	}

void fs_set_inscsl__(inscsl)
	float *inscsl;
	{
	  shm_addr->inscsl = *inscsl;
	}

void fs_get_inscsl__(inscsl)
	float *inscsl;
	{
	  *inscsl = shm_addr->inscsl;
	}

void fs_set_outscint__(outscint)
	float *outscint;
	{
	  shm_addr->outscint = *outscint;
	}

void fs_get_outscint__(outscint)
	float *outscint;
	{
	  *outscint = shm_addr->outscint;
	}

void fs_set_inscint__(inscint)
	float *inscint;
	{
	  shm_addr->inscint = *inscint;
	}

void fs_get_inscint__(inscint)
	float *inscint;
	{
	  *inscint = shm_addr->inscint;
	}

void fs_set_motorv__(motorv)
	float *motorv;
	{
	  shm_addr->motorv = *motorv;
	}

void fs_get_motorv__(motorv)
	float *motorv;
	{
	  *motorv = shm_addr->motorv;
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

void fs_set_ispeed__(ispeed)
	int *ispeed;
	{
	  shm_addr->ispeed = *ispeed;
	}

void fs_get_ispeed__(ispeed)
	int *ispeed;
	{
	  *ispeed = shm_addr->ispeed;
	}

void fs_get_cips__(cips)
	long *cips;
	{
	  *cips = shm_addr->cips;
	}

void fs_set_ienatp__(ienatp)
	int *ienatp;
	{
	  shm_addr->ienatp = *ienatp;
	}

void fs_get_ienatp__(ienatp)
	int *ienatp;
	{
	  *ienatp = shm_addr->ienatp;
	}

void fs_set_idirtp__(idirtp)
	int *idirtp;
	{
	  shm_addr->idirtp = *idirtp;
	}

void fs_get_idirtp__(idirtp)
	int *idirtp;
	{
	  *idirtp = shm_addr->idirtp;
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

void fs_set_ipashd__(ipashd)
	int ipashd[2];
	{
          shm_addr->ipashd[0]=ipashd[0];
          shm_addr->ipashd[1]=ipashd[1];
	}

void fs_get_ipashd__(ipashd)
	int ipashd[2];
	{
          ipashd[0]=shm_addr->ipashd[0];
          ipashd[1]=shm_addr->ipashd[1];
	}

void fs_set_posnhd__(posnhd)
	float posnhd[2];
	{
          shm_addr->posnhd[0]=posnhd[0];
          shm_addr->posnhd[1]=posnhd[1];
	}

void fs_get_posnhd__(posnhd)
	float posnhd[2];
	{
          posnhd[0]=shm_addr->posnhd[0];
          posnhd[1]=shm_addr->posnhd[1];
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

void fs_set_kenastk__(KENASTK)
	int *KENASTK;
        
	{
          int i;
          for(i=0;i<KENASTK_N;i++)
	    shm_addr->KENASTK[i]=*(KENASTK++);
	}

void fs_get_kenastk__(KENASTK)
	int *KENASTK;
	{
          int i;
	  for(i=0;i<KENASTK_N;i++)
	    *(KENASTK++)=shm_addr->KENASTK[i];
	}

void fs_set_irdytp__(IRDYTP)
	int *IRDYTP;
	{
	  shm_addr->IRDYTP = *IRDYTP;
	}

void fs_get_irdytp__(IRDYTP)
	int *IRDYTP;
	{
	  *IRDYTP = shm_addr->IRDYTP;
	}

void fs_set_itraka__(ITRAKA)
	int *ITRAKA;
	{
	  shm_addr->ITRAKA = *ITRAKA;
	}

void fs_get_itraka__(ITRAKA)
	int *ITRAKA;
	{
	  *ITRAKA = shm_addr->ITRAKA;
	}

void fs_set_itrakb__(ITRAKB)
	int *ITRAKB;
	{
	  shm_addr->ITRAKB = *ITRAKB;
	}

void fs_get_itrakb__(ITRAKB)
	int *ITRAKB;
	{
	  *ITRAKB = shm_addr->ITRAKB;
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

void fs_set_icaptp__(ICAPTP)
	int *ICAPTP;
	{
	  shm_addr->ICAPTP = *ICAPTP;
	}

void fs_get_icaptp__(ICAPTP)
	int *ICAPTP;
	{
          *ICAPTP = shm_addr->ICAPTP;
        }

void fs_set_istptp__(ISTPTP)
	int *ISTPTP;
	{
	  shm_addr->ISTPTP= *ISTPTP;
	}

void fs_get_istptp__(ISTPTP)
	int *ISTPTP;
	{
          *ISTPTP = shm_addr->ISTPTP; 
        }

void fs_set_itactp__(ITACTP)
	int *ITACTP;
	{
	  shm_addr->ITACTP= *ITACTP;
	}

void fs_get_itactp__(ITACTP)
	int *ITACTP;
	{
          *ITACTP = shm_addr->ITACTP; 
        }

void fs_set_klvdt_fs__(KLVDT_FS)
	int *KLVDT_FS;
	{
	  shm_addr->klvdt_fs = *KLVDT_FS;
	}

void fs_get_klvdt_fs__(KLVDT_FS)
	int *KLVDT_FS;
	{
	  *KLVDT_FS = shm_addr->klvdt_fs;
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

void fs_set_ichvkenable__(ichvkenable)
	int *ichvkenable;
	{
	  shm_addr->check.vkenable = *ichvkenable;
	}

void fs_get_ichvkenable__(ichvkenable)
	int *ichvkenable;
	{
	  *ichvkenable = shm_addr->check.vkenable;
	}

void fs_set_ichsystracks__(ichsystracks)
	int *ichsystracks;
	{
	  shm_addr->check.systracks = *ichsystracks;
	}

void fs_get_ichsystracks__(ichsystracks)
	int *ichsystracks;
	{
	  *ichsystracks = shm_addr->check.systracks;
	}

void fs_set_ichvkrepro__(ichvkrepro)
	int *ichvkrepro;
	{
	  shm_addr->check.vkrepro = *ichvkrepro;
	}

void fs_get_ichvkrepro__(ichvkrepro)
	int *ichvkrepro;
	{
	  *ichvkrepro = shm_addr->check.vkrepro;
	}

void fs_set_ichvkmove__(ichvkmove)
	int *ichvkmove;
	{
	  shm_addr->check.vkmove = *ichvkmove;
	}

void fs_get_ichvkmove__(ichvkmove)
	int *ichvkmove;
	{
	  *ichvkmove = shm_addr->check.vkmove;
	}

void fs_set_ichvklowtape__(ichvklowtape)
	int *ichvklowtape;
	{
	  shm_addr->check.vklowtape = *ichvklowtape;
	}

void fs_get_ichvklowtape__(ichvklowtape)
	int *ichvklowtape;
	{
	  *ichvklowtape = shm_addr->check.vklowtape;
	}

void fs_set_ichvkload__(ichvkload)
	int *ichvkload;
	{
	  shm_addr->check.vkload = *ichvkload;
	}

void fs_get_ichvkload__(ichvkload)
	int *ichvkload;
	{
	  *ichvkload = shm_addr->check.vkload;
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
	   shm_addr->check.rec = *ichvlba;
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
	   *ichvlba = shm_addr->check.rec;
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

void fs_set_tpivc__(TPIVC)
	int *TPIVC;
	{
	  shm_addr->TPIVC = *TPIVC;
	}

void fs_get_tpivc__(TPIVC)
	int *TPIVC;
	{
	  *TPIVC = shm_addr->TPIVC;
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

void fs_set_lfeet_fs__(LFEET_FS)
	int *LFEET_FS;
	{
          size_t N;
	  N = LFEET_N;
	  memcpy(shm_addr->LFEET_FS,LFEET_FS,N);
	}

void fs_get_lfeet_fs__(LFEET_FS)
	int *LFEET_FS;
	{
          size_t N;
	  N = LFEET_N;
	  memcpy(LFEET_FS,shm_addr->LFEET_FS,N);
	}

void fs_set_lgen__(lgen)
	int *lgen;
	{
          size_t N;
	  N = LGEN_N;
	  memcpy(shm_addr->lgen,lgen,N);
	}

void fs_get_lgen__(lgen)
	int *lgen;
	{
          size_t N;
	  N = LGEN_N;
	  memcpy(lgen,shm_addr->lgen,N);
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
	  shm_addr->equip.drive = *drive;
	}

void fs_get_drive__(drive)
	int *drive;
	{
	  *drive = shm_addr->equip.drive;
	}

void fs_set_drive_type__(drive_type)
	int *drive_type;
	{
	  shm_addr->equip.drive_type = *drive_type;
	}

void fs_get_drive_type__(drive_type)
	int *drive_type;
	{
	  *drive_type = shm_addr->equip.drive_type;
	}

void fs_set_iskdtpsd__(iskdtpsd)
	int *iskdtpsd;
	{
	  shm_addr->iskdtpsd = *iskdtpsd;
	}

void fs_get_iskdtpsd__(iskdtpsd)
	int *iskdtpsd;
	{
	  *iskdtpsd = shm_addr->iskdtpsd;
	}

void fs_set_imaxtpsd__(imaxtpsd)
	int *imaxtpsd;
	{
	  shm_addr->imaxtpsd = *imaxtpsd;
	}

void fs_get_imaxtpsd__(imaxtpsd)
	int *imaxtpsd;
	{
	  *imaxtpsd = shm_addr->imaxtpsd;
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

void fs_get_iacttp__(iacttp)
	int *iacttp;
	{
	  *iacttp = shm_addr->iacttp;
	}

void fs_set_iacttp__(iacttp)
        int *iacttp;
        {
          shm_addr->iacttp = *iacttp;
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

void fs_get_refreq__(refreq)
        float *refreq;
        {
          *refreq = shm_addr->refreq;
        }

void fs_set_refreq__(refreq)
        float *refreq;
	{
	  shm_addr->refreq = *refreq;
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

void fs_get_vgroup__(vgroup)
        int *vgroup;
	{
	  vgroup[0] = shm_addr->venable.group[0];
	  vgroup[1] = shm_addr->venable.group[1];
	  vgroup[2] = shm_addr->venable.group[2];
	  vgroup[3] = shm_addr->venable.group[3];
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

void fs_get_vrepro_equalizer__(equalizer,n)
        int *equalizer,*n;
	{
	  *equalizer = shm_addr->vrepro.equalizer[*n-1];
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

void fs_get_wrhd_fs__(wrhd_fs)
        int *wrhd_fs;
        {
          *wrhd_fs = shm_addr->wrhd_fs;
        }

void fs_set_wrhd_fs__(wrhd_fs)
        int *wrhd_fs;
	{
	  shm_addr->wrhd_fs = *wrhd_fs;
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

void fs_get_vrepromode__(vrepromode)
	int *vrepromode;
	{
          vrepromode[0]=shm_addr->vrepro.mode[0];
          vrepromode[1]=shm_addr->vrepro.mode[1];
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

void fs_set_vacsw__(vacsw)
	int *vacsw;
	{
	  shm_addr->vacsw = *vacsw;
	}

void fs_get_vacsw__(vacsw)
	int *vacsw;
	{
	  *vacsw = shm_addr->vacsw;
	}

void fs_set_motorv2__(motorv2)
	float *motorv2;
	{
	  shm_addr->motorv2 = *motorv2;
	}

void fs_get_motorv2__(motorv2)
	float *motorv2;
	{
	  *motorv2 = shm_addr->motorv2;
	}

void fs_set_itpthick2__(itpthick2)
	int *itpthick2;
	{
	  shm_addr->itpthick2 = *itpthick2;
	}

void fs_get_itpthick2__(itpthick2)
	int *itpthick2;
	{
	  *itpthick2 = shm_addr->itpthick2;
	}

void fs_set_thin__(thin)
	int *thin;
	{
	  shm_addr->thin = *thin;
	}

void fs_get_thin__(thin)
	int *thin;
	{
	  *thin = shm_addr->thin;
	}

void fs_set_vac4__(vac4)
	int *vac4;
	{
	  shm_addr->vac4 = *vac4;
	}

void fs_get_vac4__(vac4)
	int *vac4;
	{
	  *vac4 = shm_addr->vac4;
	}

void fs_set_wrvolt2__(wrvolt2)
	float *wrvolt2;
	{
	  shm_addr->wrvolt2 = *wrvolt2;
	}

void fs_get_wrvolt2__(wrvolt2)
	float *wrvolt2;
	{
	  *wrvolt2 = shm_addr->wrvolt2;
	}

void fs_set_wrvolt4__(wrvolt4)
	float *wrvolt4;
	{
	  shm_addr->wrvolt4 = *wrvolt4;
	}

void fs_get_wrvolt4__(wrvolt4)
	float *wrvolt4;
	{
	  *wrvolt4 = shm_addr->wrvolt4;
	}

void fs_set_wrvolt42__(wrvolt42)
	float *wrvolt42;
	{
	  shm_addr->wrvolt42 = *wrvolt42;
	}

void fs_get_wrvolt42__(wrvolt42)
	float *wrvolt42;
	{
	  *wrvolt42 = shm_addr->wrvolt42;
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
void fs_set_iyrctl_fs__(iyrctl_fs)
	int *iyrctl_fs;
	{
	  shm_addr->iyrctl_fs = *iyrctl_fs;
	}

void fs_get_iyrctl_fs__(iyrctl_fs)
	int *iyrctl_fs;
	{
	  *iyrctl_fs = shm_addr->iyrctl_fs;
	}

void fs_set_reccpu__(reccpu)
	int *reccpu;
	{
	  shm_addr->reccpu = *reccpu;
	}

void fs_get_reccpu__(reccpu)
	int *reccpu;
	{
	  *reccpu = shm_addr->reccpu;
	}

