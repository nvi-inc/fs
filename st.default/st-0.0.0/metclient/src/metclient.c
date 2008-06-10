/*
** metclient.c -- a stream socket client for MET.
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
#include <errno.h>
#include <time.h>

#define PORT 30384 /* the port client will be connecting to */

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
  time_t t;
  struct hostent *he;
  struct timeval to;
  fd_set ready;
  struct sockaddr_in their_addr; /* connector's address information */ 
  FILE *fp;


  if(argc!=2) {
  param_err:
    err_report("metclient: No valid file. Follow /usr2/st/metclient/INSTALL instructions", NULL,0,0);
    sleep(10);
    goto param_err;
  }

 file_err:
  /* Get the information from the metget.ctl file. */
  /* Opening met file. */
  if ((fp=fopen(argv[1],"r")) == 0) {
    /* If the file does not exist complain only once. */
    err_report("metclient: metlog.ctl does not exist", NULL,0,0);
    fclose(fp);
    sleep(10);
    goto file_err;
  } else {
    /* Read the contents of the file then close  */
    k=0;
    cnt=0;
    while(fgets(buff,MAXLEN-1,fp) != NULL) {
      if(buff[0]!='*') {
        /* station code,windsample,logging,logfile */
        for(j=0; buff[j]!='\n'; j++) {
          temp_str[j]=buff[j];
          i++;
          if(buff[0]=='\n') {
	    err_report("metlog.ctl:Syntax error-commas NOT allowed as delimeters", NULL,0,0);
	    fclose(fp);
	    sleep(10);
	    goto file_err;
          }
        }
        sscanf(temp_str," %s ",&location_str[cnt]);
	/*if you add a parameter to the control file add to the if statment.*/
        if(k==8) break;
        cnt++;
      }
      k++;
    }
  }
  fclose(fp);

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

  hostname_err:
  if ((he=gethostbyname("localhost")) == NULL) {  /* get the host info */
    err_report("metclient gethostbyname error", NULL,0,0);
    sleep(10);
    goto hostname_err;
  }

  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    err_report("metclient socket error", NULL,0,0);
    sleep(10);
    goto hostname_err;
  }

  their_addr.sin_family = AF_INET;    /* host byte order */
  their_addr.sin_port = htons(PORT);  /* short, network byte order */
  their_addr.sin_addr = *((struct in_addr *)he->h_addr);
  memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */

  /* Set socket nonblocking  */
  if ((flags = fcntl (sockfd, F_GETFL, 0)) < 0) 
    err_report("metclient f_getfl error", NULL,0,0);
  
  flags |= O_NONBLOCK; 
  
  if (( fcntl (sockfd, F_SETFL, flags )) < 0) 
    err_report("metclient f_setfl error", NULL,0,0);
  
  to.tv_sec = 4;
  to.tv_usec = 0;
  if (connect(sockfd, (struct sockaddr *)&their_addr,
	      sizeof(struct sockaddr)) < 0) {
    if(errno != EAGAIN && errno != EINPROGRESS) {
      perror("connect");
      err_report("metclient client connect error", NULL,0,0);
      sleep(10);
      goto hostname_err;
    }
  } 
   
  sleep(1);
  FD_ZERO(&ready);
  FD_SET(sockfd, &ready);
  
  select(sockfd+1, &ready, NULL, NULL, &to);

  sleep(1);
  if ((numbytes=recv(sockfd, buf, 29, 0)) < 0) {
    err_report("metclient recv error", NULL,0,0);
    strcpy(buf,"Client Timed Out");
    numbytes=34;
  }
    buf[numbytes]='\0';

    sscanf(buf,"%f,%f,%f,%f,%d",&twx,&pwx,&hwx,&swx,&dwx);
    buff[0]='\0';
    if(twx >= -50.0) sprintf(&buff[0],"%.1f",twx);
    if(swx >= 0.0 || hwx >= 0.0 || pwx >= 0.0) strcpy(&buff[strlen(buff)],",");
    if(pwx >= 0.0) sprintf(&buff[strlen(buff)],"%.1f",pwx);
    if(swx >= 0.0 || hwx >= 0.0) strcat(buff,",");
    if(hwx >= 0.0) sprintf(&buff[strlen(buff)],"%.1f",hwx);
    if(swx >= 0.0) {
      strcat(buff,",");
      sprintf(&buff[strlen(buff)],"%.1f",swx);
      strncat(buff,",",1);
      sprintf(&buff[strlen(buff)],"%d",dwx);
    }

    t=time(NULL);
    if(((time_t) -1) == t) {
      err_report("Error getting time in metclient",NULL,1,0);
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

    /* Wait the requested time period. */
    sleep(loopcnt-4);
  } while(TRUE);
  exit(0);
}







