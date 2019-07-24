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
#define LNAANT_N 8
#define LSORNA_N 10
#define IDEVANT_N 64
#define IDEVGPIB_N 64
#define IDEVLOG_N 320
#define IDEVMCB_N 64
#define HORAZ_N  4*MAX_HOR
#define HOREL_N  4*MAX_HOR

extern struct fscom *shm_addr;

void fs_set_ibmat_(ibmat)
	int *ibmat;
	{
	  shm_addr->ibmat = *ibmat;
	}

void fs_get_ibmat_(ibmat)
	int *ibmat;
	{
	  *ibmat = shm_addr->ibmat;
	}

void fs_set_ibmcb_(ibmcb)
	int *ibmcb;
	{
	  shm_addr->ibmcb = *ibmcb;
	}

void fs_get_ibmcb_(ibmcb)
	int *ibmcb;
	{
	  *ibmcb = shm_addr->ibmcb;
	}

void fs_set_wrvolt_(wrvolt)
	float *wrvolt;
	{
	  shm_addr->wrvolt = *wrvolt;
	}

void fs_get_wrvolt_(wrvolt)
	float *wrvolt;
	{
	  *wrvolt = shm_addr->wrvolt;
	}

void fs_set_itpthick_(itpthick)
	int *itpthick;
	{
	  shm_addr->itpthick = *itpthick;
	}

void fs_get_itpthick_(itpthick)
	int *itpthick;
	{
	  *itpthick = shm_addr->itpthick;
	}

void fs_set_capstan_(capstan)
	int *capstan;
	{
	  shm_addr->capstan = *capstan;
	}

void fs_get_capstan_(capstan)
	int *capstan;
	{
	  *capstan = shm_addr->capstan;
	}

void fs_set_outscsl_(outscsl)
	float *outscsl;
	{
	  shm_addr->outscsl = *outscsl;
	}

void fs_get_outscsl_(outscsl)
	float *outscsl;
	{
	  *outscsl = shm_addr->outscsl;
	}

void fs_set_inscsl_(inscsl)
	float *inscsl;
	{
	  shm_addr->inscsl = *inscsl;
	}

void fs_get_inscsl_(inscsl)
	float *inscsl;
	{
	  *inscsl = shm_addr->inscsl;
	}

void fs_set_outscint_(outscint)
	float *outscint;
	{
	  shm_addr->outscint = *outscint;
	}

void fs_get_outscint_(outscint)
	float *outscint;
	{
	  *outscint = shm_addr->outscint;
	}

void fs_set_inscint_(inscint)
	float *inscint;
	{
	  shm_addr->inscint = *inscint;
	}

void fs_get_inscint_(inscint)
	float *inscint;
	{
	  *inscint = shm_addr->inscint;
	}

void fs_set_motorv_(motorv)
	float *motorv;
	{
	  shm_addr->motorv = *motorv;
	}

void fs_get_motorv_(motorv)
	float *motorv;
	{
	  *motorv = shm_addr->motorv;
	}

void fs_set_tempwx_(tempwx)
	float *tempwx;
	{
	  shm_addr->tempwx = *tempwx;
	}

void fs_get_tempwx_(tempwx)
	float *tempwx;
	{
	  *tempwx = shm_addr->tempwx;
	}

void fs_set_humiwx_(humiwx)
	float *humiwx;
	{
	  shm_addr->humiwx = *humiwx;
	}

void fs_get_humiwx_(humiwx)
	float *humiwx;
	{
	  *humiwx = shm_addr->humiwx;
	}

void fs_set_preswx_(preswx)
	float *preswx;
	{
	  shm_addr->preswx = *preswx;
	}

void fs_get_preswx_(preswx)
	float *preswx;
	{
	  *preswx = shm_addr->preswx;
	}

void fs_set_ep1950_(ep1950)
	float *ep1950;
	{
	  shm_addr->ep1950 = *ep1950;
	}

void fs_get_ep1950_(ep1950)
	float *ep1950;
	{
	  *ep1950 = shm_addr->ep1950;
	}

