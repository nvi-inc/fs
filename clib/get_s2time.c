/* get_s2time.c - get s2 recorder time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */

#undef TRUE
#undef FALSE

#include "../rclco/rcl/rcl_def.h"
#include "../include/fs_types.h"

void skd_run();
void skd_par();

void get_s2time(centisec,it,ip)
long centisec[2];
int it[6];
long ip[5];                          /* ipc array */
{
  int ierr;
  struct rclcn_req_buf reqbuf;
  struct rclcn_res_buf resbuf;
  int year, day, hour, min, sec;
  ibool validated;

  ini_rclcn_req(&reqbuf);
  add_rclcn_time_read(&reqbuf,"rc");
  end_rclcn_req(ip,&reqbuf);

  skd_run("rclcn",'w',ip);

  skd_par(ip);
  if( ip[2] < 0 ) {
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    return;
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_time_read(&resbuf,&year,&day,&hour,&min,&sec,
			   &validated,centisec);
  clr_rclcn_res(&resbuf);
  if(ierr!=0) {
    ip[2]=ierr;
    return;
  }

  it[5]=year;
  it[4]=day;
  it[3]=hour;
  it[2]=min;
  it[1]=sec;
  it[0]=0;
          
}
