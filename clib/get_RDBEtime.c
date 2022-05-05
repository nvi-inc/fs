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
/* get time setting information from rdbe */

#include <memory.h>
#include <stdio.h>

#define BUFSIZE 2048

#include "../include/params.h"
#include "../include/fs_types.h"

get_RDBEtime(centisec,fm_tim,ip,to,iRDBE,vdif_epoch)
int centisec[6];
int fm_tim[6];
int ip[5];                          /* ipc array */
int to;
int iRDBE;
int *vdif_epoch;
{
      int out_recs, nrecs, i, ierr;
      int out_class, iclass;
      char *str;
      struct rdbe_dot_mon lclm;
      char inbuf[BUFSIZE];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      double secs;
      char *name;

      /* get dot? */

      out_recs=0;
      out_class=0;
      str="dbe_dot?;\n";
      cls_snd(&out_class, str, strlen(str) , 0, 0);
      out_recs++;

      ip[0]=4;
      ip[1]=out_class;
      ip[2]=out_recs;

#ifdef DEBUG
endwin ();
      printf("get_RDBEtime ip[0] %d ip[1] %d ip[2] %d\n",ip[0],ip[1],ip[2]);
#endif
      if(1==iRDBE) 
	name="rdbca";
      else if(2==iRDBE)
	name="rdbcb";
      else if(3==iRDBE)
	name="rdbcc";
      else if(4==iRDBE)
	name="rdbcd";
      else
	ierr = -403;
      if(to!=0) {
	while(skd_run_to(name,'w',ip,120)==1) {
	  if (nsem_test("fs   ") != 1) {
	    return 1;
	  }
	  name=NULL;
	}
      }	else
	skd_run(name,'w',ip);
      skd_par(ip);
      if(ip[2] <0) return 0;

#ifdef DEBUG
      printf("get_RDBEtime ierr %d\n",ip[2]);
#endif
      if(ip[2] <0) return 0;

      iclass=ip[0];
      nrecs=ip[1];
#ifdef DEBUG
      printf(" get_RDBEtime: iclass %d nrecs %d\n",iclass,nrecs);
#endif
      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error2;
	}
#ifdef DEBUG
	printf(" get_RDBEtime: i %d nchars %d\n",i,nchars);
#endif
	if(i==0) {
	  if(0!=rdbe_2_dot(inbuf,&lclm,ip)) {
	    goto error;
	  }
	} else if (i==1) {
	  memcpy(centisec,inbuf,24);
#ifdef DEBUG
	  printf(" get_RDBEbtime: centisecs %d %d %d %d %d %d\n",
		 centisec[0],centisec[1],centisec[2],centisec[3],centisec[4],
		 centisec[5]);
#endif

	}
      }
#ifdef DEBUG
      printf(" get_RDBEbtime: decode %s\n",lclm.time.time);
#endif

      if(5!=sscanf(lclm.time.time,"%4d-%3d-%2d-%2d-%lfs",fm_tim+5,fm_tim+4,
		   fm_tim+3,fm_tim+2,&secs)) {
	ierr =-402;
	goto error2;
      }

#ifdef DEBUG
      printf(" get_RDBEtime: fm_tim[5] %d fm_tim[4] %d fm_tim[3] %d fm_tim[2] %d secs %lf\n",fm_tim[5],fm_tim[4],fm_tim[3],fm_tim[2],secs);
#endif
      if(secs<59.995) {
	secs+=0.005;
	fm_tim[1]= secs;
	fm_tim[0]= (secs-fm_tim[1])*100;
      } else { /*overflow, increment minutes */
	fm_tim[0]=0;
	fm_tim[1]=0;
	fm_tim[2]+=1;
	if(fm_tim[2] == 60) { /* increment hours */
	  fm_tim[2]=0;
	  fm_tim[3]+=1;
	  if(fm_tim[3] == 24) { /* days */
	    fm_tim[3]=0;
	    fm_tim[4]+=1;
	    if(fm_tim[4] == 367 ||
	       (fm_tim[4]== 366 &&
		!((fm_tim[5] %4 == 0 && fm_tim[5] % 100 != 0)||
		  fm_tim[5] %400 == 0))) { /* years */
	      fm_tim[4]=1;
	      fm_tim[5]+=1;
	    }
	  }
	}
      }

      *vdif_epoch=lclm.vdif_epoch.vdif_epoch;

#ifdef DEBUG
      printf(" get_RDBEtime: fm_tim[5] %d fm_tim[4] %d fm_tim[3] %d fm_tim[2] %d fm_tim[1] %d sfm_tim[0] %d\n",fm_tim[5],fm_tim[4],fm_tim[3],fm_tim[2],fm_tim[1],fm_tim[0]);
#endif
      return 0;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"35",2);
error:
      cls_clr(iclass);
      return 0;
}
