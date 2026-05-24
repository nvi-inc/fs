/*
 * Copyright (c) 2025, 2026 NVI, Inc.
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
/* getfila10gtime.c - get fila10g formatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"
#include "fila10g_cfg.h"

extern int ip[5];           /* parameters for fs communications */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern int synch;
extern int rack, rack_type;
extern int m5b_crate;
extern int dbbcddcv;

extern WINDOW	* maindisp;  /* main display WINDOW data structure pointer */

extern int iCore3H;

void rte2secs();

void getcore3htime(unixtime,unixhs,fstime,fshs,formtime,formhs,vdif_epoch)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
int    *vdif_epoch;
{
	int centisec[6], centiavg, centidiff, hsdiff;
        int it[6], sleep;
	struct tm *formtm;
	char *str;
	char *name;
	int out_recs;
	int out_class;
	int decimate;
	char buff[80];
        int formtime32;
        int fstime32;

        if(synch) {
            synch=0;
            out_recs=0;
            out_class=0;

            str="pps_sync";
            cls_snd(&out_class, str, strlen(str) , 0, 0);
            out_recs++;
            logit("DBBC3 sync command sent.",0,NULL);

            ip[0]=8;
            ip[1]=out_class;
            ip[2]=out_recs;

            nsem_take("fsctl",0);
            name="dbbcn";
            while(skd_run_to(name,'w',ip,120)==1) {
                if (nsem_test("fs   ") != 1) {
                    endwin();
                    fprintf(stderr,"Field System not running - fmset aborting\n");
                    rte_sleep(SLEEP_TIME);
                    exit(0);
                }
                name=NULL;
            }

            skd_par(ip);
            nsem_put("fsctl");
            if(ip[1]!=0)
                cls_clr(ip[0]);
            if(ip[2] != 0) {
                logita(NULL,ip[2],ip+3,ip+4);
                logit(NULL,-9,"fv");
                *formtime=-1;
                return;
            }
        }

        nsem_take("fsctl",0);
        if(get_core3htime(centisec,it,ip,1,iCore3H,vdif_epoch)!=0) {
	  endwin();
	  fprintf(stderr,"Field System not running - fmset aborting\n");
	  exit(0);
	}
        nsem_put("fsctl");
	if( ip[2] != 0 )
		{
                logita(NULL,ip[2],ip+3,ip+4);
		logit(NULL,-9,"fv");
		*formtime=-1;
		return;
		}

	/* time before is more accurate */

	centisec[1]=centisec[0];
	centisec[3]=centisec[2];
	centisec[5]=centisec[4];

        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
//        rte_fixt(fstime,&centiavg);
        rte_fixt(&fstime32,&centiavg);
        *fstime=fstime32;
        *fshs=centiavg;

	hsdiff=(centisec[3]-centisec[2])*100+centisec[5]-centisec[4];
	*unixhs=centisec[4]+(hsdiff/2)/100;
	*unixtime=centisec[2];
	if(*unixhs>=100) {
	  *unixtime+=*unixhs/100;
	  *unixhs=*unixhs%100;
	}

//        rte2secs(it,formtime);
        rte2secs(it,&formtime32);
        *formtime=formtime32;
        *formhs=0;
}

