/* rclcn.c - rcl control program */

/* include files */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "../rclco/rcl/rcl_def.h"
#include "../rclco/rcl/rcl_cmd.h"

#define MAX_NAME 65
#define RES_MAXLEN RCL_STATUS_DETAIL_MAXLEN+sizeof(int)

/* ********************************************************************* */
int process_s2das(ip)    /* process the input class buffers */
long ip[5];
{
 char cmd_buf[RCLCN_REQ_BUF_MAX];
 char rsp_buf[RES_MAXLEN];
 int  cmd_code, cmd_len;
 int  rsp_code, rsp_len, len;

 int  i, nchars;
 int ierr   = 0;

 long outclass = 0;
 long outrecs  = 0;

 long iclass = ip[1];
 long nrecs  = ip[2];
 long timeout = ip[4] == 0 ? RCL_TIMEOUT : ip[4];
 int rtn1, rtn2, addr;

 for( i = 0 ; i < nrecs ; i++ ) 
    {
     nchars = cls_rcv(iclass,cmd_buf,RCLCN_REQ_BUF_MAX,&rtn1,&rtn2,0,0);

     if( nchars <= 0) { ierr = -320; break; }

     /* check instrument address */
     if( ( addr = get_da_addr( cmd_buf ) ) >= 0 )
       {
        cmd_code = (int)cmd_buf[2]; /* decode command code */
        cmd_len  = nchars - 3;

        rsp_code = rsp_len = 0;
        if(   ( ierr = rcl_packet_write(addr,cmd_code,cmd_buf+3,cmd_len) )
                   == RCL_ERR_NONE
	   && ( ierr = rcl_packet_read(addr,&rsp_code,rsp_buf+5,RES_MAXLEN
		       ,&rsp_len,timeout) ) == RCL_ERR_NONE
           && rsp_code == RCL_RESP_ERR
           && rsp_len == 1
	  ){ ierr = (int)rsp_buf[5]; }
       }
     else
       { ierr = addr == -2 ? -329 : -321; break; }

        memcpy(rsp_buf,&ierr,sizeof(int));
        rsp_buf[4] = rsp_code;
        for( rsp_len += 5 ; rsp_len > 0 ; rsp_len -= len )
           {
            len = rsp_len < RCLCN_RES_MAX_BUF ? rsp_len : RCLCN_RES_MAX_BUF;
            cls_snd( &outclass , rsp_buf , len , 0 , 0 );
            outrecs++;
           }
    }

 if( ierr > 0 ) /* RCL communication error */
    ierr = -130 -ierr;

 ip[0]=outclass;
 ip[1]=outrecs;
 ip[2]=ierr;

 return ierr;
}
/* ********************************************************************* */
















