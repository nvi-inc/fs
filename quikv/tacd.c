/*********************************************************************
 * tacd snap command:
 *  This program creates a socket and initiates a connection.
 *  Some data are sent over the connection and then the socket
 *  is closed ending the connection.
 *********************************************************************/
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/file.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <math.h>
#include <fcntl.h>
#include <sys/time.h>
#include <errno.h>


#include "../include/params.h"        /* general fs parameter header */
#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */
#define MAX_BUF 256

char *cmd[5] = {"$PCNSL,TICLOG,STATUS\r\n",       /* TAC filename and status */
		"$PCNSL,TICDATA,TIME,ONCE\r\n",   /* TAC time */
		"$PCNSL,TICDATA,AVERAGE,ONCE\r\n",/* TAC averages */
		"$PCNSL,VERSION\r\n",             /* TAC version # */
		"$PCNSL,EXIT\r\n"};               /* TAC exit */

void tacd(command,itask,ip)
struct cmd_ds *command;                /* command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
  /*
   * Local variables
   */
  int sock;
  int i, k, n, ierr, flags;
  struct sockaddr_in server;
  struct hostent *hp, *gethostbyname();
  char buf[MAX_BUF];
  char *reset_host;
  char mode_str[MAX_BUF];
  struct timeval to;
  fd_set ready;
  FILE *fp;

  void tacd_dis();
  void skd_run(), skd_par();      /* program scheduling utilities */

  /* Check for empty file */
  if(shm_addr->tacd.hostpc[0] == '\0') {
    ierr=-2;
    goto error;
  }

  /* Create the socket for reading */
  sock = socket( AF_INET, SOCK_STREAM, 0);
  if(sock == -1) {
    ierr=-3;
    goto error;
  }
  
  /* 
   * gethostbyname returns a structure including the network address of
   * the specified host.
   */

  server.sin_family = AF_INET;

  hp = gethostbyname(shm_addr->tacd.hostpc);

  if(hp == (struct hostent *) 0) {
    ierr=-3;
    goto error;
  }
  
  memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
  server.sin_port = htons((int)shm_addr->tacd.port);

  /* Set socket nonblocking  */
  if ((flags = fcntl (sock, F_GETFL, 0)) < 0) {
    ierr=-4;
    close(sock);
    goto error;
  }
  flags |= O_NONBLOCK; 
  
  if (( fcntl (sock, F_SETFL, flags )) < 0) {
    ierr=-4;
    close(sock);
    goto error;
  }

  to.tv_sec = 0;
  to.tv_usec = 500;
  
  if(connect(sock, (struct sockaddr *)&server, sizeof server) < 0) {
    if(errno != EAGAIN && errno != EINPROGRESS) {
      ierr=-4;
      close(sock);
      goto error;
    }
  }

  rte_sleep(1);
  FD_ZERO(&ready);
  FD_SET(sock, &ready);

  select(sock+1, &ready, NULL, NULL, &to);

  /* 
   * socket being read to check for valid IP address.
   */
  if( read(sock, buf, sizeof buf) <= 0) {
    ierr=-9;
    close(sock);
    goto error;
  }

  if (command->equal != '=') {           /* run tacd */
    if(shm_addr->tacd.display==0){
      command->argv[0]="status";
    } 
    else if(shm_addr->tacd.display==1){
      command->argv[0]="time";
      k = strlen(cmd[1]);
      if(i=write(sock, cmd[1], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[20],"%d.%d,%f,%f,%d,%f,%f,%f,%d,%f",
	     &shm_addr->tacd.day,
	     &shm_addr->tacd.day_frac,
	     &shm_addr->tacd.msec_counter,
	     &shm_addr->tacd.usec_correction,
	     &shm_addr->tacd.nsec_accuracy,
	     &shm_addr->tacd.usec_bias,
	     &shm_addr->tacd.cooked_correction,
	     &shm_addr->tacd.pc_v_utc,
	     &shm_addr->tacd.utc_correction_sec,
	     &shm_addr->tacd.utc_correction_nsec);
    } 
    else {
      command->argv[0]="average";
      k = strlen(cmd[2]);
      if(i=write(sock, cmd[2], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[23],"%d.%d,%d,%f,%f,%f,%f",
	     &shm_addr->tacd.day_a,
	     &shm_addr->tacd.day_frac_a,
	     &shm_addr->tacd.sec_average,
	     &shm_addr->tacd.rms,
	     &shm_addr->tacd.usec_average,
	     &shm_addr->tacd.max,
	     &shm_addr->tacd.min);
    }
    close(sock);
    tacd_dis(command,itask,ip);
    return;
  } else if (command->argv[0]==NULL) {
    shm_addr->tacd.continuous=0;
    skd_run("tacd",'n',ip);
    ip[0]=ip[1]=ip[2]=0;
    close(sock);
    return;
  } else if (command->argv[1]==NULL) {/* special cases */
    if (*command->argv[0]=='?') {
      tacd_dis(command,itask,ip);
      close(sock);
      return;
    } else if(!strcmp(command->argv[0],"status")){
      k = strlen(cmd[0]);
      if(i=write(sock, cmd[0], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[21],"%s,%s",
	     &shm_addr->tacd.file,
	     &shm_addr->tacd.status);
      shm_addr->tacd.display=0;
      close(sock);
      tacd_dis(command,itask,ip);
      return;
    } else if(!strcmp(command->argv[0],"version")){
      k = strlen(cmd[3]);
      if(i=write(sock, cmd[3], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[15],"%s",
	     &shm_addr->tacd.tac_ver);
      close(sock);
      tacd_dis(command,itask,ip);
      return;
      /* We might change our minds on this this. */
      /*} else if(!strcmp(command->argv[0],"cont")){
	shm_addr->tacd.continuous=1;
	skd_run("tacd",'n',ip);
	ip[0]=ip[1]=ip[2]=0;
	close(sock);
	tacd_dis(command,itask,ip);
	return;
	} else if(!strcmp(command->argv[0],"single")){
	shm_addr->tacd.continuous=0;
	skd_run("tacd",'n',ip);
	ip[0]=ip[1]=ip[2]=0;
	close(sock);
	tacd_dis(command,itask,ip);
	return; */
    } else if(!strcmp(command->argv[0],"time")){
      k = strlen(cmd[1]);
      if(i=write(sock, cmd[1], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[20],"%d.%d,%f,%f,%d,%f,%f,%f,%d,%f",
	     &shm_addr->tacd.day,
	     &shm_addr->tacd.day_frac,
	     &shm_addr->tacd.msec_counter,
	     &shm_addr->tacd.usec_correction,
	     &shm_addr->tacd.nsec_accuracy,
	     &shm_addr->tacd.usec_bias,
	     &shm_addr->tacd.cooked_correction,
	     &shm_addr->tacd.pc_v_utc,
	     &shm_addr->tacd.utc_correction_sec,
	     &shm_addr->tacd.utc_correction_nsec);
      close(sock);
      shm_addr->tacd.display=1;
      tacd_dis(command,itask,ip);
      return;
    } else if(!strcmp(command->argv[0],"average")){
      k = strlen(cmd[2]);
      if(i=write(sock, cmd[2], k) <= 0) {
	ierr=-6;
	close(sock);
	goto error;
      }
      rte_sleep(10);
      if( k=read(sock, buf, sizeof buf) <= 0) {
	ierr=-5;
	close(sock);
	goto error;
      }
      sscanf(&buf[23],"%d.%d,%d,%f,%f,%f,%f",
	     &shm_addr->tacd.day_a,
	     &shm_addr->tacd.day_frac_a,
	     &shm_addr->tacd.sec_average,
	     &shm_addr->tacd.rms,
	     &shm_addr->tacd.usec_average,
	     &shm_addr->tacd.max,
	     &shm_addr->tacd.min);
      close(sock);
      shm_addr->tacd.display=2;
      tacd_dis(command,itask,ip);
      return;
    } else if(!strcmp(command->argv[0],"stop")){
      shm_addr->tacd.continuous=0;
      shm_addr->tacd.stop_request=1;
      skd_run("tacd",'n',ip);
      ip[0]=ip[1]=ip[2]=0;
      close(sock);
      tacd_dis(command,itask,ip);
      return;
    } else if(!strcmp(command->argv[0],"start")){
      shm_addr->tacd.continuous=0;
      shm_addr->tacd.stop_request=-1;
      shm_addr->tacd.display=2;
      skd_run("tacd",'n',ip);
      ip[0]=ip[1]=ip[2]=0;
      close(sock);
      return;
    } else {
      close(sock);
      ierr=-201;
      goto error;
    }
  }
  
  ip[0]=ip[1]=ip[2]=0;
  close(sock);
  return;
 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"ta",2);
  return;
}