void fs_set_epoch_(epoch)
	float *epoch;
	{
	  shm_addr->epoch = *epoch;
	}

void fs_get_epoch_(epoch)
	float *epoch;
	{
	  *epoch = shm_addr->epoch;
	}

void fs_set_iclopr_(iclopr)
	long *iclopr;
	{
	  shm_addr->iclopr = *iclopr;
	}

void fs_get_iclopr_(iclopr)
	long *iclopr;
	{
	  *iclopr = shm_addr->iclopr;
	}

void fs_set_iclbox_(iclbox)
	long *iclbox;
	{
	  shm_addr->iclbox = *iclbox;
	}

void fs_get_iclbox_(iclbox)
	long *iclbox;
	{
	  *iclbox = shm_addr->iclbox;
	}

void fs_set_cablev_(cablev)
	float *cablev;
	{
	  shm_addr->cablev = *cablev;
	}

void fs_set_ra50_(ra50)
	double *ra50;
	{
	  shm_addr->ra50 = *ra50;
	}

void fs_get_ra50_(ra50)
	double *ra50;
	{
	  *ra50 = shm_addr->ra50;
	}

void fs_set_dec50_(dec50)
	double *dec50;
	{
	  shm_addr->dec50 = *dec50;
	}

void fs_get_dec50_(dec50)
	double  *dec50;
	{
	  *dec50 = shm_addr->dec50;
	}

void fs_set_radat_(radat)
	double *radat;
	{
	  shm_addr->radat = *radat;
	}

void fs_get_radat_(radat)
	double *radat;
	{
	  *radat = shm_addr->radat;
	}

void fs_set_decdat_(decdat)
	double *decdat;
	{
	  shm_addr->decdat = *decdat;
	}

void fs_get_decdat_(decdat)
	double  *decdat;
	{
	  *decdat = shm_addr->decdat;
	}

void fs_set_height_(height)
	float *height;
	{
	  shm_addr->height = *height;
	}

void fs_get_height_(height)
	float  *height;
	{
	  *height = shm_addr->height;
	}

void fs_set_alat_(alat)
	double *alat;
	{
	  shm_addr->alat = *alat;
	}

void fs_get_alat_(alat)
	double  *alat;
	{
	  *alat = shm_addr->alat;
	}

void fs_set_wlong_(wlong)
	double *wlong;
	{
	  shm_addr->wlong = *wlong;
	}

void fs_get_wlong_(wlong)
	double  *wlong;
	{
	  *wlong = shm_addr->wlong;
	}

void fs_set_imodfm_(imodfm)
	int *imodfm;
	{
	  shm_addr->imodfm = *imodfm;
	}

void fs_get_imodfm_(imodfm)
	int *imodfm;
	{
	  *imodfm = shm_addr->imodfm;
	}

void fs_set_iratfm_(iratfm)
	int *iratfm;
	{
	  shm_addr->iratfm = *iratfm;
	}

void fs_get_iratfm_(iratfm)
	int *iratfm;
	{
	  *iratfm = shm_addr->iratfm;
	}

void fs_set_ispeed_(ispeed)
	int *ispeed;
	{
	  shm_addr->ispeed = *ispeed;
	}

void fs_get_ispeed_(ispeed)
	int *ispeed;
	{
	  *ispeed = shm_addr->ispeed;
	}

void fs_set_ienatp_(ienatp)
	int *ienatp;
	{
	  shm_addr->ienatp = *ienatp;
	}

void fs_get_ienatp_(ienatp)
	int *ienatp;
	{
	  *ienatp = shm_addr->ienatp;
	}

void fs_set_idirtp_(idirtp)
	int *idirtp;
	{
	  shm_addr->idirtp = *idirtp;
	}

void fs_get_idirtp_(idirtp)
	int *idirtp;
	{
	  *idirtp = shm_addr->idirtp;
	}

void fs_set_inp1if_(inp1if)
	int *inp1if;
	{
	  shm_addr->inp1if = *inp1if;
	}

