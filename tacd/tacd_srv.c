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

char *cmd[4] = {"$PCNSL,TICLOG,STATUS\r\n",       /* TAC filename and status */
		"$PCNSL,TICDATA,TIME,ONCE\r\n",   /* TAC time */
		"$PCNSL,TICDATA,AVERAGE,ONCE\r\n",/* TAC averages */
		"$PCNSL,EXIT\r\n"};               /* TAC exit */

/*********************************************************************
 *  This program creates a socket and initiates a connection.
 *  Some data are sent over the connection and then the socket
 *  is closed ending the connection.
 *********************************************************************/
int
tacd_srv(char host_name[], int *port_num)
{
  /*
   * Local variables
   */
  int sock;
  int which_item,i,k;
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
  hp = gethostbyname(host_name);
  
  if(hp == (struct hostent *) 0) {
    logit(NULL,-3,"ta");
    return(-1);
  }
  
  memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
  server.sin_port = htons((int)port_num);

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
  for(which_item = 0; which_item <= 3; which_item++) {
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
    if(which_item!=3) {
      parse_it(buf,which_item);
    }
    rte_sleep(100);
  }
  close(sock);
  return(0);
}
