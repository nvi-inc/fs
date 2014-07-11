
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

char *metget(
char terminal[], /* connection for getting temp,humidity,pressure */ 
char terminal2[]) /* connection for get wind parameters. */
{

  /* Passed arguments */
char metcmd[] = "*0100P9\n";
char windcmd[] = "W5";
static  int ttynum;         /* write to com port: 1-2 or Vikom: 16-23 */
static  int ttynum2;        /* read from com port: 1-2 or Vikom: 16-23 */
  int met_baud_rate;  /* baudrate in Kbaud */
  int wind_baud_rate; /* baudrate in Kbaud */
  int parity;         /* parity bit */
  int bits;           /* bits */
  int stop;           /* stop bits */
  
  int termch, err, count, to;
  int open_err;         /* terminal error on open.  */
  int open2_err;        /* terminal2 error on open. */
  int wdir;
  float temp,pres,humi,wsp;
  char buff[MAXBUF];
static  char log_str[MAXLOG];
  int len, ierr;

  /* ttynum = MET, ttynum2 = Wind Sensor */
  met_baud_rate = 9600;
  wind_baud_rate = 2400;
  parity = 0;
  bits = 8;
  stop = 1;
  termch=0x0a; /* LF */
  to=500;      /* 500 centisecs. */

  /* Initialize parameters in case there are errors */
  temp=-51.0;
  pres=-1.0;
  humi=-1.0;
  wsp=-1.0;
  wdir=-1;

  /* OPEN devices terminal and terminal2. */
  if (ttynum==0 && !strstr(terminal,"/dev/null")) {
    len = strlen(terminal);
    open_err = portopen_(&ttynum, terminal, &len,
			&met_baud_rate, &parity, &bits, &stop);
    if(open_err!=0) {
      err_report("error opening met device", terminal,0,open_err);
      if(open_err < -2 && open_err != -16 && open_err != -19)
	portclose_(&ttynum);
      ttynum=0;
    }
  }
  if (ttynum2==0 && !strstr(terminal2,"/dev/null")) {
    len = strlen(terminal2);
    open2_err = portopen_(&ttynum2, terminal2, &len,
			 &wind_baud_rate, &parity, &bits, &stop);

    if(open2_err!=0) {
      err_report("error opening wind device", terminal2,0,open2_err);
      if(open2_err < -2 && open2_err != -16 && open2_err != -19)
	portclose_(&ttynum2);
      ttynum2=0;
    }
  }

  if (ttynum!= 0 && !strstr(terminal,"/dev/null")) {
    ierr = portflush_(&ttynum);
    len = strlen(metcmd);
    err = portwrite_(&ttynum, metcmd, &len);
    len = sizeof(buff);
    err = portread_(&ttynum, buff, &count, &len, &termch, &to);
    if(err!=0) {
      err_report("error reading met device", terminal,0,err);
      temp=51.0*(pres=humi=err);
      portclose_(&ttynum);
      ttynum=0;
    }  else {
      buff[count]=0;
      nema(buff,&pres,&temp,&humi);
      if(pres < 0 || temp <-50 || humi < 0)
	err_report("error decoding met nema string", buff,0,0);
      pres*=1000;
    }
  }

  if (ttynum2!=0 && !strstr(terminal2,"/dev/null")) {
    ierr = portflush_(&ttynum2);
    len = sizeof(windcmd)-1;
    err = portwrite_(&ttynum2, windcmd, &len);
    len = sizeof(buff);
    err = portread_(&ttynum2, buff, &count, &len, &termch, &to);
    
    if(err!=0) { 
      err_report("error reading wind device", terminal2,0,err);
      wdir=err; 
      wsp=(float)err;
      portclose_(&ttynum2);
      ttynum2=0;
    } else {
      buff[count]=0;
      sscanf(&buff[4],"%3d", &wdir);
      sscanf(&buff[7],"%6f", &wsp);
    }
  }


  snprintf(log_str,sizeof(log_str),
	   "%.1f,%.1f,%.1f,%.1f,%d\n",temp,pres,humi,wsp,wdir);
  // printf(" log_str '%s'\n",log_str);
  return log_str;

}

nema(bufin,pres,tmp,humi)
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

