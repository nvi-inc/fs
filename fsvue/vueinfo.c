/*********************************************************************
 * Function vueinfo.c (main) 
 *
 *  calls: 
 *  vueinfo - get information for fsvue 
 *********************************************************************/
#include <ncurses.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include "../monit/dpi.h"
/* S2 stuff */
#include "../rclco/rcl/rcl_def.h"
#include "../rclco/rcl/rcl_cmd.h"

#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */


struct fscom *fs;

static char *key_mode[ ]={ "prn", "v"  , "m"  , "a"  , "b"  , "c"  ,
			   "b1" , "b2" , "c1" , "c2" ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28"};
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)

static char *key_mode4[]={ "m"  , "a"  , "b1" , "b2" , "c1" , "c2" ,
                           "e1" , "e2" , "e3" , "e4" ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28"};

#define NKEY_MODE4 sizeof(key_mode4)/sizeof( char *)

/*  */
void setup_ids();
void helpstr_();
void get_err();

#define MAX_BUF 256
#define MAX_OUT 256
#define MAX_LEN 256+1
#define BLANK 8

static char *r[] = {
  "MK3","VLBA","MK4","S2","VLBA4","K4",
  "K4MK4","K4K3","VLBAG","VLBA2","MK4B","K41",
  "K41U","K42","K42A","K42BU","VLBAB","K41DMS",
  "K42DMS"};


main(int argc, char *argv[])
{
  int kMrack, kMdrive[2], kS2drive[2],kVrack,kVdrive[2],kM3rack,kM4rack,
    kV4rack, kK4drive[2],kK41drive_type[2],kK42drive_type[2],selectm;
  int i, j, iyear;
  int ip[5], it[6];
  char what[10];
  char cnam[120];
  char runstr[120], cthp[10];
  int clength;
  int rack, rack_t;
  int drive[2], drive_t[2];
  int drive1;
  int irah, iram, idecd, idecm;
  float thp, ras;
  double raxx,dcxx;
  double pos_ra_dec,azim,elev;
  int ifs[3];
  int *ierr, posdeg=0, ivalue, iversion;
  char *str, site[8];
  short int buffint[120];
  char buff[120];
  char log_name[15];
  char *whichone;
  int *p;

/* connect me to the FS */
  putpname("vueinfo");
  setup_ids();
  fs = shm_addr;
  
  strcpy(what,argv[1]);

  rte_time(it,&iyear);

  if(strstr(what,"help")) {
    rack=shm_addr->equip.rack;
    drive[0]=shm_addr->equip.drive[0];
    drive[1]=shm_addr->equip.drive[1];
    ierr=0;
    strcpy(cnam,argv[2]);
    i=strlen(cnam);
    cnam[i]='\0';
    runstr[0]='\0';
    what_help(cnam,i,runstr,rack,drive[0],drive[1],ierr,0,0);
    /*helpstr_(cnam,i,runstr,rack,drive[0],drive[1],ierr,0,0);*/
    strcpy(buff,"helpsh ");
    strcat(buff,runstr);
    system(buff);
    exit(0);
  } else if (strstr(what,"ifs")) {
    ifs[0]=shm_addr->iat1if;
    ifs[1]=shm_addr->iat2if;
    ifs[2]=shm_addr->iat3if;
    printf("%d,%d,%d",ifs[0],ifs[1],ifs[2]);
    exit(0);
  } else if (strstr(what,"wxn")) {
    /*    if(what[3]=='t') sprintf(cthp,"%5.1f",shm_addr->wxn.temp);
    else if(what[3]=='h') sprintf(cthp,"%5.1f",shm_addr->wxn.humi);
    else if(what[3]=='p') sprintf(cthp,"%6.1f",shm_addr->wxn.pres);
    else if(what[3]=='s') sprintf(cthp,"%4.1f",shm_addr->wxn.wsp);
    else if(what[3]=='d') sprintf(cthp,"%3d",shm_addr->wxn.wdir);
    else sprintf(cthp,"NODATA");;
    cthp[strlen(cthp)]='\0';
    printf("%s",cthp);
    exit(0);*/
  } else if (strstr(what,"wx")) {
    if(what[2]=='t') sprintf(cthp,"%5.1f",shm_addr->tempwx);
    else if(what[2]=='h') sprintf(cthp,"%5.1f",shm_addr->humiwx);
    else if(what[2]=='p') sprintf(cthp,"%6.1f",shm_addr->preswx);
    /*else if(what[2]=='s') sprintf(cthp,"%4.1f",shm_addr->wxn.wsp);
      else if(what[2]=='d') sprintf(cthp,"%3d",shm_addr->wxn.wdir);*/
    else sprintf(cthp,"NODATA");;
    cthp[strlen(cthp)]='\0';
    printf("%s",cthp);
    exit(0);
  } else if (strstr(what,"sour")) {
    sprintf(buff,"%.10s",shm_addr->lsorna);
    if(buff[0]==' ');
    sprintf(buff,"%.10s","NO SOURCE ");
    buff[strlen(buff)]='\0';
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"pos")) {
    if (memcmp(shm_addr->lsorna,"azel      ",10)==0 ||
	memcmp(shm_addr->lsorna,"azeluncr  ",10)==0 ) {
      posdeg = 1; 
      /* Convert az/el in common to actual ra/dec */
      cnvrt(2,shm_addr->radat,shm_addr->decdat,&raxx,&dcxx,it,
	    shm_addr->alat,shm_addr->wlong);
    } else if (memcmp(shm_addr->lsorna,"stow      ",10)==0 ||
	       memcmp(shm_addr->lsorna,"service   ",10)==0 ||
	       memcmp(shm_addr->lsorna,"hold      ",10)==0 ||
	       memcmp(shm_addr->lsorna,"disable   ",10)==0 ||
	       memcmp(shm_addr->lsorna,"idle      ",10)==0 ||
	       memcmp(shm_addr->lsorna,"          ",10)==0)  {
      posdeg = 1; 
      raxx = 0.0;
      dcxx = 0.0;
    } else if (memcmp(shm_addr->lsorna,"xy        ",10)==0) {
      posdeg = 1; 
      /* Convert x/y in common to actual ra/dec */
      cnvrt(7,shm_addr->radat,shm_addr->decdat,&raxx,&dcxx,it,
	    shm_addr->alat,shm_addr->wlong);
    }
    if(what[3]=='r') {
      if (posdeg == 1) 
	pos_ra_dec = raxx*12.0/M_PI;
      else
	pos_ra_dec = shm_addr->ra50*12.0/M_PI;
      irah=(int)(pos_ra_dec+.000001);
      iram=(pos_ra_dec-irah)*60.0;
      ras=(pos_ra_dec-irah-iram/60.0)*3600.0;
      sprintf(buff,"%02dh%02dm%04.1fs",irah,iram,ras);
    } else if(what[3]=='d'){ 
      if (posdeg == 1) {
	pos_ra_dec=fabs(dcxx)*180.0/M_PI; 
      } else {
	pos_ra_dec=fabs(shm_addr->dec50)*180.0/M_PI; 
      }
      idecd=(int)(pos_ra_dec+.00001);
      idecm= (pos_ra_dec-idecd)*60.0;
      if(memcmp(shm_addr->lsorna,"          ",10)==0)  {
	if (shm_addr->dec50 < 0 || dcxx < 0)
	sprintf(buff,"-%02dd%02dm (     )",idecd,idecm);
	else
	sprintf(buff,"%02dd%02dm (     )",idecd,idecm);
      } else {
	sprintf(buff,"%02dd%02dm (%4.0f)",idecd,idecm,shm_addr->ep1950);
      }
    } else sprintf(buff,"$$$$$$$$ ($)");
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"site")) {
    strncpy(site,shm_addr->lnaant,8);
    for(i=0; i<BLANK; i++) {
      if(site[i]==0x20 || i==9) {
	break;
      }
    }
    site[i]='\0';
    printf("%s",site);
    exit(0);
  } else if (strstr(what,"lskd")) {
    strncpy(site,shm_addr->LSKD,8);
    for(i=0; i<BLANK; i++) {
      if(site[i-1]==0x20 || i==9) {
	break;
      }
    }
    site[i]='\0';
    if (shm_addr->KHALT!=0) {
      if(it[1]%2==0)
	strcpy(buff,"HALT\0");
      if(buff[0]!='H') strcpy(buff,"HALT\0");
    } else {
      strcpy(buff,"    \0");
      if(buff[0]!=' ') strcpy(buff,"    \0");
    }
    printf("%s %.4s",site,buff);
    exit(0);
  } else if (strstr(what,"time")) {
    printf("%4d.%.3d.%.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],it[1]);
    exit(0);
  } else if (strstr(what,"rack")) {
    rack=shm_addr->equip.rack;
    rack_t=shm_addr->equip.rack_type;
    for(i=0,j=1;i<18;i++,j=j*2) {
      if(rack==j) {
	printf("%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("None");
    for(i=0,j=1;i<18;i++,j=j*2){
      if(rack_t==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("/None");
    exit(0);
  } else if (strstr(what,"drive1")) {
    drive[0]=shm_addr->equip.drive[0];
    drive_t[0]=shm_addr->equip.drive_type[0];
    for(i=0,j=1;i<18;i++,j=j*2) {
      if(drive[0]==j) {
	printf("(1)%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("(1)None");
    for(i=0,j=1;i<18;i++,j=j*2){
      if(drive_t[0]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("/None");
    exit(0);
  } else if (strstr(what,"drive2")) {
    drive[1]=shm_addr->equip.drive[1];
    drive_t[1]=shm_addr->equip.drive_type[1];
    for(i=0,j=1;i<18;i++,j=j*2) {
      if(drive[1]==j) {
	printf("(2)%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("(2)None");
    for(i=0,j=1;i<18;i++,j=j*2){
      if(drive_t[1]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=18) printf("/None");
    exit(0);
  } else if (strstr(what,"err")) {
    strcpy(buff,"Under Development NOT AVAILABLE");
    i=strlen(buff);
    buff[i]='\0';
    printf("%s\n",buff);
    exit(0);
  } else if (strstr(what,"log")) {
    strncpy(log_name,shm_addr->LLOG,8);
    for(i=0; i<BLANK; i++)
      if(log_name[i]==0x20) break;
	log_name[i++]='.';
	log_name[i++]='l';
	log_name[i++]='o';
	log_name[i++]='g';
	log_name[i]='\0';
	printf("%s",log_name);
	exit(0);
  } else if (strstr(what,"s_or_t")) {
    if (shm_addr->ionsor == 0)
      printf("SLEWING ");
    else if (shm_addr->ionsor == 1)
      printf("TRACKING");
    else
    printf("        ");
    exit(0);
  } else if (strstr(what,"inext")) {
    sprintf(buff,"%02d:%02d:%02d NEXT",
	    shm_addr->INEXT[0],shm_addr->INEXT[1],shm_addr->INEXT[2]);
    buff[strlen(buff)]='\0';
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"cablev")) {
    sprintf(buff,"%8.6fs",shm_addr->cablev);
    buff[strlen(buff)]='\0';
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"mode")) {
    selectm=shm_addr->select;
    if (kS2drive[selectm]) {
      char mode[21];
      strcpy(mode,shm_addr->rec_mode.mode);
      for (i=strlen(mode);i<sizeof(mode);i++)
	mode[i]=' ';
      mode[sizeof(mode)-1]=0;
      sprintf(buff,"%s",shm_addr->rec_mode.mode);/*mode);*/
    } else if (kK4drive[selectm]) {
      sprintf(buff," k4 ");
    } else if (kM3rack) {
      switch (shm_addr->imodfm) {
      case 0:
	sprintf(buff,"  a ");
	break;
      case 1:
	sprintf(buff,"  b ");
	break;
      case 2:
	sprintf(buff,"  c ");
	break;
      case 3:
	sprintf(buff,"  d ");
	break;
      default:
	sprintf(buff,"    ");
      }
    } else if(kM4rack||kV4rack) {
      ivalue=shm_addr->form4.mode;
      if(ivalue >= 0 && ivalue <= NKEY_MODE4)
	sprintf(buff,"%-4s",key_mode4[ivalue]);
      else
	sprintf(buff,"%-4s",key_mode4[ivalue]);
    } else if(kVrack &&!kV4rack) {
    ivalue=shm_addr->vform.mode;
    /* hex value for version 290 */
      if (shm_addr->form_version < 656)
	iversion = 0x7000;
      else
	iversion = 0x0002;
      if(ivalue >= 0 && ivalue <= NKEY_MODE)
	sprintf(buff,"%-4s",key_mode[ivalue]);
      else
	sprintf(buff,"    ",key_mode[ivalue]);
    }
    buff[strlen(buff)]='\0';
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"rate")) {
    selectm=shm_addr->select;
    /* RATE */
    if(kS2drive[selectm]) {
      if(shm_addr->rec_mode.group>7)
	sprintf(buff,"$");
      else if(shm_addr->rec_mode.group>=0)
	sprintf(buff,"%1d",0x7&shm_addr->rec_mode.group);
    } if(kK4drive[selectm] && kK41drive_type[selectm]) {
      sprintf(buff,"4.00");
    } else if (kM3rack) {
    switch (shm_addr->iratfm) {
    case 0:
      sprintf(buff,"8.00");
      break;
    case 1:
      sprintf(buff,"0.00");
      break;
    case 2:
      sprintf(buff,"0.12");
      break;
    case 3:
      sprintf(buff,"0.25");
      break;
    case 4:
      sprintf(buff,"0.50");
      break;
    case 5:
      sprintf(buff,"1.00");
      break;
    case 6:
      sprintf(buff,"2.00");
      break;
    case 7:
      sprintf(buff,"4.00");
      break;
    default:
      sprintf(buff,"    ");
    }
  } else if (kM4rack||kV4rack) {
    switch (shm_addr->form4.rate) {
    case 0:
      sprintf(buff,"0.12");
      break;
    case 1:
      sprintf(buff,"0.25");
      break;
    case 2:
      sprintf(buff,"0.50");
      break;
    case 3:
      sprintf(buff,"1.00");
      break;
    case 4:
      sprintf(buff,"2.00");
      break;
    case 5:
      sprintf(buff,"4.00");
      break;
    case 6:
      sprintf(buff,"8.00");
      break;
    case 7:
      sprintf(buff,"16.0");
      break;
    case 8:
      sprintf(buff,"32.0");
      break;
    default:
      sprintf(buff,"    ");
      break;
    }
  } else if (kVrack && !kV4rack) {
    switch (shm_addr->vform.rate) {
    case 0:
      sprintf(buff,"0.25");
      break;
    case 1:
      sprintf(buff,"0.50");
      break;
    case 2:
      sprintf(buff,"1.00");
      break;
    case 3:
      sprintf(buff,"2.00");
      break;
    case 4:
      sprintf(buff,"4.00");
      break;
    case 5:
      sprintf(buff,"8.00");
      break;
    case 6:
      sprintf(buff,"16.0");
      break;
    case 7:
      sprintf(buff,"32.0");
      break;
    default:
      sprintf(buff,"    ");
      break;
    }
  }
    buff[strlen(buff)]='\0';
    printf("%s",buff);
    exit(0);
  } else if (strstr(what,"list")) {
    strncpy(site,shm_addr->LSKD,8);
    if (strstr(site,"none")) {
      printf("no schedule currently active");
    } else {
      printf("list");
    }
    exit(0);
  } else if (strstr(what,"tactim")) {
    printf("day[%f]\nmsec_counter[%0.4f]\nusec_bais[%0.4f]\ncooked_correction[%0.4f]\nRMS[%0.4f]\nusec_average[%0.4f]\nmax[%0.4f]\nmin[%0.4f]\nusec_correction[%d]\nnsec_accuracy[%d]\nsec_average[%d]",
	   shm_addr->tacd.day_frac,
	   shm_addr->tacd.msec_counter,
	   shm_addr->tacd.usec_bias,
	   shm_addr->tacd.cooked_correction,
	   shm_addr->tacd.rms,
	   shm_addr->tacd.usec_average,
	   shm_addr->tacd.max,
	   shm_addr->tacd.min,
	   shm_addr->tacd.usec_correction,
	   shm_addr->tacd.nsec_accuracy,
	   shm_addr->tacd.sec_average);
      exit(0);
  } else if (strstr(what,"fscom")) {
    printf("[%d] ",fs->iclbox);
    printf("[%d] ",fs->iclopr);
    printf("[%0.4f] ",fs->AZOFF);
    printf("[%0.4f] ",fs->DECOFF);
    printf("[%0.4f] ",fs->ELOFF);
    printf("[%d] ",fs->ibmat);
    printf("[%d]\n",fs->ibmcb);
    printf("[%d,%d] ",fs->ICAPTP[0],fs->ICAPTP[1]);
    printf("[%d,%d] ",fs->IRDYTP[0],fs->IRDYTP[1]);
    printf("[%d] ",fs->IRENVC);
    printf("[%d] ",fs->ILOKVC);
    printf("[%d,%d,",fs->ITRAKA[0],fs->ITRAKA[1]);
    printf("%d,%d]\n",fs->ITRAKB[0],fs->ITRAKB[1]);
    printf("[%d,%d,%d,",fs->TPIVC[0],fs->TPIVC[1],fs->TPIVC[2]);
    printf("%d,%d,%d,",fs->TPIVC[3],fs->TPIVC[4],fs->TPIVC[5]);
    printf("%d,%d,%d,",fs->TPIVC[6],fs->TPIVC[7],fs->TPIVC[8]);
    printf("%d,%d,%d]\n",fs->TPIVC[9],fs->TPIVC[10],fs->TPIVC[11]);
    printf("[%0.4f,%0.4f] ",fs->ISTPTP[0],fs->ISTPTP[1]);
    printf("[%0.4f,%0.4f] ",fs->ITACTP[0],fs->ITACTP[1]);
    printf("[%d] ",fs->KHALT);
    printf("[%d] ",fs->KECHO);
    printf("[%d,%d,%d,%d] ",fs->KENASTK[0][0],fs->KENASTK[0][1],
	   fs->KENASTK[1][0],fs->KENASTK[1][1]);
    printf("[%d:%d:%d] ",fs->INEXT[0],fs->INEXT[1],fs->INEXT[2]);
    printf("[%0.4f] ",fs->RAOFF);
    printf("[%0.4f] ",fs->XOFF);
    printf("[%0.4f]\n",fs->YOFF);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LLOG[0],fs->LLOG[1],fs->LLOG[2],fs->LLOG[3],
	   fs->LLOG[4],fs->LLOG[5],fs->LLOG[6],fs->LLOG[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LNEWPR[0],fs->LNEWPR[1],fs->LNEWPR[2],fs->LNEWPR[3],
	   fs->LNEWPR[4],fs->LNEWPR[5],fs->LNEWPR[6],fs->LNEWPR[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LNEWSK[0],fs->LNEWSK[1],fs->LNEWSK[2],fs->LNEWSK[3],
	   fs->LNEWSK[4],fs->LNEWSK[5],fs->LNEWSK[6],fs->LNEWSK[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LPRC[0],fs->LPRC[1],fs->LPRC[2],fs->LPRC[3],
	   fs->LPRC[4],fs->LPRC[5],fs->LPRC[6],fs->LPRC[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LSTP[0],fs->LSTP[1],fs->LSTP[2],fs->LSTP[3],
	   fs->LSTP[4],fs->LSTP[5],fs->LSTP[6],fs->LSTP[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LSKD[0],fs->LSKD[1],fs->LSKD[2],fs->LSKD[3],
	   fs->LSKD[4],fs->LSKD[5],fs->LSKD[6],fs->LSKD[7]);
    printf("[%c%c%c%c%c%c%c%c] ",
	   fs->LEXPER[0],fs->LEXPER[1],fs->LEXPER[2],fs->LEXPER[3],
	   fs->LEXPER[4],fs->LEXPER[5],fs->LEXPER[6],fs->LEXPER[7]);
    printf("[%c%c%c%c%c%c] ",
	   fs->LFEET_FS[0][0],fs->LFEET_FS[0][1],fs->LFEET_FS[0][2],
	   fs->LFEET_FS[0][3],fs->LFEET_FS[0][4],fs->LFEET_FS[0][5]);
    printf("[%c%c%c%c%c%c]\n",
	   fs->LFEET_FS[1][0],fs->LFEET_FS[1][1],fs->LFEET_FS[1][2],
	   fs->LFEET_FS[1][3],fs->LFEET_FS[1][4],fs->LFEET_FS[1][5]);
    printf("[%d,%d,%d,%d] ",
	   fs->lgen[0][0],fs->lgen[0][1],fs->lgen[1][0],fs->lgen[1][1]);
    for (i=0; i<=22; i++) {
      printf("[%d] ",
	     fs->ICHK[i]);
	     }
    printf("\n");
    printf("[%0.4f] ",fs->tempwx);
    printf("[%0.4f] ",fs->humiwx);
    printf("[%0.4f] ",fs->preswx);
    printf("[%0.4f] ",fs->ep1950);
    printf("[%0.4f] ",fs->epoch);
    printf("[%0.4f] ",fs->cablev);
    printf("[%0.4f] ",fs->height);
    printf("[%0.4f] ",fs->ra50);
    printf("[%0.4f] ",fs->dec50);
    printf("[%0.4f] ",fs->alat);
    printf("[%0.4f]\n",fs->wlong);
    for (i=0; i<=31; i++) {
      printf("[%0.4f] ",
	     fs->systmp[i]);
      if(i==10 || i==20) printf("\n");
      	     }
    printf("\n");
    printf("[%d]",fs->ldsign);
    exit(0);
  /*  } else if (strstr(what,"fs")) {
      exit(0);*/
  } else {
    printf("$$vueinfo$$");
    exit(0);
  }
}
