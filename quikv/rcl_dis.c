/* S2 rcl SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "../rclco/rcl/rcl_def.h"

#define MAX_OUT 2048

void rcl_dis(command,icmd,itask,ip)
struct cmd_ds *command;
int icmd, itask;
int ip[5];
{
  int ierr, i;
  struct rclcn_res_buf buffer;
  char output[MAX_OUT];
  int class, nrecs;
  char *start;
  
  strcpy(output,command->name);
  strcat(output,"/");
  start=output+strlen(output);
  strcat(output,"ack");
  class=0;
  nrecs=0;
  
  opn_rclcn_res(&buffer,ip);
  switch(icmd) {
  case RCL_CMD_STOP:
    ierr=get_rclcn_stop(&buffer);
    break;
  case RCL_CMD_PLAY:
    ierr=get_rclcn_play(&buffer);
    break;
  case RCL_CMD_RECORD:
    ierr=get_rclcn_record(&buffer);
    break;
  case RCL_CMD_REWIND:
    ierr=get_rclcn_rewind(&buffer);
    break;
  case RCL_CMD_FF:
    ierr=get_rclcn_ff(&buffer);
    break;
  case RCL_CMD_PAUSE:
    ierr=get_rclcn_pause(&buffer);
    break;
  case RCL_CMD_UNPAUSE:
    ierr=get_rclcn_unpause(&buffer);
    break;
  case RCL_CMD_EJECT:
    ierr=get_rclcn_eject(&buffer);
    break;
  case RCL_CMD_STATE_READ: {
    int rstate;
    ierr=get_rclcn_state_read(&buffer,&rstate);
    if(ierr!=0)
      break;

    switch (rstate) {
    case RCL_RSTATE_PLAY:
      strcat(output,",play");
      break;
    case RCL_RSTATE_RECORD:
      strcat(output,",record");
      break;
    case RCL_RSTATE_REWIND:
      strcat(output,",rewind");
      break;
    case RCL_RSTATE_FF:
      strcat(output,",ff");
      break;
    case RCL_RSTATE_STOP:
      strcat(output,",stop");
      break;
    case RCL_RSTATE_PPAUSE:
      strcat(output,",ppause");
      break;
    case RCL_RSTATE_RPAUSE:
      strcat(output,",rpause");
      break;
    case RCL_RSTATE_CUE:
      strcat(output,",cue");
      break;
    case RCL_RSTATE_REVIEW:
      strcat(output,",review");
      break;
    case RCL_RSTATE_NOTAPE:
      strcat(output,",notape");
      break;
    case RCL_RSTATE_POSITION:
      strcat(output,",position");
      break;
    default:
      sprintf(output+strlen(output),",0x%x",rstate);
    }
    break;
  }
  case RCL_CMD_SPEED_SET:
    ierr=get_rclcn_speed_set(&buffer);
    break;
  case RCL_CMD_SPEED_READ: {
    int speed;

    ierr=get_rclcn_speed_read(&buffer,&speed);
    if(ierr!=0)
      break;

    switch (speed) {
    case RCL_SPEED_UNKNOWN:
      strcat(output,",unknown");
      break;
    case RCL_SPEED_SP:
      strcat(output,",sp");
      break;
    case RCL_SPEED_LP:
      strcat(output,",lp");
      break;
    case RCL_SPEED_SLP:
      strcat(output,",slp");
      break;
    default:
      sprintf(output+strlen(output),",0x%x",speed);
    }
    break;
  }
  case RCL_CMD_SPEED_READ_PB: {
    int speed;
    
    ierr=get_rclcn_speed_read_pb(&buffer,&speed);
    if(ierr!=0)
      break;

    switch (speed) {
    case RCL_SPEED_UNKNOWN:
      strcat(output,",unknown");
      break;
    case RCL_SPEED_SP:
      strcat(output,",sp");
      break;
    case RCL_SPEED_LP:
      strcat(output,",lp");
      break;
    case RCL_SPEED_SLP:
      strcat(output,",slp");
      break;
    default:
      sprintf(output+strlen(output),",0x%x",speed);
    }
    break;
  }
  case RCL_CMD_ERROR_DECODE: {
    char err_msg[RCL_MAXSTRLEN_ERROR_DECODE];

    ierr=get_rclcn_error_decode(&buffer,err_msg);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",err_msg);
    break;
  }
  case RCL_CMD_TIME_SET:
    ierr=get_rclcn_time_set(&buffer);
    break;
  case RCL_CMD_TIME_READ: {
    int year, day, hour, min, sec;
    ibool validated;
    int centisec[6];
    
    ierr=get_rclcn_time_read(&buffer,&year,&day,&hour,&min,&sec,
			     &validated, centisec);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%d,%d,%d,%d,%d",
	    year,day,hour,min,sec);
    
    if(validated)
      strcat(output,",valid");
    else
      strcat(output,",not-valid");

    sprintf(output+strlen(output),",%ld,%ld",
	    centisec[0],centisec[1]);
    
    break;
  }
  case RCL_CMD_TIME_READ_PB: {
    int year, day, hour, min, sec;
    ibool validated;
    
    ierr=get_rclcn_time_read_pb(&buffer,&year,&day,&hour,&min,&sec,
				&validated);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%d,%d,%d,%d,%d",
	    year,day,hour,min,sec);
    
    if(validated)
      strcat(output,",valid");
    else
      strcat(output,",not-valid");
    
    break;
  }
  case RCL_CMD_MODE_SET:
    ierr=get_rclcn_mode_set(&buffer);
    break;
  case RCL_CMD_MODE_READ: {
    char mode[RCL_MAXSTRLEN_MODE];

    ierr=get_rclcn_mode_read(&buffer,mode);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",mode);

    break;
  }
  case RCL_CMD_TAPEID_SET:
    ierr=get_rclcn_tapeid_set(&buffer);
    break;
  case RCL_CMD_TAPEID_READ: {
    char tapeid[RCL_MAXSTRLEN_TAPEID];

    ierr=get_rclcn_tapeid_read(&buffer,tapeid);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",tapeid);
    
    break;
  }
  case RCL_CMD_TAPEID_READ_PB: {
    char tapeid[RCL_MAXSTRLEN_TAPEID];

    ierr=get_rclcn_tapeid_read_pb(&buffer,tapeid);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",tapeid);

    break;
  }
  case RCL_CMD_USER_INFO_SET:
    ierr=get_rclcn_user_info_set(&buffer);
    break;
  case RCL_CMD_USER_INFO_READ: {
    char user_info[RCL_MAXSTRLEN_USER_INFO];

    ierr=get_rclcn_user_info_read(&buffer,user_info);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",user_info);

    break;
  }
  case RCL_CMD_USER_INFO_READ_PB: {
    char user_info[RCL_MAXSTRLEN_USER_INFO];

    ierr=get_rclcn_user_info_read(&buffer,user_info);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",user_info);

    break;
  }
  case RCL_CMD_USER_DV_SET:
    ierr=get_rclcn_user_dv_set(&buffer);
    break;
  case RCL_CMD_USER_DV_READ: {
    ibool user_dv, pb_enable;

    ierr=get_rclcn_user_dv_read(&buffer,&user_dv,&pb_enable);
    if(ierr!=0)
      break;
    
    if(user_dv)
      strcat(output,",true");
    else
      strcat(output,",false");

    if(pb_enable)
      strcat(output,",use");
    else
      strcat(output,",ignore");
    
    break;
  }
  case RCL_CMD_USER_DV_READ_PB: {
    ibool user_dv;

    ierr=get_rclcn_user_dv_read_pb(&buffer,&user_dv);
    if(ierr!=0)
      break;

    if(user_dv)
      strcat(output,",true");
    else
      strcat(output,",false");

    break;
  }
  case RCL_CMD_GROUP_SET:
    ierr=get_rclcn_group_set(&buffer);
    break;
  case RCL_CMD_GROUP_READ: {
    int group, num_groups;

    ierr=get_rclcn_group_read(&buffer,&group,&num_groups);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%i,%i",group,num_groups);
    
    break;
  }
  case RCL_CMD_TAPEINFO_READ_PB: {
    unsigned char table[1+RCL_TAPEINFO_LEN];

    ierr=get_rclcn_tapeinfo_read_pb(&buffer,table+1);
    if(ierr!=0)
      break;

    for (i=0;i<8;i++) {
      unsigned char *tabler=table+i*52;
      int delay;

      strcat(output,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      sprintf(start,
	      "%d,%d,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%u,%u,",
	      tabler[1],tabler[2],tabler+3,tabler+24,
	      tabler[34]<<8|tabler[35],tabler[36]<<8|tabler[37],
	      tabler[38],tabler[39],tabler[40],tabler[41],
	      tabler[42],tabler[43],tabler[44],
	      tabler[45]<<8|tabler[46],tabler[47]<<8|tabler[48]);
      delay  = (int) tabler[49]<<24;
      delay |= (int) tabler[50]<<16;
      delay |= tabler[51]<<8;
      delay |= tabler[52];
      if(delay == 0x7FFFFFFF)
	strcat(start,"unknown");
      else
	sprintf(start+strlen(start),"%d",delay);
    }
    
    break;
  }
  case RCL_CMD_DELAY_SET:
    ierr=get_rclcn_delay_set(&buffer);
    break;
  case RCL_CMD_DELAY_READ: {
    int nanosec;

    ierr=get_rclcn_delay_read(&buffer,&nanosec);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%li",nanosec);

    break;
  }
  case RCL_CMD_DELAYM_READ: {
    int nanosec;

    ierr=get_rclcn_delaym_read(&buffer,&nanosec);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%li",nanosec);

    break;
  }
  case RCL_CMD_BARRELROLL_SET:
    ierr=get_rclcn_barrelroll_set(&buffer);
    break;
  case RCL_CMD_BARRELROLL_READ: {
    ibool barrelroll;

    ierr=get_rclcn_barrelroll_read(&buffer,&barrelroll);
    if(ierr!=0)
      break;

    if(barrelroll)
      strcat(output,",on");
    else
      strcat(output,",off");
    
    break;
  }
  case RCL_CMD_ALIGN:
    ierr=get_rclcn_align(&buffer);
    break;
  case RCL_CMD_POSITION_SET:
    ierr=get_rclcn_position_set(&buffer);
    break;
  case RCL_CMD_POSITION_READ: {
    int code;
    union pos_union position;
    
    ierr=get_rclcn_position_read(&buffer, &code, &position);
    if(ierr!=0)
      break;

    switch (code) {
    case 0:
      if (position.overall.position == RCL_POS_UNKNOWN)
	strcat(output,",unknown");
      else
	sprintf(output+strlen(output),",%li",position.overall.position);
      if (position.overall.posvar == RCL_POS_UNKNOWN)
	strcat(output,",unknown");
      else
	sprintf(output+strlen(output),",%li",position.overall.posvar);
      break;
    case 1: {
      int i;
      for (i=0;i<position.individual.num_entries;i++)
	if (position.individual.position[i] == RCL_POS_UNKNOWN)
	  strcat(output,",unknown");
	else if (position.individual.position[i] == RCL_POS_UNSEL)
	  strcat(output,",unselected");
	else
	  sprintf(output+strlen(output),",%li",
		  position.individual.position[i]);
      break;
    }
    default:
      ierr=-502;
    }
    break;
  }  
  case RCL_CMD_ERRMES:
    ierr=get_rclcn_errmes(&buffer);
    break;
  case RCL_CMD_ESTERR_READ: {
    int num_entries;
    char esterr_list[8*RCL_MAXSTRLEN_ESTERR];
    int i,j;

    ierr=get_rclcn_esterr_read(&buffer,&num_entries,esterr_list);
    if(ierr!=0)
      break;
 
    sprintf(output+strlen(output),",%i",num_entries);
    j=0;
    for (i=0;i<num_entries;i++) {
      
      strcat(output,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      sprintf(start,"%s",esterr_list+j);
      j+=strlen(esterr_list+j)+1;
    }
    break;
  }
  case RCL_CMD_PDV_READ: {
    int num_entries;
    char pdv_list[8*RCL_MAXSTRLEN_PDV];
    int i,j;

    ierr=get_rclcn_pdv_read(&buffer,&num_entries,pdv_list);
    if(ierr!=0)
      break;
 
    sprintf(output+strlen(output),",%i",num_entries);
    j=0;
    for (i=0;i<num_entries;i++) {
      
      strcat(output,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      sprintf(start,"%s",pdv_list+j);
      j+=strlen(pdv_list+j)+1;
    }
    break;
  }
  case RCL_CMD_SCPLL_MODE_SET:
    ierr=get_rclcn_scpll_mode_set(&buffer);
    break;
  case RCL_CMD_SCPLL_MODE_READ: {
    int scpll_mode;
    
    ierr=get_rclcn_scpll_mode_read(&buffer,&scpll_mode);
    if(ierr!=0)
      break;

    switch (scpll_mode) {
    case RCL_SCPLL_MODE_XTAL:
      strcat(output,",xtal");
      break;
    case RCL_SCPLL_MODE_MANUAL:
      strcat(output,",manual");
      break;
    case RCL_SCPLL_MODE_REFCLK:
      strcat(output,",reflck");
      break;
    case RCL_SCPLL_MODE_1HZ:
      strcat(output,",1hz");
      break;
    case RCL_SCPLL_MODE_ERRMES:
      strcat(output,",errmes");
      break;
    default:
      sprintf(output+strlen(output),",0x%x",scpll_mode);
    }
    break;
  }
  case RCL_CMD_TAPETYPE_SET:
    ierr=get_rclcn_tapetype_set(&buffer);
    break;
  case RCL_CMD_TAPETYPE_READ: {
    char tapetype[RCL_MAXSTRLEN_TAPETYPE];
    
    ierr=get_rclcn_tapetype_read(&buffer,tapetype);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",tapetype);
    
    break;
  }
  case RCL_CMD_MK3_FORM_SET:
    ierr=get_rclcn_mk3_form_set(&buffer);
    break;
  case RCL_CMD_MK3_FORM_READ: {
    ibool mk3;

    ierr=get_rclcn_mk3_form_read(&buffer,&mk3);
    if(ierr!=0)
      break;

    if(mk3)
      strcat(output,",enabled");
    else
      strcat(output,",disabled");
    
    break;
  }
  case RCL_CMD_TRANSPORT_TIMES: {
    int num_entries;
    unsigned short serial[8];
    unsigned int tot_on_time[8];
    unsigned int tot_head_time[8];
    unsigned int head_use_time[8];
    unsigned int in_service_time[8];
    int i;

    ierr=get_rclcn_transport_times(&buffer,&num_entries,serial,tot_on_time,
				   tot_head_time,head_use_time,
				   in_service_time);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%i",num_entries);


    for(i=0;i<num_entries;i++) {
      strcat(start,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;
      sprintf(start,"%hu,%lu,%lu,%lu,%lu",
	      serial[i],tot_on_time[i],tot_head_time[i],
	      head_use_time[i],in_service_time[i]);
    }

    break;
  }
  case RCL_CMD_STATION_INFO_READ: {
    int station;
    int serialnum;
    char nickname[RCL_MAXSTRLEN_NICKNAME];
    
    ierr=get_rclcn_station_info_read(&buffer,&station,&serialnum,nickname);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%i,%i,%s",station,serialnum,nickname);
    
    break;
  }
  case RCL_CMD_CONSOLECMD:
    ierr=get_rclcn_consolecmd(&buffer);
    break;
  case RCL_CMD_POSTIME_READ: {
    int year, day, hour, min, sec, frame;
    int position;
    
    ierr=get_rclcn_postime_read(&buffer,&year,&day,&hour,&min,&sec,
				&frame,&position);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%d,%d,%d,%d,%d,%d,%ld",
	    year,day,hour,min,sec,frame,position);
    
    break;
  }
  case RCL_CMD_STATUS: {
    int summary, num_entries;
    unsigned char status_list[RCL_STATUS_MAX*2];
    int i;

    ierr=get_rclcn_status(&buffer,&summary,&num_entries,status_list);
    if(ierr!=0)
      break;
 
    sprintf(output+strlen(output),",0x%x,%i",summary,num_entries);

    for (i=0;i<num_entries;i++) {      
      char st[11];

      strcat(output,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      if(((~0x7)&status_list[i*2+1]) == 0) {
	strcpy(st,"---");
	if(0x1&status_list[i*2+1])
	  st[0]='E';
	if(0x2&status_list[i*2+1])
	  st[1]='F';
	if(0x4&status_list[i*2+1])
	  st[2]='C';
      } else
	sprintf(st,"0x%x",status_list[i*2+1]);

      sprintf(start,"%d,%s",status_list[i*2],st);
    }
    break;
  }
  case RCL_CMD_STATUS_DETAIL: {
    int summary, num_entries;
    unsigned char status_det_list[RCL_STATUS_DETAIL_MAXLEN];
    int i,j;

    ierr=get_rclcn_status_detail(&buffer,&summary,&num_entries,
				 status_det_list);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",0x%x,%i",summary,num_entries);

    j=0;
    for (i=0;i<num_entries;i++) {      
      char *newln,*colon;
      char st[11];

      strcat(start,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      if(((~0x7)&status_det_list[j+1]) == 0) {
	strcpy(st,"---");
	if((0x1&status_det_list[j+1]) == 0x1)
	  st[0]='E';
	if((0x2&status_det_list[j+1]) == 0x2)
	  st[1]='F';
	if((0x4&status_det_list[j+1]) == 0x4)
	  st[2]='C';
      } else
	sprintf(st,"0x%x",status_det_list[j+1]);

      sprintf(start,"%d,%s",status_det_list[j],st);
      j+=2;
      colon=strchr(status_det_list+j,':');
      if(colon!=NULL && strncmp(status_det_list+j,"STAT_",5)==0) {
	*colon=0;
	strcat(start,",");
	strcat(start,status_det_list+j);
	j+=strlen(status_det_list+j)+1;
	if(status_det_list[j]==' ')
	  j++;
      }
      strcat(start,",\\");
      cls_snd(&class,output,strlen(output),0,0);
      nrecs+=1;

      start[0]=0;
      while(status_det_list[j]!=0) {
	newln=strchr(status_det_list+j,'\n');
	if(newln!=NULL)
	  *newln=0;
	strcat(start,status_det_list+j);
	j+=strlen(status_det_list+j);
	if(newln!=NULL)
	  j++;
	if(status_det_list[ j]!=0) {
	  strcat(start,"\\");
	  cls_snd(&class,output,strlen(output),0,0);
	  nrecs+=1;
	  start[0]=0;
	}
      }
      j++;
    }
    break;
  }
  case RCL_CMD_STATUS_DECODE: {
    char stat_msg[RCL_MAXSTRLEN_STATUS_DECODE];
    char *colon,*newln;
    int j;

    ierr=get_rclcn_status_decode(&buffer,stat_msg);
    if(ierr!=0)
      break;

    j=0;
    colon=strchr(stat_msg,':');
    if(colon!=NULL && strncmp(stat_msg,"STAT_",5)==0) {
      *colon=0;
      strcat(start,",");
      strcat(start,stat_msg);
	j+=strlen(stat_msg)+1;
	if(stat_msg[j]==' ')
	  j++;
      }
    strcat(start,",\\");
    cls_snd(&class,output,strlen(output),0,0);
    nrecs+=1;

    start[0]=0;
    while(stat_msg[j]!=0) {
      newln=strchr(stat_msg+j,'\n');
      if(newln!=NULL)
	*newln=0;
      strcat(start,stat_msg+j);
      j+=strlen(stat_msg+j);
      if(newln!=NULL)
	j++;
      if(stat_msg[ j]!=0) {
	strcat(start,"\\");
	cls_snd(&class,output,strlen(output),0,0);
	nrecs+=1;
	start[0]=0;
      }
    }

    break;
  }
  case RCL_CMD_DIAG:
    ierr=get_rclcn_diag(&buffer);
    break;
  case RCL_CMD_BERDCB: {
    unsigned int err_bits, tot_bits;
    
    ierr=get_rclcn_berdcb(&buffer,&err_bits,&tot_bits);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%i,%i",err_bits,tot_bits);
    
    break;
  }
  case RCL_CMD_IDENT: {
    char devtype[RCL_MAXSTRLEN_IDENT];
    
    ierr=get_rclcn_version(&buffer,devtype);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",devtype);
    
    break;
  }
  case RCL_CMD_PING:
    ierr=get_rclcn_ping(&buffer);
    break;
  case RCL_CMD_VERSION: {
    char version[RCL_MAXSTRLEN_VERSION];
    
    ierr=get_rclcn_version(&buffer,version);
    if(ierr!=0)
      break;

    sprintf(output+strlen(output),",%s",version);
    
    break;
  }
  default:
    ierr=-501;
  }
  clr_rclcn_res(&buffer);

  if(ierr!=0)
    goto error;

done:     
  for (i=0;i<5;i++)
    ip[i]=0;
  cls_snd(&class,output,strlen(output),0,0);
  nrecs+=1;
  ip[0]=class;
  ip[1]=nrecs;
  return;
  
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"rm",2);
  
  return;
}
