#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>

#define MAX_BUF 90
logwx(
      char fsloc_str[],
      char wx_str[],
      char sn[],
      char logfile[])
{
  /*            /usr2/log/wx99001gg.log   */
  char file[]= "                                        ";
  char new[sizeof(file)];
  char new2[sizeof(file)];
  int error,total,ncopy;
  struct tm *ptr;
  time_t t;
  char buffer[MAX_BUF];
  char ch;
  static FILE *fildes= (FILE *) NULL;
  long offset;

  t=time(NULL);
  if(((time_t) -1) == t) {
    err_report("Error getting time in logwx",NULL,1,0);
    return;
  }

  /* Setup new logfile. */
  ptr=gmtime(&t);
  strcpy(new,logfile);
  strftime(new+strlen(new),sizeof(new),"/wx%y%j",ptr);
  if(-1==snprintf(new+strlen(new),sizeof(new)-strlen(new),
		  "%c%c.log",sn[0],sn[1])) {
    err_report("Error formatting entry for log in logwx",new,1,0);
    return;
  }

  if(strcmp(new,file)!=0) {
    if(fildes != (FILE *) NULL) {
      if(EOF == fclose(fildes)) {
	err_report("Closing old log in logwx",file,1,0);
	return;
      }
    }

    fildes=(fopen(new,"a+"));
    if(fildes == (FILE *) NULL) {
      err_report("Opening new log in logwx",new,1,0);
      return;
    }
    if(0!=chmod(new,0666)) {
      err_report("Setting permissions in logwx",new,1,0);
      return;
    }

    strncpy(file,new,sizeof(file));
    offset=ftell(fildes);
    if(offset==(long)-1) {
      err_report("Opening checking log position in logwx",new,1,0);
      return;
    }
    if(offset!=(long)0){
      if(EOF==fseek(fildes, (long) -1,SEEK_END)) {
	err_report("Error positioning log in logwx",new,1,0);
	return;
      }
      if(EOF==fread(&ch,1,1,fildes)) {
	err_report("Error reading log in logwx",new,1,0);
	return;
      }
      if(ch!='\n') {
	ch='\n';
	if(1!=fwrite(&ch,1,1,fildes)) {
	  err_report("Error adding newline to log in logwx",new,1,0);
	  return;
	}
      }
    }
  }

  if(ftell(fildes)==0) {
    if(strlen(fsloc_str)+1!=fprintf(fildes,"%s\n",fsloc_str)) {
      err_report("Error writing entry to log in logwx",new,1,0);
      return;
    }
  }

  if(-1==snprintf(buffer,sizeof(buffer)-strlen(buffer),"%s",wx_str)){
    err_report("Error formatting entry for log in logwx",new,1,0);
    return;
  }
      
  if(strlen(buffer)+1!=fprintf(fildes,"%s\n",buffer)) {
    err_report("Error writing entry to log in logwx",new,1,0);
    return;
  }

  if(EOF == fflush(fildes)) {
    err_report("Error flushing log stream in logwx",new,1,0);
    return;
  }

}    
