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
#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <unistd.h>
#include <stdlib.h>

#include "../include/ipckeys.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void setup_ids()
{
    void sem_att(), skd_att(), shm_att(), cls_att(), brk_att();

    setvbuf(stdout, NULL, _IONBF, BUFSIZ);
    setvbuf(stderr, NULL, _IONBF, BUFSIZ);

    if (sizeof(Fscom) > C_RES ) {
       printf(" setup_ids: Fscom C structure too large: %d bytes \n",
              sizeof(Fscom));
       exit(-1);
    }

    shm_att( SHM_KEY);

    cls_att( CLS_KEY);

    skd_att( SKD_KEY);

    sem_att( SEM_KEY);

    nsem_att( NSEM_KEY);

    brk_att( BRK_KEY);

    go_att( GO_KEY);

}