void fs_get_inp1if_(inp1if)
	int *inp1if;
	{
	  *inp1if = shm_addr->inp1if;
	}

void fs_set_inp2if_(inp2if)
	int *inp2if;
	{
	  shm_addr->inp2if = *inp2if;
	}

void fs_get_inp2if_(inp2if)
	int *inp2if;
	{
	  *inp2if = shm_addr->inp2if;
	}

void fs_set_ionsor_(ionsor)
	int *ionsor;
	{
	  shm_addr->ionsor = *ionsor;
	}

void fs_get_ionsor_(ionsor)
	int *ionsor;
	{
	  *ionsor = shm_addr->ionsor;
	}

void fs_set_systmp_(systmp)
	float *systmp;
	{
          int i;
	  for(i=0;i<SYSTMP_N;i++)
            shm_addr->systmp[i]=*(systmp++);
	}

void fs_set_ipashd_(ipashd)
	int ipashd[2];
	{
          shm_addr->ipashd[0]=ipashd[0];
          shm_addr->ipashd[1]=ipashd[1];
	}

void fs_get_ipashd_(ipashd)
	int ipashd[2];
	{
          ipashd[0]=shm_addr->ipashd[0];
          ipashd[1]=shm_addr->ipashd[1];
	}

void fs_set_lfreqv_(lfreqv)
	char *lfreqv;
	{
          size_t N;
	  N = LFREQV_N;
	  memcpy(shm_addr->lfreqv,lfreqv,N);
	}

void fs_get_lfreqv_(lfreqv)
	char *lfreqv;
	{
          size_t N;
	  N = LFREQV_N;
	  memcpy(lfreqv,shm_addr->lfreqv,N);
	}

void fs_set_lnaant_(lnaant)
	char *lnaant;
	{
          size_t N;
	  N = LNAANT_N;
	  memcpy(shm_addr->lnaant,lnaant,N);
	}

void fs_get_lnaant_(lnaant)
	char *lnaant;
	{
          size_t N;
	  N = LNAANT_N;
	  memcpy(lnaant,shm_addr->lnaant,N);
	}

void fs_set_idevgpib_(idevgpib)
	char *idevgpib;
	{
          size_t N;
	  N = IDEVGPIB_N;
	  memcpy(shm_addr->idevgpib,idevgpib,N);
	}

void fs_get_idevgpib_(idevgpib)
	char *idevgpib;
	{
          size_t N;
	  N = IDEVGPIB_N;
	  memcpy(idevgpib,shm_addr->idevgpib,N);
	}

void fs_set_idevant_(idevant)
	char *idevant;
	{
          size_t N;
	  N = IDEVANT_N;
	  memcpy(shm_addr->idevant,idevant,N);
	}

void fs_get_idevant_(idevant)
	char *idevant;
	{
          size_t N;
	  N = IDEVANT_N;
	  memcpy(idevant,shm_addr->idevant,N);
	}

void fs_set_idevlog_(idevlog)
	char *idevlog;
	{
          size_t N;
	  N = IDEVLOG_N;
	  memcpy(shm_addr->idevlog,idevlog,N);
	}

void fs_get_idevlog_(idevlog)
	char *idevlog;
	{
          size_t N;
	  N = IDEVLOG_N;
	  memcpy(idevlog,shm_addr->idevlog,N);
	}

void fs_set_idevmcb_(idevmcb)
	char *idevmcb;
	{
          size_t N;
	  N = IDEVMCB_N;
	  memcpy(shm_addr->mcb_dev,idevmcb,N);
	}

void fs_get_idevmcb_(idevmcb)
	char *idevmcb;
	{
          size_t N;
	  N = IDEVMCB_N;
	  memcpy(idevmcb,shm_addr->mcb_dev,N);
	}

void fs_set_ndevlog_(ndevlog)
	int *ndevlog;
	{
	  shm_addr->ndevlog = *ndevlog;
	}

void fs_get_ndevlog_(ndevlog)
	int *ndevlog;
	{
	  *ndevlog= shm_addr->ndevlog;
	}

