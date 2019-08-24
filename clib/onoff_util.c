/* onoff buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

extern char unit_letters[ ];

static char chanm[] = "0123";
static char chanv[] = "0abcd";
static char chanl[] = "01234";
static char hex[]= "0123456789abcdef";
static char dec[]= "0123456789";
static char det[] = "dlu34567";
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};
static char lwhat3i[ ]="abcdefgh";


static char *lwhati[ ]={
"ifa","ifb","ifc","ifd"};

static char *lwhati2[ ]={
"ia","ib","ic","id"};

static char *lmark[ ]={
  "v1","v2","v3","v4","v5","v6","v7","v8","v9","va","vb","vc","vd","ve",
  "i1","i2","i3"};

static char *lmarka[ ]={
  "v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14",
  "i1","i2","i3"};

static char *lmarkb[ ]={
  "vc1","vc2","vc3","vc4","vc5","vc6","vc7","vc8","vc9","vca","vcb","vcc",
  "vcd","vce","if1","if2","if3"};

static char *lmarkc[ ]={
  "vc1","vc2","vc3","vc4","vc5","vc6","vc7","vc8","vc9","vc10","vc11","vc12",
  "vc13","vc14","if1","if2","if3"};

static char *lmarkl[ ]={
  "p1","p2","p3","p4","p5","p6","p7","p8","p9","pa","pb","pc","pd","pe"};

static char *lmarkla[ ]={
  "p1","p2","p3","p4","p5","p6","p7","p8","p9","p10","p11","p12","p13","p14"};

static char *lmarklb[ ]={
  "ifp1","ifp2","ifp3","ifp4","ifp5","ifp6","ifp7","ifp8","ifp9",
  "ifpa","ifpb","ifpc","ifpd","ifpe"};

static char *lmarklc[ ]={
  "ifp1","ifp2","ifp3","ifp4","ifp5","ifp6","ifp7","ifp8","ifp9",
  "ifp10","ifp11","ifp12","ifp13","ifp14"};

static char *luser[ ] = {"u1", "u2", "u3", "u4", "u5", "u6" };

int onoff_dec(lcl,count,ptr)
struct onoff_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k, jend;
    double freq;
    static int iconv, isb;
    static int itpis_save[MAX_ONOFF_DET];
    int itpis_test[MAX_ONOFF_DET];
    char lwhatd[5];

    ierr=0;
    if(ptr==NULL) {
      if(*count>5) {
	*count=-1;
      /*
      for(i=0;i<MAX_ONOFF_DET;i++)
	if(lcl->itpis[i]!=0)
	  printf("i %d lcl->itpis[i] %d lcl->ifc[i] %d lcl->lwhat[i] %2.2s\n",
		 i,lcl->itpis[i],lcl->ifc[i],lcl->lwhat[i]);
      */

	return 0;
      } else
	ptr="";
    }
    switch (*count) {
    case 1:
      for(i=0;i<MAX_ONOFF_DET;i++) {
	itpis_save[i]=lcl->itpis[i];
	lcl->itpis[i]=0;
      }
      lcl->setup=FALSE;
      ierr=arg_int(ptr,&lcl->rep,2,TRUE);
      if(ierr==0 && (lcl->rep < 0 || lcl->rep > 100))
	ierr=-200;
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->intp,1,TRUE);
      if(ierr==0 && (lcl->intp < 0 || lcl->intp > 100))
	ierr=-200;
      break;
    case 3:
      ierr=arg_float(ptr,&lcl->cutoff,75.0,TRUE);
      if(ierr==0 && (lcl->cutoff < 0.0 || lcl->cutoff > 90.0))
	ierr=-200;
      break;
    case 4:
      ierr=arg_float(ptr,&lcl->step,3.0,TRUE);
      if(ierr==0 && (lcl->step < 0.0 || lcl->step > 90.0))
	ierr=-200;
      break;
    case 5:
      if(ptr==NULL || *ptr==0) {
	lcl->proc[0]=0;
      } else if (strlen(ptr) > 31) {
	ierr=-206;
	return ierr;
      } else {
	strncpy(lcl->proc,ptr,sizeof(lcl->proc));
      }
      break;
    case 6:
      ierr=arg_int(ptr,&lcl->wait,120,TRUE);
      if(ierr==0 && (lcl->wait < 0 || lcl->wait > 1200))
	ierr=-200;
      break;
    default:
      if(*ptr==0) {
	  ierr=-107;
	  return ierr;
      }
      for(i=(sizeof(luser)/sizeof(char *))-2;i<sizeof(luser)/sizeof(char *);i++) {
	if(strcmp(ptr,luser[i])==0) {
	  lcl->itpis[MAX_GLOBAL_DET+i]=1;
	  strncpy(lcl->devices[MAX_GLOBAL_DET+i].lwhat,luser[i],2);
	  memcpy(lcl->devices[MAX_GLOBAL_DET+i].lwhat+2,"  ",2);
	  goto done;
	}
      }
      if(strcmp(ptr,"*")==0) {
	for (i=0;i<MAX_ONOFF_DET;i++)
	  lcl->itpis[i]=itpis_save[i];
      } else if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4
		||shm_addr->equip.rack==LBA4) {
	if(strcmp(ptr,"allvc")==0) {
	  for (i=0;i<14;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lmark[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"all")==0) {
	  for (i=0;i<17;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lmark[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"formvc")==0) {
	  for(i=0;i<MAX_ONOFF_DET;i++)
	    itpis_test[i]=0;
	  if(shm_addr->equip.rack==MK4&&shm_addr->equip.rack_type==MK45 &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5vcd(itpis_test); 
	  else if(shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA)
	    mk4vcd(itpis_test);
	  else if(shm_addr->equip.rack==MK3) {
	    if(shm_addr->imodfm==0||shm_addr->imodfm==2)
	      for(i=0;i<14;i++)
		itpis_test[i]=1;
	    else if(shm_addr->imodfm==1)
	      for(i=0;i<13;i+=2)
		itpis_test[i]=1;
	    else if(shm_addr->imodfm==3)
		itpis_test[0]=1;
	  }
	  for (i=0;i<14;i++)
	    if(itpis_test[i]!=0) {
	      lcl->itpis[i]=1;
	      strncpy(lcl->devices[i].lwhat,lmark[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
	    }
	  goto done;
	} else if(strcmp(ptr,"formif")==0) {
	  for(i=0;i<MAX_ONOFF_DET;i++)
	    itpis_test[i]=0;
	  if(shm_addr->equip.rack==MK4&&shm_addr->equip.rack_type==MK45 &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5vcd(itpis_test); 
	  else if(shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA)
	    mk4vcd(itpis_test);
	  else if(shm_addr->equip.rack==MK3) {
	    if(shm_addr->imodfm==0||shm_addr->imodfm==2)
	      for(i=0;i<14;i++)
		itpis_test[i]=1;
	    else if(shm_addr->imodfm==1)
	      for(i=0;i<13;i+=2)
		itpis_test[i]=1;
	    else if(shm_addr->imodfm==3)
		itpis_test[0]=1;
	  }
	  for(j=1;j<4;j++)
	    for (i=0;i<14;i++) {
	      if(itpis_test[i]!=0 && abs(shm_addr->ifp2vc[i])==j) {
		lcl->itpis[13+j]=1;
		strncpy(lcl->devices[13+j].lwhat,lmark[13+j],2);
		memcpy(lcl->devices[13+j].lwhat+2,"  ",2);
	      }
	    }
	  goto done;
	} else { 
	  for(i=0;i<sizeof(lmark)/sizeof(char *);i++) {
	    if(strcmp(ptr,lmark[i])==0||strcmp(ptr,lmarka[i])==0
	       ||strcmp(ptr,lmarkb[i])==0||strcmp(ptr,lmarkc[i])==0) {
	      lcl->itpis[i]=1;
	      strncpy(lcl->devices[i].lwhat,lmark[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
	      goto done;
	    }
	  }
	  ierr=-207;
	  return ierr;
	}
      } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	if(strcmp(ptr,"allbbc")==0) {
	  for (i=0;i<MAX_VLBA_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	    lcl->itpis[i+MAX_BBC]=1;
	    strncpy(lcl->devices[i+MAX_BBC].lwhat,lwhat[i+MAX_BBC],2);
	    memcpy(lcl->devices[i+MAX_BBC].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"all")==0) {
	  for (i=0;i<MAX_VLBA_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	    lcl->itpis[i+MAX_BBC]=1;
	    strncpy(lcl->devices[i+MAX_BBC].lwhat,lwhat[i+MAX_BBC],2);
	    memcpy(lcl->devices[i+MAX_BBC].lwhat+2,"  ",2);
	  }
	  for (i=0;i<MAX_VLBA_IF;i++) {
	    lcl->itpis[i+2*MAX_BBC]=1;
	    strncpy(lcl->devices[i+2*MAX_BBC].lwhat,lwhat[i+2*MAX_BBC],2);
	    memcpy(lcl->devices[i+2*MAX_BBC].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"allu")==0) {
	  for (i=MAX_BBC;i<MAX_BBC+MAX_VLBA_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"alll")==0) {
	  for (i=0;i<MAX_VLBA_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"alli")==0) {
	  for (i=2*MAX_BBC;i<2*MAX_BBC+MAX_VLBA_IF;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;

	} else if(strcmp(ptr,"formbbc")==0) {
	  if(shm_addr->equip.rack==VLBA4&&shm_addr->equip.rack_type==VLBA45 &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5bbcd(lcl->itpis); 
	  else if(shm_addr->equip.rack==VLBA4)
	    mk4bbcd(&lcl->itpis);
	  else if(shm_addr->equip.rack==VLBA)
	    vlbabbcd(&lcl->itpis);
	  for (i=0;i<MAX_VLBA_BBC;i++) {
	    if(lcl->itpis[i]==1) {
	      strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
/*
	      printf(" device %2s \n",lcl->devices+i);
*/
	    }
	    if(lcl->itpis[i+MAX_BBC]==1) {
	      strncpy(lcl->devices[i+MAX_BBC].lwhat,lwhat[i+MAX_BBC],2);
	      memcpy(lcl->devices[i+MAX_BBC].lwhat+2,"  ",2);
/*
	      printf(" device %2s \n",lcl->devices+i+MAX_BBC);
*/
	    }
	  }
	  goto done;
	} else if(strcmp(ptr,"formif")==0) {
	  for(i=0;i<MAX_ONOFF_DET;i++)
	    itpis_test[i]=0;
	  if(shm_addr->equip.rack==VLBA4&&shm_addr->equip.rack_type==VLBA45 &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5bbcd(itpis_test); 
	  else if(shm_addr->equip.rack==VLBA4)
	    mk4bbcd(&itpis_test);
	  else if(shm_addr->equip.rack==VLBA)
	    vlbabbcd(&itpis_test);
	  for (j=0;j<MAX_VLBA_IF;j++)
	    for(i=0;i<MAX_VLBA_BBC;i++)
	      if(itpis_test[i]!=0||itpis_test[i+MAX_BBC]!=0)
		if(shm_addr->bbc[i].source==j) {
		 lcl->itpis[MAX_BBC*2+j]=1;
		 strncpy(lcl->devices[MAX_BBC*2+j].lwhat,lwhat[MAX_BBC*2+j],2);
		 memcpy(lcl->devices[MAX_BBC*2+j].lwhat+2,"  ",2);
		}
	  goto done;
	} else { 
	  for(i=0;i<sizeof(lwhat)/sizeof(char *);i++) {
	    if(strcmp(ptr,lwhat[i])==0) {
	      lcl->itpis[i]=1;
	      strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
	      goto done;
	    }
	  }
	}
	ierr=-207;
	return ierr;
      } else if(shm_addr->equip.rack==LBA) {
	if(strcmp(ptr,"allifp")==0||strcmp(ptr,"all")==0) {
	  for (i=0;i<2*shm_addr->n_das;i++) {
	    lcl->itpis[i]=1;
            strncpy(lcl->devices[i].lwhat,lmarkl[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
          }
	  goto done;
	} else { 
	  for(i=0;i<sizeof(lmarkl)/sizeof(char *);i++) {
	    if(strcmp(ptr,lmarkl[i])==0||strcmp(ptr,lmarkla[i])==0
	       ||strcmp(ptr,lmarklb[i])==0||strcmp(ptr,lmarklc[i])==0) {
	      lcl->itpis[i]=1;
	      strncpy(lcl->devices[i].lwhat,lmarkl[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
	      goto done;
	    }
	  }
	  ierr=-207;
	  return ierr;
	}
      } else if(shm_addr->equip.rack==DBBC && 
	    (shm_addr->equip.rack_type == DBBC_DDC ||
	     shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
	if(strcmp(ptr,"allbbc")==0) {
	  for (i=0;i<MAX_DBBC_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	    lcl->itpis[i+MAX_DBBC_BBC]=1;
	    strncpy(lcl->devices[i+MAX_DBBC_BBC].lwhat,lwhat[i+MAX_DBBC_BBC],2);
	    memcpy(lcl->devices[i+MAX_DBBC_BBC].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"all")==0) {
	  for (i=0;i<MAX_DBBC_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	    lcl->itpis[i+MAX_DBBC_BBC]=1;
	    strncpy(lcl->devices[i+MAX_DBBC_BBC].lwhat,lwhat[i+MAX_DBBC_BBC],2);
	      memcpy(lcl->devices[i+MAX_DBBC_BBC].lwhat+2,"  ",2);
	  }
	  for (i=0;i<MAX_DBBC_IF;i++) {
	    lcl->itpis[i+2*MAX_DBBC_BBC]=1;
	    strncpy(lcl->devices[i+2*MAX_DBBC_BBC].lwhat,lwhat[i+2*MAX_DBBC_BBC],2);
	    memcpy(lcl->devices[i+2*MAX_DBBC_BBC].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"allu")==0) {
	  for (i=MAX_DBBC_BBC;i<2*MAX_DBBC_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"alll")==0) {
	  for (i=0;i<MAX_DBBC_BBC;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;
	} else if(strcmp(ptr,"alli")==0) {
	  for (i=2*MAX_BBC;i<2*MAX_DBBC_BBC+MAX_DBBC_IF;i++) {
	    lcl->itpis[i]=1;
	    strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	    memcpy(lcl->devices[i].lwhat+2,"  ",2);
	  }
	  goto done;

	} else if(strcmp(ptr,"formbbc")==0) {
	  if(shm_addr->equip.rack==DBBC &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5dbbcd(lcl->itpis); 
	  else
	    for(i=0;i<2*MAX_DBBC_BBC;i++)
	      lcl->itpis[i]=0;
	  for (i=0;i<MAX_DBBC_BBC;i++) {
	    if(lcl->itpis[i]==1) {
	      strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
/*
	      printf(" device %2s \n",lcl->devices+i);
*/
	    }
	    if(lcl->itpis[i+MAX_BBC]==1) {
	      strncpy(lcl->devices[i+MAX_BBC].lwhat,lwhat[i+MAX_BBC],2);
	      memcpy(lcl->devices[i+MAX_BBC].lwhat+2,"  ",2);
/*
	      printf(" device %2s \n",lcl->devices+i+MAX_BBC);
*/
	    }
	  }
	  goto done;
	} else if(strcmp(ptr,"formif")==0) {
	  for(i=0;i<MAX_ONOFF_DET;i++)
	    itpis_test[i]=0;
	  if(shm_addr->equip.rack==DBBC &&
	     shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5dbbcd(itpis_test); 
	  for (j=0;j<MAX_DBBC_IF;j++)
	    for(i=0;i<MAX_DBBC_BBC;i++)
	      if(itpis_test[i]!=0||itpis_test[i+MAX_BBC]!=0)
		if(shm_addr->dbbcnn[i].source==j) {
		 lcl->itpis[MAX_DBBC_BBC*2+j]=1;
		 strncpy(lcl->devices[MAX_DBBC_BBC*2+j].lwhat,
			 lwhat[MAX_DBBC_BBC*2+j],2);
		 memcpy(lcl->devices[MAX_DBBC_BBC*2+j].lwhat+2,"  ",2);
		}
	  goto done;
	} else { 
	  for(i=0;i<sizeof(lwhat)/sizeof(char *);i++) {
	    if(strcmp(ptr,lwhat[i])==0) {
	      lcl->itpis[i]=1;
	      strncpy(lcl->devices[i].lwhat,lwhat[i],2);
	      memcpy(lcl->devices[i].lwhat+2,"  ",2);
	      goto done;
	    }
	  }
	}
	ierr=-207;
	return ierr;
      } else if(shm_addr->equip.rack==DBBC && 
	    (shm_addr->equip.rack_type == DBBC_PFB ||
	     shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
	int icore, ik;

	if(strcmp(ptr,"allbbc")==0||
	   strcmp(ptr,"alli")==0||
	   strcmp(ptr,"all")==0) {
	  if(strcmp(ptr,"allbbc")==0||
	     strcmp(ptr,"alli")!=0) {
      icore=0;
	    for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	      for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
		icore++;
		for(k=1;k<16;k++) {
		  ik=k+(icore-1)*16;
		  lcl->itpis[ik]=1;
		  snprintf(lcl->devices[ik].lwhat,4,"%c%02d",
			   lwhati[i][2],k+j*16);
		}
	      }
	    }
	  }
	  if(strcmp(ptr,"alli")==0||
	     strcmp(ptr,"allbbc")!=0) {
	    for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	      lcl->itpis[i+MAX_DBBC_PFB]=1;
	      strncpy(lcl->devices[i+MAX_DBBC_PFB].lwhat,lwhati[i],4);
	    }
	  }
	  goto done;
	} else if(strcmp(ptr,"formbbc")==0||strcmp(ptr,"formif")==0) {
	  for(i=0;i<MAX_ONOFF_DET;i++)
	    itpis_test[i]=0;
	  if( shm_addr->equip.drive[0]==MK5 &&
	     (shm_addr->equip.drive_type[0]==MK5B ||
	      shm_addr->equip.drive_type[0]==MK5B_BS ||
	      shm_addr->equip.drive_type[0]==MK5C ||
	      shm_addr->equip.drive_type[0]==MK5C_BS ||
	      shm_addr->equip.drive_type[0]==FLEXBUFF) )
	    mk5dbbcd_pfb(itpis_test);
	  icore=0;
	  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	      icore++;
	      for(k=1;k<16;k++) {
		ik=k+(icore-1)*16;
		if(itpis_test[ik]==1)
		  if(strcmp(ptr,"formbbc")==0) {
		    lcl->itpis[ik]=1;
		    snprintf(lcl->devices[ik].lwhat,4,"%c%02d",
			     lwhati[i][2],k+j*16);
		  } else if(strcmp(ptr,"formif")==0) {
		    lcl->itpis[i+MAX_DBBC_PFB]=1;
		    strncpy(lcl->devices[i+MAX_DBBC_PFB].lwhat,lwhati[i],4);
		  }
	      }
	    }
	  }
	  goto done;
	} else { 
	  icore=0;
	  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	      char idevice[4];
	      icore++;
	      for(k=1;k<16;k++) {
		ik=k+(icore-1)*16;
		snprintf(idevice,4,"%c%02d",lwhati[i][2],k+j*16);
		if(strcmp(idevice,ptr)==0) {
		    lcl->itpis[ik]=1;
		    strncpy(lcl->devices[ik].lwhat,idevice,4);
		    goto done;
		}
	      }
	    }
	    if(strcmp(ptr,lwhati[i])==0||strcmp(ptr,lwhati2[i])==0) {
	      lcl->itpis[i+MAX_DBBC_PFB]=1;
	      strncpy(lcl->devices[i+MAX_DBBC_PFB].lwhat,lwhati[i],4);
	      goto done;
	    }
	  }
	}
	ierr=-207;
	return ierr;
      } else if(shm_addr->equip.rack==RDBE) {
	int iscan, irdbe=-1, ichan, ifc,idet;
	char crdbe,*prdbe;

	if(strcmp(ptr,"all")==0) {
	  char buf[80];
	  for(i=0;i<MAX_RDBE;i++)
	    if(shm_addr->rdbe_active[i]) {
	      for(j=0;j<MAX_RDBE_IF;j++)
		if(shm_addr->lo.lo[j+i*MAX_RDBE_IF]>=0)
		  for(k=1;k<MAX_RDBE_CH;k++) {
		    idet=i*MAX_RDBE_CH*MAX_RDBE_IF+j*MAX_RDBE_CH+k;
		    lcl->itpis[idet]=1;
		    sprintf(buf,"%.2d%c%.1d",k,chanv[i+1],j);
		    memcpy(lcl->devices[idet].lwhat,buf,4);
		  }
	    }
	  goto done;
	}
	iscan=sscanf(ptr,"%2d%c%1d",&ichan,&crdbe,&ifc);
	if(iscan != 3)
	  iscan=sscanf(ptr,"%c%1d",&crdbe,&ifc);
	prdbe=strchr(unit_letters,crdbe);
	if(prdbe!=NULL)
	  irdbe=prdbe-unit_letters-1;
	if(iscan == 3 && strlen(ptr) == 4 &&
	   (ichan >= 0 && ichan < MAX_RDBE_CH) &&
	   (irdbe >= 0 && irdbe < MAX_RDBE) &&
	   (ifc >= 0 && ifc < MAX_RDBE_IF)) {
	  idet=irdbe*MAX_RDBE_CH*MAX_RDBE_IF+ifc*MAX_RDBE_CH+ichan;
	  lcl->itpis[idet]=1;
	  memcpy(lcl->devices[idet].lwhat,ptr,4);
	  goto done;
	} else if(iscan == 2 && strlen(ptr) == 2 &&
		  (irdbe >= 0 && irdbe < MAX_RDBE) &&
		  (ifc >= 0 && ifc < MAX_RDBE_IF)){
	  for(i=1;i<MAX_RDBE_CH;i++) {
	    lcl->itpis[i+irdbe*MAX_RDBE_CH*MAX_RDBE_IF+ifc*MAX_RDBE_CH]=1;
	    snprintf(lwhatd,5,"%02d%c%d",i,unit_letters[irdbe+1],ifc);
	    memcpy(lcl->devices[i+irdbe*MAX_RDBE_CH*MAX_RDBE_IF+ifc*MAX_RDBE_CH].lwhat,
		   lwhatd,4);
	  }
	  goto done;
	}
	ierr= -207;
	return ierr;
      } else if(shm_addr->equip.rack==DBBC3) {
	if(strcmp(ptr,"allbbc")==0) {
	  for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	    jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	    if(8<jend) jend=8;
	    for (j=0;j<jend;j++) {
	      lcl->itpis[j+i*8]=1;
	      snprintf(lwhatd,5,"%03dl",j+i*8+1);
	      memcpy(lcl->devices[j+i*8].lwhat,lwhatd,4);
	      lcl->itpis[j+i*8+MAX_DBBC3_BBC]=1;
	      snprintf(lwhatd,5,"%03du",j+i*8+1);
	      memcpy(lcl->devices[j+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	    }
	    if(shm_addr->dbbc3_ddc_bbcs_per_if>8) {
	      jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	      if(16<jend) jend=16;
	      for (j=8;j<jend;j++) {
	        lcl->itpis[64+j-8+i*8]=1;
	        snprintf(lwhatd,5,"%03dl",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8].lwhat,lwhatd,4);
	        lcl->itpis[64+j-8+i*8+MAX_DBBC3_BBC]=1;
	        snprintf(lwhatd,5,"%03du",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	      }
	    }     
	  }
	  goto done;
	} else if(strcmp(ptr,"all")==0) {
	  for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	    jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	    if(8<jend) jend=8;
	    for (j=0;j<jend;j++) {
	      lcl->itpis[j+i*8]=1;
	      snprintf(lwhatd,5,"%03dl",j+i*8+1);
	      memcpy(lcl->devices[j+i*8].lwhat,lwhatd,4);
	      lcl->itpis[j+i*8+MAX_DBBC3_BBC]=1;
	      snprintf(lwhatd,5,"%03du",j+i*8+1);
	      memcpy(lcl->devices[j+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	    }
	    if(shm_addr->dbbc3_ddc_bbcs_per_if>8) {
	      jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	      if(16<jend) jend=16;
	      for (j=8;j<jend;j++) {
	        lcl->itpis[64+j-8+i*8]=1;
	        snprintf(lwhatd,5,"%03dl",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8].lwhat,lwhatd,4);
	        lcl->itpis[64+j-8+i*8+MAX_DBBC3_BBC]=1;
	        snprintf(lwhatd,5,"%03du",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	      }
	    }     
	    lcl->itpis[i+2*MAX_DBBC3_BBC]=1;
	    snprintf(lwhatd,5,"i%c  ", lwhat3i[i]);
	    memcpy(lcl->devices[i+2*MAX_DBBC3_BBC].lwhat,lwhatd,4);
	  }
	  goto done;
	} else if(strcmp(ptr,"allu")==0) {
	  for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	    jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	    if(8<jend) jend=8;
	    for (j=0;j<jend;j++) {
	      lcl->itpis[j+i*8+MAX_DBBC3_BBC]=1;
	      snprintf(lwhatd,5,"%03du",j+i*8+1);
	      memcpy(lcl->devices[j+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	    }
	    if(shm_addr->dbbc3_ddc_bbcs_per_if>8) {
	      jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	      if(16<jend) jend=16;
	      for (j=8;j<jend;j++) {
	        lcl->itpis[64+j-8+i*8+MAX_DBBC3_BBC]=1;
	        snprintf(lwhatd,5,"%03du",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8+MAX_DBBC3_BBC].lwhat,lwhatd,4);
	      }
	    }     
	  }
	  goto done;
	} else if(strcmp(ptr,"alll")==0) {
	  for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	    jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	    if(8<jend) jend=8;
	    for (j=0;j<jend;j++) {
	      lcl->itpis[j+i*8]=1;
	      snprintf(lwhatd,5,"%03dl",j+i*8+1);
	      memcpy(lcl->devices[j+i*8].lwhat,lwhatd,4);
	    }
	    if(shm_addr->dbbc3_ddc_bbcs_per_if>8) {
	      jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	      if(16<jend) jend=16;
	      for (j=8;j<jend;j++) {
	        lcl->itpis[64+j-8+i*8]=1;
	        snprintf(lwhatd,5,"%03dl",64+j-8+i*8+1);
	        memcpy(lcl->devices[64+j-8+i*8].lwhat,lwhatd,4);
	      }
	    }     
	  }
	  goto done;
	} else if(strcmp(ptr,"alli")==0) {
	  for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	    lcl->itpis[i+2*MAX_DBBC3_BBC]=1;
	    snprintf(lwhatd,5,"i%c  ", lwhat3i[i]);
	    memcpy(lcl->devices[i+2*MAX_DBBC3_BBC].lwhat,lwhatd,4);
	  }
	  goto done;

	} else if(strcmp(ptr,"formbbc")==0) {
	  ierr= -309;
	  return ierr;
	} else if(strcmp(ptr,"formif")==0) {
	  ierr= -309;
	  return ierr;
	} else { 
	  int ibc;
	  char isb;
	  if(2==sscanf(ptr,"%d%c",&ibc,&isb)) {
	    int kfound=FALSE;
	    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	      jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	      if(8<jend) jend=8;
	      for (j=0;j<jend;j++) {
		if(ibc==j+i*8+1)
		  kfound=TRUE;
	      }
	      if(shm_addr->dbbc3_ddc_bbcs_per_if>8 &&!kfound) {
		jend=shm_addr->dbbc3_ddc_bbcs_per_if;
		if(16<jend) jend=16;
		for (j=8;j<jend;j++) {
		  if(ibc==64+j-8+i*8+1)
		    kfound=TRUE;
		}
	      }     
	    }
	    if(kfound) {
	      if(1 <= ibc && ibc <= MAX_DBBC3_BBC) {
		if(isb=='l') {
		  lcl->itpis[ibc-1]=1;
		  snprintf(lwhatd,5,"%03dl",ibc);
		  memcpy(lcl->devices[ibc-1].lwhat,lwhatd,4);
		  goto done;
		} else if(isb=='u') {
		  lcl->itpis[ibc+MAX_DBBC3_BBC-1]=1;
		  snprintf(lwhatd,5,"%03du",ibc);
		  memcpy(lcl->devices[ibc+MAX_DBBC3_BBC-1].lwhat,lwhatd,4);
		  goto done;
		}
	      }
	    }
	  }else if(strlen(ptr)==2 &&ptr[0]=='i') {
	    char *ptr1=strchr(lwhat3i,ptr[1]);
	    if(ptr1!=NULL&& ptr1-lwhat3i<shm_addr->dbbc3_ddc_bbcs_per_if) {
	      lcl->itpis[ptr1-lwhat3i+2*MAX_DBBC3_BBC]=1;
	      strncpy(lcl->devices[ptr1-lwhat3i+2*MAX_DBBC3_BBC].lwhat,ptr,2);
	      memcpy(lcl->devices[ptr1-lwhat3i+2*MAX_DBBC3_BBC].lwhat+2,"  ",2);
	      goto done;
	    }
	  }
	}
   	ierr=-207;
	return ierr;
      }
    }
 done:
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void onoff_enc(output,count,lcl)
char *output;
int *count;
struct onoff_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;
  static int inext;

  output=output+strlen(output);

  if(*count == 1) {
    sprintf(output+strlen(output),"%d",lcl->rep);
    strcat(output,",");
    sprintf(output+strlen(output),"%d",lcl->intp);
    strcat(output,",");
    sprintf(output+strlen(output),"%.1f",lcl->cutoff);
    strcat(output,",");
    sprintf(output+strlen(output),"%.1f",lcl->step);
    strcat(output,",");
    sprintf(output+strlen(output),"%s",lcl->proc);
    strcat(output,",");
    sprintf(output+strlen(output),"%d",lcl->wait);
    strcat(output,",");
    if(lcl->setup) {
      sprintf(output+strlen(output),"%.4f",lcl->ssize*RAD2DEG);
      strcat(output,",");
      sprintf(output+strlen(output),"%.4f",lcl->fwhm*RAD2DEG);
    }
    inext=0;
  }
  
  if(*count >= 2) {
    int iwide;
    for(i=inext;i<MAX_ONOFF_DET;i++) {
      inext=i+1;
      if(lcl->itpis[i]!=0) {
	if(lcl->devices[i].lwhat[2] == ' ')
	  iwide=2;
	else if (lcl->devices[i].lwhat[3] == ' ')
	  iwide=3;
	else
	  iwide=4;
	if(lcl->setup) { 
	  sprintf(output+strlen(output),
		  "%.*s,%d,%c,%.4f,%.2f,%.2lf,%.3f,%.3f,%.6f,%.4f,%.6f",iwide,
		  lcl->devices[i].lwhat,lcl->devices[i].ifchain,
		  lcl->devices[i].pol,
		  lcl->devices[i].fwhm*RAD2DEG,
		  lcl->devices[i].center,lcl->devices[i].tcal,
		  lcl->devices[i].flux,lcl->devices[i].corr,
		  lcl->devices[i].dpfu,lcl->devices[i].gain,
		  lcl->devices[i].dpfu*lcl->devices[i].gain);
	} else {
	  sprintf(output+strlen(output),"%.*s,,,,,,,,,,",iwide,
		  lcl->devices[i].lwhat);
	}
	return;
      }
	}
	return;
      }
    }
    *count=-1;
  }

  return;
}
