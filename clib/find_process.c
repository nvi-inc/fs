/*
 * Copyright (c) 2022 NVI, Inc.
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
#include <sys/types.h>
#include <dirent.h>
#include<unistd.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <errno.h>

pid_t find_process(const char* name,int *err)
{
// Return values:
//     +ve = pid of a process with program 'name'
//      0  = not possible
//     -1  = can't open /proc
//     -2  = error reading /proc
//     -3  = can't open /proc/PID/stat
//     -4  = can't read /proc/PID/stat
//     -5  = can't decode /proc/PID/stat
//     -6  = can't form file name
//     -7  = 'name' not active
//
// -1 to -4 set *err with errno

    DIR* dir;
    struct dirent* ent;
    char buf[512];

    long  pid;
    char pname[33] = {0,}; /* actual maximum is 16 plus a null */
    char state;
    FILE *fp=NULL;
    int ipid;
    int count;

    if (!(dir = opendir("/proc"))) {
        *err = errno;
        return -1;
    }

    errno=0;
    while (NULL != (ent = readdir(dir))) {
        if (0 >= (ipid = atoi(ent->d_name)))
            continue;
        if (sizeof(buf) <= snprintf(buf, sizeof(buf), "/proc/%d/stat", ipid)) {
            closedir(dir);
            return -6;
        }
        fp = fopen(buf, "r");
        if (fp) {
            if (EOF == (count = fscanf(fp, "%d (%32[^)]) %c", &pid, pname, &state))) {
                fclose(fp);
                closedir(dir);
                return -4;
            } else if (3 != count) {
                fclose(fp);
                closedir(dir);
                return -5;
            } else if (!strcmp(pname, name)) {
                fclose(fp);
                closedir(dir);
                return (pid_t) ipid;
            } else
                fclose(fp);
        } else {
            closedir(dir);
            *err=errno;
            return -3;
        }
        errno=0;
    }

    if(errno) {
        *err=errno;
        return -2;
    } else {
        closedir(dir);
        return -7;
    }
}