void fs_set_lsorna_(lsorna)
	char *lsorna;
	{
          size_t N;
	  N = LSORNA_N;
	  memcpy(shm_addr->lsorna,lsorna,N);
	}

void fs_get_lsorna_(lsorna)
	char *lsorna;
	{
          size_t N;
	  N = LSORNA_N;
	  memcpy(lsorna,shm_addr->lsorna,N);
	}

void fs_set_azoff_(AZOFF)
	float *AZOFF;
	{
	  shm_addr->AZOFF = *AZOFF;
	}

void fs_get_azoff_(AZOFF)
	float *AZOFF;
	{
	  *AZOFF = shm_addr->AZOFF;
	}

void fs_set_lexper_(LEXPER)
	int *LEXPER;
	{
          size_t N;
	  N = LEXPER_N;
	  memcpy(shm_addr->LEXPER,LEXPER,N);
	}

void fs_get_lexper_(LEXPER)
	int *LEXPER;
	{
          size_t N;
	  N = LEXPER_N;
	  memcpy(LEXPER,shm_addr->LEXPER,N);
	}

void fs_set_inext_(INEXT)
	short *INEXT;
        
	{
          int i;
          for(i=0;i<INEXT_N;i++)
	    shm_addr->INEXT[i]=*(INEXT++);
	}

void fs_get_inext_(INEXT)
	short *INEXT;
	{
          int i;
	  for(i=0;i<INEXT_N;i++)
	    *(INEXT++)=shm_addr->INEXT[i];
	}

void fs_set_kena_(KENASTK)
	int *KENASTK;
        
	{
          int i;
          for(i=0;i<KENASTK_N;i++)
	    shm_addr->KENASTK[i]=*(KENASTK++);
	}

void fs_get_kena_(KENASTK)
	int *KENASTK;
	{
          int i;
	  for(i=0;i<KENASTK_N;i++)
	    *(KENASTK++)=shm_addr->KENASTK[i];
	}

void fs_set_irdytp_(IRDYTP)
	int *IRDYTP;
	{
	  shm_addr->IRDYTP = *IRDYTP;
	}

void fs_get_irdytp_(IRDYTP)
	int *IRDYTP;
	{
	  *IRDYTP = shm_addr->IRDYTP;
	}

void fs_set_itraka_(ITRAKA)
	int *ITRAKA;
	{
	  shm_addr->ITRAKA = *ITRAKA;
	}

void fs_get_itraka_(ITRAKA)
	int *ITRAKA;
	{
	  *ITRAKA = shm_addr->ITRAKA;
	}

void fs_set_itrakb_(ITRAKB)
	int *ITRAKB;
	{
	  shm_addr->ITRAKB = *ITRAKB;
	}

void fs_get_itrakb_(ITRAKB)
	int *ITRAKB;
	{
	  *ITRAKB = shm_addr->ITRAKB;
	}

void fs_set_decoff_(DECOFF)
	float *DECOFF;
	{
	  shm_addr->DECOFF = *DECOFF;
	}

void fs_get_decoff_(DECOFF)
	float *DECOFF;
	{
	  *DECOFF = shm_addr->DECOFF;
	}

void fs_set_eloff_(ELOFF)
	float *ELOFF;
	{
	  shm_addr->ELOFF = *ELOFF;
	}

void fs_get_eloff_(ELOFF)
	float *ELOFF;
	{
	  *ELOFF = shm_addr->ELOFF;
	}

void fs_set_icaptp_(ICAPTP)
	int *ICAPTP;
	{
	  shm_addr->ICAPTP = *ICAPTP;
	}

void fs_get_icaptp_(ICAPTP)
	int *ICAPTP;
	{
          *ICAPTP = shm_addr->ICAPTP;
        }

void fs_set_iremtp_(IREMTP)
	int *IREMTP;
	{
	  shm_addr->IREMTP= *IREMTP;
	}

void fs_get_iremtp_(IREMTP)
	int *IREMTP;
	{
          *IREMTP = shm_addr->IREMTP; 
        }

