/*
 * Copyright (c) 2020, 2022 NVI, Inc.
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

/* read erchk.ctl - see /usr2/fs/st.default/control/erchk.ctl for syntax */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "../include/params.h" /* FS parameters            */

#include "erchk.h"

int read_ctl(FILE *fp, struct errlist **start) {

/* input values:
 *      fp            FILE pointer to open control file at start
 *      start         where to store the starting pointer for the linked list
 *
 *  output values:
 *      fp            still open
 *      start         NULL or points to linked list of data
 *
 * return value:  0  is no error
 *               -1  error in file format
 *              +ve  line number being processed when a system error occurred
 */

    struct errlist *item = NULL;
    struct errlist *last = NULL;
    char *line = NULL;
    ssize_t len = 0;
    ssize_t nread;
    int count=0;
    int i;
    int ierr = 0;
    char *ptr;

    if(NULL==start) {
        fprintf(stderr,"start pointer was NULL.\n");
        return count+1;
    }

    *start=NULL;

 /* I thought getline newould detect this, but apparently seg faults instead */
    if(NULL==fp) {
        fprintf(stderr,"FILE pointer was NULL.\n");
        return count+1;
    }

    while((nread = getline(&line, &len, fp)) != -1) {
        count++;
        for (i=0;i<nread;i++)
            if(0==line[i]) {
                fprintf(stderr,"Null byte found on line %d\n",count);
                free(line);
                ierr=-1;
                continue;
            }
        if(nread >= 1 && '*' == line[0])
            continue;           /* skip comments */

        /* error code */

        ptr=strtok(line," \t\n");
        if(NULL == ptr) {  /* skip blank lines */
            continue;
        }

        /* we got something, allocate and initialize structure */

        item=malloc(sizeof(struct errlist));
        if(NULL==item) {
            perror("Allocating structure");
            free(line);
            return count;
        }
        if(NULL==*start)
            *start=item;
        else
            last->next=item;
        last=item;

        item->next=NULL;
        item->code="";
        item->num="";
        item->attrib=NULL;
        item->prefix="";

        /* error code, continued */

        if(2!=strlen(ptr) && strcmp("any",ptr)) {
            fprintf(stderr,
                    "First token (error code) on line %d is not two characters and not 'any': '%s'\n",
                    count,ptr);
            ierr=-1;
        }
        item->code=strdup(ptr);
        if(NULL==item->code) {
            perror("Allocating code");
            free(line);
            return count;
        }

        /* error number */

        ptr=strtok(NULL," \t\n");
        if(NULL == ptr) {
            fprintf(stderr,
                    "Second token (error number) on line %d is missing.\n",count);
            ierr=-1;
            continue;
        }

        if(!strcmp("any",ptr))
            item->num="any";
        else {
            for (i=0;i<strlen(ptr);i++) {
                if(0==i && ('-'==ptr[i] ||'+'==ptr[i]))
                    continue;
                if(!isdigit(ptr[i])) {
                    fprintf(stderr,
                            "Second token (error number) on line %d is not an integer and not 'any': '%s'\n",
                            count,ptr);
                    ierr=-1;
                    break;
                }
            }
            item->num=strdup(ptr);
            if(NULL==item->num) {
                perror("Allocating num");
                free(line);
                return count;
            }
            if('+'==item->num[0])
                item->num++;
        }

        /* attribute */

        ptr=strtok(NULL," \t\n");
        if(NULL == ptr)  /* ignore */
            continue;

        item->attrib=strdup(ptr);
        if(NULL==item->attrib) {
            perror("Allocating attrib");
            free(line);
            return count;
        }
        if(2<strlen(ptr)) {
            fprintf(stderr,
                    "Third token (attributes) on line %d is more than two characters: '%s'\n",
                    count,ptr);
            ierr=-1;
        }

        /* prefix */

        ptr=strtok(NULL," \t\n");
        if(NULL == ptr)
            continue;

        item->prefix=strdup(ptr);
        if(NULL==item->prefix) {
            perror("Allocating prefix");
            free(line);
            return count;
        }
    }

   if(ferror(fp)) {
        perror("Reading file");
        ierr=count+1;
    } else if(NULL==*start) {
        fprintf(stderr,"No non-comment lines in file.\n");
        ierr=-1;
    }

    if(line)
        free(line);

    return ierr;
}
