/* response buffer utilities */

#include <stdio.h>

#include "../include/rclcn_res_ds.h"

#include "../rclco/rcl/rcl_def.h"

void opn_rclcn_res(buffer,ip)      /* initialize (open) response structs */
struct rclcn_res_buf *buffer;        /* work struct */
long ip[5];                    /* ip information from mcbcn */
{
    buffer->class = ip[0];
    buffer->count = ip[1];
    buffer->ifc   = 0;
    buffer->nchars= 0;

    ip[0]=0;
    ip[1]=0;
    return;
}

int get_rclcn_res(struct rclcn_res_buf *buffer)
 /* fetch next response */
{
  int ierr, ierr2;
  ierr=get_rclcn_res_data(buffer,&ierr2,sizeof(int));
  if(ierr!=0)
    return ierr;

  return ierr2;
}

int get_rclcn_res_data(struct rclcn_res_buf *buffer,void *ptr,int len)
{
  if(len<0)
    return -402;

  while (len > 0) {
    int len2;

    len2 = buffer->nchars-buffer->ifc;
    len2 = len2 < len ? len2 : len;

    if(len2 <= 0 && buffer->count > 0) {
      int idum;

      buffer->nchars=
	cls_rcv(buffer->class,buffer->buf,RCLCN_RES_MAX_BUF,&idum,&idum,0,0);
      buffer->count--;
      buffer->ifc=0;
      len2 = buffer->nchars-buffer->ifc;
      len2 = len2 < len ? len2 : len;
    } else if (len2 <= 0 && buffer->count <= 0)
      return -401;
      
    memcpy(ptr,buffer->buf+buffer->ifc,len2);
    buffer->ifc+=len2;
    ptr+=len2;
    len-=len2;

  }
  return 0;
}

int get_rclcn_res_string(struct rclcn_res_buf *buffer,char *ptr)
{
  int ierr;

  ierr=get_rclcn_res_data(buffer,ptr,1);
  if(ierr!=0)
    return ierr;
  while(*ptr!=0) {
    ierr=get_rclcn_res_data(buffer,++ptr,1);
    if(ierr!=0)
      return ierr;
  }
  return 0;
}
    
