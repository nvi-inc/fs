/*
** fsmetc.c -- a FS stream socket client for MET to get weather.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>

#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */
/*  */

#define PORT 30384 /* the port client will be connecting to */

#define MAXDATASIZE 90 /* max number of bytes we can get at once */
#define MAXLEN 90
long begin, end;

int fsmetc_()
{
  int sockfd, numbytes,cnt,i,k,j,flags;
  char buf[MAXLEN];
  int loopcnt, err;
  struct timeval to;
  fd_set ready;
  struct hostent *he;
  struct sockaddr_in their_addr; /* connector's address information */ 
  float temp,pres,humi,wsp;
  int wdir, status, once=0;

  rte_rawt(&begin);
  /* Give me the most recent weather data. 
   * Weather can not be older then 4secs.
   */
  if(begin >= end+400) {
    if ((he=gethostbyname("localhost")) == NULL) {  /* get the host info */
      return (-8);
    }

    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
       return (-1);
    }
    
    their_addr.sin_family = AF_INET;    /* host byte order */
    their_addr.sin_port = htons(PORT);  /* short, network byte order */
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */
    if (connect(sockfd, (struct sockaddr *)&their_addr, 
		sizeof(struct sockaddr)) == -1) {
      return (-2);
    }
    
    if ((numbytes=recv(sockfd, buf, 29, 0)) == -1) {
      return (-6);
    }
    buf[numbytes]='\0';
    sscanf(buf,"%f,%f,%f,%f,%d",
	   &shm_addr->tempwx,
	   &shm_addr->preswx,
	   &shm_addr->humiwx,
	   &shm_addr->speedwx,
	   &shm_addr->directionwx);
    rte_rawt(&end);
    close(sockfd);
  }
  return (0);
}
