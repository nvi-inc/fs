/*
 * Copyright (c) 2022, 2023 NVI, Inc.
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
/* RDBE_data_send.c - Turn RDBE data sending on or off */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "../include/params.h"

#include "fmset.h"

extern int ip[5];           /* parameters for fs communications */
extern int iRDBE;

#define BUFSIZE 513

static char unit_letters[ ] = {" abcdefghijklm"}; /* mk6/rdbe unit letters */
static char *name_save;

static int check_send()
{
    char *name;
    char *str, *ptr;
    int out_recs;
    int out_class;

    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    char inbuf[BUFSIZE];

    out_recs=0;
    out_class=0;

    str="dbe_data_send?;\n";
    cls_snd(&out_class, str, strlen(str) , 0, 0);
    out_recs++;

    ip[0]=1;
    ip[1]=out_class;
    ip[2]=out_recs;

    name=name_save;
    nsem_take("fsctl",0);
    while(skd_run_to(name,'w',ip,120)==1) {
        if (nsem_test("fs   ") != 1) {
            endwin();
            fprintf(stderr,"Field System not running - fmset aborting\n");
            exit(0);
        }
        name=NULL;
    }
    skd_par(ip);
    nsem_put("fsctl");
    if(ip[2] != 0 ) {
        if(ip[2] != -104) {
            endwin();
            if(ip[1]!=0)
                cls_clr(ip[0]);
            fprintf(stderr,"Error %d from rdbc%c, see log for message\n",
                    ip[2], unit_letters[iRDBE-1]);
            logita(NULL,ip[2],ip+3,ip+4);
            rte_sleep(SLEEP_TIME);
            exit(0);
        }
        ip[2]=0;
    }
    if(ip[1]!=1) {
        endwin();
        if(ip[1]!=0)
            cls_clr(ip[0]);
        fprintf(stderr,"Wrong number of records, %d, from rdbc%c\n",ip[1],
                unit_letters[iRDBE-1]);
        rte_sleep(SLEEP_TIME);
        exit(0);

    }
    if ((nchars = cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
        endwin();
        fprintf(stderr,"Error reading record from rdbc%c\n",ip[1],
                unit_letters[iRDBE-1]);
        rte_sleep(SLEEP_TIME);
        exit(0);
    }

    inbuf[nchars]=0;
    ptr=strtok(inbuf,":");
    if(NULL==ptr) {
        endwin();
        fprintf(stderr,
                "Unable to decode dbe_data_send response from rdbc%c\n",
                unit_letters[iRDBE-1]);
        rte_sleep(SLEEP_TIME);
        exit(0);
    }

    ptr=strtok(NULL,":");

    if(NULL==ptr
      || strcmp(ptr,"on") && strcmp(ptr,"off") && strcmp(ptr,"waiting")) {
        endwin();
        fprintf(stderr,
                "Unable to decode on/off field of dbe_data_send response from rdbc%c\n",
                unit_letters[iRDBE-1]);
        if(NULL!=ptr)
            fprintf(stderr, "The string '%s' was not recognized",ptr);
        rte_sleep(SLEEP_TIME);
        exit(0);
    }
    if(!strcmp(ptr,"on"))
        return 1;
    else
        return 0;
}
static void set_send(int on)
{
    char *name;
    char *str;
    int out_recs;
    int out_class;

    out_recs=0;
    out_class=0;

    if(on)
        str="dbe_data_send=on;\n";
    else
        str="dbe_data_send=off;\n";

    cls_snd(&out_class, str, strlen(str) , 0, 0);
    out_recs++;

    ip[0]=1;
    ip[1]=out_class;
    ip[2]=out_recs;

    name=name_save;
    nsem_take("fsctl",0);
    while(skd_run_to(name,'w',ip,120)==1) {
        if (nsem_test("fs   ") != 1) {
            endwin();
            fprintf(stderr,"Field System not running - fmset aborting\n");
            exit(0);
        }
        name=NULL;
    }
    skd_par(ip);
    nsem_put("fsctl");
    if(ip[2] != 0) {
        endwin();
        if(ip[1]!=0)
            cls_clr(ip[0]);
        fprintf(stderr,"Error %d from rdbc%d, see log for message\n",ip[2],
                unit_letters[iRDBE-1]);
        logita(NULL,ip[2],ip+3,ip+4);
        rte_sleep(SLEEP_TIME);
        exit(0);
    } else {
        if(ip[1]!=0)
            cls_clr(ip[0]);
    }
}
void RDBE_data_send(int on)
{
    static int turn_on[MAX_RDBE];

    if (on == 1 && turn_on[iRDBE-1]==0)
        return;

    if(1==iRDBE)
        name_save="rdbca";
    else if(2==iRDBE)
        name_save="rdbcb";
    else if(3==iRDBE)
        name_save="rdbcc";
    else if(4==iRDBE)
        name_save="rdbcd";
    else {
        endwin();
        fprintf(stderr,"Internal error in getRDBEtime, no RDBE selected\n");
        rte_sleep(SLEEP_TIME);
        exit(0);
    }

    if(on==0) {
        if(0==check_send())
           return;

        turn_on[iRDBE-1]=1;
        set_send(0);
        rte_sleep(110);
    } else {
        set_send(1);
        turn_on[iRDBE-1]=0;
    }
}
