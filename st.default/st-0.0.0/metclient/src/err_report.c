#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>

#define MAX_BUF 80

void fc_err_report(str1,str2,flag,ierr,len1,len2)
int *flag,*ierr,len1,len2;
char *str1,*str2;
{

  err_report(str1,str2,*flag,*ierr);
  return;
}
err_report(str,file,flag,ierr)
char *str,*file;
int flag,ierr;
{
  time_t t;
  static time_t old=-1;
  FILE *fildes;
  char buff[MAX_BUF];

  if(old==-1)
#if 1
    openlog("metclient",LOG_CONS|LOG_PID,LOG_DAEMON);
#else
    openlog("metclient",LOG_CONS|LOG_PID|LOG_PERROR,LOG_DAEMON);
#endif

  buff[0]=0;
  if(flag) {
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),"%s: ",str);
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),"%s",strerror(errno));
  } else
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),"%s",str);
  if(file!=NULL)
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),", %s",file);
  if(ierr!=0)
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),", Error =%d",
	     ierr);

  syslog(LOG_DAEMON|LOG_ERR,"%s",buff);

  t=time(NULL);
  if(old==-1||t-old > 3600) {
    old=t;

    fildes=fopen("/tmp/metclient.error","w+");

    fprintf(fildes,"%s\n",buff);

    fclose(fildes);

    system("/bin/cat /tmp/metclient.error | /usr/bin/mail -s 'metclient ERROR' oper");

    return;
  }
}
