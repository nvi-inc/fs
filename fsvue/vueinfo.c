/*********************************************************************
 * Function vueinfo.c (main) 
 *
 *  calls: 
 *  vueinfo - get information for fsvue 
 *********************************************************************/
#include <sys/types.h>
#include <stdio.h>
#include <string.h>

#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */


struct fscom *fs;

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
  "K42DMS","K42B","K42C","VLBA42"};


main(int argc, char *argv[])
{
  int i, j, iyear;
  int ip[5], it[5];
  char what[4];
  char cnam[120];
  int clength;
  char runstr[120];
  int rack, rack_t;
  int drive[2], drive_t[2];
  int drive1;
  float thp;
  int ifs[3];
  int *ierr;
  char *str, site[8];
  short int buffint[120];
  char buff[120];
  char log_name[15];

/* connect me to the FS */
  putpname("vueinfo");
  setup_ids();
  fs = shm_addr;
  
  strcpy(what,argv[1]);
  
  if(strstr(what,"help")) {
    fs_get_rack__(&rack);
    fs_get_drive__(&drive);
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
    fs_get_iat1if__(&ifs[0]);
    fs_get_iat2if__(&ifs[1]);
    fs_get_iat3if__(&ifs[2]);
    printf("%d - %d - %d",ifs[0],ifs[1],ifs[2]);
    exit(0);
  } else if (strstr(what,"wx")) {
    if(what[2]=='t') fs_get_tempwx__(&thp);
    else if(what[2]=='h') fs_get_humiwx__(&thp);
    else if(what[2]=='p') fs_get_preswx__(&thp);
    else thp=0.0;
    printf("%.2f",thp);
    exit(0);
  } else if (strstr(what,"site")) {
    fs_get_lnaant__(site);
    for(i=0; i<BLANK; i++) {
      if(site[i]==0x20 || i==9) {
	break;
      }
    }
    site[i]='\0';
    printf("%s",site);
    exit(0);
  } else if (strstr(what,"lskd")) {
    fs_get_lskd__(site);
    for(i=0; i<BLANK; i++) {
      if(site[i-1]==0x20 || i==9) {
	break;
      }
    }
    site[i]='\0';
    printf("%s",site);
    exit(0);
  } else if (strstr(what,"time")) {
    rte_time(it,&iyear);
    printf("%d.%.3d.%.2d:%.2d:%.2d",iyear,it[4],it[3],it[2],it[1]);
    exit(0);
  } else if (strstr(what,"rack")) {
    fs_get_rack__(&rack);
    fs_get_rack_type__(&rack_t);
    for(i=0,j=1;i<21;i++,j=j*2) {
      if(rack==j) {
	printf("%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("None");
    for(i=0,j=1;i<21;i++,j=j*2){
      if(rack_t==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("/None");
    exit(0);
  } else if (strstr(what,"drive1")) {
    fs_get_drive__(&drive);
    fs_get_drive_type__(&drive_t);
    for(i=0,j=1;i<21;i++,j=j*2) {
      if(drive[0]==j) {
	printf("(1)%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("(1)None");
    for(i=0,j=1;i<21;i++,j=j*2){
      if(drive_t[0]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("/None");
    exit(0);
  } else if (strstr(what,"drive2")) {
    fs_get_drive__(&drive);
    fs_get_drive_type__(&drive_t);
    for(i=0,j=1;i<21;i++,j=j*2) {
      if(drive[1]==j) {
	printf("(2)%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("(2)None");
    for(i=0,j=1;i<21;i++,j=j*2){
      if(drive_t[1]==j)	{
	printf("/%s",r[i]);
	break;
      }
    }
    if(i>=21) printf("/None");
    exit(0);
  } else if (strstr(what,"err")) {
    strcpy(buff,"Under Development NOT AVAILABLE");
    i=strlen(buff);
    buff[i]='\0';
    printf("%s\n",buff);
    exit(0);
  } else if (strstr(what,"log")) {
    fs_get_llog__(&log_name);
    for(i=0; i<BLANK; i++)
      if(log_name[i]==0x20) break;
	log_name[i++]='.';
	log_name[i++]='l';
	log_name[i++]='o';
	log_name[i++]='g';
	log_name[i]='\0';
	printf("%s",log_name);
	exit(0);
    /*  } else if (strstr(what,"fs")) {
    exit(0);*/
  } else {
    exit(0);
  }
}



