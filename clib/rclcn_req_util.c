/* rclcn communication request utilities */

#include <string.h>
#include <sys/types.h>
#include "../include/rclcn_req_ds.h"

#include "../rclco/rcl/rcl_def.h"
#include "../rclco/rcl/rcl_cmd.h"

void ini_rclcn_req(buffer)               /* initialize buffer */
struct rclcn_req_buf *buffer;
{
     buffer->count=0;
     buffer->class=0;
     buffer->nchars=0;

     return;
}

void add_rclcn_request(struct rclcn_req_buf *buffer, char *device, 
		       char *request, int len)
 /* add a request to buffer */
{
  if (2+len+buffer->nchars > RCLCN_REQ_BUF_MAX ) {
       cls_snd(&buffer->class,buffer->buf,buffer->nchars,0,0);
       buffer->count++;
       buffer->nchars=0;
  }
  
  memcpy(buffer->buf+buffer->nchars,device ,2);
  buffer->nchars+=2;
  
  memcpy(buffer->buf+buffer->nchars,request,len);
  buffer->nchars+=len;

  return;
}
void add_rclcn_request_string(struct rclcn_req_buf *buffer, char *device, 
		       char *request, int len, char *string)
 /* add a request to buffer */
{
  int lens=strlen(string)+1;

  if (2+len+lens+buffer->nchars > RCLCN_REQ_BUF_MAX ) {
       cls_snd(&buffer->class,buffer->buf,buffer->nchars,0,0);
       buffer->count++;
       buffer->nchars=0;
  }
  
  memcpy(buffer->buf+buffer->nchars,device ,2);
  buffer->nchars+=2;
  
  memcpy(buffer->buf+buffer->nchars,request,len);
  buffer->nchars+=len;

  memcpy(buffer->buf+buffer->nchars,string,lens);
  buffer->nchars+=lens;
  
  return;
}