void fs_set_istptp_(ISTPTP)
	int *ISTPTP;
	{
	  shm_addr->ISTPTP= *ISTPTP;
	}

void fs_get_istptp_(ISTPTP)
	int *ISTPTP;
	{
          *ISTPTP = shm_addr->ISTPTP; 
        }

void fs_set_itactp_(ITACTP)
	int *ITACTP;
	{
	  shm_addr->ITACTP= *ITACTP;
	}

void fs_get_itactp_(ITACTP)
	int *ITACTP;
	{
          *ITACTP = shm_addr->ITACTP; 
        }

void fs_set_klvdt_fs_(KLVDT_FS)
	int *KLVDT_FS;
	{
	  shm_addr->klvdt_fs = *KLVDT_FS;
	}

void fs_get_klvdt_fs_(KLVDT_FS)
	int *KLVDT_FS;
	{
	  *KLVDT_FS = shm_addr->klvdt_fs;
	}

void fs_set_kecho_(KECHO)
	int *KECHO;
	{
	  shm_addr->KECHO = *KECHO;
	}

void fs_get_kecho_(KECHO)
	int *KECHO;
	{
	  *KECHO = shm_addr->KECHO;
	}

void fs_set_khalt_(KHALT)
	int *KHALT;
	{
	  shm_addr->KHALT = *KHALT;
	}

void fs_get_khalt_(KHALT)
	int *KHALT;
	{
	  *KHALT = shm_addr->KHALT;
	}

void fs_set_ichvkenable_(ichvkenable)
	int *ichvkenable;
	{
	  shm_addr->check.vkenable = *ichvkenable;
	}

void fs_get_ichvkenable_(ichvkenable)
	int *ichvkenable;
	{
	  *ichvkenable = shm_addr->check.vkenable;
	}

void fs_set_ichvkrepro_(ichvkrepro)
	int *ichvkrepro;
	{
	  shm_addr->check.vkrepro = *ichvkrepro;
	}

void fs_get_ichvkrepro_(ichvkrepro)
	int *ichvkrepro;
	{
	  *ichvkrepro = shm_addr->check.vkrepro;
	}

void fs_set_ichvkmove_(ichvkmove)
	int *ichvkmove;
	{
	  shm_addr->check.vkmove = *ichvkmove;
	}

void fs_get_ichvkmove_(ichvkmove)
	int *ichvkmove;
	{
	  *ichvkmove = shm_addr->check.vkmove;
	}

void fs_set_ichvklowtape_(ichvklowtape)
	int *ichvklowtape;
	{
	  shm_addr->check.vklowtape = *ichvklowtape;
	}

void fs_get_ichvklowtape_(ichvklowtape)
	int *ichvklowtape;
	{
	  *ichvklowtape = shm_addr->check.vklowtape;
	}

void fs_set_ichvkload_(ichvkload)
	int *ichvkload;
	{
	  shm_addr->check.vkload = *ichvkload;
	}

void fs_get_ichvkload_(ichvkload)
	int *ichvkload;
	{
	  *ichvkload = shm_addr->check.vkload;
	}

void fs_set_ichfm_cn_tm_(ichfm_cn_tm)
	int *ichfm_cn_tm;
	{
	  shm_addr->check.fm_cn_tm = *ichfm_cn_tm;
	}

void fs_get_ichfm_cn_tm_(ichfm_cn_tm)
	int *ichfm_cn_tm;
	{
	  *ichfm_cn_tm = shm_addr->check.fm_cn_tm;
	}

void fs_set_raoff_(RAOFF)
	float *RAOFF;
	{
	  shm_addr->RAOFF = *RAOFF;
	}

void fs_get_raoff_(RAOFF)
	float *RAOFF;
	{
	  *RAOFF = shm_addr->RAOFF;
	}

void fs_set_xoff_(XOFF)
	float *XOFF;
	{
	  shm_addr->XOFF = *XOFF;
	}

void fs_get_xoff_(XOFF)
	float *XOFF;
	{
	  *XOFF = shm_addr->XOFF;
	}

