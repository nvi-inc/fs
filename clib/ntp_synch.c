#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define _USE_BSD
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

/* test code
int main()
{
  int synch;
  synch=ntp_synch(0);
if(synch==1)
printf("ntp synched\n");
else if(synch==0)
printf("ntp not synched\n");
else
printf("check failed\n");
}
*/
int ntp_synch(errors)
int errors;
{
  /* ntp_synch checks the status of ntp to see if it is "synch'd", note that
     being "synch'd" is no guarantee that the time is right, in fact it can
     still be wrong by constant offset or wander slowly

     input: errors  !=0 print errors, ==0 no errors
     
     If environment variable FS_CHECK_NTP does not exist, this routine
     is essentiall a NOOP and will just return -1

     if errors ==1 on the first call to ntp_synch then on subsequent calls
     even if errors == 0, some other errors may be printed, but only the frist
     time they occur

     output: (return value)  ==-1 unknown further checks disabled
                             ==0  not synched
			     ==1  synched

     even if there is an error, on subsequent calls, this routine will try
     to clean-up pids left hanging, it should be called at least once if
     there is an error
  */

  int data_processed;   /* bytes read back from ntpq */
  int file_pipes[2];    /* pipes created by pipe call */
  static pid_t fork_result=0;  /*result of fork to create child process */
  pid_t wait_result;           /* result of waiting WNOHANG for child to end */
  char buff[3072];             /* buffer to read ntpq output in */
  fd_set rfds;                 /* select() read file descriptor set */
  struct timeval tv;           /* time-out value array for select() */
  int retval;                  /* select() result */
  static errors_1st_time=-1;   /* to remember initial value of "errors" */
  static wait_1st_time=1;      /* are in initial wait errors report? */
  int status;                  /* return status of wait4() */
  int iret;                    /* kill() return value */
  static int env_check=-1;     /* have check the environment variable */ 

  if(env_check==-1) {
    if(getenv("FS_CHECK_NTP")==NULL)
      env_check=0;
    else
      env_check=1;
  }
  if(env_check==0)
    return -1;

  if(errors < 0) /* remove negative values */
    errors=1;
  
  if(errors_1st_time < 0)    /* save initial value */
    errors_1st_time=errors;

  /* first check to see if any forked process is left hanging from last
     time. If so, clean it up. If an error occurs, print the message if
     errors is set or was set on the first call. If the pid has not
     cleaned-up, we don't continue.
  */
  
  if(fork_result>0) {
    wait_result=wait4(fork_result,&status,WNOHANG,NULL);
    if(fork_result==wait_result) {
      fork_result=0;
      if(! WIFEXITED(status)) {
	if(errors) {
	  shm_addr->abend.other_error=1;
	  fprintf(stderr,
  "ntp_synch: previous ntpq ended abnormally with exit status %04.4x\n",
		  status);
	}
	shm_addr->ntp_synch_unknown=1;
	return -1;
      }
    } else if(wait_result<0) {
      if(errors || (errors_1st_time && wait_1st_time)) {
	shm_addr->abend.other_error=1;
	perror("ntp_synch: wait 1");
	wait_1st_time=0;
      }
      shm_addr->ntp_synch_unknown=1;
      return -1;
    } else if(wait_result > 0) {
      if(errors || (errors_1st_time && wait_1st_time)) {
	shm_addr->abend.other_error=1;
	perror("ntp_synch: wait 1, wrong process");
	wait_1st_time=0;
      }
      shm_addr->ntp_synch_unknown=1;
      return -1;
    } else { /* wait_result must be zero */
      if(errors || (errors_1st_time && wait_1st_time)) {
	shm_addr->abend.other_error=1;
	fprintf(stderr,"ntp_synch: old ntpq process didn't terminate\n");
	wait_1st_time=0;
      }
      shm_addr->ntp_synch_unknown=1;
      return -1;
    }
  }
  
  /* if it has failed, it is assumed it will fail at least until next
     FS start, so no more checks, unless this call asked for errors */
  
  if(shm_addr->ntp_synch_unknown && !errors)
    return -1;
  
  /* make the pipe and fork to the new process */
  
  if (pipe(file_pipes) == 0) {
    fork_result = fork();
    if (fork_result == (pid_t)-1) { /* failure */
      if(errors) {
	shm_addr->abend.other_error=1;
	perror("ntp_synch: Fork failure");
      }
      shm_addr->ntp_synch_unknown=1;
      return -1;
    } else if (fork_result == (pid_t)0) { /* we are in the new process */
      close(1);                /* should probably use dup2() to remove this */
      dup(file_pipes[1]);      /* dups file_pipes[1] into FD 1 (just closed)*/
      close(file_pipes[0]);    /* close now extraneous FD */
      close(file_pipes[1]);    /* close now extraneous FD */
      if(!errors) /* if we aren't printing errors, don't let the child do it */
	close(2);
      
      execlp("ntpq",
	     "ntpq", "-n", "-c", "rv",
	     (char *)0); /* start new program */
      exit(EXIT_FAILURE); /* if we get here it must have failed, we ignore
			     the status in the parent, depending on the lack
			     of a response to signal that there is a problem.
			     of course there could be a response and a problem,
			     but should be very unlikely. However, to be
			     really complete we should probably pipe the stderr
                             output back, to check for any and check the
			     child's return code for normal termination and a
			     zero exit status as well */
    } else { /* we are in the old process */
      close(file_pipes[1]);
      
      /* set-up select() call, allow tv_sec seconds time-out for a response */
      
      FD_ZERO(&rfds);
      FD_SET(file_pipes[0],&rfds);
      tv.tv_sec=0;
      tv.tv_usec=500000; /* one half second */
      retval=select(file_pipes[0]+1,&rfds,NULL,NULL,&tv);
      
      if(retval==-1) { /* error */
	if(errors) {
	  shm_addr->abend.other_error=1;
	  perror("ntp_synch: waiting for data from ntpq");
	}
	
	/* try to clean up pid */
	
	wait_result=wait4(fork_result,&status,WNOHANG,NULL);
	if(fork_result==wait_result) {
	  fork_result=0;
	  if(errors && ! WIFEXITED(status)) {
	    shm_addr->abend.other_error=1;
	    fprintf(stderr,
  "ntp_synch: at select ntpq ended abnormally with exit status %04.4x\n",
		    status);
	  }
	} else {
	  if((-1==kill(fork_result,SIGKILL)) && errno != ESRCH && errors) {
	    shm_addr->abend.other_error=1;
	    perror("ntp_synch: kill 2");
	  }
	  if(errors) {
	    if(wait_result<0) {
	      shm_addr->abend.other_error=1;
	      perror("ntp_synch: wait 2");
	    } else if(wait_result > 0 ) {
	      shm_addr->abend.other_error=1;
	      perror("ntp_synch: wait 2, wrong process");
	    } 
	  }
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	}
      } else if(!retval) { /* timed-out */
	if(errors) {
	  perror("ntp_synch: time-out waiting for data from ntpq");
	  shm_addr->abend.other_error=1;
	}
	wait_result=wait4(fork_result,&status,WNOHANG,NULL);
	if(fork_result==wait_result) {
	  fork_result=0;
	  if(errors && ! WIFEXITED(status)) {
	    shm_addr->abend.other_error=1;
	    fprintf(stderr,
    "ntp_synch: at time-out ntpq ended abnormally with exit status %04.4x\n",
		    status);
	  }
	} else {
	  if((-1==kill(fork_result,SIGKILL)) && errno != ESRCH && errors) {
	    shm_addr->abend.other_error=1;
	    perror("ntp_synch: kill 3");
	  }
	  if(errors) {
	    if(wait_result<0) {
	      shm_addr->abend.other_error=1;
	      perror("ntp_synch: wait 3");
	    } else if(wait_result > 0) {
	      shm_addr->abend.other_error=1;
	      perror("ntp_synch: wait 3, wrong process");
	    }
	  }
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	}
      } /* else there is something to read */
      
      data_processed = read(file_pipes[0], buff, sizeof(buff));
      close(file_pipes[0]);
      
      /* clean-up pid */
      
      wait_result=wait4(fork_result,&status,WNOHANG,NULL);
      if(fork_result==wait_result) {
	fork_result=0;
	if(! WIFEXITED(status)) {
	  if(errors) {
	    shm_addr->abend.other_error=1;
	    fprintf(stderr,
    "ntp_synch: ntpq ended abnormally with exit status %04.4x\n",status);
	  }
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	}
      } else { /* fork_result wasn't returned */
/* we don't kill here in case it is just slow in exiting
 * the wait at the start will catch this one if we are called again
 *	if(-1==(iret=kill(fork_result,SIGKILL)) && errno != ESRCH) {
 *	  if(errors) {
 *	    shm_addr->abend.other_error=1;
 *	    perror("ntp_synch: kill 4");
 *	  }
 *	}
 */
	if(wait_result<0) {
	  if(errors) {
	    shm_addr->abend.other_error=1;
	    perror("ntp_synch: wait 4");
	  }
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	} else if(wait_result > 0) {
	  if(errors) {
	    shm_addr->abend.other_error=1;
	    perror("ntp_synch: wait 4, wrong process");
	  }
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	}
	if(-1==iret && ESRCH!=errno) {
	  shm_addr->ntp_synch_unknown=1;
	  return -1;
	}
      }
      if(data_processed <0) {
	if(errors) {
	  shm_addr->abend.other_error=1;
	  perror("ntp_synch: read error");
	}
	shm_addr->ntp_synch_unknown=1;
	return -1;
      } else if(data_processed == 0) {
	if(errors) {
	  shm_addr->abend.other_error=1;
	  fprintf(stderr,"ntp_synch: read EOF\n");
	}
	shm_addr->ntp_synch_unknown=1;
	return -1;
      } else if(NULL!=strstr(buff,"sync_ntp"))
	return 1;
      else
	return 0;
    }
  } else {
    if(errors) {
      shm_addr->abend.other_error=1;
      perror("ntp_synch: pipe error");
    }
    shm_addr->ntp_synch_unknown=1;
    return -1;
  }
}
