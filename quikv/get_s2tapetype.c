/* retreive s2 tapetype */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"

#include "../rclco/rcl/rcl_def.h"

void get_s2tapetype(char *tapetype, int ip[], char *lwho)
{
  struct rclcn_req_buf req_buf;        /* rclcn request buffer */
  struct rclcn_res_buf res_buf;
  char device[]= "r1";

  void ini_rclcn_req(), end_rclcn_req(); /*rclcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */
  int i, ierr=0;

  ini_rclcn_req(&req_buf);

  add_rclcn_tapetype_read(&req_buf,device);

  end_rclcn_req(ip,&req_buf);

  skd_run("rclcn",'w',ip);

  skd_par(ip);

  if (ip[2]<0) {
    ip[1]=0;
    cls_clr(ip[0]);
    return;
  }

  opn_rclcn_res(&res_buf,ip);

  ierr=get_rclcn_tapetype_read(&res_buf,tapetype);

error:
  if(ierr!=0) {
    ip[2]=ierr;
    memcpy(ip+3,lwho,2);
  }

  clr_rclcn_res(&res_buf);
  return;
  
}
