
#include <stdio.h>
#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>
#include <linux/serial.h>
#include <sys/errno.h>
/*  */

#define MAXLEN 1024
#define MAXBUF 80
/* Some commands are here for later use. */
char *metcmd[7] = {"*0100Q3\r\n",   /* MET3 temperature measurement. */
		   "*0100P3\r\n",   /* MET3 pressure measurement. */
		   "*0100RH\r\n",   /* MET3 humidity measurement. */
		   "*0100UN\r\n",   /* MET3 pressure determination (doc's) */
		   "*0100VR\r\n",   /* MET3 stop any commands in progress,
				       reset. */
		   "*0100EW*0100UN=2\r\n",  /* MET3 change to mbar. */
		   "*0100P9\r\n"};  /* MET3 Transducer Serial # with
                                       MET information. */
char *windcmd[6] = {"C0.0\r\n",     /* WindSensor coast. */
		    "D\r\n",        /* WindSensor Diagnostics. */
		    "H\r\n",        /* WinddSensor heater control 
				     * 0=off 1=on. */
		    "I\r\n",        /* WindSensor Identity. */
		    "W5\r\n",        /* WindSensor Identity. */
		    "U3\r\n"};      /* WindSensor units:0=miles,1=knots,
				     *  2=kilometers,3=meters per hour. */
/*
 * This will user designated the Field System ports.
 */
char *metget(
char terminal[], /* connection for getting temp,humidity,pressure */ 
char terminal2[]) /* connection for get wind parameters. */
{
  /* Passed arguments */
  int ttynum;         /* write to com port: 1-2 or Vikom: 16-23 */
  int ttynum2;        /* read from com port: 1-2 or Vikom: 16-23 */
  int met_baud_rate;  /* baudrate in Kbaud */
  int wind_baud_rate; /* baudrate in Kbaud */
  int parity;         /* parity bit */
  int bits;           /* bits */
  int stop;           /* stop bits */
  int buffsize;       /* read and write buffer size. */
  
  /* Local variables. */
  int metcnt,i; /* counters */
  int termch, err, count, to;
  int open_err;         /* terminal error on open.  */
  int open2_err;        /* terminal2 error on open. */
  int wdir;
  float temp,pres,humi,wsp;
  char datetime[MAXLEN];
  char buff[MAXLEN];
  char log_str[MAXLEN];
  char *p;
  int len, ierr;
  time_t curtime;
  FILE *fp;

  /* Initialize parameters */
  temp=-51.0;
  pres=-1.0;
  humi=-1.0;
  wsp=-1.0;
  wdir=-1;

  /* ttynum = MET, ttynum2 = Wind Sensor */
  met_baud_rate = 9600;
  wind_baud_rate = 2400;
  parity = 0;
  bits = 8;
  stop = 1;
  buffsize = 256;

  /* OPEN devices terminal and terminal2. */
  if (!strstr(terminal,"/dev/null")) {
    ttynum=atoi(&terminal[9]);
    /* Flush port (don't forget to put the seat down). */
    ierr = portflush(&ttynum);
    len = strlen(terminal);
    open_err = portopen(&ttynum, terminal, &len,
			&met_baud_rate, &parity, &bits, &stop);
  }
  if (!strstr(terminal2,"/dev/null")) {
    ttynum2=atoi(&terminal2[9]);
    ierr = portflush(&ttynum2);
    len = strlen(terminal2);
    open2_err = portopen(&ttynum2, terminal2, &len,
			 &wind_baud_rate, &parity, &bits, &stop);
  }

  termch=0x0a; /* LF */
  to=500;      /* 500 centisecs. */

  /* 
   * This is left here but commented out to acquire the Transducer Serial 
   * Numbers. If anyone should need them.
   * This takes just as long as getting the temp,pres,humi 
   * individualy. Before you can get this string you have to set Pressure 
   * to Bar's.
   */ 
  /*if (!strstr(terminal,"/dev/null")) {
    len = 80;
    * Set to Bars. *
    err = portwrite(&ttynum, metcmd[5], &len);
    if(err==-2) printf("write error\n");
    len = 80;
    err = portread(&ttynum, buff, &count, &len, &termch, &to);
    * Get on string with all parameters. *
    buff[0]='\0';
    err = portwrite(&ttynum, metcmd[6], &len);
    if(err==-2) printf("write error\n");
    len = 80;
    err = portread(&ttynum, buff, &count, &len, &termch, &to);
    buff[strlen(buff)]='\0';
    printf("[%d]%s\n",err,buff);
  */
  i=0;
  if (!strstr(terminal,"/dev/null")) {
    buff[0]='\0';
    for (metcnt=0;metcnt<=2;metcnt++) {
      len = strlen(metcmd[metcnt]);
      /* read from a port */
      err = portwrite(&ttynum, metcmd[metcnt], &len);
      /*if(err==-2) printf("write error\n");*/
      if(err==-2) {
	strcpy(log_str,",,,");
	break;
      }
      len = 20;
      err = portread(&ttynum, buff, &count, &len, &termch, &to);
      if(err!=-2) {
	/* DEBUG 
	   if(err==-1) printf("wrong number of chars. read\n");
	   if(err==-2) printf("timed out\n");
	   if(err==-3) printf("read error\n");
	*/
	switch (metcnt) {
	case 0:
	  if(err!=0) temp=(float)err*51.0;
	  else  sscanf(&buff[5],"%f", &temp);
	  break;
	case 1:
	  if(err!=0) pres=(float)err;
	  else sscanf(&buff[5],"%f", &pres);
	  break;
	case 2:
	  if(err!=0) humi=(float)err;
	  else sscanf(&buff[5],"%f", &humi);
	  break;
	default:
	  break;
	}
      } else {
	temp=(float)err*50.0;
	pres=(float)err;
	humi=(float)err;
	break;
      }
    }
  }

  if (!strstr(terminal2,"/dev/null")) {
    err = portwrite(&ttynum2, windcmd[4], &len);
    len = 80;
    err = portread(&ttynum2, buff, &count, &len, &termch, &to);
    if(err!=-2) {
      /* DEBUG 
	 if(err==-1) printf("wind:wrong number of chars. read\n");
	 if(err==-2) printf("wind:timed out\n");
	 if(err==-3) printf("wind:read error\n");
      */
      if(err!=0) { 
	wdir=err; 
	wsp=(float)err;
      } else {
	len = strlen(buff);
	buff[len]='\0';
	sscanf(&buff[4],"%3d", &wdir);
	sscanf(&buff[7],"%6f", &wsp);
      }
    } else {
      wdir=err;
      wsp=(float)err;
    }
  }

  log_str[strlen(log_str)]='\0';
  sprintf(log_str,"%.1f,%.1f,%.1f,%.1f,%d",temp,pres,humi,wsp,wdir);
  p=log_str;
  portclose(&ttynum);
  portclose(&ttynum2);
  
  return(p);
}




