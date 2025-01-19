/*
 * Copyright (c) 2023, 2025 NVI, Inc.
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
//     -7  = 'name' too long
//     -8  = 'name' not active
//
// -1 to -4 set *err with errno
//
// -7 exists because not all scanf()s support the 'm' directive,
//    if they did, then it would be necessary to figure out if it is
//    safe in this case, instead the limit is massively too large since
//    that is inexpensive and removes dependence on any likely expansion
//    of the comm name in /etc/[pid]/stat, or at least any likely
//    FS program name length
//
//    apparently the comm name can be longer than the current claimed max
//    of 16 characters, which seems to be for file names of programs, lengths
//    of more than 32 characters have been observed

    DIR* dir;
    struct dirent* ent;
    char buf[512];

    long  pid;
    char pname[258] = {0,}; /* actual maximum is 16 plus a null */
    FILE *fp=NULL;
    int ipid;
    int count;
/*
 *  The edge case is that the max has to be one less than what will
 *  fit in pname, so if the field that pname is reading is longer than
 *  name, we won't get a match due to truncation.
 */
    if(strlen(name)>sizeof(pname)-2)
        return -7;

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
            if (NULL==fgets(buf,sizeof(buf),fp)) {
                fclose(fp);
                closedir(dir);
                return -4;
            }
            count = sscanf(buf, "%d (%257[^)]", &pid, pname);
            if (2 != count) {
                char buf2[129];
                int len=strlen(buf);

                if(len>64)
                    buf[64]=0;
                else if(len>0 && buf[len-1]=='\n')
                    buf[len-1]=0;
                sprintf(buf2,"internal error: find_process failed to decode: '%s'",buf);
                logite(buf2,-179,"bo");
                fclose(fp);
                closedir(dir);
                return -5;
            } else if (!strcmp(pname, name)) {
                fclose(fp);
                closedir(dir);
                return (pid_t) ipid;
            } else
                fclose(fp);
        } else if (ENOENT==errno) {
            ; /* in case the file disappeared after the directory read */
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
        return -8;
    }
}
