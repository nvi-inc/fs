/* Field System functions */
/*********************************************************************
 * Function tacd.c (main)
 *
 *  calls: 
 *  tacd_srv - to open socket that initiates a connection with the
 *  host and port given from a file '/usr2/control/tacd.ctl'.
 *
 *  'tacd' is executed at fs startup.
 * 080101 rdg - check to see if log is open before writing when .ctl
 *              is empty.
 *********************************************************************/
#include <sys/types.h>
#include <stdio.h>
#include <string.h>

#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */
/*  */
#define MAX_BUF 256

main()
{
  int i,j;
  long ip[5];
  char buff[120];
  char mode_str[MAX_BUF];
  struct tacd_shm tacd;
  /* HOST and PORT definition file located in /usr2/control/tacd.ctl */
  FILE *fp;
  char host_name[80];
  int *port_num=0;
  int tacd_srv();

/* connect me to the FS */
  putpname("tacd");
  setup_ids();

restart_tac:
  /* Opening file for host and port number. */
  if ((fp=fopen(FS_ROOT"/control/tacd.ctl","r")) == 0) {
    /* If the file does not exist complain only once. */
    logit(NULL,-1,"ta");
    exit(0);
  } else {
    /* Read the contents of the file then close  */
    i=0;
    while(fgets(mode_str,MAX_BUF-1,fp) != NULL) {
      if(mode_str[0]!='*') {
	/* host name please */
	for(i=0; mode_str[i]!='\n'; i++) {
	  if(mode_str[i]==',') {
	    logit(NULL,-8,"ta");
	    exit(0);
	  }
	}
	sscanf(&mode_str[0],"%s %d %d\n",
	       host_name, &port_num, &shm_addr->tacd.check);
	continue;
      }
    }
    if(!i) {
    /* 
     * File is empty.
     * logit(NULL,-2,"ta");
     * logitf("tacd/tacd.ctl control file is empty or just has comments.");
     */
      for(;;) {
	if(shm_addr->LLOG[0]!=' ') {
	  logitf("tacd/,,");
	  shm_addr->tacd.check=0;
	  shm_addr->tacd.stop_request=2;
	  break;
	}
      }
    }
    if(shm_addr->tacd.check!=0) {
      shm_addr->tacd.check*=100; /* convert to centiseconds. */
    } else {
      shm_addr->tacd.check=30*100;  /* default is 30 secs. */
    }
    i = strlen(host_name);
    host_name[i]='\0';
  }
  close(fp);  

no_tac:
  if(shm_addr->tacd.stop_request==2) {
    /* 
     * Stay here for as long as the user has no use for you.
     */
    skd_wait("tacd",ip,shm_addr->tacd.check);
    goto no_tac;
  }
  /* 
   * Test to request if we got past the no_tac.
   * This happens when a tacd=start command is issued.
   */
  if(shm_addr->tacd.stop_request==-1) {
    goto loop;
  }

  /* If we get this far save these in FS memory */
  strcpy(shm_addr->tacd.hostpc,host_name);
  shm_addr->tacd.port=(int)port_num;

  /* Run tacd_srv the first time thru. */
  if(shm_addr->tacd.hostpc[0] != '\0')
    tacd_srv(host_name,port_num);
  
  sprintf(buff,"tacd/%s,%d,%d",
	  shm_addr->tacd.hostpc,
	  shm_addr->tacd.port,
	  shm_addr->tacd.check);  

  logitf(buff);

loop:
  skd_wait("tacd",ip,shm_addr->tacd.check);

  if(shm_addr->tacd.stop_request==1) {
    /* Stay here if tacd is told to stop. */
    goto loop;
  }
  /* 
   * Test to see if the TAC host and/or port have changed.
   * This will go and reopen the file and read its content
   * when a tacd=start command is issued.
   */
  if(shm_addr->tacd.stop_request==-1) {
    shm_addr->tacd.stop_request=0;
    goto restart_tac;
  }

wakeup_block:
  memcpy(&tacd,&shm_addr->tacd,sizeof(tacd));

  if(!shm_addr->tacd.stop_request) {
    tacd_srv(host_name,port_num);
  }

  if(!shm_addr->tacd.continuous)
    goto loop;
  
  skd_end(ip);

/* extract forever until some one wakes up */
  while(TRUE) {

    if(!shm_addr->tacd.stop_request) {
      if(tacd_srv(host_name,port_num) == -1) {
	logit(NULL,-3,"ta");
	shm_addr->tacd.continuous=1;
	goto loop;
      }
    }
    /* 
     * If I have to wait for anything I always use skd_wait.
     * The last argument is the number of centiseconds to wait. 
     * The wait can be longer than 1 second, because skd_wait() will
     *  return immediately if something happens
     */
    skd_wait("tacd",ip,100);

    /* When I do a 'tacd=start' I go back to the beginning, read SM again. */
    if(shm_addr->tacd.stop_request==1)
      goto wakeup_block;

    /* when I wake-up I goto the wake-up block if some one else woke me up */
    if(dad_pid()!=0) {
      goto wakeup_block;
    }
  }
  exit(-1);
}  /* end main */
