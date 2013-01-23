/* get_s2time.c - get s2 recorder time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */

#include "../include/params.h"
#include "../rclco/rcl/rcl_def.h"
#include "../include/fs_types.h"

void skd_run();
void skd_par();

int get_s2time(dev,centisec,it,nanosec,ip,to)
char dev[];
long centisec[6];
int it[6];
long *nanosec;
long ip[5];                          /* ipc array */
{
  int ierr;
  struct rclcn_req_buf reqbuf;
  struct rclcn_res_buf resbuf;
  int year, day, hour, min, sec;
  ibool validated;

  ini_rclcn_req(&reqbuf);
  add_rclcn_delaym_read(&reqbuf,dev);
  add_rclcn_time_read(&reqbuf,dev);
  end_rclcn_req(ip,&reqbuf);

  if(to!=0) {
    char *name;
    name="rclcn";
    while(skd_run_to(name,'w',ip,100)==1) {
      if (nsem_test("fs   ") != 1) {
	return 1;
      }
      name=NULL;
    }
  } else
    skd_run("rclcn",'w',ip);

  skd_par(ip);
  if( ip[2] < 0 ) {
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    return 0;
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_delaym_read(&resbuf,nanosec);

  if(ierr!=0) {
    clr_rclcn_res(&resbuf);
    ip[2]=ierr;
    return 0;
  }

 ierr=get_rclcn_time_read(&resbuf,&year,&day,&hour,&min,&sec,
			   &validated,centisec);
  clr_rclcn_res(&resbuf);
  if(ierr!=0) {
    ip[2]=ierr;
    return 0;
  }

  it[5]=year;
  it[4]=day;
  it[3]=hour;
  it[2]=min;
  it[1]=sec;
  it[0]=0;
          
  return 0;
}
