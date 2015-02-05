#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>

#define MAX_BUF 160

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
  char buff[MAX_BUF];

  buff[0]=0;

  if(old==-1)
#if 1
    openlog("metclient",LOG_CONS|LOG_PID,LOG_DAEMON);
#else
    openlog("metclient",LOG_CONS|LOG_PID|LOG_PERROR,LOG_DAEMON);
#endif

  if(flag) {
    snprintf(buff,-1+sizeof(buff)-strlen(buff),"%s: ",str);
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),"%s",
	     strerror(flag));
  } else
    snprintf(buff,-1+sizeof(buff)-strlen(buff),"%s",str);

  if(file!=NULL)
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),", %s",file);
  if(ierr!=0)
    snprintf(buff+strlen(buff),-1+sizeof(buff)-strlen(buff),", Error =%d",
	     ierr);
  /* extra space after '%s' seems to help show trailing control chars */
  syslog(LOG_DAEMON|LOG_ERR,"%s ",buff);

  t=time(NULL);
  if(old==-1||t-old >= 3600) {
    char message_file[ ]="/tmp/metclient.XXXXXX";
    FILE *fildes;
    int iret;
    int fd;
    
    old=t;

    fd=mkstemp(message_file);
    if(fd==-1) {
      syslog(LOG_DAEMON|LOG_ERR, "creating error message file: %m, %s",
	     message_file);
      goto done;
    }

    fildes=fdopen(fd,"w+");
    if(fildes==NULL) {
      syslog(LOG_DAEMON|LOG_ERR,"re-opening error message file: %m, %s",
	     message_file);
      close(fd);
      goto done0;
    }
    
      
    if(0 > fprintf(fildes,"%s\n",buff)) {
      syslog(LOG_DAEMON|LOG_ERR,"write failed to message file: %m, %s",
	     message_file);
      goto done0;
    }

    if(EOF==fclose(fildes)) {
      syslog(LOG_DAEMON|LOG_ERR,"write failed to message file: %m, %s",
	     message_file);
      goto done0;
    }

    if(-1==snprintf(buff,sizeof(buff),
	     "/bin/cat %s | /usr/bin/mail -s 'metclient ERROR' root",
		    message_file)) {
      syslog(LOG_DAEMON|LOG_ERR,"mail command truncated");
      goto done0;
    }
    errno=0;
    iret=system(buff);
    if(iret==127) {
      syslog(LOG_DAEMON|LOG_ERR,"/bin/sh failed sending mailing file: %m, %s",
	     message_file);
      goto done0;
    } else if(iret==-1) {
      syslog(LOG_DAEMON|LOG_ERR,"error sending mailing file: %m, %s",
	     message_file);
      goto done0;
    }
  done0:
    if(-1==unlink(message_file))
      syslog(LOG_DAEMON|LOG_ERR,"unlink failed on message file: %m, %s",
	     message_file);
  }
 done:
  closelog();

}
