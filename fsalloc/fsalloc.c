#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

main()
{
    int size, nsems, shm_id, sem_id, cls_id, skd_id, brk_id;
    key_t key;
    void nsem_ini(),shm_att();

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

    key = SEM_KEY;
    nsems = SEM_NUM;
    if( (sem_id = sem_get( key, nsems)) == -1) {
      fprintf( stderr," sem_get failed\n");
      goto cleanup2;
    }
    sem_att(key);
    nsem_ini();

    key = CLS_KEY;
    size = CLS_SIZE;
    if( (cls_id = cls_get( key, size)) == -1) {
      fprintf( stderr," cls_get failed\n");
      goto cleanup3;
    }
    cls_ini( key);

    key = SKD_KEY;
    size = SKD_SIZE;
    if( (skd_id =  skd_get( key, size)) == -1) {
      fprintf( stderr," skd_get failed\n");
      goto cleanup4;
    }
    skd_ini( key);

    key = BRK_KEY;
    size = BRK_SIZE;
    if( (brk_id =  brk_get( key, size)) == -1) {
      fprintf( stderr," brk_get failed\n");
      goto cleanup5;
    }
    brk_ini( key);

    exit( 0);

cleanup5:
    key = SKD_KEY;
    if( -1 == skd_rel( key)) {
      fprintf( stderr," skd_rel failed\n");
    }
cleanup4:
    key = CLS_KEY;
    if( -1 == cls_rel( key)) {
      fprintf( stderr," cls_rel failed\n");
    }
cleanup3:
   key = SEM_KEY;
    if( -1 == sem_rel( key)) {
      fprintf( stderr," sem_rel failed\n");
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
