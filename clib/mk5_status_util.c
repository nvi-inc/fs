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
/* mk5b_status SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <limits.h>     /* ULONG_MAX */
#include <errno.h>      /* ... */
#include <stdlib.h>     /* malloc(3) and free(3) */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */


extern char* m5trim(char*);

/* Note: I wouldn't have mind a ".h" file with error code #define's in */

/*
 * The original '5B' errors should be a guideline of what is typical eg.
 * -301 is when you are sent a parameter as you surmised, but you should add
 *  a 5H -301 to match
 *
 *  [16/01/15 10:38:55] Jonathan Quick: Then the -500 errors codes document
 *  things that went wrong whilst enacting the command, so most of yours
 *  belong in that range ... the <n> there is just the nth possible error so
 *  its -501,-502,... for as many distinct errors as you need.
 *
 *  [16/01/15 10:39:38] Jonathan Quick: and the -40x document when the
 *  internal FS class message passing mechanism lets you down
 *
 *  [16/01/15 10:42:46] Jonathan Quick: The -9<n>x appear to be marking
 *  errors in parsing the <n>th underlying command (to the Mark5) so -90x
 *  for the 'status?' and then -91x for the 'error?' say
 */
#define ECLASS          (-401) /* "error retrieving class" */
#define ENREPLY         (-501) /* "wrong number of replies" */
#define ENOREPLY_STATUS (-900) /* "query response not received" for "status?" query */
#define ESTATUSWORD     (-901) /* "error decoding status word" */
#define ENOREPLY_ERROR  (-910) /* "query response not received" for "error?" query */
#define ESTRDUP_ERROR   (-912) /* "strdup failed" */

/* Little helper to set error return.
 * 'modnm' MUST be a NTBS of at least 2 characters long */
int mk5_status_set_error_rtn(int* ip, int eno, const char* modnm) {
    ip[ 0 ] = 0;
    ip[ 1 ] = 0;
    ip[ 2 ] = eno;
    memcpy(ip+3, modnm, 2);
    return ip[ 2 ];
}


/* Replace embedded colons with their surrounding spaces to ','
 *
 * Assumption: 'ptr' points at a '\0'-terminated string
 * Each colon gets replaced by a ','.
 *
 * Thus:
 *    <gunk> : <more gunk> : : [....]
 * Becomes:
 *    <gunk>,<more gunk>,,[....]
 */
void mk5_status_replace_colons(char* ptr) {
    char*  s = ptr;
    while( 1 ) {
        char *first, *last;

        first = last = strchr(s, ':');

        if( first==NULL )
            break;

        /* Find the last non-whitespace character before the ':' */
        while( first>s && *(first-1)==' ' )
            first--;

        /* Find the first non-whitespace character *after* the ':' */
        last++;
        while( *last!='\0' && *last==' ' )
            last++;

        /* 'first' points at the character where we want the ',' */
        /* The remainder of the string needs to be moved
         * leftwards, immediately following the ',' */
        *first++   = ',';

        /* Is there actually anything following?
         * Note: we move the terminating '\0' character as well,
         * so there's no need to manually 'terminate' the string!
         */
        if( last>first )
            memmove(first, last, strlen(last)+1);

        /* Restart searching at the first character after the ',' */
        s = first;
    }
    return;
}                     


