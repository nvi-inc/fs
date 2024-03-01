/*
 * Copyright (c) 2020-2021, 2023-2024 NVI, Inc.
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
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define PERMISSIONS 0664
#define BUFFSIZE 512*4096

static int  write_comment(lnamef,fd,buff)
char lnamef[];
int fd;
char buff[ ];
{
  off_t offset;
  ssize_t count;
  int it[6];

  offset=lseek(fd, -1L, SEEK_END);
  if(offset == (off_t) -1) {
    perror("\007!! help! ** error seeking last byte");
    return -1;
  }

  count=read(fd,buff,1);
  if(count < 0) {
    perror("\007!! help! ** error reading last byte");
    return -2;
  } else if (count == 0) {
    fprintf(stderr,"\007!! help! ** couldn't read last byte for unknown reason\n");
    return -3;
  }

  if(count == 1 && buff[0] != '\n') {
    buff[0]='\n';
    errno=0;
    count=write(fd,buff,1);
    if(count < 0 || count == 0 && errno !=0) {
      perror("\007!! help! ** error writing pre-comment new-line");
      return -4;
    } else if(count ==0) {
      fprintf(stderr,"\007!! help! ** couldn't add pre-comment new-line for unknown reason\n");
      return -5;
    }
  }
  rte_time(it,&it[5]);
  buff[0]='\0';
  int2str(buff,it[5],-4,1);
  strcat(buff,".");
  int2str(buff,it[4],-3,1);
  strcat(buff,".");
  int2str(buff,it[3],-2,1);
  strcat(buff,":");
  int2str(buff,it[2],-2,1);
  strcat(buff,":");
  int2str(buff,it[1],-2,1);
  strcat(buff,".");
  int2str(buff,it[0],-2,1);
  sprintf(buff+strlen(buff),":\"ddout recovered log file, resulting file: '%s'\n",lnamef);

  errno=0;
  count=write(fd,buff,strlen(buff));
  if(count < 0 || count == 0 && errno !=0) {
    perror("\007!! help! ** error writing comment");
    return -6;
  } else if(count ==0) {
    fprintf(stderr,"\007!! help! ** couldn't add comment for unknown reason\n");
    return -7;
  }
  return 0;
}

int recover_log(lnamef,fd)
char lnamef[];
int fd;
{
  int fail, fd2, recovered_in_name;
  int before, after, seconds;
  ssize_t count, countw, cum;
  off_t size, offset;
  static char buf_copy[BUFFSIZE];
  int inode, inode2;
  char file_name[sizeof(FS_ROOT "/log/")+MAX_SKD+sizeof(".log_recovered.XXXXXX")-1];

  fd2=open(lnamef,O_RDONLY);  /* check to see if the file exists */
  if (fd2 < 0) {
    if (errno != ENOENT)
      perror("\007!! help! ** error checking for existence of log file");
    else
      fprintf(stderr,"\007!! help! ** log file '%s' doesn't exist\n",lnamef);
  } else {
    struct stat file_stat;
    int ret;

    ret = fstat(fd, &file_stat);
    if (ret < 0) {
      perror("\007!! help! ** error getting inode of open log file");
    } else {
      inode = file_stat.st_ino;

      ret = fstat(fd2, &file_stat);
      if (ret < 0) {
        perror("\007!! help! ** error getting inode of file with the open log file's name");
      } else {
        inode2 = file_stat.st_ino;

        if(inode == inode2)
          goto done;         /* we are good */

        fprintf(stderr,"\007!! help! ** file '%s' is not the open log file\n", lnamef);
      }
    }
  }

