/* setvtime.c - set vlba formmatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <errno.h>       /* error code definition header file */
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */

#include "../include/fs_types.h"

#include "../rclco/rcl/rcl_def.h"

#include "fmset.h"

extern long ip[5];           /* parameters for fs communications */
long nanosec;

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

void sets2time(formtime)
time_t formtime;
{
  struct tm *fmtime;  /* pointer to tm structure */
  int ierr;
  struct rclcn_req_buf reqbuf;
  struct rclcn_res_buf resbuf;
  int year, day, hour, min, sec;
  ibool relative;
  long int dnanosec;

  time_t unixtime; /* computer time */
  int    unixhs;
  time_t fstime; /* field system time */
  int    fshs;
  time_t formtime2; /* formatter time received from mcbcn */
  int    formhs;
  long before,after;

  if(nanosec==0)
    goto set;

  rte_rawt(&before);
  ini_rclcn_req(&reqbuf);

  relative=FALSE;
  dnanosec=0;
  add_rclcn_delay_set(&reqbuf,"rc",relative,dnanosec);

  end_rclcn_req(ip,&reqbuf);

  nsem_take("fsctl",0);
  skd_run("rclcn",'w',ip);
  nsem_put("fsctl");

  skd_par(ip);
  if( ip[2] < 0 )	{
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    if(ip[2]==-39)
      goto set;
    endwin();
    fprintf(stderr,"Error reply from rclcn - error %d\n", ip[2] );
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_delay_set(&resbuf);
  if(ierr!=0) {
    endwin();
    fprintf(stderr,"Error getting rclcn response - error %d\n", ierr );
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

  clr_rclcn_res(&resbuf);

  gets2time(&unixtime,&unixhs,&fstime,&fshs,&formtime2,&formhs);

  rte_rawt(&after);

  formtime+=(after-before+50)/100;

set:
  ini_rclcn_req(&reqbuf);
  
  /* convert calendar time to conventional time */

  fmtime = gmtime(&formtime);

  fmtime->tm_year += 1900;  /* gmtime returns years since 1900 */
  fmtime->tm_yday += 1;  /* gmtime returns days since 1 january */

  year=fmtime->tm_year;
  day =fmtime->tm_yday;
  hour=fmtime->tm_hour;
  min =fmtime->tm_min;
  sec =fmtime->tm_sec;
  add_rclcn_time_set(&reqbuf,"rc",year,day,hour,min,sec);

  end_rclcn_req(ip,&reqbuf);

  nsem_take("fsctl",0);
  skd_run("rclcn",'w',ip);
  nsem_put("fsctl");

  skd_par(ip);
  if( ip[2] < 0 ) {
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    if(ip[2]==-133)
      return;
    endwin();
    fprintf(stderr,"Error reply from rclcn - error %d\n", ip[2] );
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_time_set(&resbuf);
  if(ierr!=0) {
    endwin();
    fprintf(stderr,"Error getting rclcn response - error %d\n", ierr );
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  clr_rclcn_res(&resbuf);


}
