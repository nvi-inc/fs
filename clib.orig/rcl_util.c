/* rcl command buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"

#include "../rclco/rcl/rcl_def.h"

char *arg_next(struct cmd_ds *command,int *ilast);  /* traverse argv array */

int rcl_dec(struct cmd_ds *command,struct rclcn_req_buf *buffer,int *icmd)
{
  int ilast;
  char *ptr;
  char device[2];

  ilast=0;                                      /* last argv examined */

  ptr=arg_next(command,&ilast);
  if(strlen(ptr)==2)
    memcpy(device,ptr,2);
  else
    return -201;

  ptr=arg_next(command,&ilast);
  if(strcmp(ptr,"stop")==0) {
    *icmd=RCL_CMD_STOP;
    add_rclcn_stop(buffer,device);
    return 0;
  } else if(strcmp(ptr,"play")==0) {
    *icmd=RCL_CMD_PLAY;
    add_rclcn_play(buffer,device);
    return 0;
  } else if(strcmp(ptr,"record")==0) {
    *icmd=RCL_CMD_RECORD;
    add_rclcn_record(buffer,device);
    return 0;
  } else if(strcmp(ptr,"rewind")==0) {
    *icmd=RCL_CMD_REWIND;
    add_rclcn_rewind(buffer,device);
    return 0;
  } else if(strcmp(ptr,"ff")==0) {
    *icmd=RCL_CMD_FF;
    add_rclcn_ff(buffer,device);
    return 0;
  } else if(strcmp(ptr,"pause")==0) {
    *icmd=RCL_CMD_PAUSE;
    add_rclcn_pause(buffer,device);
    return 0;
  } else if(strcmp(ptr,"unpause")==0) {
    *icmd=RCL_CMD_UNPAUSE;
    add_rclcn_unpause(buffer,device);
    return 0;
  } else if(strcmp(ptr,"eject")==0) {
    *icmd=RCL_CMD_EJECT;
    add_rclcn_eject(buffer,device);
    return 0;
  } else if(strcmp(ptr,"state_read")==0) {
    *icmd=RCL_CMD_STATE_READ;
    add_rclcn_state_read(buffer,device);
    return 0;
  } else if(strcmp(ptr,"speed_set")==0) {
    int speed;
    *icmd=RCL_CMD_SPEED_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"lp")==0)
      speed=RCL_SPEED_LP;
    else if(strcmp(ptr,"slp")==0)
      speed=RCL_SPEED_SLP;
    else if(1!=sscanf(ptr,"%i",&speed))
      return -203;
    add_rclcn_speed_set(buffer,device,speed);
    return 0;
  } else if(strcmp(ptr,"speed_read")==0) {
    *icmd=RCL_CMD_SPEED_READ;
    add_rclcn_speed_read(buffer,device);
    return 0;
  } else if(strcmp(ptr,"speed_read_pb")==0) {
    *icmd=RCL_CMD_SPEED_READ_PB;
    add_rclcn_speed_read_pb(buffer,device);
    return 0;
  } else if(strcmp(ptr,"error_decode")==0) {
    int err_code;
    *icmd=RCL_CMD_ERROR_DECODE;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&err_code))
      return -203;
    add_rclcn_error_decode(buffer,device,err_code);
    return 0;
  } else if(strcmp(ptr,"time_set")==0) {
    int year, day, hour, min, sec;
    *icmd=RCL_CMD_TIME_SET;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&year))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if(1!=sscanf(ptr,"%i",&day))
      return -204;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -205;
    else if(1!=sscanf(ptr,"%i",&hour))
      return -205;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -206;
    else if(1!=sscanf(ptr,"%i",&min))
      return -206;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -207;
    else if(1!=sscanf(ptr,"%i",&sec))
      return -207;

    add_rclcn_time_set(buffer,device,year,day,hour,min,sec);
    return 0;
  } else if(strcmp(ptr,"time_read")==0) {
    *icmd=RCL_CMD_TIME_READ;
    add_rclcn_time_read(buffer,device);
    return 0;
  } else if(strcmp(ptr,"time_read_pb")==0) {
    *icmd=RCL_CMD_TIME_READ_PB;
    add_rclcn_time_read_pb(buffer,device);
    return 0;

  } else if(strcmp(ptr,"mode_set")==0) {
    *icmd=RCL_CMD_MODE_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    add_rclcn_mode_set(buffer,device,ptr);
    return 0;

  } else if(strcmp(ptr,"mode_read")==0) {
    *icmd=RCL_CMD_MODE_READ;
    add_rclcn_mode_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"tapeid_set")==0) {
    *icmd=RCL_CMD_TAPEID_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)  /* empty okay */
      ptr="";
    add_rclcn_tapeid_set(buffer,device,ptr);
    return 0;

  } else if(strcmp(ptr,"tapeid_read")==0) {
    *icmd=RCL_CMD_TAPEID_READ;
    add_rclcn_tapeid_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"tapeid_read_pb")==0) {
    *icmd=RCL_CMD_TAPEID_READ_PB;
    add_rclcn_tapeid_read_pb(buffer,device);
    return 0;

  } else if(strcmp(ptr,"user_info_set")==0) {
    int fieldnum;
    ibool label;

    *icmd=RCL_CMD_USER_INFO_SET;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if (1!=sscanf(ptr,"%i",&fieldnum))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if (strcmp(ptr,"label")==0)
      label=TRUE;
    else if (strcmp(ptr,"field")==0)
      label=FALSE;
    else if(1!=sscanf(ptr,"%i",&label))
      return -204;
      
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      ptr="";

    add_rclcn_user_info_set(buffer,device,fieldnum,label,ptr);
    return 0;

  } else if(strcmp(ptr,"user_info_read")==0) {
    int fieldnum;
    ibool label;

    *icmd=RCL_CMD_USER_INFO_READ;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if (1!=sscanf(ptr,"%i",&fieldnum))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if (strcmp(ptr,"label")==0)
      label=TRUE;
    else if (strcmp(ptr,"field")==0)
      label=FALSE;
    else if(1!=sscanf(ptr,"%i",&label))
      return -204;

    add_rclcn_user_info_read(buffer,device,fieldnum,label);
    return 0;

  } else if(strcmp(ptr,"user_info_read_pb")==0) {
    int fieldnum;
    ibool label;

    *icmd=RCL_CMD_USER_INFO_READ_PB;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if (1!=sscanf(ptr,"%i",&fieldnum))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if (strcmp(ptr,"label")==0)
      label=TRUE;
    else if (strcmp(ptr,"field")==0)
      label=FALSE;
    else if(1!=sscanf(ptr,"%i",&label))
      return -204;

    add_rclcn_user_info_read_pb(buffer,device,fieldnum,label);
    return 0;

  } else if(strcmp(ptr,"user_dv_set")==0) {
    ibool user_dv, pb_enable;

    *icmd=RCL_CMD_USER_DV_SET;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if (strcmp(ptr,"true")==0)
      user_dv=TRUE;
    else if (strcmp(ptr,"false")==0)
      user_dv=FALSE;
    else if(1!=sscanf(ptr,"%i",&user_dv))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if (strcmp(ptr,"use")==0)
      pb_enable=TRUE;
    else if (strcmp(ptr,"ignore")==0)
      pb_enable=FALSE;
    else if(1!=sscanf(ptr,"%i",&pb_enable))
      return -204;
      
    add_rclcn_user_dv_set(buffer,device,user_dv,pb_enable);
    return 0;

  } else if(strcmp(ptr,"user_dv_read")==0) {

    *icmd=RCL_CMD_USER_DV_READ;
      
    add_rclcn_user_dv_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"user_dv_read_pb")==0) {

    *icmd=RCL_CMD_USER_DV_READ_PB;
      
    add_rclcn_user_dv_read_pb(buffer,device);
    return 0;

  } else if(strcmp(ptr,"group_set")==0) {
    int group;
    *icmd=RCL_CMD_GROUP_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&group))
      return -203;
    add_rclcn_group_set(buffer,device,group);
    return 0;

  } else if(strcmp(ptr,"group_read")==0) {
    *icmd=RCL_CMD_GROUP_READ;
    add_rclcn_group_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"tapeinfo_read_pb")==0) {
    *icmd=RCL_CMD_TAPEINFO_READ_PB;
    add_rclcn_tapeinfo_read_pb(buffer,device);
    return 0;

  } else if(strcmp(ptr,"delay_set")==0) {
    ibool relative;
    long int nanosec;
    *icmd=RCL_CMD_DELAY_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"relative")==0)
      relative=TRUE;
    else if(strcmp(ptr,"absolute")==0)
      relative=FALSE;
    else if(1!=sscanf(ptr,"%i",&relative))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if(1!=sscanf(ptr,"%li",&nanosec))
      return -204;

    add_rclcn_delay_set(buffer,device,relative,nanosec);
    return 0;

  } else if(strcmp(ptr,"delay_read")==0) {
    *icmd=RCL_CMD_DELAY_READ;
    add_rclcn_delay_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"delaym_read")==0) {
    *icmd=RCL_CMD_DELAYM_READ;
    add_rclcn_delaym_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"barrelroll_set")==0) {
    ibool barrelroll;
    *icmd=RCL_CMD_BARRELROLL_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"on")==0 || strcmp(ptr,"true")==0)
      barrelroll=TRUE;
    else if(strcmp(ptr,"off")==0 || strcmp(ptr,"false")==0)
      barrelroll=FALSE;
    else if(1!=sscanf(ptr,"%i",&barrelroll))
      return -203;
    add_rclcn_barrelroll_set(buffer,device,barrelroll);
    return 0;

  } else if(strcmp(ptr,"barrelroll_read")==0) {
    *icmd=RCL_CMD_BARRELROLL_READ;
    add_rclcn_barrelroll_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"align")==0) {
    int idecode, type;

    *icmd=RCL_CMD_ALIGN;

    ptr=arg_next(command,&ilast);

    if(ptr!=NULL)
      idecode=1==sscanf(ptr,"%i",&type);
    else
      idecode=1==0;

    if(strcmp(ptr,"absolute")==0 || (idecode && type==0)) {
      int year, day, hour, min, sec;
      long int nanosec;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&year))
	return -204;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&day))
	return -205;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&hour))
	return -206;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&min))
	return -207;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&sec))
	return -208;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%li",&nanosec))
	return -209;

      add_rclcn_align(buffer,device,year,day,hour,min,sec,nanosec);
    } else if(strcmp(ptr,"relative")==0 || (idecode && type==1)) {
      ibool negative;
      int hour, min, sec;
      long int nanosec;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL)
	return -204;
      else if(strcmp(ptr,"-")==0)
	negative=TRUE;
      else if(strcmp(ptr,"+")==0)
	negative=FALSE;
      else if(1!=sscanf(ptr,"%i",&negative))
	return -204;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&hour))
	return -205;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&min))
	return -206;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%i",&sec))
	return -207;

      ptr=arg_next(command,&ilast);
      if(ptr==NULL || 1!=sscanf(ptr,"%li",&nanosec))
	return -208;

      add_rclcn_align_rel(buffer,device,negative,hour,min,sec,nanosec);
    } else if(strcmp(ptr,"re-align")==0 || (idecode && type==2)) {
      add_rclcn_align_realign(buffer,device);
    } else if(strcmp(ptr,"self-align")==0 || (idecode && type==3)) {
      add_rclcn_align_selfalign(buffer,device);
    } else
      return -203;

    return 0;

  } else if(strcmp(ptr,"position_set")==0) {
    int code;

    *icmd=RCL_CMD_POSITION_SET;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"absolute")==0) {
      code=0;
    }  else if(strcmp(ptr,"relative")==0) {
      code=1;
    }  else if(strcmp(ptr,"preset")==0) {
      code=2;
    }  else if(strcmp(ptr,"re-establish")==0) {
      code=3;
    }  else if(1!=sscanf(ptr,"%i",&code) || code < 0 || code >3)
      return -203;

    if(-1 < code && code < 3) {
      int num,i;
      long int position[8];

      ptr=arg_next(command,&ilast);
      if(ptr==NULL)
	return -204;
      else if(strcmp(ptr,"1")==0)
	num=1;
      else if(strcmp(ptr,"8")==0)
	num=8;
      else
	return -204;
      for (i=0;i<num;i++) {
	ptr=arg_next(command,&ilast);
	if(ptr==NULL)
	  return -205-i;
	else if (num==8 && strcmp(ptr,"unselected")==0)
	  position[i]=RCL_POS_UNSEL;
	else if (code == 2 && strcmp(ptr,"unknown")==0)
	  position[i]=RCL_POS_UNKNOWN;
	else if (1!=sscanf(ptr,"%li",position+i))
	  return -205-i;
      }
      switch (num) {
      case 1:
	add_rclcn_position_set(buffer,device,code,position[0]);
	break;
      case 8:
	add_rclcn_position_set_ind(buffer,device,code,position);
	break;
      default:
	return -331;
      }
    } else if (code == 3) 
	add_rclcn_position_reestablish(buffer,device);
    else
      return -332;

    return 0;

  } else if(strcmp(ptr,"position_read")==0) {
    int code;

    *icmd=RCL_CMD_POSITION_READ;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"overall")==0) {
      code=0;
    }  else if(strcmp(ptr,"individual")==0) {
      code=1;
    }  else if(1!=sscanf(ptr,"%i",&code) || code <0 || code >3)
      return -203;
    add_rclcn_position_read(buffer,device, code);
    return 0;

  } else if(strcmp(ptr,"errmes")==0) {
    long int error;
    *icmd=RCL_CMD_ERRMES;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL || 1!=sscanf(ptr,"%li",&error))
      return -203;

    add_rclcn_errmes(buffer,device,error);
    return 0;

  } else if(strcmp(ptr,"esterr_read")==0) {
    ibool order_chantran;

    *icmd=RCL_CMD_ESTERR_READ;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"channel")==0)
      order_chantran=TRUE;
    else if(strcmp(ptr,"transport")==0)
      order_chantran=FALSE;
    else if(1!=sscanf(ptr,"%i",&order_chantran))
      return -203;

    add_rclcn_esterr_read(buffer,device,order_chantran);
    return 0;

  } else if(strcmp(ptr,"pdv_read")==0) {
    ibool order_chantran;

    *icmd=RCL_CMD_PDV_READ;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"channel")==0)
      order_chantran=TRUE;
    else if(strcmp(ptr,"transport")==0)
      order_chantran=FALSE;
    else if(1!=sscanf(ptr,"%i",&order_chantran))
      return -203;

    add_rclcn_pdv_read(buffer,device,order_chantran);
    return 0;

  } else if(strcmp(ptr,"scpll_mode_set")==0) {
    int scpll_mode;
    *icmd=RCL_CMD_SCPLL_MODE_SET;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"xtal")==0)
      scpll_mode=RCL_SCPLL_MODE_XTAL;
    else if(strcmp(ptr,"manual")==0)
      scpll_mode=RCL_SCPLL_MODE_MANUAL;
    else if(strcmp(ptr,"refclk")==0)
      scpll_mode=RCL_SCPLL_MODE_REFCLK;
    else if(strcmp(ptr,"1hz")==0)
      scpll_mode=RCL_SCPLL_MODE_1HZ;
    else if(strcmp(ptr,"errmes")==0)
      scpll_mode=RCL_SCPLL_MODE_ERRMES;
    else if(1!=sscanf(ptr,"%i",&scpll_mode))
      return -203;
    add_rclcn_scpll_mode_set(buffer,device,scpll_mode);
    return 0;

  } else if(strcmp(ptr,"scpll_mode_read")==0) {
    *icmd=RCL_CMD_SCPLL_MODE_READ;
    add_rclcn_scpll_mode_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"tapetype_set")==0) {
    *icmd=RCL_CMD_TAPETYPE_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    add_rclcn_tapetype_set(buffer,device,ptr);
    return 0;

  } else if(strcmp(ptr,"tapetype_read")==0) {
    *icmd=RCL_CMD_TAPETYPE_READ;
    add_rclcn_tapetype_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"mk3_form_set")==0) {
    ibool mk3;
    *icmd=RCL_CMD_MK3_FORM_SET;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"enable")==0 || strcmp(ptr,"true")==0)
      mk3=TRUE;
    else if(strcmp(ptr,"disable")==0 || strcmp(ptr,"false")==0)
      mk3=FALSE;
    else if(1!=sscanf(ptr,"%i",&mk3))
      return -203;
    add_rclcn_mk3_form_set(buffer,device,mk3);
    return 0;

  } else if(strcmp(ptr,"mk3_form_read")==0) {
    *icmd=RCL_CMD_MK3_FORM_READ;
    add_rclcn_mk3_form_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"transport_times")==0) {
    *icmd=RCL_CMD_TRANSPORT_TIMES;
    add_rclcn_transport_times(buffer,device);
    return 0;

  } else if(strcmp(ptr,"station_info_read")==0) {
    *icmd=RCL_CMD_STATION_INFO_READ;
    add_rclcn_station_info_read(buffer,device);
    return 0;

  } else if(strcmp(ptr,"consolecmd")==0) {
    *icmd=RCL_CMD_CONSOLECMD;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    add_rclcn_consolecmd(buffer,device,ptr);
    return 0;

  } else if(strcmp(ptr,"postime_read")==0) {
    int tran;
    *icmd=RCL_CMD_POSTIME_READ;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&tran))
      return -203;
    add_rclcn_postime_read(buffer,device,tran);
    return 0;

  } else if(strcmp(ptr,"status")==0) {
    int err_code;
    *icmd=RCL_CMD_STATUS;
    add_rclcn_status(buffer,device);
    return 0;

  } else if(strcmp(ptr,"status_detail")==0) {
    int stat_code;
    ibool reread, shortt;

    *icmd=RCL_CMD_STATUS_DETAIL;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&stat_code))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if(strcmp(ptr,"false")==0)
      reread=FALSE;
    else if(strcmp(ptr,"true")==0)
      reread=TRUE;
    else if(1!=sscanf(ptr,"%i",&reread))
      return -204;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -205;
    else if(strcmp(ptr,"false")==0)
      shortt=FALSE;
    else if(strcmp(ptr,"true")==0)
      shortt=TRUE;
    else if(1!=sscanf(ptr,"%i",&shortt))
      return -205;

    add_rclcn_status_detail(buffer,device,stat_code,reread,shortt);
    return 0;

  } else if(strcmp(ptr,"status_decode")==0) {
    int stat_code;
    ibool reread, shortt;

    *icmd=RCL_CMD_STATUS_DECODE;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&stat_code))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if(strcmp(ptr,"false")==0)
      shortt=FALSE;
    else if(strcmp(ptr,"true")==0)
      shortt=TRUE;
    else if(1!=sscanf(ptr,"%i",&shortt))
      return -204;

    add_rclcn_status_decode(buffer,device,stat_code,shortt);
    return 0;

  } else if(strcmp(ptr,"diag")==0) {
    int type;
    *icmd=RCL_CMD_DIAG;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&type))
      return -203;
    add_rclcn_diag(buffer,device,type);
    return 0;

  } else if(strcmp(ptr,"berdcb")==0) {
    int op_type, chan, meas_time;

    *icmd=RCL_CMD_BERDCB;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(strcmp(ptr,"fmber")==0)
      op_type=1;
    else if(strcmp(ptr,"uiber")==0)
      op_type=2;
    else if(strcmp(ptr,"uidcb")==0)
      op_type=3;
    else if(1!=sscanf(ptr,"%i",&op_type))
      return -203;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -204;
    else if(1!=sscanf(ptr,"%i",&chan))
      return -204;

    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -205;
    else if(1!=sscanf(ptr,"%i",&meas_time))
      return -205;

    add_rclcn_berdcb(buffer,device,op_type,chan,meas_time);
    return 0;

  } else if(strcmp(ptr,"ident")==0) {
    *icmd=RCL_CMD_IDENT;
    add_rclcn_ident(buffer,device);
    return 0;

  } else if(strcmp(ptr,"ping")==0) {
    int timeout;
    *icmd=RCL_CMD_PING;
    ptr=arg_next(command,&ilast);
    if(ptr==NULL)
      return -203;
    else if(1!=sscanf(ptr,"%i",&timeout))
      return -203;
    add_rclcn_ping(buffer,device,timeout);
    return 0;

  } else if(strcmp(ptr,"version")==0) {
    *icmd=RCL_CMD_VERSION;
    add_rclcn_version(buffer,device);
    return 0;

  } else
    return -202;
}