void fs_set_yoff_(YOFF)
	float *YOFF;
	{
	  shm_addr->YOFF = *YOFF;
	}

void fs_get_yoff_(YOFF)
	float *YOFF;
	{
	  *YOFF = shm_addr->YOFF;
	}

void fs_set_icheck_(icheck,N)
	int *icheck, *N;
	{
	  shm_addr->ICHK[*N-1] = *icheck;
	}

void fs_get_icheck_(icheck,N)
	int *icheck, *N;
	{
	  *icheck = shm_addr->ICHK[*N-1];
	}

void fs_set_ichvlba_(ichvlba,N)
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

void fs_get_ichvlba_(ichvlba,N)
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

void fs_set_stchk_(ichk,n)
int *ichk,*n;
{
      shm_addr->stchk[*n-1]=*ichk;
}

void fs_get_stchk_(ichk,n)
int *ichk,*n;
{
      *ichk=shm_addr->stchk[*n-1];
}

void fs_set_sterp_(sterp)
int *sterp;
{
      shm_addr->sterp=*sterp;
}

void fs_set_stcnm_(lhol,n)
char lhol[2];
int *n;
{
      memcpy(shm_addr->stcnm[*n-1],lhol,2);
}

void fs_get_stcnm_(lhol,n)
char lhol[2];
int *n;
{
      memcpy(lhol,shm_addr->stcnm[*n-1],2);
}

void fs_set_irenvc_(IRENVC)
	int *IRENVC;
	{
	  shm_addr->IRENVC = *IRENVC;
	}

void fs_get_irenvc_(IRENVC)
	int *IRENVC;
	{
	  *IRENVC = shm_addr->IRENVC;
	}

void fs_set_ilokvc_(ILOKVC)
	int *ILOKVC;
	{
	  shm_addr->ILOKVC = *ILOKVC;
	}

void fs_get_ilokvc_(ILOKVC)
	int *ILOKVC;
	{
	  *ILOKVC = shm_addr->ILOKVC;
	}

void fs_set_tpivc_(TPIVC)
	int *TPIVC;
	{
	  shm_addr->TPIVC = *TPIVC;
	}

void fs_get_tpivc_(TPIVC)
	int *TPIVC;
	{
	  *TPIVC = shm_addr->TPIVC;
	}

void fs_set_llog_(LLOG)
	int *LLOG;
	{
          size_t N;
	  N = LLOG_N;
	  memcpy(shm_addr->LLOG,LLOG,N);
	}

void fs_get_llog_(LLOG)
	int *LLOG;
	{
          size_t N;
	  N = LLOG_N;
	  memcpy(LLOG,shm_addr->LLOG,N);
	}

void fs_set_lfeet_fs_(LFEET_FS)
	int *LFEET_FS;
	{
          size_t N;
	  N = LFEET_N;
	  memcpy(shm_addr->LFEET_FS,LFEET_FS,N);
	}

void fs_get_lfeet_fs_(LFEET_FS)
	int *LFEET_FS;
	{
          size_t N;
	  N = LFEET_N;
	  memcpy(LFEET_FS,shm_addr->LFEET_FS,N);
	}

void fs_set_lgen_(lgen)
	int *lgen;
	{
          size_t N;
	  N = LGEN_N;
	  memcpy(shm_addr->lgen,lgen,N);
	}

void fs_get_lgen_(lgen)
	int *lgen;
	{
          size_t N;
	  N = LGEN_N;
	  memcpy(lgen,shm_addr->lgen,N);
	}

void fs_set_lnewpr_(LNEWPR)
	int *LNEWPR;
	{
          size_t N;
	  N = LNEWPR_N;
	  memcpy(shm_addr->LNEWPR,LNEWPR,N);
	}

void fs_get_lnewpr_(LNEWPR)
	int *LNEWPR;
	{
          size_t N;
	  N = LNEWPR_N;
	  memcpy(LNEWPR,shm_addr->LNEWPR,N);
	}

