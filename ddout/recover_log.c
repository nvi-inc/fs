#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define PERMISSIONS 0666
#define BUFFSIZE 131072

int recover_log(lnamef,fd)
char lnamef[];
int fd;
{
  int fail, fd2, fd_temp;
  long count, countw, cum, size, before, after, seconds, offset;
  char buf_copy[BUFFSIZE];

  fail=FALSE;
  fd2=open(lnamef,O_RDONLY);  /* check to see if the file exists */
  if(fd2<0 && errno == ENOENT) {
    shm_addr->abend.other_error=1;
    fprintf(stderr,"\007!! help! ** log file '%s' doesn't exist, attempting to recover by copying.\n",
	    lnamef);

    fd2 = open(lnamef, O_RDWR|O_SYNC|O_CREAT,PERMISSIONS); /* try to create it */
    if (fd2 < 0) {
      fprintf(stderr,
	      "\007!! help! ** can't create file '%s', giving up\n",
	      lnamef);
      fail=TRUE;
    } else { 

      /* now try to make a copy */
      size=lseek(fd,0L,SEEK_CUR);
      if(size < 0)
	perror("determining size of old file to copy, ddout");
      offset=lseek(fd, 0L, SEEK_SET);
      if(offset < 0) {
	fprintf(stderr,"\007!! help! ** can't rewind original file, giving up\n");
	fail=TRUE;
      } else {
	count=0;
	countw=0;
	cum=0;
	rte_rawt(&before);
	seconds=2;
	fprintf(stderr,
		"\007!! help! ** copying to recover log file '%s', please wait ... starting.\n",
		lnamef);
	while(count==countw && 0 < (count= read(fd,buf_copy,BUFFSIZE))) {
	  countw= write(fd2,buf_copy,count);
	  if(size >0) {
	    cum+=count;
	    rte_rawt(&after);
	    if((after-before)>seconds*100) {
	      fprintf(stderr,
		      "\007!! help! ** copying to recover log file '%s', please wait ... %2d%%\n",
		      lnamef, (int) (cum*100./size));
	      seconds=seconds+2;
	    }
	  }
	}
	if(count < 0) {
	  fprintf(stderr,"\007!! help! ** failed, error reading original file, giving up\n",lnamef);
	  perror("!! help! ** ddout");
	  fail=TRUE;
	} else if (count!=0 && count!=countw) {
	  fprintf(stderr,"\007!! help! ** failed, error writing to '%s', giving up\n",lnamef);
	  perror("!! help! ** ddout");
	  fail=TRUE;
	} else 
	  fprintf(stderr,
		"\007!! help! ** copying to recover log file '%s', done.\n",
		lnamef);
      }
    }

    if(fail) {
      fprintf(stderr,"\007!! help! ** you can attempt to recover by unmounting the file system and\n");
      fprintf(stderr,"\007!! help! ** grep-ing the file system for lines starting with the date\n");
      fprintf(stderr,"\007!! help! ** portion of time tag for the date(s) of the session try to\n");
      fprintf(stderr,"\007!! help! ** do as little as possible to the file system until you\n");
      fprintf(stderr,"\007!! help! ** dismount it. Please see /usr2/fs/misc/logrecovery for details.\n");
    } else {
      fprintf(stderr,"\007!! help! ** good news, log file '%s' seems to be recovered, please check it.\n",lnamef);
      fd_temp=fd;
      fd=fd2;
      fd2=fd_temp;
    }
  } else if (fd2 < 0) {
    shm_addr->abend.other_error=1;
    perror("checking for existence of log file, ddout");
  }

  if(fd2 >= 0 && close(fd2) < 0) {
    shm_addr->abend.other_error=1;
    perror("closing fd2, ddout");
  }

  return fd;
}
