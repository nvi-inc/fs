/*
** metclient.c -- a stream socket client for MET.
*/

#include <time.h>
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
#include <errno.h>

#define MAX_LINES 8

#define PORT 50001          /* the port client will be connecting to */

#define MAXLEN 90
#define TRUE 1
#define TIMEOUT_SEC 0
#define TIMEOUT_USEC 500000 /* Microseconds, here half a second. */


/* To use old way of doing things, just make sure '#define USE_GETADDRINFO' 
   is commented. When doing it with gethostbyX (X being 'name' or 'addr') 
   way, make sure one and only one of the USE_GETHOSTBYNAME or USE_GETHOSTBYADDR 
   are defined. By commenting the line containing "#define USE_GETHOSTBYNAME" 
   the code will automatically define the other one. So in short, there 
   are two lines that can be commented to control how the client is run, 
   the one defining USE_GETADDRINFO and the one defining USE_GETHOSTBYNAME.
   When using USE_GETHOSTBYNAME the client could be called with the
   hostname or ip address for the server (localhost is used as default).
   When using USE_GETHOSTBYADDR the client has to be called with the ip-address
   for the server (no default is used for this one). */
#define USE_GETADDRINFO          /* This is the line to be commented. */
#ifndef USE_GETADDRINFO
#define USE_GETHOSTBYX           /* For using gethostbyX code. */
#define USE_GETHOSTBYNAME           /* This line could be commented! */
#ifndef USE_GETHOSTBYNAME
#define USE_GETHOSTBYADDR
#endif                           /* End if not defined USE_GETHOSTBYNAME */
#endif                           /* End if not defined USE_GETADDRINFO */
int main(int argc, char *argv[])
{
  int sockfd, numbytes,cnt,i,k,j, flags,len;  
  char buf[MAXLEN];
  char loc_stamp[MAXLEN];
  char location_str[MAX_LINES][MAXLEN];
  char host_str[MAXLEN];
  char *sn;
  char *logfile;
  char log_str[MAXLEN];
  char temp_str[MAXLEN];
  char buff[MAXLEN];
  int loopcnt,dwx;
  char fsloc_str[MAXLEN];
  float twx,pwx,hwx,swx;
  struct tm *ptr;
  time_t t, tnew;
  int diff,phase;
  struct timeval to, tv, tv1;
  fd_set ready;
  FILE *fp;
  int csec;
  unsigned int port;
#ifdef USE_GETHOSTBYX
  /* Variables used to set up connection using gethostbyname or
     gethostbyaddr. */
  struct sockaddr_in their_addr;  /* connector's address information */
  struct hostent *he;
#ifdef USE_GETHOSTBYADDR
  struct in_addr ipv4addr;        /* Only used by gethostbyaddr. */
#endif                            /* End if USE_GETHOSTBYADDR */
#endif                            /* End if USE_GETHOSTBYX */
#ifdef USE_GETADDRINFO
  /* Variables used to set up connection with getaddrinfo */
  struct addrinfo hints, *servinfo, *p;
  char port_ch[10];
#endif                            /* End if USE_GETADDRINFO */

  errno=0;

arg_err:
  if(argc<2) {
    err_report("No valid file. Follow INSTALL instructions", NULL,0,0);
    sleep(60);
    goto arg_err;
  }

file_err:
  /* Get the information from the metget.ctl file. */
  /* Opening met file. */
  if ((fp=fopen(argv[1],"r")) == 0) {
    /* If the file does not exist complain only once. */
    err_report("metlog.ctl does not exist", NULL,errno,0);
    fclose(fp);
    sleep(60);
    goto file_err;
  } else {
    /* Read the contents of the file then close  */

    cnt=0;
    buff[0]=0;
    while(cnt < MAX_LINES && fgets(buff,MAXLEN-1,fp) != NULL) {
      if(NULL==strchr(buff,'\n')) {
	err_report("error reading metlog.ctl or contains a long line or without new-line"
		   ,buff,errno,0);
	fclose(fp);
	sleep(60);
	goto file_err;
      }
      if(buff[0]!='*' && buff[0]!= '\n') {
	int num;
        /* station code,windsample,logging,logfile */
        num=sscanf(buff," %s ",&location_str[cnt]);
	if(EOF==num || num!=1) {
	  err_report("error decoding line in metlog.ctl" ,buff,errno,num);
	  fclose(fp);
	  sleep(60);
	  goto file_err;
	}
        cnt++;
      }
      /*if you add a parameter to the control file add to the if statment.*/
      buff[0]=0;
    }
    if(cnt < MAX_LINES) {
      err_report("not enough lines in metlog.ctl" ,argv[1],0,cnt);
      fclose(fp);
      sleep(60);
      goto file_err;
    }
  }
  fclose(fp);

  if(argc<3)
    port=PORT;
  else
    port=atoi(argv[2]);

  if (argc<4)
    strcpy(host_str, "localhost"); /* Default value */
  else
    strcpy(host_str, argv[3]);

port_err:
  if(port <= 0) {
    err_report("invalid socket. Follow INSTALL instructions", NULL,0,0);
    sleep(60);
    goto port_err;
  }

  /* Build the header string */
  sprintf(fsloc_str,":location,%s,%s,%s,%s",
         &location_str[4], &location_str[5],
         &location_str[6], &location_str[7]);
  sn=location_str[0];
  loopcnt=atoi(location_str[2]);
  logfile=location_str[3];
  
  /*
     In case this is started from bootup, give metserver a chance to settle. 
  */
  sleep(10);

  do {
    if(0!=gettimeofday(&tv,NULL))
       err_report("Error getting time",NULL,errno,0);
    phase=tv.tv_sec%loopcnt;

    /* This part puts us into sleep, making sure we only ask for data
      as often as mentioned in the metlog.ctl file. */
    if(phase > 0 || tv.tv_usec > 0) {
      usleep( (loopcnt-phase)*1000000L-tv.tv_usec);
    }

    if(0!=gettimeofday(&tv,NULL))
      err_report("Error getting time0",NULL,errno,0);
      
#ifdef USE_GETHOSTBYX
    /* Use the old way of setting up a socket and connecting to the server. */
    hostname_err: 
#ifdef USE_GETHOSTBYNAME
    /* Use gethostbyname to set up 'he'. */
    if ((he = gethostbyname(host_str)) == NULL) {
      err_report("gethostbyname error", NULL,errno,0);
      continue;
    }
#endif /* End if USE_GETHOSTBYNAME */
    
#ifdef USE_GETHOSTBYADDR 
    /* Use gethostbyaddr to set up 'he'. */
    /* Now the ip address has to be given in dot notation as 
       argument when starting the client. */
    inet_pton(AF_INET, host_str, &ipv4addr);
    if ((he = gethostbyaddr(&ipv4addr, sizeof ipv4addr, AF_INET)) == NULL) {
      err_report("gethostbyaddr error", NULL, errno, 0);
      continue;
    }
#endif /* End if USE_GETHOSTBYADDR */

    if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1) {
      err_report("socket error", NULL,errno,0);
      continue;
    }
    /* Set socket non-blocking. */
    if (fcntl(sockfd, F_SETFL, O_NONBLOCK) == -1) {
      err_report("fcntl error", NULL, errno, 0);
      goto closer;
    }
    
    their_addr.sin_family = AF_INET;    /* host byte order */
    their_addr.sin_port = htons(port);  /* short, network byte order */
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */
    
    /* Year, Day, and UT time */
    if(0!=gettimeofday(&tv1,NULL))
       err_report("Error getting time1.1",NULL,errno,0);
    else {
      diff=(tv1.tv_sec-tv.tv_sec)*1000000L+(tv1.tv_usec-tv.tv_usec);
      if(diff>1000000L) 
	err_report"(pre-connect1 to metserver took more than 1.0 seconds",NULL,0,diff);
    }

    if(0!=gettimeofday(&tv,NULL))
     err_report("Error getting time2.1",NULL,errno,0);

    if (connect(sockfd, (struct sockaddr *)&their_addr,
		sizeof(struct sockaddr)) < 0) {
      if(errno != EINPROGRESS) {
	err_report("connect error", NULL,errno,0);
	goto closer;
      }
    }
