/*
** metserver.c -- a stream socket server for the MET system.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/time.h>
#include <fcntl.h>

#define MYPORT 30384    /* the port users will be connecting to */

#define BACKLOG 5       /* how many pending connections queue will hold */
#define TRUE 1
#define METBUF 80

/* No Zombies allowed */
void sigchld_handler(int s)
{
    while(wait(NULL) > 0);
}

main(argc, argv)
     int argc;
     char *argv[];
{
  int sockfd, new_fd;            /* listen on sock_fd, new connection 
				    on new_fd */
  struct sockaddr_in my_addr;    /* my address information */
  struct sockaddr_in their_addr; /* connector's address information */
  int sin_size;
  struct sigaction sa;
  int yes=1, len;
  char port1[20], port2[20], buf[METBUF];
  fd_set ready;
  struct timeval to;
  int   flags;
  int sockcnt;                   /* counter for testing connections */
  pid_t pid;

  if( argc <= 1) {
  ports_err:
    err_report("metserver: ports NOT specifed, check INSTALL", NULL,0,0);
    strcpy(port1,"/dev/null");
    port2[strlen(port2)]='\0';
    strcpy(port2,"/dev/null");
    port2[strlen(port2)]='\0';
    sleep(10);
    goto ports_err;
  } else if(argc == 2) {
    strcpy(port1,argv[1]);
    port1[strlen(port1)]='\0';
    strcpy(port2,"/dev/null");
    port2[strlen(port2)]='\0';
  } else {
    strcpy(port1,argv[1]);
    port1[strlen(port1)]='\0';
    strcpy(port2,argv[2]);
    port2[strlen(port2)]='\0';
  }

 
 socket_err:
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    /* Hopefully this will never happen. */
    err_report("metserver: socket error", NULL,0,0);
    /* Be nice to others and I give me some time before I try again. */
    sleep(10);
    goto socket_err;
  }

  /* For non-blocking mode. This is not needed here. */
  fcntl(sockfd, F_SETFL, O_NONBLOCK);

  if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
    err_report("metserver: setsocketopt error", NULL,0,0);
    sleep(10);
    goto socket_err;
  }
    
  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(MYPORT);     /* short, network byte order */
  my_addr.sin_addr.s_addr = INADDR_ANY; /* automatically fill with my IP */
  memset(&(my_addr.sin_zero), '\0', 8); /* zero the rest of the struct */
  
  if (bind(sockfd, (struct sockaddr *)&my_addr, 
	   sizeof(struct sockaddr)) == -1) {
    err_report("metserver: binding socket error", NULL,0,0);
    sleep(10);
    goto socket_err;
  }

    sprintf(buf,"%s",(char *)metget(&port1,&port2));
    len=strlen(buf);
    buf[len]='\0';

  do { 

    if (listen(sockfd, BACKLOG) == -1) {
      err_report("metserver: listen socket error", NULL,0,0);
    sleep(10);
    goto socket_err;
    }

    sa.sa_handler = sigchld_handler; /* reap all dead processes */
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &sa, NULL) == -1) {
      err_report("metserver: sigaction error", NULL,0,0);
    }
    sin_size = sizeof(struct sockaddr_in);
  
    /* Set socket nonblocking   */
    if ((flags = fcntl (sockfd, F_GETFL, 0)) < 0) {
      err_report("metserver: fcntl f_getfl error", NULL,0,0);
    }
    
    flags |= O_NONBLOCK; 
    
    if (( fcntl (sockfd, F_SETFL, flags )) < 0) {
      err_report("metserver: fcntl f_setfl error", NULL,0,0);
    }
    
    to.tv_sec = 1;
    to.tv_usec = 250000;
    
    FD_ZERO(&ready);
    FD_SET(sockfd,&ready);

    if (select(sockfd + 1, &ready, (fd_set *)0,
	       (fd_set *)0, &to) < 0) {
      err_report("metserver: socket select error", NULL,0,0);
      continue;
    }

    new_fd = accept(sockfd,(struct sockaddr *)0,(int *)0);
    if(FD_ISSET(sockfd, &ready)) {
      if( new_fd == -1) {
	err_report("metserver: socket accept error", NULL,0,0);
	/*} else if (send(new_fd, buf, len, 0) == -1) {*/
      } else if (send(new_fd, buf, len, MSG_DONTWAIT) == -1) {
	err_report("metserver: socket send error", NULL,0,0);
      }
      close(new_fd);
      sprintf(buf,"%s",(char *)metget(&port1,&port2));
      len=strlen(buf);
      buf[len]='\0';
    } else close(new_fd);
  } while(TRUE);
  exit(0);
}