void fs_set_lnewsk_(LNEWSK)
	int *LNEWSK;
	{
          size_t N;
	  N = LNEWSK_N;
          memcpy(shm_addr->LNEWSK, LNEWSK, N);
	}

void fs_get_lnewsk_(LNEWSK)
	int *LNEWSK;
	{
          size_t N;
	  N = LNEWSK_N;
	  memcpy(LNEWSK,shm_addr->LNEWSK,N);
	}

void fs_set_lprc_(LPRC)
	int *LPRC;
	{
          size_t N;
	  N = LPRC_N;
	  memcpy(shm_addr->LPRC,LPRC,N);
	}

void fs_get_lprc_(LPRC)
	int *LPRC;
	{
          size_t N;
	  N = LPRC_N;
	  memcpy(LPRC,shm_addr->LPRC,N);
	}

void fs_set_lstp_(LSTP)
	int *LSTP;
	{
          size_t N;
	  N = LSTP_N;
	  memcpy(shm_addr->LSTP,LSTP,N);
	}

void fs_get_lstp_(LSTP)
	int *LSTP;
	{
          size_t N;
	  N = LSTP_N;
	  memcpy(LSTP,shm_addr->LSTP,N);
	}

void fs_set_hwid_(hwid)
	int *hwid;
	{
          shm_addr->hwid = 0xff & *hwid;
        }

void fs_get_hwid_(hwid)
	int *hwid;
	{
          *hwid = shm_addr->hwid;
	}

void fs_set_lskd_(LSKD)
	int *LSKD;
	{
          size_t N;
          N = LSKD_N;
          memcpy(shm_addr->LSKD,LSKD,N);
        }

void fs_get_lskd_(LSKD)
	int *LSKD;
	{
          size_t N;
          N = LSKD_N;
          memcpy(LSKD,shm_addr->LSKD,N);
	}

void fs_set_rack_(rack)
	int *rack;
	{
	  shm_addr->equip.rack = *rack;
	}

void fs_get_rack_(rack)
	int *rack;
	{
	  *rack = shm_addr->equip.rack;
	}

void fs_set_drive_(drive)
	int *drive;
	{
	  shm_addr->equip.drive = *drive;
	}

void fs_get_drive_(drive)
	int *drive;
	{
	  *drive = shm_addr->equip.drive;
	}

void fs_set_iskdtpsd_(iskdtpsd)
	int *iskdtpsd;
	{
	  shm_addr->iskdtpsd = *iskdtpsd;
	}

void fs_get_iskdtpsd_(iskdtpsd)
	int *iskdtpsd;
	{
	  *iskdtpsd = shm_addr->iskdtpsd;
	}

void fs_set_imaxtpsd_(imaxtpsd)
	int *imaxtpsd;
	{
	  shm_addr->imaxtpsd = *imaxtpsd;
	}

void fs_get_imaxtpsd_(imaxtpsd)
	int *imaxtpsd;
	{
	  *imaxtpsd = shm_addr->imaxtpsd;
	}

void fs_set_freqlo_(freqlo,N)
	int *N;
        float *freqlo;
	{
	  shm_addr->freqlo[*N] = *freqlo;
	}

void fs_get_freqlo_(freqlo,N)
	int *N;
	float *freqlo;
	{
	  *freqlo = shm_addr->freqlo[*N];
	}

void fs_set_frequp_(frequp,N)
	int *N;
        float *frequp;
	{
	  shm_addr->frequp[*N] = *frequp;
	}

void fs_get_frequp_(frequp,N)
	int *N;
	float *frequp;
	{
	  *frequp = shm_addr->frequp[*N];
	}

void fs_get_diaman_(diaman)
	float *diaman;
	{
	  *diaman = shm_addr->diaman;
	}

void fs_set_diaman_(diaman)
        float *diaman;
	{
	  shm_addr->diaman = *diaman;
	}

void fs_get_slew1_(slew1)
	float *slew1;
	{
	  *slew1 = shm_addr->slew1;
	}

