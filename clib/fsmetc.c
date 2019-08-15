/*
** fsmetc.c -- a FS stream socket client for MET to get weather.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <strings.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>

#include "../include/params.h"        /* general fs parameter header */
#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */
/*  */


/* User has the choice to use function getaddrinfo to automatically fill up
   structures used for connecting to server or using getbyhostname and
   manually fill up the structure used for creating the connection.
   One line should be commented/uncommented to decide which one to be used,
   the line with '#define USE_GETADDRINFO'. */
#define USE_GETADDRINFO     /* Line to comment/uncomment */
#ifndef USE_GETADDRINFO
#define USE_GETHOSTBYNAME
#endif

#define MAXDATASIZE 90      /* max number of bytes we can get at once */
#define MAXLEN 90
#define TIMEOUT_SEC 0
#define TIMEOUT_USEC 500000 /* Microseconds, here half a second. */

int fsmetc_()
{
  int sockfd, numbytes,cnt,i,k,j,flags;
  char buf[MAXLEN],*ptr;
  int loopcnt, err;
  struct timeval to;
  fd_set ready;
  float temp,pres,humi,wsp;
  int wdir, status, once=0;
  int errno_save = 0;
#ifdef USE_GETHOSTBYNAME
  struct hostent *he;
  struct sockaddr_in their_addr; /* connector's address information */ 
#endif
#ifdef USE_GETADDRINFO
  struct addrinfo hints, *servinfo, *p;
  char port_ch[16];
  int loop_err = 0;  /* will keep track of where last error happened in loop. */
#endif

  err = 0;  /* err will keep track of the error. Will be used by the functions 
	       where we should close the socket descriptor if an error occured. 
	       Then a goto statement is used that will take us to where the 
	       socket is being closed. Functions resulting in an error that is 
	       used before creating the socket will return right away. */
#ifdef USE_GETHOSTBYNAME
  if ((he=gethostbyname(shm_addr->equip.wx_host)) == NULL) { /* get host info */
    logit(NULL,errno,"un");
    return -1; /* Could not find host name */
  }
  
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    logit(NULL,errno,"un");
    return -2; /* Unable to create a socket descriptor. */
  }

  /* Set socket non-blocking. */
  if (fcntl(sockfd, F_SETFL, O_NONBLOCK) == -1) {
    errno_save = errno;
    err = -3; /* Error when setting socket non-blocking. */
    goto closer;
  }

  their_addr.sin_family = AF_INET;    /* host byte order */
  their_addr.sin_port = htons(shm_addr->equip.wx_met);
                                       /* short, network byte order */
  their_addr.sin_addr = *((struct in_addr *)he->h_addr);
  memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */
  if (connect(sockfd, (struct sockaddr *)&their_addr, 
	      sizeof(struct sockaddr)) == -1) {
    if (errno != EINPROGRESS) {
      errno_save = errno;
      err = -4; /* Could not connect to server. */
      goto closer;
    }
  }
#endif /* End if USE_GETHOSTBYNAME */