/* Execute 1 Mark5 command and get its reply */
int mk5_status_mk5cn_exec(int* ip, const char* cmd, char* buf, const size_t bufsz) {
    int   class = 0;
    void   skd_run(), skd_par();      /* program scheduling utilities */

    /* put command in shmem and prepare ip array for mk5cn */
    cls_snd(&class, cmd, strlen(cmd), 0, 0);
    ip[ 0 ] = 1;
    ip[ 1 ] = class;
    ip[ 2 ] = 1;

    skd_run("mk5cn", 'w', ip);
    skd_par(ip);

    /* ip[2] apparently is the return code from mk5cn.
     *   "<0" means: mk5cn failed
     * ip[1] is number of replies in queue, which should
     *   be exactly 1
     *
     * Separate into two different clauses:
     *   - mk5cn failing
     *   - incorrect # of replies
     */
    if( ip[2]<0 ) {
        /* mk5cn failed, return reply unmodified */
        /* Please move along, nothing to see here! */
    } else if( ip[1]!=1 ) {
        /* Clear messages left in the msgqueue, if any */
        if( ip[1]>0 )
            cls_clr( ip[0] );
        /* override return value in case of wrong number of replies */
        ip[ 1 ] = 0;
        mk5_status_set_error_rtn(ip, ENREPLY, "5h"); 
    } else {
        /* Good. mk5cn worked, (attempt to) extract the reply and copy to usr */
        int   dummy;
        int   nch = cls_rcv(ip[0], buf, ((int)bufsz) - 1, &dummy, &dummy, 0 /*blocking wait*/, 0/*do not save*/);

        /* We have received all messages of class ip[0] */
        ip[ 1 ] = 0;

        /* Less than zero characters is an error :D,
         * otherwise make it a null-terminated string */
        if( nch<0 )
            mk5_status_set_error_rtn(ip, ECLASS, "5h"); 
        else
            buf[ nch ] = '\0';
    }
    /* Return the return code of either mk5cn or indicate that something
     * else went wrong */
    return ip[ 2 ];
}

int mk5_status_get_status(int* ip, unsigned int* statusword) {
    char          buf[ 128 ], *question, *colon, *eptr;
    const int    ierr = mk5_status_mk5cn_exec(ip, "status?\n", buf, sizeof(buf));
    unsigned int word;

    /* If the execution failed, not much we can do about it eh? */
    if( ierr<0 )
        return ierr;

    /* Decode the reply we got. Should look like:
     *  !status ? 0 : 0x.... [ : <optional gunk> ]
     */
    if( (question=strchr(buf, '?'))==NULL ||
        (colon=strchr(question+1, ':'))==NULL ) {
            return mk5_status_set_error_rtn(ip, ENOREPLY_STATUS, "5h");
    }
    /* characters following ":" should be a hex number
     * so after stopping the conversion we should be looking at:
     *   '\0' (end of string),
     *   ' '  (space) or
     *   ':'  (start op optional extra gunk)
     * and also, if the conversion succeeded, the value shouldn't be larger
     * than UINT_MAX ...
     */
    word = strtoul(colon+1, &eptr, 16);

    if( (word==ULONG_MAX && errno==ERANGE) /* overflow - see strtoul(3) */ ||
        eptr==colon+1 /* "no digits at all" - see strtoul(3) */ ||
        (strchr(" :", *eptr)==NULL && *eptr!='\0') /* not an acceptable final character */ ||
        word>(unsigned int)UINT_MAX /* too big for unsigned int */ )
            return mk5_status_set_error_rtn(ip, ESTATUSWORD, "5h");

    /* Done! */
    *statusword = (unsigned int)word;
    return 0; /* success */
}

int mk5_status_get_error(int* ip, char* buf, const size_t bufsz) {
    char*  tmp  = (char*)malloc( bufsz );
    int   ierr = (tmp==NULL) ? ESTRDUP_ERROR : mk5_status_mk5cn_exec(ip, "error?\n", tmp, bufsz);

    /* only process reply if succesfull.
     * the reply looks like:
     *    !error? 0 : <error message> ;
     * we're only interested in the bit between ":" and ";"
     */
    if( ierr==0 ) {
        char *question, *colon, *semicolon;

        if( (question=strchr(tmp, '?'))==NULL ||
            (colon=strchr(question+1, ':'))==NULL ||
            (semicolon=strchr(colon+1, ';'))==NULL ) {
                ierr = mk5_status_set_error_rtn(ip, ENOREPLY_ERROR, "5h");
        } else {
                *semicolon = '\0';

                /* Trim leading/trailing whitespace */
                colon = m5trim(colon+1);

                /* replace ':'s by ',' (and remove surrounding whitespace) */
                mk5_status_replace_colons(colon);

                strcpy(buf, colon);
        }
    }
    if( tmp )
        free( tmp );
    /* Make sure that ip[2] has exactly the same value as ierr
     * (there is a code path which sets ierr but not ip[2]) */
    return ip[ 2 ] = ierr;
}
