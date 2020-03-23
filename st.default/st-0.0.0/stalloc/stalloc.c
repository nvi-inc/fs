/*
 *
 * This file is part of the station example code
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the public
 * domain worldwide. This software is distributed without any warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication along
 * with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 *
 */


#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <stdlib.h>

#include "../../fs/include/params.h"
#include "../../fs/include/fs_types.h"
#include "../include/stparams.h"
#include "../include/stcom.h"
#include "../include/stm_addr.h"

main()
{
    int size, stm_id;
    key_t key;

    key = STM_KEY;
    size = STM_SIZE;

    if( (stm_id = stm_get( key, size)) == -1) {
        fprintf( stderr, " stm_get failed \n");
        exit( -1);
    }
    stm_att( key);
}