#endif /* End if USE_GETHOSTBYX */

#ifdef USE_GETADDRINFO
    /* Use getaddrinfo to fill up addrinfo structure which will be
       used for creating socket and setting up connection. */
    sprintf(port_ch, "%d", port);  /* We need port number as char for getaddrinfo. */
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
  /* use AF_INET if want IPv4 only, AF_INET6 for IPv6 only. */
    hints.ai_socktype = SOCK_STREAM;
    
    if (getaddrinfo(host_str, port_ch, &hints, &servinfo) < 0) {
      err_report("getaddrinfo error", NULL, errno, 0);
      continue;
    }
    /* Loop through all the results and connect to the first we can */
    for (p = servinfo; p != NULL; p = p->ai_next) {
      if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
	err_report("socket error", NULL, errno, 0);
        continue; /* Or what should we do??? */
      }
      /* Set socket non-blocking. */
      if (fcntl(sockfd, F_SETFL, O_NONBLOCK) == -1) {
	err_report("fcntl error", NULL, errno, 0);
	if (close(sockfd) != 0) {
	  err_report("close error (USE_GETADDRINFO) directly after fcntl", NULL, errno, 0);
	}
	continue;
      }

      /* Year, Day, and UT time */
      if(0!=gettimeofday(&tv1,NULL))
	err_report("Error getting time1.2",NULL,errno,0);
      else {
	diff=(tv1.tv_sec-tv.tv_sec)*1000000L+(tv1.tv_usec-tv.tv_usec);
	if(diff>1000000L) 
	  err_report("pre-connect2 to metserver took more than 1.0 seconds",NULL,0,diff);
      }

      if(0!=gettimeofday(&tv,NULL))
	err_report("Error getting time2.2",NULL,errno,0);
      
      if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
	if(errno != EINPROGRESS) {
	  err_report("connect error", NULL,errno,0);
	  if (close(sockfd) != 0) {
	    err_report("close error (USE_GETADDRINFO) directly after connect", NULL, errno, 0);
	  }
	  continue; 
	}
      }
      break; /* If we got this far we successfully connected. */
    }/* End loop */
    
    if (p == NULL) {
      err_report("metclient failed to connect\n");
      continue;
    }
    
    freeaddrinfo(servinfo); /* All done with this structure. */
