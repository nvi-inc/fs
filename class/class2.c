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

#include <stdio.h>	/* standard I/O header file */
#include <limits.h>     /* limits header file */
#include <errno.h>	/* error number definitions */
#include <sys/types.h>
#include <sys/ipc.h>	/* interprocess communications (IPC) header file */
#include <sys/msg.h>	/* message IPC header file */
#include <memory.h>    /* shared memory IPC header file */

#include "../include/ipckeys.h"
#include "../include/params.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define MAX_TEXT  120

struct  cls_buf {
	long	mtype;
        struct {
          int     parm[2];
          char    mtext[ MAX_TEXT];
        } messg;
} ;

static int msqid;

main()
{
key_t key;
int    class;
struct  cls_buf msg;
void sem_take(), sem_put();
int nchars, icount;
   setup_ids();

   key=CLS_KEY;
   msqid = msgget( key, 0);
   if ( msqid == -1 ) {
        perror("translating key");
	exit( -1);
   }

sem_take( SEM_CLS);
printf(" locked class semaphore\n");

msg.mtype=45;
icount=1;

while ( -1 != msgsnd( msqid, &msg, 99, 0))
 printf(" icount %d\n",icount++);
        

}