void fs_set_slew1_(slew1)
        float *slew1;
	{
	  shm_addr->slew1 = *slew1;
	}

void fs_get_slew2_(slew2)
	float *slew2;
	{
	  *slew2 = shm_addr->slew2;
	}

void fs_set_slew2_(slew2)
        float *slew2;
	{
	  shm_addr->slew2 = *slew2;
	}

void fs_get_uplim1_(uplim1)
	float *uplim1;
	{
	  *uplim1 = shm_addr->uplim1;
	}

void fs_set_uplim1_(uplim1)
        float *uplim1;
	{
	  shm_addr->uplim1 = *uplim1;
	}

void fs_get_uplim2_(uplim2)
	float *uplim2;
	{
	  *uplim2 = shm_addr->uplim2;
	}

void fs_set_uplim2_(uplim2)
        float *uplim2;
	{
	  shm_addr->uplim2 = *uplim2;
	}

void fs_get_lolim1_(lolim1)
	float *lolim1;
	{
	  *lolim1 = shm_addr->lolim1;
	}

void fs_set_lolim1_(lolim1)
        float *lolim1;
	{
	  shm_addr->lolim1 = *lolim1;
	}

void fs_get_lolim2_(lolim2)
	float *lolim2;
	{
	  *lolim2 = shm_addr->lolim2;
	}

void fs_set_lolim2_(lolim2)
        float *lolim2;
	{
	  shm_addr->lolim2 = *lolim2;
	}

void fs_get_iacttp_(iacttp)
	int *iacttp;
	{
	  *iacttp = shm_addr->iacttp;
	}

void fs_set_iacttp_(iacttp)
        int *iacttp;
        {
          shm_addr->iacttp = *iacttp;
        }

void fs_get_i70kch_(i70kch)
        int *i70kch;
        {
          *i70kch = shm_addr->i70kch;
        }

void fs_set_i70kch_(i70kch)
        int *i70kch;
	{
	  shm_addr->i70kch = *i70kch;
	}

void fs_get_i20kch_(i20kch)
        int *i20kch;
        {
          *i20kch = shm_addr->i20kch;
        }

void fs_set_i20kch_(i20kch)
        int *i20kch;
	{
	  shm_addr->i20kch = *i20kch;
	}

void fs_get_refreq_(refreq)
        float *refreq;
        {
          *refreq = shm_addr->refreq;
        }

void fs_set_refreq_(refreq)
        float *refreq;
	{
	  shm_addr->refreq = *refreq;
	}

void fs_get_time_coeff_(secs_off,epoch,offset,rate,span,model)
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

void fs_set_time_coeff_(secs_off,epoch,offset,rate,span,model)
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

void fs_get_vgroup_(vgroup)
        int *vgroup;
	{
	  vgroup[0] = shm_addr->venable.group[0];
	  vgroup[1] = shm_addr->venable.group[1];
	  vgroup[2] = shm_addr->venable.group[2];
	  vgroup[3] = shm_addr->venable.group[3];
	}

void fs_get_vrepro_equalizer_(equalizer,n)
        int *equalizer,*n;
	{
	  *equalizer = shm_addr->vrepro.equalizer[*n-1];
	}

void fs_set_horaz_(HORAZ)
	float *HORAZ;
	{
          size_t N;
          N = HORAZ_N;
          memcpy(shm_addr->horaz,HORAZ,N);
        }

void fs_get_horaz_(HORAZ)
	float *HORAZ;
	{
          size_t N;
          N = HORAZ_N;
          memcpy(HORAZ,shm_addr->horaz,N);
	}


void fs_set_horel_(HOREL)
	float *HOREL;
	{
          size_t N;
          N = HOREL_N;
          memcpy(shm_addr->horel,HOREL,N);
        }

void fs_get_horel_(HOREL)
	float *HOREL;
	{
          size_t N;
          N = HOREL_N;
          memcpy(HOREL,shm_addr->horel,N);
	}

void fs_get_bbc_source_(source,n)
	int *source, *n;
	{
          *source=shm_addr->bbc[*n-1].source;
	}
