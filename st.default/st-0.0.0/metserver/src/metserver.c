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
#include <signal.h>  /* Not needed anymore? */
#include <sys/time.h>
#include <fcntl.h>
#include <pthread.h>    /* For multithreading. */
#include <netdb.h>      /* For structure addrinfo. */
#include <time.h>

char *metget(char*, char*); 

#define MYPORT 50001    /* the port users will be connecting to */

/* STALE_AGE determines how old, in seconds, data must be
 * to be considered stale. Stale data results in an error. */
#define STALE_AGE 300

#define BACKLOG 5       /* how many pending connections queue will hold */
#define TRUE 1
#define METBUF 80

/* To use gethostbyname make sure '#define USE_GETADDRINFO' 
   is commented. */
#define USE_GETADDRINFO /* Line to comment that modifies behavior. */
#ifndef USE_GETADDRINFO
#define USE_GETHOSTBYX
#endif                  /* End if not USE_GETADDRINFO defined */

/* Need a structure to pass to the thread that will get new met data. */
struct met_data{
  char *buf;
  struct timespec last_updated;
  pthread_mutex_t mutex; /* Mutex for locking the met data for reading/writing. */
};

int met_data_age(struct met_data *md) {
	struct timespec now;
	if (clock_gettime(CLOCK_MONOTONIC, &now) < 0) {
		err_report("clock_gettime", 0, errno, 0);
		return 0;
	}
	return now.tv_sec - md->last_updated.tv_sec;
}


/* Define  globally accessible variables. */
static struct met_data metstr;
static char temp_buf[2][METBUF]; /* Will contain met data string from function metget */
static char port1[20];
static char port2[20];
char metdevice[20];

void *threadFunc(void *arg) {
  /* This function will simply continuously call metget.
     The read string will be saved in one of the two indexes of
     'temp_buf' using the integer 'iping'. Then the buf to be sent
     will be set to point to the most recent updated string in
     'temp_buf'. This will ensure that the main thread will be able to 
     send the last updated string by copying the values pointed by 
     'metstr.buf'. */
  int iping = 0;

  while(1) {
    sprintf(temp_buf[iping], "%s", metget(port1, port2));
    pthread_mutex_lock(&metstr.mutex); /* Lock the mutex, will cause main thread to block
				          if trying to lock mutex protecting 'metstr.buf'. */
    metstr.buf = temp_buf[iping];
    if (clock_gettime(CLOCK_MONOTONIC, &metstr.last_updated) < 0) {
        err_report("clock_gettime", 0, errno, 0);
    }
    pthread_mutex_unlock(&metstr.mutex); /* Time to unlock. */
    /* Now change the value of iping so we save metget string on the other
      index the next time. */
    iping = 1 - iping;
  }/* End while */
  return NULL;
}/* End threadFunc */

void close_socket(int sockfd, char *str) 
{
  /* Function for closing the socket */
  if (close(sockfd) != 0) {
    err_report("close() error", str, errno, 0);
  }
} /* End close_socket */

main(argc, argv)
     int argc;
     char *argv[];
{
  int sockfd, new_fd;            /* listen on sock_fd, new connection 
				    on new_fd */
  struct sockaddr_in their_addr; /* connector's address information */
  int yes=1, len;
  char buf[METBUF], send_buf[METBUF];
  fd_set ready;
  struct timeval to;
  int   flags;
  int sockcnt;                   /* counter for testing connections */
  pid_t pid;
  unsigned int myport;
  int use_remote;                /* 1 if use, 0 else. */
  pthread_t thread;              /* Identifier to new thread */
#ifdef USE_GETHOSTBYX
  struct sockaddr_in my_addr;    /* my address information */
#endif
#ifdef USE_GETADDRINFO
  struct addrinfo hints, *servinfo, *p;
  char port_ch[10];
#endif

  errno=0;
 
  /* As default, set use_remote to 0. Indicates that we will not allow 
     remote connections. For us to allow the fifth argument should be 
     'remote'. */
  use_remote = 0;
  metdevice[0] = 0; 

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
  } else if (argc == 5) {
    strcpy(port1,argv[1]);
    strcpy(port2,argv[2]);
    myport=atoi(argv[3]);
    if (strstr(argv[4], "remote") != NULL) use_remote = 1;
  } else if (argc == 6) {
    strcpy(port1,argv[1]);
    strcpy(port2,argv[2]);
    myport=atoi(argv[3]);
    if (strstr(argv[4], "remote") != NULL) use_remote = 1;
    strcpy(metdevice,argv[5]);   
  }
  if(myport <= 0) {
    err_report("metserver: socket invalid value, check INSTALL", NULL,0,0);
    exit(-1);  /* Will not be able to accept connections on negative ports */
  }

  /* Set up the buffer for the structure.*/
  metstr.buf = send_buf;

  /* Initialize the mutex that will protect the met data. Create the thread that
     will read met data. */
  pthread_mutex_init(&metstr.mutex, NULL);
  pthread_create(&thread, NULL, threadFunc, NULL);

 socket_err: /* This is where we will end up when there is some kind of
	        problem when trying to set up the socket, all the way from
	        getting the host name to listening on the socket. */
