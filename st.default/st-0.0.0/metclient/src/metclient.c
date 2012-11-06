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

#define PORT 50001 /* the port client will be connecting to */

#define MAXLEN 90
#define TRUE 1

int main(int argc, char *argv[])
{
  int sockfd, numbytes,cnt,i,k,j, flags,len;  
  char buf[MAXLEN];
  char loc_stamp[MAXLEN];
  char location_str[10][MAXLEN];
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
  struct hostent *he;
  struct timeval to, tv;
  fd_set ready;
  struct sockaddr_in their_addr; /* connector's address information */ 
  FILE *fp;
  unsigned int port;

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
    while(cnt <= 7 && fgets(buff,MAXLEN-1,fp) != NULL) {
      if(buff[0]!='*' && buff[0]!= '\n') {
        /* station code,windsample,logging,logfile */
        sscanf(buff," %s ",&location_str[cnt]);
        cnt++;
      }
      /*if you add a parameter to the control file add to the if statment.*/
    }
  }
  fclose(fp);

  if(argc<3)
    port=PORT;
  else
    port=atoi(argv[2]);

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

    if(phase > 0 || tv.tv_usec > 0)
      usleep( (loopcnt-phase)*1000000L-tv.tv_usec);

    if(0!=gettimeofday(&tv,NULL))
       err_report("Error getting time",NULL,errno,0);
    t=tv.tv_sec;

  hostname_err:
  if ((he=gethostbyname("localhost")) == NULL) {  /* get the host info */
    err_report("gethostbyname error", NULL,errno,0);
    sleep(60);
    goto hostname_err;
  }

  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    err_report("socket error", NULL,errno,0);
    sleep(60);
    goto hostname_err;
  }

  their_addr.sin_family = AF_INET;    /* host byte order */
  their_addr.sin_port = htons(port);  /* short, network byte order */
  their_addr.sin_addr = *((struct in_addr *)he->h_addr);
  memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */

  /* Set socket nonblocking  */
  if ((flags = fcntl (sockfd, F_GETFL, 0)) < 0) 
    err_report("f_getfl error", NULL,errno,0);
  
  flags |= O_NONBLOCK; 
  
  if (( fcntl (sockfd, F_SETFL, flags )) < 0) 
    err_report("f_setfl error", NULL,errno,0);
  
  to.tv_sec = 10;
  to.tv_usec = 0;
  if (connect(sockfd, (struct sockaddr *)&their_addr,
	      sizeof(struct sockaddr)) < 0) {
    if(errno != EAGAIN && errno != EINPROGRESS) {
      err_report("client connect error", NULL,errno,0);
      sleep(60);
      goto hostname_err;
    }
  } 
   
  FD_ZERO(&ready);
  FD_SET(sockfd, &ready);
  
  select(sockfd+1, &ready, NULL, NULL, &to);

  twx=-51.0;
  pwx=hwx=-1.;
  swx=dwx=-1.;
  if ((numbytes=recv(sockfd, buf, 29, 0)) < 0) {
    err_report("recv error, metserver not responding", NULL,errno,0);
  } else {
    int icount;
    buf[numbytes]='\0';
    icount=sscanf(buf,"%f,%f,%f,%f,%d",&twx,&pwx,&hwx,&swx,&dwx);
    buff[0]=0;
    if(icount != 5)
      err_report("error decoding met string", buf,0,0);
    else {
      if(twx >= -50.0)
	sprintf(buff,"%.1f",twx);
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
    /* Year, Day, and UT time */
    ptr=gmtime(&t);

    /* HEADER */
    strftime(loc_stamp,sizeof(loc_stamp),"%Y.%j.%H:%M:%S.00",ptr);
    strcat(loc_stamp,fsloc_str);

    /* WEATHER */
    strftime(log_str,sizeof(log_str),"%Y.%j.%H:%M:%S.00/wx/",ptr);
    /*strcat(log_str,buf);*/
    strcat(log_str,buff);

    /* LOGGER */
    logwx(loc_stamp,log_str,sn,logfile);
    close(sockfd);

  } while(TRUE);
  exit(0);
}







