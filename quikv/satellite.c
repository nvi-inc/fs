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
/* satellite snap command */

#include <stdlib.h>
#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void satellite(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, count;
      char *ptr;
      struct satellite_cmd lcl;
      char buff[160];
      char tlefile[sizeof(lcl.tlefile)+sizeof("/tle_files/")
		   +sizeof(FS_ROOT)];
      FILE *fd,*fdqth, *fdtle;
      int id, idqth, idtle, iret, i, it[6], idinyr;
      int seconds;
      char tempname[30],qthfile[30];
      char tle0[75], tle1[75],tle2[75], name[25], *pret;
      double azcmd,elcmd;
      float epoch;

      int satellite_dec();                 /* parsing utilities */
      char *arg_next();

      void satellite_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ierr=0;

      if (command->equal != '=') {           /* display */
	satellite_dis(command,ip);
	return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          satellite_dis(command,ip);
	  return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->satellite,sizeof(lcl));
      lcl.tle0[0]=0;
      lcl.tle1[0]=0;
      lcl.tle2[0]=0;

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=satellite_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      shm_addr->satellite.satellite=0;
      memcpy(&shm_addr->satellite,&lcl,sizeof(lcl));

      if(lcl.tlefile[0]!=0) {
	strcpy(tlefile,FS_ROOT);
	strcat(tlefile,"/tle_files/");
	strcat(tlefile,lcl.tlefile);
	fdtle=fopen(tlefile,"r");
	if(fdtle==NULL) {
	  ierr=-323;
	  logit(NULL,errno,"un");
	  goto error;
	}
	tle0[0]=0;
	tle1[0]=0;
	tle2[0]=0;
	strcpy(name,lcl.name);
	for(i=strlen(name);i<24;i++)
	  name[i]=' ';
	name[24]=0;
	pret=(char *)!NULL;
	while(pret!=NULL) {
	  if(NULL!=(pret=fgets(tle0,sizeof(tle0),fdtle)))
	    if(NULL!=(pret=fgets(tle1,sizeof(tle1),fdtle)))
	    if(NULL!=(pret=fgets(tle2,sizeof(tle2),fdtle))) {
		char testname[25];
		int num1,num2,line1,line2,chk1,chk2;
		if(tle0[strlen(tle0)-1]!='\n'
		   ||tle1[strlen(tle1)-1]!='\n'
		   ||tle2[strlen(tle2)-1]!='\n') {
		  ierr=-328;
		  close(fdtle);
		  goto error;
		}
		tle0[strlen(tle0)-1]=0;
		for(i=strlen(tle0)-1;-1<i;i--)
		  if(tle0[i]!=' '
		     && tle0[i]!='\t'
		     && tle0[0]!='\r')
		    break;
		  else
		    tle0[i]=0;
		for(i=0;i<sizeof(tle0);i++) tle0[i]=toupper(tle0[i]);
		strcpy(testname,tle0);
		for(i=strlen(testname);i<24;i++)
		  testname[i]=' ';
		testname[24]=0;
		if(3!=sscanf(tle1,"%1d%*1c%5d%*61c%1d",&line1,&num1,&chk1)||
		   3!=sscanf(tle2,"%1d%*1c%5d%*61c%1d",&line2,&num2,&chk2)) {
		  ierr=-324;
		  fclose(fdtle);
		  goto error;		  
		} else if(line1!=1 || line2 != 2 || num1!=num2 || num1==0
			  || check_tle(tle1)!=chk1
			  || check_tle(tle2)!=chk2) {
		  ierr=-325;
		  fclose(fdtle);
		  goto error;		  
		} else if(strcmp(name,testname)==0 || atol(name)==num1) {
		  /* found it */
		  for(i=0;i<sizeof(tle1);i++) tle1[i]=toupper(tle1[i]);
		  for(i=0;i<sizeof(tle2);i++) tle2[i]=toupper(tle2[i]);
		  fclose(fdtle);
		  goto tle_write;
		}
	      }
	}
	if(pret==NULL) {
	  if(ferror(fdtle)) {
	    ierr=-326;
	    logit(NULL,errno,"un");
	    fclose(fdtle);
	    goto error;
	  } else {
	    ierr=-327;
	    fclose(fdtle);
	    goto error;
	  }
	}
      } else { /* tle command's imput */
	if(shm_addr->tle.catnum[0]!=shm_addr->tle.catnum[1]
	   ||shm_addr->tle.catnum[1]!=shm_addr->tle.catnum[2]) {
	  ierr=-319;
	  goto error;
	} else if (shm_addr->tle.catnum[0]<=0) {
	  ierr=-320;
	  goto error;
	}
	memcpy(tle0,shm_addr->tle.tle0,sizeof(tle0));
	memcpy(tle1,shm_addr->tle.tle1,sizeof(tle1));
	memcpy(tle2,shm_addr->tle.tle2,sizeof(tle2));

	memcpy(lcl.name,tle0,sizeof(lcl.name));
      }

 tle_write:
      strcpy(tlefile,"/tmp/predict.tle.XXXXXX");
      idtle=mkstemp(tlefile);
      if(idtle==-1) {
	ierr=-321;
	logit(NULL,errno,"un");
	goto error;
      }
	
      fdtle=fopen(tlefile,"w");
      if(fdtle==NULL) {
	ierr=-322;
	logit(NULL,errno,"un");
	goto clean_up5;
      }

      fprintf(fdtle,"%.24s\n",tle0);
      fprintf(fdtle,"%.69s\n",tle1);
      fprintf(fdtle,"%.69s\n",tle2);
      fflush(fdtle);

      strcpy(qthfile,"/tmp/predict.qth.XXXXXX");
      idqth=mkstemp(qthfile);
      if(idqth==-1) {
	ierr=-316;
	logit(NULL,errno,"un");
	goto clean_up4;
      }

      fdqth=fopen(qthfile,"w");
      if(fdqth==NULL) {
	ierr=-317;
	logit(NULL,errno,"un");
	goto clean_up3;
      }
      fprintf(fdqth,"%8.8s        \n",shm_addr->lnaant);
      fprintf(fdqth,"%.6lf\n",shm_addr->alat*RAD2DEG);
      fprintf(fdqth,"%.6lf\n",shm_addr->wlong*RAD2DEG);
      fprintf(fdqth,"%.0lf\n",shm_addr->height);
      fflush(fdqth);	    

      rte_time(it,it+5);
      rte2secs(it,&seconds);
      strcpy(tempname,"/tmp/predict.eph.XXXXXX");
      id=mkstemp(tempname);
      if(id==-1) {
	ierr=-315;
	logit(NULL,errno,"un");
	goto clean_up2;
      }

      snprintf(buff,sizeof(buff),
	       "predict -t %s -q %s -f '%s' %d +%d -o %s >/dev/null",
	       tlefile,qthfile,lcl.name,seconds,MAX_EPHEM-1,tempname);

      ierr=system(buff);
      if(ierr==-1) {
	logit(NULL,errno,"un");
	ierr=-305;
	goto clean_up1;
      }
      ierr=WEXITSTATUS(ierr);
      if(ierr==255) { /* predict unknown error */
	ip[4]=ierr;
	ierr=-306;
	goto clean_up1;
      } else if (ierr==254) { /* TLE not found */
	ierr=-310;
	goto clean_up1;
      } else if (ierr==253) { /* QTH not found */
	ierr=-311;
	goto clean_up1;
      } else if (ierr==252) { /* both TLE & QTH not found */
	ierr=-312;
      	goto clean_up1;
      } else if (ierr==251) { /* error reading QTH file */
	ierr=-318;
      	goto clean_up1;
      } else if (ierr==127) { /* /bin/sh or predict not found */
	ierr=-313;
      	goto clean_up1;
      } else if(ierr!=0){ /* something else */
	ip[4]=ierr;
	ierr=-314;
	goto clean_up1;
      }

      fd=fopen(tempname,"r");
      if(fd==NULL) {
	ierr=-309;
	logit(NULL,errno,"un");
	goto clean_up1;
      }
	
      for (i=0;i<MAX_EPHEM;i++) {
	iret=fscanf(fd,"%d%*21c %lf %lf%*[^\n]%*c",
		    &shm_addr->ephem[i].t,
		    &shm_addr->ephem[i].el,
		    &shm_addr->ephem[i].az);
	if(iret == EOF && i==0) {
	  ierr=-301;
	  goto clean_up;
	} else if (iret == EOF) {
	  ierr=-302;
	  ip[4]=i+1;
	  goto clean_up;
	} else if(iret !=3) {
	  ierr=-303;
	  ip[4]=i+1;
	  goto clean_up;
	}
	shm_addr->ephem[i].az*=DEG2RAD;
	shm_addr->ephem[i].el*=DEG2RAD;
      }
 clean_up:
      fclose(fd);

 clean_up1:
      unlink(tempname);
      close(id);

 clean_up2:
      fclose(fdqth);

 clean_up3:
      unlink(qthfile);
      close(idqth);

 clean_up4:
      if(lcl.tlefile[0]==0)
	fclose(fdtle);
 
 clean_up5:
      unlink(tlefile);
      close(idtle);

      if(ierr != 0)
	goto error;

      shm_addr->satellite.satellite=1;
      memcpy(shm_addr->satellite.tle0,tle0,sizeof(shm_addr->satellite.tle0));
      memcpy(shm_addr->satellite.tle1,tle1,sizeof(shm_addr->satellite.tle1));
      memcpy(shm_addr->satellite.tle2,tle2,sizeof(shm_addr->satellite.tle2));
      memcpy(shm_addr->satellite.name,lcl.name,sizeof(shm_addr->satellite.name));

      sprintf(buff,"/%s/tle0,%.24s",command->name,tle0);
      logitf(buff);
      sprintf(buff,"/%s/tle1,%.69s",command->name,tle1);
      logitf(buff);
      sprintf(buff,"/%s/tle2,%.69s",command->name,tle2);
      logitf(buff);

      if(lcl.mode == 1 || lcl.mode == 2) {
	int adder;
	rte_time(it,it+5);
	rte2secs(it,&seconds);
	if(shm_addr->satoff.seconds >=0.0) {
	  adder=shm_addr->satoff.seconds*100+0.5;
	} else {
	  adder=-(-shm_addr->satoff.seconds*100+.5);
	}
	seconds+=adder/100;
	it[0]+=adder%100;
	if (it[0] > 99) {
	  seconds++;
	  it[0]-=100;
	} else if (it[0] < 0) {
	  seconds--;
	  it[0]+=100;
	}
	secs2rte(&seconds,it);
	ierr=satpos(it,&azcmd,&elcmd);
	if(ierr==-1) {
	  ierr=-307;
	  goto error;
	}  else if (ierr==+1) {
	  ierr=-308;
	  goto error;
	}
        rte2secs(it,&seconds);

	idinyr=365;
	if(it[5]%400 == 0 || (it[5]%4 == 0 && it[5]%100 !=0))
	  idinyr=366;
	epoch=it[5]+it[4]/(float)idinyr;
      }

      if(lcl.mode == 1) {
	strncpy(shm_addr->lsorna,lcl.name,sizeof(shm_addr->lsorna));
	for(i=strlen(lcl.name);i<sizeof(shm_addr->lsorna);i++)
	  shm_addr->lsorna[i]=' ';
	cnvrt(2,azcmd,elcmd, &shm_addr->ra50,&shm_addr->dec50,
	      it,shm_addr->alat,shm_addr->wlong);
	shm_addr->ep1950=epoch;
	shm_addr->radat=shm_addr->ra50;
	shm_addr->decdat=shm_addr->dec50;
	shm_addr->epoch=shm_addr->ep1950;

	ip[0]=1;
	antcn(ip);
	if(ip[2]!=0)
	  return;
      } else if(lcl.mode==2) {
	strncpy(shm_addr->lsorna,"azel",sizeof(shm_addr->lsorna));
	for(i=strlen("azel");i<sizeof(shm_addr->lsorna);i++)
	  shm_addr->lsorna[i]=' ';
	shm_addr->ra50=azcmd;
	shm_addr->dec50=elcmd;
	shm_addr->ep1950=-1;
	shm_addr->radat=azcmd;
	shm_addr->decdat=elcmd;
	shm_addr->epoch=epoch;

	ip[0]=1;
	antcn(ip);
	if(ip[2]!=0)
	  return;
      } else if (lcl.mode==0) {
	ip[0]=9;
	antcn(ip);
	if(ip[2]!=0)
	  return;
      } else {
	ierr=-304;
	goto error;
      }

      ip[0]=ip[1]=ip[2]=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q2",2);
      return;
}
