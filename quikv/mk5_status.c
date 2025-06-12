/*
 * Copyright (c) 2020, 2022, 2025 NVI, Inc.
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
/* mk5 mk5_status SNAP command
 * 
 * Dramatis Personae:
 *      HV = Harro Verkouter / verkouter@jive.nl
 *
 * HISTORY:
 *
 * HV: 12-Jan-2015  created ['$> cp bank_check.c mk5_status.c']
 *
 *  see ../include/mk5_status.h for error codes history
 *
 *  [12/02/2022       ] Ed Himwich: Get command name for log entries from
 *  parsing of the command so that the command is agnostic about its name.
 *
 *  [06/15/2022       ] Ed Himwich: fix class number leaks
 */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/mk5_status.h"    /* error codes */

extern void logit(char* msg, int ierr, char* who);

/* 
 *  This is a multi-action Mark5 command.
 *  First we request Mark5's status ("status?"), which we log.
 *  Then we inspect the 'pending error bit'.
 *  If the Mark5 indicates there is a pending error, we extract the actual
 *  error message ("error?"), which will clear the error flag.
 *
 *  Depending on actual Mark5 server software, there may be an actual error
 *  queue. I.e. after clearing an error, we issue another "status?" to check
 *  if more errors remain.
 */

int mk5_status(command, itask, ip)
    struct cmd_ds *command;                /* parsed command structure */
    int itask;                            /* sub-task (not used?) */
    int ip[5];                           /* ipc parameters */
{
    int                nch;
    int               ierr, out_class = 0;  /* out_class init to 0 means "get next available" */
    char               buf[ 512 ];   /* could be bigger, but this could also cause class clogging */
    unsigned int       statusword, nmsg = 0;
    const unsigned int maxmsg_per_iter = 11; /* Send only a limited amount of messages per invocation
                                               to prevent clogging (locking) up the message queue */

    /* this SNAP command is only available as query, not as command */
    if( itask!=21 || command->equal=='=' )
        return mk5_status_set_error_rtn(ip, EPARM, "5h");

    /* if we get this far it is a query */
    while( 1 ) {
        /* Step 1: send "status?" query and get the status word */
        if( (ierr=mk5_status_get_status(ip, &statusword))<0 )
            return ierr;

        /* Format + send reply to this query */
        nch = snprintf(buf, sizeof(buf)-1, "%s/status,0x%08X%s", command->name,
                      statusword, ((statusword&0x0002)?",error(s) pending":""));
        cls_snd(&out_class, buf, nch, 0, 0);
        nmsg++;

        /* Error bit set or not? */
        if( (statusword&0x0002)==0 )
            break;

        /* Error bit set, check if we're not over our limit of ~5 errors */
        if( nmsg>=maxmsg_per_iter ) {
            break;
        }

        /* Retrieve the error - let the code write it after the prefix */
        nch = sprintf(buf, "%s/error,",command->name);
        if( (ierr=mk5_status_get_error(ip, buf+nch, sizeof(buf)-nch-1))<0 )
            return ierr;

        /* Send this message to the callert */
        cls_snd(&out_class, buf, strlen(buf), 0, 0);
        nmsg++;
    }
    /* If we are returning more than just the status, then we did find and
     * log errors, so we inform that something bad has happened */
    if( nmsg>1) {
        logit(NULL, -302, "5h");
    }
    /* Check if the error bit is still set because if so, we need to inform
     *  the system there's more to come */
    if( (statusword&0x0002)==0x02 ) {
            logit(NULL, -303, "5h");
    }
    /* Inform the caller about the number of messages and under which class
     * (== message ID) we sent them back */
    ip[ 0 ] = out_class;
    ip[ 1 ] = (int)nmsg;
    ip[ 2 ] = 0;
    return ip[ 2 ];
}
