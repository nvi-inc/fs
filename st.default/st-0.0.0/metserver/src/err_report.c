/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>
#include <unistd.h>

#define LGERR_FMT "/usr2/fs/bin/lgerr lg -1 '%s'"

#define MAX_BUF 512

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
  char cmd_buff[MAX_BUF] = {0};

  if(old==-1)
#if 1
    openlog("metserver",LOG_CONS|LOG_PID,LOG_DAEMON);
#else
    openlog("metserver",LOG_CONS|LOG_PID|LOG_PERROR,LOG_DAEMON);
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
    char message_file[ ]="/tmp/metserver.XXXXXX";
    FILE *fildes;
    int iret;
    int fd;
    
    old=t;

    if (snprintf(cmd_buff, sizeof(cmd_buff), LGERR_FMT, buff) < 0) {
        syslog(LOG_DAEMON | LOG_ERR, "lgerr command truncated");
        goto done0;
    }
    system(cmd_buff);

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
	     "/bin/cat %s | /usr/bin/mail -s 'metserver ERROR' root",
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
