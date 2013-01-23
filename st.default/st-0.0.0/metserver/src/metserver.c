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

#define MYPORT 50001    /* the port users will be connecting to */

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
  unsigned int myport;

  errno=0;

  if( argc <= 1) {
    err_report("metserver: ports NOT specifed, check INSTALL", NULL,0,0);
    strcpy(port1,"/dev/null");
    strcpy(port2,"/dev/null");
    exit(-1);
  } else if(argc == 2) {
    strcpy(port1,argv[1]);
    strcpy(port2,"/dev/null");
    myport=MYPORT;
  } else if(argc == 3) {
    strcpy(port1,argv[1]);
    strcpy(port2,argv[2]);
    myport=MYPORT;
  } else if(argc == 4) {
    strcpy(port1,argv[1]);
    strcpy(port2,argv[2]);
    myport=atoi(argv[3]);
  }
  if(myport <= 0)
    err_report("metserver: socket invalid value, check INSTALL", NULL,0,0);

 socket_err:
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    /* Hopefully this will never happen. */
    err_report("socket error", NULL,errno,0);
    /* Be nice to others and I give me some time before I try again. */
    sleep(10);
    goto socket_err;
  }

  /* For non-blocking mode. This is not needed here. */
  fcntl(sockfd, F_SETFL, O_NONBLOCK);

  if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
    err_report("setsocketopt error", NULL,errno,0);
    sleep(10);
    goto socket_err;
  }
    
  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(myport);     /* short, network byte order */
  my_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK); /* localhost only */
  //  my_addr.sin_addr.s_addr = htonl(INADDR_ANY); /* remote connections too */
  memset(&my_addr.sin_zero, 0, sizeof(my_addr.sin_zero)); /* zero the restt */
  
  if (bind(sockfd, (struct sockaddr *)&my_addr, 
	   sizeof(struct sockaddr)) == -1) {
    err_report("binding socket error", NULL,errno,0);
    sleep(10);
    goto socket_err;
  }

    sprintf(buf,"%s",(char *)metget(&port1,&port2));
    len=strlen(buf);
    buf[len]='\0';

  do { 

    if (listen(sockfd, BACKLOG) == -1) {
      err_report("listen socket error", NULL,errno,0);
    sleep(10);
    goto socket_err;
    }

    sa.sa_handler = sigchld_handler; /* reap all dead processes */
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &sa, NULL) == -1) {
      err_report("sigaction error", NULL,errno,0);
    }
    sin_size = sizeof(struct sockaddr_in);
  
    /* Set socket nonblocking   */
    if ((flags = fcntl (sockfd, F_GETFL, 0)) < 0) {
      err_report("fcntl f_getfl error", NULL,errno,0);
    }
    
    flags |= O_NONBLOCK; 
    
    if (( fcntl (sockfd, F_SETFL, flags )) < 0) {
      err_report("fcntl f_setfl error", NULL,errno,0);
    }
    
    to.tv_sec = 3600;
    to.tv_usec = 0;
    
    FD_ZERO(&ready);
    FD_SET(sockfd,&ready);

    if (select(sockfd + 1, &ready, (fd_set *)0,
	       (fd_set *)0, &to) < 0) {
      err_report("socket select error", NULL,errno,0);
      continue;
    }

    if(FD_ISSET(sockfd, &ready)) {
      new_fd = accept(sockfd,(struct sockaddr *)0,(int *)0);
      if( new_fd == -1) {
	err_report("socket accept error", NULL,errno,0);
       continue;
      }
      sprintf(buf,"%s",(char *)metget(&port1,&port2));
      len=strlen(buf);
      if (send(new_fd, buf, len, 0) == -1) {
	/* } else if (send(new_fd, buf, len, MSG_DONTWAIT) == -1) { */
	err_report("socket send error", NULL,errno,0);
      }
      close(new_fd);
    } else close(new_fd);
  } while(TRUE);
  exit(0);
}