#ifdef USE_GETHOSTBYX
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    /* Hopefully this will never happen. */
    err_report("socket error", NULL,errno,0);
    /* Be nice to others and I give me some time before I try again. */
    sleep(10);
    goto socket_err;
  }

  if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
    err_report("setsocketopt error", NULL,errno,0);
    close_socket(sockfd,"after setsockopt()");
    sleep(10);
    goto socket_err;
  }
 
  memset(&my_addr.sin_zero, 0, sizeof(my_addr.sin_zero)); /* zero the restt */
  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(myport);     /* short, network byte order */
  if (use_remote == 1)
    my_addr.sin_addr.s_addr = htonl(INADDR_ANY); /* remote connections too */  
  else
    my_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK); /* localhost only */
  
  if (bind(sockfd, (struct sockaddr *)&my_addr, 
	   sizeof(struct sockaddr)) == -1) {
    err_report("binding socket error", NULL,errno,0);
    close_socket(sockfd,"after bind");
    sleep(10);
    goto socket_err;
  }
#endif /* End if USE_GETHOSTBYX */

#ifdef USE_GETADDRINFO
  sprintf(port_ch, "%d", myport);
  memset(&hints, 0, sizeof hints); 
  hints.ai_family = AF_UNSPEC; 
  /* use AF_INET if want IPv4 only, AF_INET6 for IPv6 only. */
  hints.ai_socktype = SOCK_STREAM;
  /* If we do want remote connections, set the ai_flags to AI_PASSIVE. */
  if (use_remote == 1) hints.ai_flags = AI_PASSIVE;
  
  if (getaddrinfo(NULL, port_ch, &hints, &servinfo) < 0) {
    err_report("getaddrinfo error", NULL, errno, 0);
    goto socket_err;
  }
  /* Loop through all the results and connect to the first we can */
  for (p = servinfo; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
      err_report("socket error", NULL, errno, 0);
      continue; /* Or what should we do??? */
    }

    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
      err_report("setsocketopt error", NULL, errno, 0);
      close_socket(sockfd,"after setsockopt (GETADDRINFO)");
      continue;
    }

    if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      err_report("bind error", NULL, errno, 0);
      close_socket(sockfd,"after bind (GETADDRINFO)");
      continue;
    }
    break; /* If we got this far we successfully connected. */
  }/* End loop */

  if (p == NULL) {
    err_report("metserver failed to bind");
    sleep(10);
    goto socket_err;  /* Restart everything trying to get connected. */
  }

  freeaddrinfo(servinfo); /* All done with this structure. */
#endif /* End if USE_GETADDRINFO */

  if (listen(sockfd, BACKLOG) == -1) {
    err_report("listen socket error", NULL, errno, 0);
    close_socket(sockfd,"after listen()");
    sleep(10);
    goto socket_err;
  }

  do { 
    
    to.tv_sec = 3600;
    to.tv_usec = 0;
    
    FD_ZERO(&ready);
    FD_SET(sockfd,&ready);

    int ret = select(sockfd + 1, &ready, NULL, NULL, &to);
    if (ret <0) {
      err_report("socket select error", NULL,errno,0);
      continue;
    }

    if (met_data_age(&metstr) > STALE_AGE) {
      err_report("data stale", NULL, 0, 0);
    }

    if(FD_ISSET(sockfd, &ready)) {
      new_fd = accept(sockfd,(struct sockaddr *)0,(int *)0);
      if(new_fd == -1) {
	err_report("socket accept error", NULL,errno,0);
	continue;
      }
      pthread_mutex_lock(&metstr.mutex);
      memcpy(send_buf, metstr.buf, METBUF); /* Copy the values */
      pthread_mutex_unlock(&metstr.mutex);

      len=strlen(send_buf);
   
      if (send(new_fd, send_buf, len, 0) == -1) {
	/* } else if (send(new_fd, buf, len, MSG_DONTWAIT) == -1) { */
	err_report("socket send error", NULL,errno,0);
      }
      close_socket(new_fd,"after send()");
    } 
  } while(TRUE);
  close_socket(sockfd,"at end");
  pthread_mutex_destroy(&metstr.mutex);
  pthread_cancel(thread); 
  exit(0);
}

