/*
 * Copyright (c) 2020, 2023 NVI, Inc.
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
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/ipc.h>

#include "../include/ipckeys.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void setupdirs(void) {
#ifdef FS_SERVER_SOCKET_PATH
    system("mkdir -p " FS_SERVER_SOCKET_PATH);
    system("chgrp rtx " FS_SERVER_SOCKET_PATH);
    system("chmod 770 " FS_SERVER_SOCKET_PATH);
#endif
}

main()
{
    int size, nsems, shm_id, sem_id, cls_id, skd_id, brk_id;
    key_t key;
    void shm_att();
    int rte_secs();

    key = SHM_KEY;
    size = SHM_SIZE;

    if( (shm_id = shm_get( key, size)) == -1) {
        fprintf( stderr, " shm_get failed \n");
        exit( -1);
    }
    shm_att( key);
    shm_addr->time.index = 0;
    shm_addr->time.offset[0] = 0;
    shm_addr->time.offset[1] = 0;
    shm_addr->time.epoch[0] = 0;
    shm_addr->time.epoch[1] = 0;
    shm_addr->time.icomputer[0]=0;
    shm_addr->time.icomputer[1]=0;
    shm_addr->time.secs_off = rte_secs(&shm_addr->time.usecs_off,
				       &shm_addr->time.ticks_off,
				       &shm_addr->time.init_error,
				       &shm_addr->time.init_errno);
    shm_addr->terminate_ticks=0;
    key = SEM_KEY;
    nsems = SEM_NUM;
    if( (sem_id = sem_get( key, nsems)) == -1) {
      fprintf( stderr," sem_get failed\n");
      goto cleanup2;
    }
    sem_att(key);

    key = NSEM_KEY;
    nsems = SEM_NUM;
    if( (sem_id = nsem_get( key, nsems)) == -1) {
      fprintf( stderr," nsem_get failed\n");
      goto cleanup3;
    }
    nsem_att(key);

    key = CLS_KEY;
    size = CLS_SIZE;
    if( (cls_id = cls_get( key, size)) == -1) {
      fprintf( stderr," cls_get failed\n");
      goto cleanup4;
    }
    cls_ini( key);

    key = SKD_KEY;
    size = SKD_SIZE;
    if( (skd_id =  skd_get( key, size)) == -1) {
      fprintf( stderr," skd_get failed\n");
      goto cleanup5;
    }
    skd_ini( key);

    key = BRK_KEY;
    size = BRK_SIZE;
    if( (brk_id =  brk_get( key, size)) == -1) {
      fprintf( stderr," brk_get failed\n");
      goto cleanup6;
    }
    brk_ini( key);

    key = GO_KEY;
    nsems = SEM_NUM;
    if( (sem_id = nsem_get( key, nsems)) == -1) {
      fprintf( stderr," nsem_get failed\n");
      goto cleanup7;
    }
    go_att(key);

    setupdirs();

    exit( 0);

cleanup7:
   key = NSEM_KEY;
    if( -1 == go_rel( key)) {
      fprintf( stderr," go_rel failed\n");
    }
cleanup6:
    key = SKD_KEY;
    if( -1 == skd_rel( key)) {
      fprintf( stderr," skd_rel failed\n");
    }
cleanup5:
    key = CLS_KEY;
    if( -1 == cls_rel( key)) {
      fprintf( stderr," cls_rel failed\n");
    }
cleanup4:
   key = SEM_KEY;
    if( -1 == sem_rel( key)) {
      fprintf( stderr," sem_rel failed\n");
    }
cleanup3:
   key = NSEM_KEY;
    if( -1 == nsem_rel( key)) {
      fprintf( stderr," nsem_rel failed\n");
    }
cleanup2:
       if( shm_det( ) == -1) {
        fprintf( stderr, " shm_det failed \n");
    }
cleanup1:
    key = SHM_KEY;
       if( shm_rel( key) == -1) {
        fprintf( stderr, " shm_rel failed \n");
    }
    exit( -1);
}