void clr_rclcn_res(struct rclcn_res_buf *buffer)
/* close buffer and clear class number */
{
    void cls_clr();

    if(buffer->count >0) cls_clr(buffer->class);

    buffer->class=0;
    buffer->count=0;

    return;
}
int get_rclcn_stop(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_play(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_record(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_rewind(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_ff(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_pause(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_unpause(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_eject(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_state_read(struct rclcn_res_buf *buffer, int *rstate)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,rstate,sizeof(int));

  return ierr;
}
int get_rclcn_speed_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_speed_read(struct rclcn_res_buf *buffer, int *speed)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,speed,sizeof(int));

  return ierr;
}
int get_rclcn_speed_read_pb(struct rclcn_res_buf *buffer, int *speed)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,speed,sizeof(int));

  return ierr;
}
int get_rclcn_error_decode(struct rclcn_res_buf *buffer, char *err_msg)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,err_msg);

  return ierr;
}
int get_rclcn_time_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_time_read(struct rclcn_res_buf *buffer, int *year, int *day,
			int *hour, int *min, int *sec, ibool *validated,
			long *centisec)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,year,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,day ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,hour,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,min ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,sec ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,validated ,sizeof(ibool));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,centisec ,6*sizeof(long));

  return ierr;
}
int get_rclcn_time_read_pb(struct rclcn_res_buf *buffer, int *year, int *day,
			int *hour, int *min, int *sec, ibool *validated)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,year,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,day ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,hour,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,min ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,sec ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,validated ,sizeof(ibool));

  return ierr;
}
int get_rclcn_mode_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_mode_read(struct rclcn_res_buf *buffer, char *mode)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,mode);

  return ierr;
}
int get_rclcn_tapeid_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_tapeid_read(struct rclcn_res_buf *buffer, char *tapeid)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,tapeid);

  return ierr;
}
int get_rclcn_tapeid_read_pb(struct rclcn_res_buf *buffer, char *tapeid)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,tapeid);

  return ierr;
}
int get_rclcn_user_info_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_user_info_read(struct rclcn_res_buf *buffer, char *user_info)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,user_info);

  return ierr;
}
int get_rclcn_user_info_read_pb(struct rclcn_res_buf *buffer, char *user_info)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,user_info);

  return ierr;
}
int get_rclcn_user_dv_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_user_dv_read(struct rclcn_res_buf *buffer, ibool *user_dv,
			   ibool *pb_enable)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,user_dv,  sizeof(ibool));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,pb_enable,sizeof(ibool));

  return ierr;
}
int get_rclcn_user_dv_read_pb(struct rclcn_res_buf *buffer, ibool *user_dv)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,user_dv,  sizeof(ibool));

  return ierr;
}
int get_rclcn_group_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_group_read(struct rclcn_res_buf *buffer, int *group,
			 int *num_groups)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,group,     sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,num_groups,sizeof(int));

  return ierr;
}
int get_rclcn_tapeinfo_read_pb(struct rclcn_res_buf *buffer,
			 unsigned char *table)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,table,RCL_TAPEINFO_LEN);

  return ierr;
}
int get_rclcn_delay_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_delay_read(struct rclcn_res_buf *buffer,
			 long int *nanosec)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,nanosec, sizeof(long int));

  return ierr;
}
int get_rclcn_delaym_read(struct rclcn_res_buf *buffer,
			 long int *nanosec)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,nanosec, sizeof(long int));

  return ierr;
}
int get_rclcn_barrelroll_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_barrelroll_read(struct rclcn_res_buf *buffer, ibool *barrelroll)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,barrelroll, sizeof(ibool));

  return ierr;
}
int get_rclcn_align(struct rclcn_res_buf *buffer)
{
  int ierr=get_rclcn_res(buffer);

  return ierr;
}
int get_rclcn_position_set(struct rclcn_res_buf *buffer)
{
  int ierr=get_rclcn_res(buffer);

  return ierr;
}
int get_rclcn_position_read(struct rclcn_res_buf *buffer,int *code,
		      union pos_union *position)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,code,     sizeof(int));

  switch (*code) {
  case 0:
    ierr=get_rclcn_res_data(buffer,&position->overall.position,
			    sizeof(long int));
    if(ierr!=0)
      return ierr;

    ierr=get_rclcn_res_data(buffer,&position->overall.posvar  ,
			    sizeof(long int));
    break;
  case 1:
    ierr=get_rclcn_res_data(buffer,&position->individual.num_entries,
			    sizeof(int));
    if(ierr!=0)
      return ierr;

    ierr=get_rclcn_res_data(buffer, position->individual.position,
			    position->individual.
			    num_entries*sizeof(long int));
    break;
  default:
    ierr=-403;
  }

  return ierr;
}
int get_rclcn_errmes(struct rclcn_res_buf *buffer)
{
  int ierr=get_rclcn_res(buffer);

  return ierr;
}
int get_rclcn_esterr_read(struct rclcn_res_buf *buffer, int *num_entries,
			  char esterr_list[])
{
  int ierr=get_rclcn_res(buffer);
  int i,j;

  ierr=get_rclcn_res_data(buffer,num_entries, sizeof(int));
  if(ierr!=0)
    return ierr;

  j=0;
  for (i=0;i<*num_entries;i++) {
    ierr=get_rclcn_res_string(buffer,esterr_list+j);
    if(ierr!=0)
      return ierr;

    j+=strlen(esterr_list+j)+1;
  }
  
  return ierr;
}
int get_rclcn_pdv_read(struct rclcn_res_buf *buffer, int *num_entries,
		       char pdv_list[])
{
  int ierr=get_rclcn_res(buffer);
  int i,j;

  ierr=get_rclcn_res_data(buffer,num_entries, sizeof(int));
  if(ierr!=0)
    return ierr;


  j=0;
  for (i=0;i<*num_entries;i++) {
    ierr=get_rclcn_res_string(buffer,pdv_list+j);
    if(ierr!=0)
      return ierr;

    j+=strlen(pdv_list+j)+1;
  }
  
  return ierr;
}
int get_rclcn_scpll_mode_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_scpll_mode_read(struct rclcn_res_buf *buffer, int *scpll_mode)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,scpll_mode, sizeof(int));

  return ierr;
}
int get_rclcn_tapetype_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_tapetype_read(struct rclcn_res_buf *buffer, char *tapetype)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,tapetype);

  return ierr;
}
int get_rclcn_mk3_form_set(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_mk3_form_read(struct rclcn_res_buf *buffer, ibool *mk3)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,mk3, sizeof(ibool));

  return ierr;
}
int get_rclcn_transport_times(struct rclcn_res_buf *buffer, int *num_entries,
			      unsigned short serial[],
			      unsigned long tot_on_time[],
			      unsigned long tot_head_time[],
			      unsigned long head_use_time[],
			      unsigned long in_service_time[])
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,num_entries, sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,serial, 8*sizeof(unsigned short));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,tot_on_time, 8*sizeof(unsigned long));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,tot_head_time, 8*sizeof(unsigned long));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,head_use_time, 8*sizeof(unsigned long));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,in_service_time, 8*sizeof(unsigned long));

  return ierr;
}
int get_rclcn_station_info_read(struct rclcn_res_buf *buffer, int *station,
				long int *serialnum, char *nickname)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,station, sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,serialnum, sizeof(long int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,nickname);

  return ierr;
}
int get_rclcn_consolecmd(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_postime_read(struct rclcn_res_buf *buffer, int *year, int *day,
			   int *hour, int *min, int *sec, int *frame,
			   long int *position)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,year ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,day  ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,hour ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,min  ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,sec  ,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,frame,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,position,sizeof(long int));

  return ierr;
}
int get_rclcn_status(struct rclcn_res_buf *buffer, int *summary,
		     int *num_entries, unsigned char *status_list)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,summary,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,num_entries,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,status_list,2**num_entries);

  return ierr;
}
int get_rclcn_status_detail(struct rclcn_res_buf *buffer, int *summary,
		     int *num_entries, unsigned char *status_det_list)
{
  int ierr=get_rclcn_res(buffer);
  int j,i;

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,summary,sizeof(int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,num_entries,sizeof(int));
  if(ierr!=0)
    return ierr;


  j=0;
  for(i=0;i<*num_entries;i++) {
    ierr=get_rclcn_res_data(buffer,status_det_list+j  ,1);
    if(ierr!=0)
      return ierr;

    ierr=get_rclcn_res_data(buffer,status_det_list+j+1,1);
    if(ierr!=0)
      return ierr;

    ierr=get_rclcn_res_string(buffer,status_det_list+j+2);
    if(ierr!=0)
      return ierr;

    j+=2+strlen(status_det_list+j+2)+1;
  }

  return ierr;
}
int get_rclcn_status_decode(struct rclcn_res_buf *buffer, char *stat_msg)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,stat_msg);

  return ierr;
}
int get_rclcn_diag(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_berdcb(struct rclcn_res_buf *buffer,long int *err_bits,
		     long int *tot_bits)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,err_bits, sizeof(long int));
  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_data(buffer,tot_bits, sizeof(long int));

  return ierr;
}
int get_rclcn_ident(struct rclcn_res_buf *buffer, char *devtype)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,devtype);

  return ierr;
}
int get_rclcn_ping(struct rclcn_res_buf *buffer)
{
  return get_rclcn_res(buffer);
}
int get_rclcn_version(struct rclcn_res_buf *buffer, char *version)
{
  int ierr=get_rclcn_res(buffer);

  if(ierr!=0)
    return ierr;

  ierr=get_rclcn_res_string(buffer,version);

  return ierr;
}