/* something went wrong; no matter what it was, we will try to recover the open
   log; this is our only chance */

  shm_addr->abend.other_error=1;
  fail=FALSE;
  recovered_in_name=FALSE;
  fprintf(stderr,"!! help! ** attempting to recover '%s' by copying\n", lnamef);
  if(fd2 >= 0 && close(fd2) < 0)
    perror("\007!! help! ** error closing file with the log file name");

  strcpy(file_name,lnamef);
  fd2 = open(file_name, O_RDWR|O_SYNC|O_CREAT|O_EXCL,PERMISSIONS); /* try to create it */
  if (fd2 < 0) {
    if(errno != EEXIST)
      perror("\007!! help! ** error creating log file");
    else
      fprintf(stderr,"\007!! help! ** file '%s' already exists\n",file_name);

    strcat(file_name,"_recovered");
    fd2 = open(file_name, O_RDWR|O_SYNC|O_CREAT|O_EXCL,PERMISSIONS); /* try to create it */
    if (fd2 < 0) {
      if(errno != EEXIST)
        perror("\007!! help! ** error creating .log_recovery file");
      else
        fprintf(stderr,"\007!! help! ** file '%s' already exists\n",file_name);

      strcat(file_name,".XXXXXX");
      fd2 = mkstemp(file_name); /* try to create it */
      if (fd2 < 0) {
        if (errno != EEXIST)
          perror("\007!! help! ** error creating .log_recovery.XXXXXX file, giving up");
        else
          fprintf(stderr,"\007!! help! ** could not create a unique file name, giving up");
        fail=TRUE;
        goto fail;
      } else
        recovered_in_name=TRUE;
    } else
      recovered_in_name=TRUE;
  }
  fprintf(stderr,"!! help! ** Good news: created file '%s' for recovery.\n",file_name);

  /* now try to make a copy */
  size=lseek(fd,0L,SEEK_CUR);
  if(size < 0)
    perror("\007!! help! ** error determining size of open log file to copy: no progress meter");
  offset=lseek(fd, 0L, SEEK_SET);
  if(offset < 0) {
    perror("\007!! help! ** error rewinding open log file to copy, giving up");
    fail=TRUE;
    goto fail;
  }
  count=0;
  countw=0;
  cum=0;
  rte_rawt(&before);
  seconds=2;
  fprintf(stderr,
          "!! help! ** copying to recovery file: please wait ... starting\n");
  while(count==countw && 0 < (count= read(fd,buf_copy,BUFFSIZE))) {
    countw= write(fd2,buf_copy,count);
    cum+=count;
    rte_rawt(&after);
    if((after-before)>seconds*100) {
      if(size >0)
          fprintf(stderr,
                  "!! help! ** copying to recovery file: please wait ... %2d%%\n",
                  (int) (cum*100./size));
      else
          fprintf(stderr,
                  "!! help! ** copying to recovery file: please wait ...\n");
      seconds=seconds+2;
    }
  }
  if(count < 0) {
    perror("\007!! help! ** error reading open log file, giving up");
    fail=TRUE;
  } else if (count!=0 && count!=countw) {
    perror("\007!! help! ** error writing recovery file, giving up");
    fail=TRUE;
  } else
    fprintf(stderr,
            "!! help! ** copying to recovery file: done\n");

fail:
  if(fail) {
    fprintf(stderr,"\007!! help! ** You can attempt to recover by unmounting the file system and\n");
    fprintf(stderr,"\007!! help! ** grep-ing the file system for lines starting with the date\n");
    fprintf(stderr,"\007!! help! ** portion of time tag for the date(s) of the session. Try to\n");
    fprintf(stderr,"\007!! help! ** do as little as possible to the file system until you\n");
    fprintf(stderr,"\007!! help! ** dismount it. Please see /usr2/fs/misc/logrecovery.txt for details.\n");
  } else {
    int ierr;

    fprintf(stderr,"!! help! ** Good news: the log file seems to be recovered.\n");
    fprintf(stderr,"!! help! ** The recovery file is: '%s', please check it.\n",file_name);

    ierr=write_comment(file_name,fd2,buf_copy);
    if(ierr < -5)
      fprintf(stderr,"\007!! help! ** problem adding comment at end of recovery file, see above, may be benign\n");
    else if (ierr < -3)
      fprintf(stderr,"\007!! help! ** problem adding pre-comment new-line at end of recovery file, see above, may be benign\n");
    else if (ierr < 0)
      fprintf(stderr,"\007!! help! ** problem checking for new-line at end of recoverd file, see above, may be benign\n");
    else
      fprintf(stderr,"!! help! ** Recovery comment successfully added to recovery file.\n");

    if(recovered_in_name) {
      fprintf(stderr,"!! help! ** NOTE WELL: If you re-opened the same log file, the file with that name (whatever it is),\n");
      fprintf(stderr,"!! help! ** NOTE WELL: not the recovery file, is getting the new log entries.\n");
    }
  }

done:
  if(fd2 >= 0 && close(fd2) < 0) {
    perror("\007!! help! ** error closing fd2");
    shm_addr->abend.other_error=1;
  }

  return fd;
}
