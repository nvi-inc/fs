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

#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */

char *cmd[5] = {"$PCNSL,TICLOG,STATUS\r\n",       /* TAC filename and status */
		"$PCNSL,TICDATA,TIME,ONCE\r\n",   /* TAC time */
		"$PCNSL,TICDATA,AVERAGE,ONCE\r\n",/* TAC averages */
		"$PCNSL,VERSION\r\n",             /* TAC version # */
		"$PCNSL,EXIT\r\n"};               /* TAC exit */
/*********************************************************************
 *  This program creates a socket and initiates a connection.
 *  Some data are sent over the connection and then the socket
 *  is closed ending the connection.
 *********************************************************************/
int
tacd_srv()
{
  /*
   * Local variables
   */
  int sock;
  int which_item,i,k,n;
  struct sockaddr_in server;
  struct hostent *hp, *gethostbyname();
  char buf[1024];
  
  /* Create the socket for reading */
  sock = socket( AF_INET, SOCK_STREAM, 0);
  if(sock == -1) {
    logit(NULL,-3,"ta");
    return(-1);
  }
  /* 
   * gethostbyname returns a structure including the network address of
   * the specified host.
   */
  server.sin_family = AF_INET;
  hp = gethostbyname(shm_addr->tacd.hostpc);
  
  if(hp == (struct hostent *) 0) {
    logit(NULL,-3,"ta");
    return(-1);
  }
  
  memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
  server.sin_port = htons((int)shm_addr->tacd.port);

  if(connect(sock, (struct sockaddr *)&server, sizeof server) == -1) {
    logit(NULL,-4,"ta");
    close(sock);
    return(-1);
  }
  /* 
   * This is the very first instance of the socket being read 
   * It will never close unless it is closed from outside or the 
   * Field System closes it with the 'terminate' command.
   */
  if( read(sock, buf, sizeof buf) == 0) {
    logit(NULL,-5,"ta");
    close(sock);
    return(-1);
  }
  /* Begin writing and reading from the socket. */
  for(which_item = 0; which_item <= 4; which_item++) {
    k = strlen(cmd[which_item]);
    if(i=write(sock, cmd[which_item], k) == 0) {
      logit(NULL,-6,"ta");
      close(sock);
      return(-1);
    }
    if( k=read(sock, buf, sizeof buf) == 0) {
      logit(NULL,-5,"ta");
      close(sock);
      return(-1);
    }
    /* parse the string if the exit command not sent to TAC.
     * This will make a clean exit from TAC.
     */
    if(which_item!=4) {
      switch (which_item) {
      case 0:
	/*printf("%s",&buf[21]);*/
	sscanf(&buf[21],"%s,%s",
	       &shm_addr->tacd.file,
	       &shm_addr->tacd.status);
	break;
      case 1:
	/* printf("%s",buf);*/
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
	break;
      case 2:
	/*printf("%s",&buf[23]);*/
	sscanf(&buf[23],"%d.%d,%d,%f,%f,%f,%f",
	       &shm_addr->tacd.day_a,
	       &shm_addr->tacd.day_frac_a,
	       &shm_addr->tacd.sec_average,
	       &shm_addr->tacd.rms,
	       &shm_addr->tacd.usec_average,
	       &shm_addr->tacd.max,
	       &shm_addr->tacd.min);
	break;
      case 3:
	/*printf("%s",&buf[15]);*/
	sscanf(&buf[15],"%s",
	       &shm_addr->tacd.tac_ver);
	break;
      default:
      }
    }
  }
  close(sock);
  return(0);
}
