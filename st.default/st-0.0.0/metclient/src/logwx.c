#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>

logwx(
      char fsloc_str[],
      char wx_str[],
      char sn[],
      char logfile[],
      struct tm *ptr)
{
  static char file[] =
    "                                                                ";
 /*  1234567890123456789012345678901234567890123456789012345678901234
 /*  /usr2/log/wx/wx99001gg.log   */
  char new[sizeof(file)];
  int error,total,ncopy;
  time_t t;
  char ch;
  static FILE *fildes= (FILE *) NULL;
  long offset;
  int kopen;
  int len;
  size_t size;

  /* Setup new logfile. */
  if(strlen(logfile)+1 > sizeof(new)) {
    err_report("Error formatting directory in log file name in logwx",
	       logfile,0,strlen(logfile)+1);
    return;
  }
  strcpy(new,logfile);
  size=sizeof(new)-strlen(new);
  len=strftime(new+strlen(new),size,"/wx%y%j",ptr);
  if(0==len||size == len) {
    err_report("Error formatting date in log file name in logwx",NULL,0,len);
    return;
  }
  size=sizeof(new)-strlen(new);
  len=snprintf(new+strlen(new),size,"%c%c.log",sn[0],sn[1]);
  if(-1 == len || len >= size) {
    err_report("Error formatting station code in log file name in logwx",
	       new,0,len);
    return;
  }

  kopen=0;
  if(strcmp(new,file)!=0) {
    kopen=1;
    if(fildes != (FILE *) NULL) {
      if(EOF == fclose(fildes)) {
	err_report("Closing old log in logwx",file,errno,0);
	return;
      }
    }

    fildes=(fopen(new,"a+"));
    if(fildes == (FILE *) NULL) {
      err_report("Opening new log in logwx",new,errno,0);
      return;
    }
    if(0!=chmod(new,0666)) {
      err_report("Setting permissions in logwx",new,errno,0);
      return;
    }

    strncpy(file,new,sizeof(file));

    /* position to end for our reading here */
    if(EOF==fseek(fildes, (long) 0,SEEK_END)) {
      err_report("Error positioning to EOF in logwx",new,errno,0);
      return;
    }

    offset=ftell(fildes);
    if(offset==(long)-1) {
      err_report("Opening checking log position in logwx",new,errno,0);
      return;
    }

    if(offset!=(long)0){
      if(EOF==fseek(fildes, (long) -1,SEEK_END)) {
	err_report("Error positioning log in logwx",new,errno,0);
	return;
      }
      if(EOF==fread(&ch,1,1,fildes)) {
	err_report("Error reading log in logwx",new,errno,0);
	return;
      }
      /* must seek between reads and writes */
      if(EOF==fseek(fildes, (long) 0,SEEK_END)) { 
	err_report("Error positioning to EOF2 in logwx",new,errno,0);
	return;
      }
      if(ch!='\n') {
	ch='\n';
	if(1!=fwrite(&ch,1,1,fildes)) {
	  err_report("Error adding newline to log in logwx",new,errno,0);
	  return;
	}
      }
    }
  }

  if(kopen) {
    if(strlen(fsloc_str)+1!=fprintf(fildes,"%s\n",fsloc_str)) {
      err_report("Error writing entry to log in logwx",new,errno,0);
      return;
    }
  }

  if(strlen(wx_str)+1!=fprintf(fildes,"%s\n",wx_str)) {
    err_report("Error writing entry to log in logwx",new,errno,0);
    return;
  }

  if(EOF == fflush(fildes)) {
    err_report("Error flushing log stream in logwx",new,errno,0);
    return;
  }

}    
