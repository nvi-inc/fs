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
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

extern void skd_run(char name[5], char w, int ip[5]);

static int ip[5] = { 0, 0, 0, 0, 0};

#define MAX_BUF 512

static char buf[MAX_BUF+1];

int
main(int argc, char **argv)
{
  int length,i, nchar, rtn1, rtn2;
  char wait;

  setup_ids();

  if (nsem_test("fs   ") != 1) {
    printf("fs isn't running\n");
    exit(-1);
  }
  if (argc < 2) {
    printf("no SNAP command provided\n");
    exit(-1);
  }

  wait='n';
  if(argc>2)
    if(strcmp(argv[1],"-w")==0)
      wait='w';
    else {
      printf("only option supported is -w\n");
      exit(-1);
    }
  
  length = strlen(argv[argc-1]);
  
  /* Execute this SNAP command via "boss". */
  if(wait=='n') {
    cls_snd( &(shm_addr->iclopr), argv[argc-1], length, 0, 0);
    skd_run("boss ",'n',ip);
    return (0);  /* ok termination */
  } else {
    skd_boss_inject_w( &(shm_addr->iclopr), argv[argc-1], length);
    skd_par(ip);
    for(i=0;i<ip[1];i++) {
      int kack;
      char *ich,buf2[MAX_BUF];

      nchar = cls_rcv(ip[0],buf,MAX_BUF,&rtn1,&rtn2,0,0);
      if(nchar < 0)
	nchar=0;
      else if (nchar>MAX_BUF)
	nchar=MAX_BUF;

      buf[nchar]=0;
      
      /* check for only ACKs */
      strcpy(buf2,buf);
      ich = strchr(buf2,'/');
      kack=ich!=NULL;
      if(kack) {
      /* ich now points to spot '/' */
	ich++;
	kack = (ich = strtok(ich, ","))!=NULL &&
	  strncmp(ich, "ack",3)==0;
	while(kack && (ich=strtok(NULL,","))!=NULL) {
	  kack=strncmp(ich,"ack",3)==0;
	}
      }
      if(!kack)
	printf("%s\n",buf);
    }
    if(ip[2]!=0) {
//      int class, ipf[5], rtn1f,rtn2f;
      char ibur[MAX_BUF];
//      int iburl;
//      if(ip[4]==0)
//	sprintf(buf,"ERROR %2.2s %4d \n",ip+3,ip[2]);
//      else
//	sprintf(buf,"ERROR %2.2s %4d (%2.2s)\n",ip+3,ip[2],ip+4);
//      class=0;
//      cls_snd(&class, buf, 80, 0, 0);
//      ipf[0]=class;
//      skd_run("fserr", 'w', ipf); 
//      skd_par(ipf);
//      iburl=cls_rcv(ipf[0], ibur, 118, &rtn1f, &rtn2f, 0,0);
//      ibur[iburl]='\0';

/* temporary fix until fserr interface is generalized or replaced */

      strcpy(ibur,"(Please check log/display for error message expansion)");

      if(ip[4]==0)
	printf("ERROR %2.2s %4d %s\n",ip+3,ip[2],ibur);
      else if(isprint(((char *)(ip+4))[0]) && isprint(((char *)(ip+4))[1]))
	printf("ERROR %2.2s %4d (%2.2s) %s\n",ip+3,ip[2],ip+4,ibur);
      else
	printf("ERROR %2.2s %4d (%d) %s\n",ip+3,ip[2],ip[4],ibur);
      exit(-1);
    }
  }
  exit(0);
    
}