#ifdef USE_GETADDRINFO
  /* Use getaddrinfo to fill up addrinfo structure which will be
     used for creating socket and setting up connection. */
  snprintf(port_ch,sizeof(port_ch), "%d", shm_addr->equip.wx_met);
  port_ch[sizeof(port_ch)-1]=0;
  memset(&hints, 0, sizeof hints);
  hints.ai_family = AF_UNSPEC;
  /* use AF_INET if want IPv4 only, AF_INET6 for IPv6 only. */
  hints.ai_socktype = SOCK_STREAM;
  
  if (getaddrinfo(shm_addr->equip.wx_host, port_ch, &hints, &servinfo) < 0) {
    logit(NULL,errno,"un");
    return -5; /* Error on getaddrinfo, could not set up structures with
		     information needed to connect to server. */
  }
  /* Loop through all the results and connect to the first we can */
  for (p = servinfo; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
      errno_save=errno;
      loop_err = 1; /* Last error occured in socket(). */
      continue; 
    }

    /* Set socket non-blocking. */
    if (fcntl(sockfd, F_SETFL, O_NONBLOCK) == -1) {
      errno_save=errno;
      if (close(sockfd) != 0) {
	logit(NULL,errno,"un");
	logit(NULL,-13,"wx");  /* close() directly after fcntl */
      }
      loop_err = 2; /* Last error occured in fcntl(). */
      continue;
    }

    if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      if (errno != EINPROGRESS) {
	errno_save=errno;
	if (close(sockfd) != 0) {
	  logit(NULL,errno,"un");
	  logit(NULL,-14,"wx");  /* close() directly after connect */
	}
	loop_err = 3; /* Last error occured in connect(). */
	continue;
      }
    }
    break; /* If we got this far we successfully connected. */
  }/* End loop */
  /* Check if we successfully connected, then p should not be NULL */
  if (p == NULL) {
     if (loop_err == 1) {
       logit(NULL,errno_save,"un");
       return -6;            /* Unable to create a socket descriptor. */
    } else if (loop_err == 2) {
       logit(NULL,errno_save,"un");
       return -7;           /* Error when setting socket non-blocking. */
    } else if (loop_err == 3) {
       logit(NULL,errno_save,"un");
       return -8;           /* Could not connect to server. */
    } else {
      return -9;            /* Did not find any addrinfo structure returned
				  by getaddrinfo we could connect to. */
    }
  } /* End if p == NULL */ 

  freeaddrinfo(servinfo); /* All done with this structure. */
#endif  /* End USE_GETADDRINFO */

  /* Check if we are ready to read from the fd_set ready where we have
     the socket sockfd. Using this we might time out. */
  FD_ZERO(&ready); /* Make sure it is empty. */
  FD_SET(sockfd, &ready);

  to.tv_sec = TIMEOUT_SEC; 
  to.tv_usec = TIMEOUT_USEC; 

  if (select(sockfd+1, &ready, NULL, NULL, &to) < 0) {
    errno_save = errno;
    err = -10;       /* Error in call to select. */
    goto closer;
  }

  /* If the select call times out sockfd will no longer be in the set ready. */ 
  if (!FD_ISSET(sockfd, &ready)) {
    errno_save = 0;
    err = -11;  /* Select call (i.e., server) timed out. */
    goto closer;
  }
  if ((numbytes=recv(sockfd, buf, 29, 0)) == -1) {
    errno_save = errno;
    err = -12;        /* Did not successfully retreive data */
    goto closer;
  }

  shm_addr->tempwx=-100;
  shm_addr->preswx=-1;
  shm_addr->humiwx=-1;
  shm_addr->speedwx=-1;
  shm_addr->directionwx=-1;
  buf[numbytes]='\0';
  ptr=buf;
  sscanf(ptr,"%f",&shm_addr->tempwx);
  ptr=index(ptr,',');
  if (ptr!=NULL & *++ptr!=0) {
      sscanf(ptr,"%f",&shm_addr->preswx);
      ptr=index(ptr,',');
      if (ptr!=NULL & *++ptr!=0) {
            sscanf(ptr,"%f",&shm_addr->humiwx);
            ptr=index(ptr,',');
            if (ptr!=NULL & *++ptr!=0) {
                sscanf(ptr,"%f",&shm_addr->speedwx);
                ptr=index(ptr,',');
                if (ptr!=NULL & *++ptr!=0) {
                   sscanf(ptr,"%d",&shm_addr->directionwx);
                }
            }
      }
   }

  errno_save = 0;

 closer:
  if (close(sockfd) != 0) {
    logit(NULL,errno,"un");
    logit(NULL,-15,"wx");  /* close error */
  }
  if(errno_save!=0)
    logit(NULL,errno_save,"un");
  
  return (err);
} 
