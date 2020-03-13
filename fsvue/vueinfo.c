/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/*********************************************************************
 * Function vueinfo.c (main) 
 *
 *  calls: 
 *  vueinfo - get information for fsvue 
 *********************************************************************/
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include <stdlib.h>
#include "../monit/dpi.h"
/* S2 stuff */
#include "../rclco/rcl/rcl_def.h"
#include "../rclco/rcl/rcl_cmd.h"

#include "../include/params.h"        /* general fs parameter header */
#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
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
void skd_wait();
void get_err();

#define MAX_BUF 256
#define MAX_OUT 256
#define MAX_LEN 256+1
#define BLANK 8

static char *r[] = {
  "MK3","VLBA","MK4","S2","VLBA4","K4",
  "K4MK4","K4K3","LBA","LBA4","","",
  "VLBAG","VLBA2","MK4B","K41",
  "K41U","K42","K42A","K42BU","VLBAB","K41DMS",
  "K42DMS"};
static int nr = sizeof(r)/sizeof(char *);


main(int argc, char *argv[])
{
  int kMrack, kMdrive[2], kS2drive[2],kVrack,kVdrive[2],kM3rack,kM4rack,
    kV4rack, kK4drive[2],kK41drive_type[2],kK42drive_type[2],selectm;
  int i, j, iyear;
  int ip[5], it[6];
  char what[10], cmd[100];
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
  char ibc1[12],ibc2[12],pathname[MAX_LEN];
  int *p;

/* connect me to the FS  */
  putpname("vueinfo");
  setup_ids();
  fs = shm_addr;

  if (argc<2) {printf("vueinfo needs more information\n"); exit(0);}
  strcpy(what,argv[1]);
  if (argc>=3) strcpy(cmd,argv[2]);
  else cmd[0]='\0';

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
    if(buff[0]==' ')
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
    for(i=0,j=1;i<nr;i++,j=j*2) {
      if(rack==j) {
	printf("%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("None");
    for(i=0,j=1;i<nr;i++,j=j*2){
      if(rack_t==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("/None");
    exit(0);
  } else if (strstr(what,"drive1")) {
    drive[0]=shm_addr->equip.drive[0];
    drive_t[0]=shm_addr->equip.drive_type[0];
    for(i=0,j=1;i<nr;i++,j=j*2) {
      if(drive[0]==j) {
	printf("(1)%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("(1)None");
    for(i=0,j=1;i<nr;i++,j=j*2){
      if(drive_t[0]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("/None");
    exit(0);
  } else if (strstr(what,"drive2")) {
    drive[1]=shm_addr->equip.drive[1];
    drive_t[1]=shm_addr->equip.drive_type[1];
    for(i=0,j=1;i<nr;i++,j=j*2) {
      if(drive[1]==j) {
	printf("(2)%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("(2)None");
    for(i=0,j=1;i<nr;i++,j=j*2){
      if(drive_t[1]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=nr) printf("/None");
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
  } else if (strstr(what,"vuecalq")) {
    vuecalq(cmd);
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
    printf("iclbox=%d, ",fs->iclbox);
    printf("iclopr=%d\n",fs->iclopr);
    printf("AZOFF=%0.4f, ",fs->AZOFF);
    printf("DECOFF=%0.4f, ",fs->DECOFF);
    printf("ELOFF=%0.4f\n",fs->ELOFF);
    printf("ibmat=%d, ",fs->ibmat);
    printf("ibmcb=%d\n",fs->ibmcb);
    printf("ICAPTP=[%d,%d], ",fs->ICAPTP[0],fs->ICAPTP[1]);
    printf("IRDYTP=[%d,%d], ",fs->IRDYTP[0],fs->IRDYTP[1]);
    printf("IRENVC=%d, ",fs->IRENVC);
    printf("ILOKVC=%d\n ",fs->ILOKVC);
    printf("ITRAKA=[%d,%d], ",fs->ITRAKA[0],fs->ITRAKA[1]);
    printf("ITRAKB=[%d,%d]\n",fs->ITRAKB[0],fs->ITRAKB[1]);
    printf("TPIVC=[%d,%d,%d,",fs->TPIVC[0],fs->TPIVC[1],fs->TPIVC[2]);
    printf("%d,%d,%d,",fs->TPIVC[3],fs->TPIVC[4],fs->TPIVC[5]);
    printf("%d,%d,%d,\n",fs->TPIVC[6],fs->TPIVC[7],fs->TPIVC[8]);
    printf("%d,%d,%d,",fs->TPIVC[9],fs->TPIVC[10],fs->TPIVC[11]);
    printf("%d,%d,%d]\n",fs->TPIVC[12],fs->TPIVC[13],fs->TPIVC[14]);
    printf("ISTPTP=[%0.4f,%0.4f], ",fs->ISTPTP[0],fs->ISTPTP[1]);
    printf("ITACTP=[%0.4f,%0.4f], ",fs->ITACTP[0],fs->ITACTP[1]);
    printf("KHALT=%d, ",fs->KHALT);
    printf("KECHO=%d\n",fs->KECHO);
    printf("KENASTK=[%d,%d,%d,%d], ",fs->KENASTK[0][0],fs->KENASTK[0][1],
	   fs->KENASTK[1][0],fs->KENASTK[1][1]);
    printf("INEXT=[%d:%d:%d]\n",fs->INEXT[0],fs->INEXT[1],fs->INEXT[2]);
    printf("RAOFF=%0.4f, ",fs->RAOFF);
    printf("XOFF=%0.4f, ",fs->XOFF);
    printf("YOFF=%0.4f, ",fs->YOFF);
    printf("LLOG=%0.8s\n", fs->LLOG);
    printf("INEWPR=%0.8s, ", fs->LNEWPR);
    printf("LNEWSK=%0.8s, ", fs->LNEWSK);
    printf("LPRC=%0.8s, ", fs->LPRC);
    printf("LSTP=%0.8s, ", fs->LSTP);
    printf("LSKD=%0.8s\n", fs->LSKD);
    printf("LEXPER=%0.8s, ", fs->LEXPER);
    printf("LFEET_FS=%0.6s, ", fs->LFEET_FS[0]);
    printf("LFEET_FS2=%0.6s, ", fs->LFEET_FS[1]);
    printf("lgen=[%d,%d,%d,%d]\n ",
	   fs->lgen[0][0],fs->lgen[0][1],fs->lgen[1][0],fs->lgen[1][1]);
    printf("ICHK=[");
    for (i=0; i<=22; i++) {
      printf("%d, ",
	     fs->ICHK[i]);
	     }
    printf("]\n");
    printf("tempwx=%0.4f, ",fs->tempwx);
    printf("humiwx=%0.4f, ",fs->humiwx);
    printf("preswx=%0.4f, ",fs->preswx);
    printf("speedwx=%0.4f, ",fs->speedwx);
    printf("directionwx=%d\n",fs->directionwx);
    printf("ep1950=%0.4f, ",fs->ep1950);
    printf("epoch=%0.4f, ",fs->epoch);
    printf("cablev=%0.4f, ",fs->cablev);
    printf("height=%0.4f\n",fs->height);
    printf("ra50=%0.4f, ",fs->ra50);
    printf("dec50=%0.4f, ",fs->dec50);
    printf("alat=%0.4f, ",fs->alat);
    printf("wlong=%0.4f\n",fs->wlong);
    printf("systmp=[");
    for (i=0; i<32; i++) {
      if(i==8 || i==16 || i==24) printf("\n");
      if (i==31) printf("%0.4f",fs->systmp[i]);
      else printf("%0.4f, ",fs->systmp[i]);
    }
    printf("]\n");
    printf("ldsign=%d\n",fs->ldsign);
    printf("lfreqv=%0.90s\n",fs->lfreqv);
    printf("lnaant=%0.8s, ",fs->lnaant);
    printf("lsorna=%0.10s\n",fs->lsorna);
    printf("idevant=%0.64s\n",fs->idevant);
    printf("idevgpib=%0.64s\n",fs->idevgpib);
    printf("idevlog0=%0.64s\n",fs->idevlog[0]);
    printf("idevlog1=%0.64s\n",fs->idevlog[1]);
    printf("idevlog2=%0.64s\n",fs->idevlog[2]);
    printf("idevlog3=%0.64s\n",fs->idevlog[3]);
    printf("idevlog4=%0.64s\n",fs->idevlog[4]);
    printf("ndevlog=%d, ",fs->ndevlog);
    printf("imodfm=%d, ",fs->imodfm);
    printf("ipashd=[%d,%d,%d,%d], ",
	   fs->ipashd[0][0],fs->ipashd[0][1],
	   fs->ipashd[1][0],fs->ipashd[1][1]);
    printf("iratfm=%d, ",fs->iratfm);
    printf("ispeed=[%d,%d]\n",fs->ispeed[0],fs->ispeed[1]);
    printf("idirtp=[%d,%d], ",fs->idirtp[0],fs->idirtp[1]);
    printf("cips=[%d,%d], ",fs->cips[0],fs->cips[1]);
    printf("bit_density=[%d,%d], ",fs->bit_density[0],fs->bit_density[1]);
    printf("ienatp=[%d,%d]\n",fs->ienatp[0],fs->ienatp[1]);
    printf("inp1if=%d, ",fs->inp1if);
    printf("inp2if=%d, ",fs->inp2if);
    printf("ionsor=%d\n",fs->ionsor);
    printf("imaxtpsd=[%d,%d], ",fs->imaxtpsd[0],fs->imaxtpsd[1]);
    printf("iskdtpsd=[%d,%d], ",fs->iskdtpsd[0],fs->iskdtpsd[1]);
    printf("motorv=[%0.4f,%0.4f]\n",fs->motorv[0],fs->motorv[1]);
    printf("inscint=[%0.4f,%0.4f], ",fs->inscint[0],fs->inscint[1]);
    printf("inscsl=[%0.4f,%0.4f]\n",fs->inscsl[0],fs->inscsl[1]);
    printf("outscint=[%0.4f,%0.4f], ",fs->outscint[0],fs->outscint[1]);
    printf("outscsl=[%0.4f,%0.4f]\n",fs->outscsl[0],fs->outscsl[1]);
    printf("itpthick=[%d,%d], ",fs->itpthick[0],fs->itpthick[1]);
    printf("wrvolt=[%0.4f,%0.4f], ",fs->wrvolt[0],fs->wrvolt[1]);
    printf("capstan=[%d,%d]\n",fs->capstan[0],fs->capstan[1]);
    exit(0);
  } else if (strstr(what,"errs")) {
    exit(0);
  /*  } else if (strstr(what,"fs")) {
      exit(0);*/
  } else if (strstr(what,"chksem")) {
    if ( 1 == nsem_take("fs   ",1)) {
       printf("fs already running");
    }
    if ( 1 == nsem_take("fsctl",1)) {
       printf("fsctl semaphore failed");
    }
    exit(0);
  } else {
    printf("$$vueinfo$$");
    exit(0);
  }
}
