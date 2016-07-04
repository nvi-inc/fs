
#include <stdio.h>
#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>
#include <linux/serial.h>
#include <sys/errno.h>
/*  */

#define MAXBUF 1024
#define MAXLOG  80
/* Some commands are here for later use. */

extern char metdevice[20];

char *metget(
char terminal[], /* connection for getting temp,humidity,pressure */ 
char terminal2[]) /* connection for get wind parameters. */
{

  /* Passed arguments */
char metcmd[] = "*0100P9\n";
char fancmd[] = "*0100FS\n";
char fanspd[] = "*0100FR\n";
char windcmd[] = "W5";
static  int ttynum;         /* write to com port: 1-2 or Vikom: 16-23 */
static  int ttynum2;        /* read from com port: 1-2 or Vikom: 16-23 */
  int met_baud_rate;  /* baudrate in Kbaud */
  int wind_baud_rate; /* baudrate in Kbaud */
  int parity;         /* parity bit */
  int bits;           /* bits */
  int stop;           /* stop bits */
  
  int termch, err, count, to, towind;
  int open_err;         /* terminal error on open.  */
  int open2_err;        /* terminal2 error on open. */
  int wdir;
  float temp,pres,humi,wsp;
  char buff[MAXBUF];
  char buff2[MAXBUF];
static  char log_str[MAXLOG];
  int len, ierr;
  int kmet, kwind, iret;

  /* ttynum = MET, ttynum2 = Wind Sensor */
  met_baud_rate = 9600;
  wind_baud_rate = 9600;
  parity = 0;
  bits = 8;
  stop = 1;
  termch=0x0a; /* LF */
  to=500;      /* 500 centisecs. */
  towind=150;

  /* Initialize parameters in case there are errors */
  temp=-51.0;
  pres=-1.0;
  humi=-1.0;
  wsp=-1.0;
  wdir=-1;

  /* OPEN devices terminal and terminal2. */
  kmet=0;
  if (ttynum==0 && !strstr(terminal,"/dev/null")) {
    len = strlen(terminal);
    open_err = portopen_(&ttynum, terminal, &len,
			&met_baud_rate, &parity, &bits, &stop);
    if(open_err!=0) {
      err_report("error opening met device", terminal,0,open_err);
      if(open_err <= -2)
	portclose_(&ttynum);
      ttynum=0;
      sleep(1); /* don't retry too often */
    }
  }
  if (ttynum2==0 && !strstr(terminal2,"/dev/null")) {
    len = strlen(terminal2);
    open2_err = portopen_(&ttynum2, terminal2, &len,
			 &wind_baud_rate, &parity, &bits, &stop);

    if(open2_err!=0) {
      err_report("error opening wind device", terminal2,0,open2_err);
      if(open2_err <= -2)
	portclose_(&ttynum2);
      ttynum2=0;
      sleep(1); /* don't retry too often */
    }
  }

  if (ttynum!= 0 && !strstr(terminal,"/dev/null")) {
    ierr = portflush_(&ttynum);
    len = strlen(metcmd);
    err = portwrite_(&ttynum, metcmd, &len);
    len = sizeof(buff);
    err = portread_(&ttynum, buff, &count, &len, &termch, &to);
    if(err!=0) {
      err_report("error reading met device nmea string", terminal,0,err);
      temp=51.0*(pres=humi=err);
      portclose_(&ttynum);
      ttynum=0;
    }  else {
      buff[count]=0;
      nmea(buff,&pres,&temp,&humi);
      if(pres < 0 || temp <-50 || humi < 0)
	err_report("error decoding met nmea string", buff,0,0);
      else
	kmet=1;
      pres*=1000;
    }
    if(0==strcmp(metdevice,"MET4A")){  /* check on fan */
      ierr = portflush_(&ttynum);
      len = strlen(fancmd);
      err = portwrite_(&ttynum, fancmd, &len);
      len = sizeof(buff);
      err = portread_(&ttynum, buff, &count, &len, &termch, &to);
      if(err!=0) {
	err_report("error reading met fan status", terminal,0,err);
	portclose_(&ttynum);
	ttynum=0;
      }  else {
	int status;
	buff[count]=0;
	if(1!=sscanf(buff,"*0001FS=%d",&status))
	  err_report("error decoding met fan status", buff,0,0);
	else if(1!=status) {
	  ierr = portflush_(&ttynum);
	  len = strlen(fanspd);
	  err = portwrite_(&ttynum, fanspd, &len);
	  len = sizeof(buff2);
	  err = portread_(&ttynum, buff2, &count, &len, &termch, &to);
	  if(err!=0) {
	    err_report("fan status bad, and now error reading actual speed",
		       terminal,0,err);
	    portclose_(&ttynum);
	    ttynum=0;
	  }  else {
	    int speed;
	    buff2[count]=0;
	    if(1!=sscanf(buff2,"*0001FR=%d",&speed))
	      err_report("fan staus bad, and now error decoding actual speed"
			 , buff2,0,0);
	    else {
	      snprintf(buff2,sizeof(buff2),"fan status bad, speed %d RPM",
		       speed);
	      err_report(buff2, NULL,0,0);
	    }
	  }
	}
      }
    }
  }

  kwind=0;
  if (ttynum2!=0 && !strstr(terminal2,"/dev/null")) {
    ierr = portflush_(&ttynum2);
    // len = sizeof(windcmd)-1;
    //    err = portwrite_(&ttynum2, windcmd, &len);
    len = sizeof(buff);
    err = portread_(&ttynum2, buff, &count, &len, &termch, &to);

    if(err!=0) { 
      err_report("error on initial reading of wind device", terminal2,0,err);
      wdir=err; 
      wsp=(float)err;
      portclose_(&ttynum2);
      ttynum2=0;
    } else {
      buff[count]=0;
      iret=nmea_wind(buff,&wdir,&wsp);
      if(iret==0)
	kwind=1;
      else {  /*try again in case we got only a partial response */
	err = portread_(&ttynum2, buff, &count, &len, &termch, &to);
	if(err!=0) { 
	  err_report("error on second reading of wind device", terminal2,0,err);
	  wdir=err; 
	  wsp=(float)err;
	  portclose_(&ttynum2);
	  ttynum2=0;
	} else {
	  buff[count]=0;
	  iret=nmea_wind(buff,&wdir,&wsp);
	  if(iret==-1) /* explicit messages for the most useful cases */
	    err_report("windsensor sent wrong data message", terminal2,0,iret);
	  else if(iret==-13) 
	    err_report("windsensor has wrong units", terminal2,0,iret);
	  else if(iret==-15) 
	    err_report("windsensor data not valid", terminal2,0,iret);
	  else if(iret!=0)
	    err_report("error decoding wind data", terminal2,iret,0);
	  else
	    kwind=1;
	}
      }
    }
  }

  if(kmet && kwind)
    snprintf(log_str,sizeof(log_str),
	     "%.1f,%.1f,%.1f,%.1f,%d,",temp,pres,humi,wsp,wdir);
  else if(kmet)
    snprintf(log_str,sizeof(log_str),
	     "%.1f,%.1f,%.1f,,,",temp,pres,humi);
  else if(kwind)
    snprintf(log_str,sizeof(log_str),
	     ",,,%.1f,%d,",wsp,wdir);
  else
    strcpy(log_str,",,,,,");

  return log_str;
}

nmea(bufin,pres,tmp,humi)
char *bufin;
float *pres, *tmp, *humi;
{
  char *p,comma[]=",";
  char buf[256];

  strncpy(buf,bufin,sizeof(buf));
  buf[sizeof(buf)-1]=0;

  *pres=-1;
  *tmp==51;
  *humi=-1;

  p=strtok(buf,comma);
  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  if(p==NULL)
    return;
  sscanf(p,"%f",pres);

  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  if(p==NULL)
    return;
  sscanf(p,"%f",tmp);

  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  p=strtok(NULL,comma);
  if(p==NULL)
    return;
  sscanf(p,"%f",humi);

  return;
}