void end_rclcn_req(long ip[5],struct rclcn_req_buf *buffer)
/* end buffer, send if partial */
{
     if(buffer->nchars>0) {
       cls_snd(&buffer->class,buffer->buf,buffer->nchars,0,0);
       buffer->count++;
       buffer->nchars=0;
     }
     ip[0]=1;
     ip[1]=buffer->class;
     ip[2]=buffer->count;

     buffer->class=0;
     buffer->count=0;

     return;
}
void add_rclcn_stop(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_STOP;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_play(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_PLAY;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_record(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_RECORD;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_rewind(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_REWIND;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_ff(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_FF;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_pause(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_PAUSE;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_unpause(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_UNPAUSE;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_eject(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_EJECT;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_state_read(struct rclcn_req_buf *buffer, char *device)
{
  char byte=RCL_CMD_STATE_READ;

  add_rclcn_request(buffer,device,&byte,1);
  
  return;
}
void add_rclcn_speed_set(struct rclcn_req_buf *buffer, char *device,
			 int speed)
{
  char bytes[1+sizeof(int)];
  bytes[0]=RCL_CMD_SPEED_SET;
  memcpy(bytes+1,&speed,sizeof(int));

  add_rclcn_request(buffer,device,bytes,1+sizeof(int));
  
  return;
}
void add_rclcn_speed_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_SPEED_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_speed_read_pb(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_SPEED_READ_PB;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_error_decode(struct rclcn_req_buf *buffer, char *device,
			 int err_code)
{
  char bytes[1+sizeof(int)];
  bytes[0]=RCL_CMD_ERROR_DECODE;
  memcpy(bytes+1,&err_code,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_time_set(struct rclcn_req_buf *buffer, char *device,
			 int year, int day, int hour, int min, int sec)
{
  char bytes[1+5*sizeof(int)];
  bytes[0]=RCL_CMD_TIME_SET;
  memcpy(bytes+1,              &year,sizeof(int));
  memcpy(bytes+1+  sizeof(int),&day ,sizeof(int));
  memcpy(bytes+1+2*sizeof(int),&hour,sizeof(int));
  memcpy(bytes+1+3*sizeof(int),&min ,sizeof(int));
  memcpy(bytes+1+4*sizeof(int),&sec ,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_time_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_TIME_READ;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_time_read_pb(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_TIME_READ_PB;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_mode_set(struct rclcn_req_buf *buffer, char *device,
			 char *mode)
{
  char bytes[1];

  bytes[0]=RCL_CMD_MODE_SET;

  add_rclcn_request_string(buffer,device,bytes,sizeof(bytes),mode);
  
  return;
}
void add_rclcn_mode_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_MODE_READ;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_tapeid_set(struct rclcn_req_buf *buffer, char *device,
			 char *tapeid)
{
  char bytes[1];

  bytes[0]=RCL_CMD_TAPEID_SET;

  add_rclcn_request_string(buffer,device,bytes,sizeof(bytes),tapeid);
  
  return;
}
void add_rclcn_tapeid_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];

  bytes[0]=RCL_CMD_TAPEID_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_tapeid_read_pb(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];

  bytes[0]=RCL_CMD_TAPEID_READ_PB;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_user_info_set(struct rclcn_req_buf *buffer, char *device,
			     int fieldnum, ibool label, char *user_info)
{
  char bytes[1+sizeof(int)+sizeof(ibool)];

  bytes[0]=RCL_CMD_USER_INFO_SET;
  memcpy(bytes+1,            &fieldnum,sizeof(int)  );
  memcpy(bytes+1+sizeof(int),&label,   sizeof(ibool));

  add_rclcn_request_string(buffer,device,bytes,sizeof(bytes),user_info);
  
  return;
}
void add_rclcn_user_info_read(struct rclcn_req_buf *buffer, char *device,
			      int fieldnum, ibool label)
{
  char bytes[1+sizeof(int)+sizeof(ibool)];

  bytes[0]=RCL_CMD_USER_INFO_READ;
  memcpy(bytes+1,            &fieldnum,sizeof(int)  );
  memcpy(bytes+1+sizeof(int),&label,   sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_user_info_read_pb(struct rclcn_req_buf *buffer, char *device,
				 int fieldnum, ibool label)
{
  char bytes[1+sizeof(int)+sizeof(ibool)];

  bytes[0]=RCL_CMD_USER_INFO_READ_PB;
  memcpy(bytes+1,            &fieldnum,sizeof(int)  );
  memcpy(bytes+1+sizeof(int),&label,   sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_user_dv_set(struct rclcn_req_buf *buffer, char *device,
			   ibool user_dv, ibool pb_enable)
{
  char bytes[1+2*sizeof(ibool)];

  bytes[0]=RCL_CMD_USER_DV_SET;
  memcpy(bytes+1,              &user_dv,  sizeof(ibool));
  memcpy(bytes+1+sizeof(ibool),&pb_enable,sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_user_dv_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];

  bytes[0]=RCL_CMD_USER_DV_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_user_dv_read_pb(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];

  bytes[0]=RCL_CMD_USER_DV_READ_PB;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_group_set(struct rclcn_req_buf *buffer, char *device,
			 int group)
{
  char bytes[1+sizeof(int)];
  bytes[0]=RCL_CMD_GROUP_SET;
  memcpy(bytes+1,&group,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_group_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_GROUP_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_tapeinfo_read_pb(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_TAPEINFO_READ_PB;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_delay_set(struct rclcn_req_buf *buffer, char *device,
			 ibool relative, long int nanosec)
{
  char bytes[1+sizeof(ibool)+sizeof(long int)];
  bytes[0]=RCL_CMD_DELAY_SET;
  memcpy(bytes+1,              &relative,sizeof(ibool)   );
  memcpy(bytes+1+sizeof(ibool),&nanosec ,sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_delay_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_DELAY_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_delaym_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_DELAYM_READ;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_align(struct rclcn_req_buf *buffer, char *device,
		     int year, int day, int hour, int min, int sec,
		     long int nanosec)
{
  char bytes[2+5*sizeof(int)+sizeof(long int)];
  bytes[0]=RCL_CMD_ALIGN;
  bytes[1]=0;
  memcpy(bytes+2,              &year    ,sizeof(int)     );
  memcpy(bytes+2+  sizeof(int),&day     ,sizeof(int)     );
  memcpy(bytes+2+2*sizeof(int),&hour    ,sizeof(int)     );
  memcpy(bytes+2+3*sizeof(int),&min     ,sizeof(int)     );
  memcpy(bytes+2+4*sizeof(int),&sec     ,sizeof(int)     );
  memcpy(bytes+2+5*sizeof(int),&nanosec ,sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_align_rel(struct rclcn_req_buf *buffer, char *device,
		     ibool negative, int hour, int min, int sec,
		     long int nanosec)
{
  char bytes[2+sizeof(ibool)+3*sizeof(int)+sizeof(long int)];
  bytes[0]=RCL_CMD_ALIGN;
  bytes[1]=1;
  memcpy(bytes+2,                            &negative,sizeof(ibool)   );
  memcpy(bytes+2+sizeof(ibool)              ,&hour    ,sizeof(int)     );
  memcpy(bytes+2+sizeof(ibool)+  sizeof(int),&min     ,sizeof(int)     );
  memcpy(bytes+2+sizeof(ibool)+2*sizeof(int),&sec     ,sizeof(int)     );
  memcpy(bytes+2+sizeof(ibool)+3*sizeof(int),&nanosec ,sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_align_realign(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[2];
  bytes[0]=RCL_CMD_ALIGN;
  bytes[1]=2;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_align_selfalign(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[2];
  bytes[0]=RCL_CMD_ALIGN;
  bytes[1]=3;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_position_set(struct rclcn_req_buf *buffer, char *device,
		     int code, long int position)
{
  char bytes[1+2*sizeof(int)+sizeof(long int)];
  int num=1;

  bytes[0]=RCL_CMD_POSITION_SET;
  memcpy(bytes+1              ,&code    ,sizeof(int)     );
  memcpy(bytes+1+  sizeof(int),&num     ,sizeof(int)     );
  memcpy(bytes+1+2*sizeof(int),&position,sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_position_set_ind(struct rclcn_req_buf *buffer, char *device,
		     int code, long int position[])
{
  char bytes[1+2*sizeof(int)+8*sizeof(long int)];
  int num=8;

  bytes[0]=RCL_CMD_POSITION_SET;
  memcpy(bytes+1              ,&code    ,  sizeof(int)     );
  memcpy(bytes+1+  sizeof(int),&num     ,  sizeof(int)     );
  memcpy(bytes+1+2*sizeof(int), position,8*sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_position_reestablish(struct rclcn_req_buf *buffer,
				    char *device)
{
  char bytes[1+sizeof(int)];
  int code=3;

  bytes[0]=RCL_CMD_POSITION_SET;
  memcpy(bytes+1              ,&code    ,sizeof(int)     );

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_position_read(struct rclcn_req_buf *buffer, char *device,
			     int code)
{
  char bytes[1+sizeof(int)];

  bytes[0]=RCL_CMD_POSITION_READ;
  memcpy(bytes+1              ,&code    ,sizeof(int)     );

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_errmes(struct rclcn_req_buf *buffer, char *device,
			 long int error)
{
  char bytes[1+sizeof(long int)];

  bytes[0]=RCL_CMD_ERRMES;
  memcpy(bytes+1,&error,sizeof(long int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_esterr_read(struct rclcn_req_buf *buffer, char *device,
			   ibool order_chantran)
{
  char bytes[1+sizeof(ibool)];

  bytes[0]=RCL_CMD_ESTERR_READ;
  memcpy(bytes+1,&order_chantran,sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_pdv_read(struct rclcn_req_buf *buffer, char *device,
			   ibool order_chantran)
{
  char bytes[1+sizeof(ibool)];

  bytes[0]=RCL_CMD_PDV_READ;
  memcpy(bytes+1,&order_chantran,sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_scpll_mode_set(struct rclcn_req_buf *buffer, char *device,
			      int scpll_mode)
{
  char bytes[1+sizeof(int)];

  bytes[0]=RCL_CMD_SCPLL_MODE_SET;
  memcpy(bytes+1,&scpll_mode,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_scpll_mode_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_SCPLL_MODE_READ;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_tapetype_set(struct rclcn_req_buf *buffer, char *device,
			    char *tapetype)
{
  char bytes[1];

  bytes[0]=RCL_CMD_TAPETYPE_SET;

  add_rclcn_request_string(buffer,device,bytes,sizeof(bytes),tapetype);
  
  return;
}
void add_rclcn_tapetype_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_TAPETYPE_READ;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_station_info_read(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_STATION_INFO_READ;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_consolecmd(struct rclcn_req_buf *buffer, char *device,
			  char *command)
{
  char bytes[1];

  bytes[0]=RCL_CMD_CONSOLECMD;

  add_rclcn_request_string(buffer,device,bytes,sizeof(bytes),command);
  
  return;
}
void add_rclcn_postime_read(struct rclcn_req_buf *buffer, char *device,
			    int tran)
{
  char bytes[1+sizeof(int)];

  bytes[0]=RCL_CMD_POSTIME_READ;
  memcpy(bytes+1,&tran,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_status(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_STATUS;

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_status_detail(struct rclcn_req_buf *buffer, char *device,
			     int stat_code, ibool reread, ibool shortt)
{
  char bytes[1+sizeof(int)+2*sizeof(ibool)];

  bytes[0]=RCL_CMD_STATUS_DETAIL;
  memcpy(bytes+1,                          &stat_code,sizeof(int  ));
  memcpy(bytes+1+sizeof(int),              &reread   ,sizeof(ibool));
  memcpy(bytes+1+sizeof(int)+sizeof(ibool),&shortt   ,sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_status_decode(struct rclcn_req_buf *buffer, char *device,
			     int stat_code, ibool shortt)
{
  char bytes[1+sizeof(int)+sizeof(ibool)];

  bytes[0]=RCL_CMD_STATUS_DECODE;
  memcpy(bytes+1,            &stat_code,sizeof(int  ));
  memcpy(bytes+1+sizeof(int),&shortt   ,sizeof(ibool));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_ping(struct rclcn_req_buf *buffer, char *device,
		    int timeout)
{
  char bytes[1+sizeof(int)];

  bytes[0]=RCL_CMD_PING;
  memcpy(bytes+1,&timeout,sizeof(int));

  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
void add_rclcn_version(struct rclcn_req_buf *buffer, char *device)
{
  char bytes[1];
  bytes[0]=RCL_CMD_VERSION;
  add_rclcn_request(buffer,device,bytes,sizeof(bytes));
  
  return;
}
