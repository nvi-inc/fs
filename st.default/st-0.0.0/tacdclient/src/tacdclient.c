/*
** tacdclient.c -- a stream socket client for TAC32+.
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
#include <sys/file.h>
#include <signal.h>
#include <math.h>

#define MAXLEN 120
#define TRUE 1

char *cmd[5] = {"$PCNSL,TICLOG,STATUS\r\n",       /* TAC filename and status */
                "$PCNSL,TICDATA,TIME,ONCE\r\n",   /* TAC time */
                "$PCNSL,TICDATA,AVERAGE,ONCE\r\n",/* TAC averages */
                "$PCNSL,VERSION\r\n",             /* TAC version # */
                "$PCNSL,EXIT\r\n"};               /* TAC exit */
int which_item;

int main(int argc, char *argv[])
{
  int port;
  int sockfd,cnt,i,k,j, flags;
  char buf[MAXLEN];
  char loc_stamp[MAXLEN];
  char location_str[10][MAXLEN];
  char log_str[MAXLEN];
  char temp_str[MAXLEN];
  char buff[MAXLEN];
  int loopcnt;
  char fsloc_str[MAXLEN];
  struct tm *ptr;
  time_t t;
  struct hostent *he;
  struct timeval to;
  fd_set ready;
  struct sockaddr_in their_addr; /* connector's address information */ 
  FILE *fp;


  if(argc!=2) {
  param_err:
    err_report("tacdclient: No valid file. Follow /usr2/st/tacdclient/INSTALL instructions", NULL,0,0);
    sleep(10);
    goto param_err;
  }

 file_err:
  /* Get the information from the metget.ctl file. */
  /* Opening met file. */
  if ((fp=fopen(argv[1],"r")) == 0) {
    /* If the file does not exist complain only once. */
    err_report("tacdclient: tacdlog.ctl does not exist", NULL,0,0);
    fclose(fp);
    sleep(10);
    goto file_err;
  } else {
    /* Read the contents of the file then close  */
    k=0;
    cnt=0;
    while(fgets(buff,MAXLEN-1,fp) != NULL) {
      if(buff[0]!='*') {
        /* IP or hostname,PORT,logging,logfile..... */
        for(j=0; buff[j]!='\n'; j++) {
          temp_str[j]=buff[j];
          i++;
          if(buff[0]=='\n') {
            err_report("tacdlog.ctl:Syntax error-commas NOT allowed as delimeters
", NULL,0,0);
            fclose(fp);
            sleep(10);
            goto file_err;
          }
        }
        sscanf(temp_str," %s ",&location_str[cnt]);
        /*if you add a parameter to the control file add to the if statment.*/
        if(k==13) break;
        cnt++;
      }
      k++;
    }
  }
  fclose(fp);

  /* Build the header string */
  sprintf(fsloc_str,":location,%s,%s,%s,%s:%s,%s",
	  &location_str[6], &location_str[7],
	  &location_str[8], &location_str[9],
	  &location_str[0], &location_str[1]);
  loopcnt=atoi(location_str[4]);
  port=atoi(location_str[1]);
  if(strstr(location_str[2],"time")) which_item=1;
  else if(strstr(location_str[2],"average")) which_item=2;
  else which_item=-1;

  do {
  hostname_err:
    if ((he=gethostbyname(location_str[0])) == NULL) {  /* get the host info */
      err_report("tacdclient gethostbyname error", NULL,0,0);
      sleep(10);
      goto hostname_err;
    }

    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
      err_report("tacdclient socket error", NULL,0,0);
      sleep(10);
      goto hostname_err;
    }

    their_addr.sin_family = AF_INET;    /* host byte order */
    their_addr.sin_port = htons(port);  /* short, network byte order */
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(&(their_addr.sin_zero), '\0', 8);  /* zero the rest of the struct */
    
    /* Set socket nonblocking  */
    if ((flags = fcntl (sockfd, F_GETFL, 0)) < 0) 
      err_report("tacdclient f_getfl error", NULL,0,0);
    
    flags |= O_NONBLOCK; 
    
    if (( fcntl (sockfd, F_SETFL, flags )) < 0) 
      err_report("tacdclient f_setfl error", NULL,0,0);
    
    to.tv_sec = 4;
    to.tv_usec = 0;

    if (connect(sockfd, (struct sockaddr *)&their_addr, 
		sizeof(struct sockaddr)) < 0) {
      if(errno != EAGAIN && errno != EINPROGRESS) {
	err_report("tacdclient connect error", NULL,0,0);
	sleep(10);
	goto hostname_err;
      }
    }
    
    FD_ZERO(&ready);
    FD_SET(sockfd, &ready);

    sleep(1);
    select(sockfd+1, &ready, NULL, NULL, &to);
    
    /* 
     * This is the very first instance of the socket being read. 
     */
    sleep(1);
    if( read(sockfd, buf, sizeof buf) == 0) {
      err_report("tacdclient sock read error", NULL,0,0);
      close(sockfd);
    }
    
    /* Begin writing and reading from the socket. */
    if (which_item!=-1) {
      k = strlen(cmd[which_item]);
      if(i=write(sockfd, cmd[which_item], k) == 0) {
	err_report("tacdclient sock write error", NULL,0,0);
	close(sockfd);
      }
      sleep(1);
      if( k=read(sockfd, buf, sizeof buf) == 0) {
	err_report("tacdclient sock read error", NULL,0,0);
	close(sockfd);
      }
    } else {
      err_report("tacdclient: Confused time or average", NULL,0,0);
      close(sockfd);
    }
    for(i=0; buf[i]!='\r' && buf[i]!='\n'; i++);
    buf[i]='\0';
    close(sockfd);
    
    t=time(NULL);
    if(((time_t) -1) == t) {
      err_report("Error getting time in tacdclient",NULL,1,0);
    }

    /* Year, Day, and UT time */
    (int *)ptr=gmtime(&t);

    /* HEADER */
    strftime(loc_stamp,sizeof(loc_stamp),"%Y.%j.%H:%M:%S.00",ptr);
    strcat(loc_stamp,fsloc_str);

    /* WEATHER */
    if (which_item == 1) {
      strftime(log_str,sizeof(log_str),"%Y.%j.%H:%M:%S.00/tacd/time,",ptr);
      strcat(log_str,&buf[20]);
    } else {
      strftime(log_str,sizeof(log_str),"%Y.%j.%H:%M:%S.00/tacd/average,",ptr);
      strcat(log_str,&buf[23]);
    }

    /* LOGGER  */
    logtacd(loc_stamp,log_str,location_str[3],location_str[5]);

    /* Wait the requested time period. */
    sleep(loopcnt);
  } while(TRUE);
  exit(0);
}