#endif /* End if USE_GETADDRINFO */ 
   
    FD_ZERO(&ready);
    FD_SET(sockfd, &ready);

    to.tv_sec = TIMEOUT_SEC;
    to.tv_usec = TIMEOUT_USEC;
  
    /* Check if we are ready to read from the fd_set 'ready'. */
    if (select(sockfd+1, &ready, NULL, NULL, &to) < 0) {
      err_report("select error", NULL, errno, 0);
      goto closer;
    }

    /* If the select call times out sockfd will not be in the set ready
       anymore since select modifies the set accordingly. Report error. */
    if (!FD_ISSET(sockfd, &ready)) {
      err_report("timed out", NULL, errno, 0); /*What should the message be???*/
      goto closer;
    }

    twx=-51.0;
    pwx=hwx=-1.;
    swx=dwx=-1.;
    buff[0]=0;

    /*Get the data*/
    numbytes=recv(sockfd, buf, 29, 0);

    /* Year, Day, and UT time */
    if(0!=gettimeofday(&tv1,NULL))
       err_report("Error getting time3",NULL,errno,0);
    else {
      diff=(tv1.tv_sec-tv.tv_sec)*1000000L+(tv1.tv_usec-tv.tv_usec);
      if(diff>500000L) 
	err_report("metserver took more than 0.5 seconds to respond",NULL,0,diff);
    }

    if (numbytes < 0) {
      err_report("recv error, metserver not responding", NULL,errno,0);
      buff[0] = 0; /* Will make us print no met data, only time and wx. */
    } else { /*This is where we end up if we successfully got the data.*/
      int icount;
      buf[numbytes]='\0';
      icount=sscanf(buf,"%f,%f,%f,%f,%d",&twx,&pwx,&hwx,&swx,&dwx);
      buff[0]=0;
      if(icount != 5) {
	err_report("error decoding met string", buf,0,0);
      } else {
	if(twx >= -50.0) sprintf(buff,"%.1f",twx);
	strcat(buff,",");
	if(pwx >= 0.0) sprintf(buff+strlen(buff),"%.1f",pwx);
	strcat(buff,",");
	if(hwx >= 0.0) sprintf(buff+strlen(buff),"%.1f",hwx);  
	if(swx >= 0.0) {
	  strcat(buff,",");
	  sprintf(buff+strlen(buff),"%.1f",swx);
	  strncat(buff,",",1);
	  sprintf(buff+strlen(buff),"%d",dwx);
	}
      }
    }

    t=tv1.tv_sec;
    csec=(tv1.tv_usec+5000L)/10000L;
    if(csec>=100) {
      t+=1;
      csec-=100;
    }
    ptr=gmtime(&t);

    /* HEADER */
    strftime(loc_stamp,sizeof(loc_stamp),"%Y.%j.%H:%M:%S.",ptr);
    sprintf(loc_stamp+strlen(loc_stamp),"%02d",csec);
    strcat(loc_stamp,fsloc_str);

    /* WEATHER */
    strftime(log_str,sizeof(log_str),"%Y.%j.%H:%M:%S.",ptr);
    sprintf(log_str+strlen(log_str),"%02d/wx/",csec);
    strcat(log_str,buff);

    /* LOGGER */
    logwx(loc_stamp,log_str,sn,logfile,ptr);

  closer:
    if (close(sockfd) != 0) {
      err_report("close error", NULL, errno, 0);
    }
    
  } while(TRUE);
  exit(0);
}
