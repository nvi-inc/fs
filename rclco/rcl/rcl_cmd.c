#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RCL_MAIN           /* main definitions for global variables */
#include "rcl_def.h"
#include "rcl_pkt.h"

#include "rcl_cmd.h"

/*
 * Recorder Control Link (RCL) "master" side interface library. Contains 
 * high-level command processing routines for communicating with S2 recorders.
 * Other devices may use the RCL in the future, in which case other interface
 * libraries will need to be written (although a few commands such as PING,
 * VERSION, and IDENT will be common to all devices).
 * The "master" side sends commands while the "slave" side (S2 or other device)
 * carries out the commands and issues responses.
 *
 * In general each function below corresponds to a specific RCL command.
 * The return value is either a negative S2 error code (remote), or
 * a positive local error code RCL_ERR_* as defined in rcl_def.h. Local
 * error codes are returned when an error is encountered before successfully
 * communicating with the S2. For successful commands the returned value
 * is RCL_ERR_NONE.
 * 
 * These routines automatically perform retries for most RCL commands if no
 * response is received within an appropriate timeout interval. After a certain
 * number of unsuccessful retries (given by RCL_RETRIES) the local error code
 * RCL_ERR_TIMEOUT is returned, indicating that communication failed. 
 * Certain RCL command functions below do not perform any retries: rcl_ping(),
 * rcl_time_set(), rcl_time_read, rcl_time_read_pb(), and rcl_align_abs(). 
 * For these functions retries at the packet processing level are
 * inappropriate so they return RCL_ERR_TIMEOUT on the first failed attempt.
 * The caller should retry these commands externally if necessary, possibly
 * requiring an update of the command's data portion (e.g. a new time value
 * in rcl_time_set()). Such retries should be performed only when error code
 * RCL_ERR_TIMEOUT is returned.
 *
 * See also rcl_open() and rcl_close() in rcl_sysn.c.
 */


int rcl_ping(int addr, int timeout)
/*
 * Tests to see if RCL device (S2) is alive. Performs no operation.
 * 'addr' is the address of the RCL device (S2) to control, from 0 to 253.
 *        For serial port operation this is the S2 RCL address set using 
 *        the 'rcladdr' parameter in the S2 defaults file (address 0 should be
 *        used if there is only one RCL device in the system). For network
 *        operation this is the reference address returned by rcl_open().
 * 'timeout' is in milliseconds. 0 means use default RCL_TIMEOUT.
 * Return value is local or remote error code.
 */
{
   int err;

   if (timeout<=0)      /* check if not specified */
      timeout=RCL_TIMEOUT;

   err=rcl_simple_cmd(addr,RCL_CMD_PING,NULL,0,timeout);

   return(err);
}

int rcl_stop(int addr)
/*
 * Stops transports and/or current operation.
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_STOP,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_play(int addr)
/*
 * Starts playback (use rcl_status() to monitor progress).
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_PLAY,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_record(int addr)
/*
 * Starts recording (use rcl_status() to monitor progress).
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_RECORD,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_rewind(int addr)
/*
 * Rewinds tapes (use rcl_state_read() to test completion, recorder will
 * auto-stop).
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_REWIND,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_ff(int addr)
/*
 * Fast-forwards tapes (use rcl_state_read() to test completion, recorder will
 * auto-stop).
 * **Not recommended. Use rcl_position_set() instead.**
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_FF,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_pause(int addr)
/*
 * Temporarily pauses recording or playback.
 * **Not recommended. Use rcl_stop() instead.**
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_PAUSE,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_unpause(int addr)
/*
 * Resumes recording or playback after pause.
 * **Not recommended.**
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_UNPAUSE,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_eject(int addr)
/*
 * Ejects tapes.
 * Return value is local or remote error code.
 */
{
   int err;

   err=rcl_simple_cmd(addr,RCL_CMD_EJECT,NULL,0,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_state_read(int addr, int* rstate)
/*
 * Reads current recorder state (stop, record, play, rewind, ff, no_tape etc).
 * 'rstate' returns numeric state code.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char rcl_rstate;
   
   err=rcl_general_cmd(addr,RCL_CMD_STATE_READ,NULL,0,&resp_code,
                       &rcl_rstate,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code (should be RCL_RESP_STATE) */
   if (resp_code!=RCL_RESP_STATE)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *rstate=rcl_rstate;

   return(RCL_ERR_NONE);
}

int rcl_speed_set(int addr, int speed)
/*
 * Sets the record tape speed.
 * 'speed' is the numeric speed code to set.
 * Return value is local or remote error code.
 */
{
   int err;
   signed char parm;

   /* basic range check (further checking done by S2) */
   if (speed<-128 || speed>127)
      return(RCL_ERR_BADVAL);

   parm=speed;        /* convert data size */
   err=rcl_simple_cmd(addr,RCL_CMD_SPEED_SET,(char*)&parm,1,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_speed_read(int addr, int* speed)
/*
 * Reads the current record tape speed.
 * 'speed' returns the numeric speed code.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char rcl_speed;
   
   err=rcl_general_cmd(addr,RCL_CMD_SPEED_READ,NULL,0,&resp_code,
                       &rcl_speed,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_SPEED)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *speed=rcl_speed;

   return(RCL_ERR_NONE);
}

int rcl_speed_read_pb(int addr, int* speed)
/*
 * Reads the current playback tape speed.
 * 'speed' returns the numeric speed code.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char rcl_speed;
   
   err=rcl_general_cmd(addr,RCL_CMD_SPEED_READ_PB,NULL,0,&resp_code,
                       &rcl_speed,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_SPEED)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *speed=rcl_speed;

   return(RCL_ERR_NONE);
}

int rcl_time_set(int addr, int year, int day, int hour, int min, int sec)
/*
 * Sets the S2 system time, which is the time encoded onto tape during record.
 * Caller should synchronize to the 1 Hz tick being fed to the S2
 * (S-1 Hz rec), i.e. send the command immediately follow a tick.
 * 'year' is the absolute year number (must be greater than 1900).
 * 'day' is the absolute day number (1 to 365, 1 to 366 for leap years).
 * 'hour' is the hour from 0 to 23.
 * 'min' is the minute from 0 to 59.
 * 'sec' is the second from 0 to 59.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[7];

   /* basic range check (further checking done by S2) */
   if (year<1901 || day<1 || day>366 || hour<0 || hour>23
         || min<0 || min>59 || sec<0 || sec>59)  {
      return(RCL_ERR_BADVAL);
   }

   parm[0]=(year>>8) & 0xff;
   parm[1]=year & 0xff;
   parm[2]=(day>>8) & 0xff;
   parm[3]=day & 0xff;
   parm[4]=hour;
   parm[5]=min;
   parm[6]=sec;

   err=rcl_simple_cmd(addr,RCL_CMD_TIME_SET,(char*)parm,7,RCL_TIMEOUT);

   return(err);
}

int rcl_time_read(int addr, int* year, int* day, int* hour, int* min,
                  int* sec, ibool* validated)
/*
 * Reads the current S2 system time, as set using rcl_time_set().
 * The response from the S2 is sent immediately following the next 1 Hz
 * input tick (S-1 Hz rec or C-1 Hz rec), and gives the time of the tick that
 * just passed. In System Clock PLL modes where no 1 Hz input reference is
 * used (errmes, xtal) the response is sent immediately following the next
 * 1 Hz output tick (S-1 Hz pb) instead.
 * 'year' returns the absolute year number.
 * 'day' returns the absolute day number (1 to 365, 1 to 366 for leap years).
 * 'hour' returns the hour from 0 to 23.
 * 'min' returns the minute from 0 to 59.
 * 'sec' returns the second from 0 to 59.
 * 'validated' returns TRUE if the time has been validated (set) since the
 *             last S2 reboot (or major timing glitch), FALSE otherwise.
 *             To ignore this parameter, pass NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char parm[8];
   
   err=rcl_general_cmd(addr,RCL_CMD_TIME_READ,NULL,0,&resp_code,
                       (char*)parm,8/*maxlength*/,&resp_length,RCL_TIMEOUT_S1);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TIME)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=8)
      return(RCL_ERR_PKTLEN);

   /* Note: parm[] must be unsigned for following to work */
   *year=((int)parm[0]<<8) | (int)parm[1];
   *day=((int)parm[2]<<8) | (int)parm[3];
   *hour=parm[4];
   *min=parm[5];
   *sec=parm[6];

   if (validated!=NULL)
      *validated=parm[7];

   return(RCL_ERR_NONE);
}

int rcl_time_read_pb(int addr, int* year, int* day, int* hour, int* min,
                     int* sec, ibool* validated)
/*
 * Reads the S2 playback tape time. The S2 must currently be playing back
 * properly recorded tapes and the tapes must be aligned.
 * The response from the S2 is sent immediately following the next 1 Hz
 * output tick (S-1 Hz pb), and gives the time of the tick that just passed.
 * 'year' returns the absolute year number.
 * 'day' returns the absolute day number (1 to 365, 1 to 366 for leap years).
 * 'hour' returns the hour from 0 to 23.
 * 'min' returns the minute from 0 to 59.
 * 'sec' returns the second from 0 to 59.
 * 'validated' returns TRUE if the system time was validated (set) at record
 *             time, FALSE otherwise. To ignore this parameter, pass NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char parm[8];
   
   err=rcl_general_cmd(addr,RCL_CMD_TIME_READ_PB,NULL,0,&resp_code,
                       (char*)parm,8/*maxlength*/,&resp_length,RCL_TIMEOUT_S1);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TIME)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=8)
      return(RCL_ERR_PKTLEN);

   /* Note: parm[] must be unsigned for following to work */
   *year=((int)parm[0]<<8) | (int)parm[1];
   *day=((int)parm[2]<<8) | (int)parm[3];
   *hour=parm[4];
   *min=parm[5];
   *sec=parm[6];

   if (validated!=NULL)
      *validated=parm[7];

   return(RCL_ERR_NONE);
}

int rcl_mode_set(int addr, const char* mode)
/*
 * Sets the S2 recorder mode, which determines the user data rate and the
 * number/configuration of user data channels.
 * 'mode' is a string containing the mode designator. The following modes are
 *        presently recognized with the RadioAstron User Interface Card.
 *        RadioAstron modes:
 *           I-2-2, I-4-1, I-4-2, I-8-1, I-8-2,
 *           II-2-1, II-2-2, II-4-1, II-4-2, II-8-1,
 *           IV-2-1, IV-2-2, IV-4-1.
 *        S2 modes:
 *           4-4, 4-8, 4-16, 8-2, 8-4, 8-8, 8-16,
 *           16-1, 16-2, 16-4, 16-8, 32-1, 32-2, 32-4,
 *           4i8, 4p8, 8i4, 8p8, 8i8, 16i4, 16i8, 16p8.
 *        Test modes:
 *           c1test4, c1test8, c1test16,
 *           c2test4, c2test8, c2test16,
 *           diag4, diag8, diag16.
 *
 * Note: The timeout used below is fairly long (3 sec) because mode setting
 *       takes longer than most commands, about 2 seconds.
 * Return value is local or remote error code.
 */
{
   int err;
   int l;

   /* ensure parameter string is not too long */
   l=strlen(mode);
   if (l>=RCL_MAXSTRLEN_MODE)
      return(RCL_ERR_BADLEN);

   err=rcl_simple_cmd(addr,RCL_CMD_MODE_SET,mode,l+1,3000/*timeout*/);

   return(err);
}

int rcl_mode_read(int addr, char* mode)
/*
 * Reads the current S2 recorder mode, which determines the user data rate and
 * the number/configuration of user data channels.
 * 'mode' returns the S2 mode string. At least RCL_MAXSTRLEN_MODE bytes of
 *        space must be available.
 * An error will be returned (S2 error code ERR_ILMODE) if for some reason
 * such as a hardware fault the S2 is not currently set to a valid mode.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_MODE_READ,NULL,0,&resp_code,
                       mode,RCL_MAXSTRLEN_MODE,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_MODE)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_tapeid_set(int addr, const char* tapeid)
/*
 * Sets the tape ID to be recorded. 
 * 'tapeid' is a string containing the tape ID, up to 20 characters long
 *          plus NULL terminator. Avoid using unprintable characters.
 * Return value is local or remote error code.
 */
{
   int err;
   int l;

   /* ensure parameter string is not too long */
   l=strlen(tapeid);
   if (l>=RCL_MAXSTRLEN_TAPEID)
      return(RCL_ERR_BADLEN);

   err=rcl_simple_cmd(addr,RCL_CMD_TAPEID_SET,tapeid,l+1,RCL_TIMEOUT);

   return(err);
}

int rcl_tapeid_read(int addr, char* tapeid)
/*
 * Reads the current record tape ID, as set using rcl_tapeid_set().
 * 'tapeid' returns the tape ID. At least RCL_MAXSTRLEN_TAPEID bytes of space
 *          must be available, including the terminating NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_TAPEID_READ,NULL,0,&resp_code,
                       tapeid,RCL_MAXSTRLEN_TAPEID,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TAPEID)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_tapeid_read_pb(int addr, char* tapeid)
/*
 * Reads the playback tape ID. The S2 must currently be playing back properly
 * recorded tapes and all individual tapes must contain the same tape ID value
 * (this should automatically be true if the tapes are aligned, and may or
 * may not be true if they are not).
 * 'tapeid' returns the tape ID. At least RCL_MAXSTRLEN_TAPEID bytes of space
 *          must be available
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_TAPEID_READ_PB,NULL,0,&resp_code,
                       tapeid,RCL_MAXSTRLEN_TAPEID,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TAPEID)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_user_info_set(int addr, int fieldnum, ibool label, 
                      const char* user_info)
/*
 * Sets one of the four user-info fields to be recorded, or sets a field's
 * label.
 * 'fieldnum' is the field number to set from 1 to 4.
 * 'label' indicates that the label should be set if TRUE, or the field itself
 *         if FALSE.
 * 'user_info' is a string containing the user info or label. Maximum length
 *             depends on the field number and label flag:
 *             Field 1: 16 chars
 *             Field 2: 16 chars
 *             Field 3: 32 chars
 *             Field 4: 48 chars
 *             Labels 1-4: 16 chars
 *             (consult the latest RCL specification to confirm these values).
 * Return value is local or remote error code.
 */
{
   int err;
   int l;
   char data[103];

   /* ensure parameter string is not longer than maximum (S2 may impose
        further length restrictions) */
   l=strlen(user_info);
   if (l>=RCL_MAXSTRLEN_USER_INFO)
      return(RCL_ERR_BADLEN);

   data[0]=fieldnum;
   data[1]=(label!=0);
   strcpy(data+2,user_info);

   err=rcl_simple_cmd(addr,RCL_CMD_USER_INFO_SET,data,l+3,RCL_TIMEOUT);

   return(err);
}

int rcl_user_info_read(int addr, int fieldnum, ibool label, char* user_info)
/*
 * Reads one of the four record user-info fields or labels, as set using
 * rcl_user_info_set().
 * 'fieldnum' is the field number to read from 1 to 4.
 * 'label' indicates that the label should be read if TRUE, or the field itself
 *         if FALSE.
 * 'user_info' returns the user info field or label. At least 
 *             RCL_MAXSTRLEN_USER_INFO bytes of space should be available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   data[0]=fieldnum;
   data[1]=(label!=0);

   err=rcl_general_cmd(addr,RCL_CMD_USER_INFO_READ,data,2,&resp_code,user_info,
                         RCL_MAXSTRLEN_USER_INFO,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_USER_INFO)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_user_info_read_pb(int addr, int fieldnum, ibool label, char* user_info)
/*
 * Reads one of the four playback user-info fields or labels. The S2 must
 * currently be playing back properly recorded tapes and all individual tapes
 * must contain the same user info value (this should automatically be true
 * if the tapes are aligned, and may or may not be true if they are not).
 * 'fieldnum' is the field number to read from 1 to 4.
 * 'label' indicates that the label should be read if TRUE, or the field itself
 *         if FALSE.
 * 'user_info' returns the user info field or label. At least 
 *             RCL_MAXSTRLEN_USER_INFO bytes of space should be available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   data[0]=fieldnum;
   data[1]=(label!=0);

   err=rcl_general_cmd(addr,RCL_CMD_USER_INFO_READ_PB,data,2,&resp_code,user_info,
                         RCL_MAXSTRLEN_USER_INFO,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_USER_INFO)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_user_dv_set(int addr, ibool user_dv, ibool pb_enable)
/*
 * Sets the value of the record user data-valid (DV) flag. This flag is
 * recorded continuously on the S2 auxiliary data channel and recovered at
 * playback time, where it is used to invalidate data if FALSE. This facility
 * provides a way to indicate at record time that invalid data is being
 * recorded, e.g. the telescope is slewing or off source. The 'pb_enable' flag
 * controls a playback option to ignore the user DV, so that data incorrectly
 * marked invalid at record time can still be processed.
 * 'user_dv' indicates data is valid if TRUE, or invalid if FALSE.
 * 'pb_enable' causes user DV to be recognized on playback if TRUE, or ignored
 *             if FALSE.
 * Return value is local or remote error code.
 */
{
   int err;
   char data[2];

   data[0]=(user_dv!=0);
   data[1]=(pb_enable!=0);

   err=rcl_simple_cmd(addr,RCL_CMD_USER_DV_SET,data,2,RCL_TIMEOUT);

   return(err);
}

int rcl_user_dv_read(int addr, ibool* user_dv, ibool* pb_enable)
/*
 * Reads the current setting of the record user data-valid (DV) flag and
 * the playback DV-enable flag, as set using rcl_user_dv_set().
 * 'user_dv' returns the record data-valid flag.
 * 'pb_enable' returns the playback DV-enable flag.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   err=rcl_general_cmd(addr,RCL_CMD_USER_DV_READ,NULL,0,&resp_code,
                       data,2/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_USER_DV)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=2)
      return(RCL_ERR_PKTLEN);

   *user_dv=data[0];
   *pb_enable=data[1];

   return(RCL_ERR_NONE);
}

int rcl_user_dv_read_pb(int addr, ibool* user_dv)
/*
 * Reads the playback user data-valid (DV) flag, as set by the user at record
 * time. The S2 must currently be playing back properly recorded tapes and all
 * individual tapes must indicate the same user DV value (this should
 * automatically be true if the tapes are aligned, and may or may not be true
 * if they are not).
 * 'user_dv' returns the playback user data-valid flag.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   err=rcl_general_cmd(addr,RCL_CMD_USER_DV_READ_PB,NULL,0,&resp_code,
                       data,2/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_USER_DV)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=2)
      return(RCL_ERR_PKTLEN);

   /* second data byte of response is unused */
   *user_dv=data[0];

   return(RCL_ERR_NONE);
}

int rcl_group_set(int addr, int newgroup)
/*
 * Sets the transport group number. This selects which group of transports
 * should be used in modes that don't require all 8 transports. Groups are
 * numbered starting at 0 and there can be up to 8 different groups,
 * depending on the total data rate of the current mode. For example, in 
 * mode 16-2 there are 4 groups: transports 0-1 (group 0), transports 2-3
 * (group 1), transports 4-5 (group 2), and transports 6-7 (group 3).
 * In mode 16-1 there are 8 groups, and in mode 16-8 there is only 1 group.
 * 'newgroup' is the new desired group number, 0-7. Actual upper limit may
 *            be 0, 1, 3 or 7 depending on the current S2 mode.
 * Return value is local or remote error code.
 */
{
   int err;
   char data[1];

   /* basic range check (further checking done by S2) */
   if (newgroup<0 || newgroup>127)
      return(RCL_ERR_BADVAL);

   data[0]=newgroup;

   err=rcl_simple_cmd(addr,RCL_CMD_GROUP_SET,data,1,1500);

   return(err);
}

int rcl_group_read(int addr, int* group, int* num_groups)
/*
 * Reads the current transport group number as set using rcl_group_set().
 * Also indicates the total number of groups available in the current mode.
 * 'group' returns the current group number, 0-7.
 * 'num_groups' returns the number of groups available, 1-8.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   err=rcl_general_cmd(addr,RCL_CMD_GROUP_READ,NULL,0,&resp_code,
                       data,2/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_GROUP)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=2)
      return(RCL_ERR_PKTLEN);

   *group=data[0];
   *num_groups=data[1];

   return(RCL_ERR_NONE);
}

int rcl_tapeinfo_read_pb(int addr, unsigned char* table)
/*
 * Reads tape-related information during playback for each of the 8 individual
 * transports, including channel ID, tape ID, recorder mode, tape time, and
 * several other items. The S2 must currently be in playback, but need not be
 * aligned.
 * 'table' returns a large binary table of size RCL_TAPEINFO_LEN. Each
 *         transport's information occupies one "row" in the table of length
 *         (RCL_TAPEINFO_LEN/8). The format is the same as returned by the
 *         raw data portion of the RCL response, so see the description of the
 *         RESP_TAPEINFO response and TAPEINFO_READ_PB command in the User's
 *         Manual (Appendix A) for further details.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr, RCL_CMD_TAPEINFO_READ_PB, NULL, 0, &resp_code,
                     (char*)table, RCL_TAPEINFO_LEN, &resp_length, RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TAPEINFO)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=RCL_TAPEINFO_LEN)
      return(RCL_ERR_PKTLEN);

   return(RCL_ERR_NONE);
}

int rcl_delay_set(int addr, ibool relative, long int nanosec)
/*
 * Sets the S2 station delay in absolute or relative terms. This can be
 * used to implement clock offsets or corrections during record and 
 * delay tracking during playback (if System Clock PLL mode is '1hz').
 * 'relative' TRUE indicates a relative delay setting, FALSE indicates an
 *            absolute setting.
 * 'nanosec' is the signed delay value in nanoseconds. Allowed range 
 *           is -500000000 to +(500000000-1bit) (abs),
 *           -(1000000000-1bit) to +(1000000000-1bit) (rel).
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[5];

   /* Assemble packet data */
   parm[0]=(relative!=0);

   parm[1]=(nanosec>>24) & 0xff;
   parm[2]=(nanosec>>16) & 0xff;
   parm[3]=(nanosec>>8) & 0xff;
   parm[4]=nanosec & 0xff;

   err=rcl_simple_cmd(addr,RCL_CMD_DELAY_SET,(char*)parm,5,4000/*timeout*/);

   return(err);
}

int rcl_delay_read(int addr, long int* nanosec)
/*
 * Reads the S2 station delay setting from the last rcl_delay_set() call.
 * This is not necessarily the same as the station delay measurement returned
 * by rcl_delaym_read().
 * 'nanosec' returns the signed delay value in nanoseconds. Possible range 
 *           is -500000000 to +(500000000-1bit).
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char parm[4];
   
   err=rcl_general_cmd(addr,RCL_CMD_DELAY_READ,NULL,0,&resp_code,
                       (char*)parm,4/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_DELAY)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=4)
      return(RCL_ERR_PKTLEN);

   /* Assemble bytes to make long int. Note: parm[] must be unsigned for
        following to work */
   *nanosec=((long int)parm[0]<<24) | ((long int)parm[1]<<16)
             | ((long int)parm[2]<<8) | (long int)parm[3];

   return(RCL_ERR_NONE);
}

int rcl_delaym_read(int addr, long int* nanosec)
/*
 * Reads the current S2 station delay measurement.
 * 'nanosec' returns the signed delay measurement in nanoseconds. Possible
 *           range is -500000000 to +(500000000-1bit).
 * Return value is local or remote error code. If the S2 user external 1 Hz
 * reference is not present, ERR_NOU1HZ will be returned.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char parm[4];
   
   err=rcl_general_cmd(addr,RCL_CMD_DELAYM_READ,NULL,0,&resp_code,
                       (char*)parm,4/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_DELAY)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=4)
      return(RCL_ERR_PKTLEN);

   /* Assemble bytes to make long int. Note: parm[] must be unsigned for
        following to work */
   *nanosec=((long int)parm[0]<<24) | ((long int)parm[1]<<16)
             | ((long int)parm[2]<<8) | (long int)parm[3];

   return(RCL_ERR_NONE);
}

int rcl_barrelroll_set(int addr, ibool barrelroll)
/*
 * Turns barrel-roll on or off. When on, barrel-roll rotates user data over
 * all active transports, and un-rotates on playback, so that the possible
 * effect of a marginal transport is averaged over all channels.
 * 'barrelroll' indicates barrel roll should be 'on' if TRUE, or 'off' if FALSE.
 * Return value is local or remote error code.
 */
{
   int err;
   char data[1];

   data[0]=(barrelroll!=0);

   err=rcl_simple_cmd(addr,RCL_CMD_BARRELROLL_SET,data,1,RCL_TIMEOUT);

   return(err);
}

int rcl_barrelroll_read(int addr, ibool* barrelroll)
/*
 * Reads the current barrel-roll setting, as set using rcl_barrelroll_set().
 * 'barrelroll' returns the current barrel-roll setting, TRUE meaning 'on'
 *              and FALSE meaning 'off'.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[1];

   err=rcl_general_cmd(addr,RCL_CMD_BARRELROLL_READ,NULL,0,&resp_code,
                       data,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_BARRELROLL)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *barrelroll=data[0];

   return(RCL_ERR_NONE);
}

int rcl_errmes(int addr, long int error)
/*
 * This command is used to synchronize the S2 recorder's playback rate
 * when the system-clock PLL is in errmes mode. 'error' indicates the
 * difference between the actual playback tape position and the desired
 * position as a number of bits (data samples) at the current user channel
 * data rate. In practice, this is the relative distance between the
 * center of the correlator's internal data FIFO and the read pointer.
 * If the sign is positive then the FIFO read pointer is between center
 * and overflow. If the sign is negative then the pointer is between
 * center and underflow. When the SC PLL is in errmes mode, rcl_errmes()
 * should be called by the external control computer about once per second.
 * (occasionally missing one is not serious). The time between taking the
 * FIFO error measurement and transmitting the commmand should be kept as
 * short as possible for optimum PLL performance.
 * 'error' is a 32-bit signed integer indicating the FIFO error in samples
 *         at the current user channel data rate.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[4];

   /* Assemble packet data */
   parm[0]=(error>>24) & 0xff;
   parm[1]=(error>>16) & 0xff;
   parm[2]=(error>>8) & 0xff;
   parm[3]=error & 0xff;

   err=rcl_simple_cmd(addr,RCL_CMD_ERRMES,(char*)parm,4,RCL_TIMEOUT);

   return(err);
}

int rcl_align_abs(int addr, int year, int day, int hour, int min, int sec,
                  long int nanosec)
/*
 * Performs absolute playback tape alignment. Works by slewing the transports
 * and (if necessary) adjusting the station delay setting. Do not use this
 * for small playback delay adjustments (less than about 100 microseconds),
 * use rcl_delay_set() instead.
 * Caller should synchronize to the 1 Hz tick being output by the S2
 * (S-1 Hz pb), i.e. send the command immediately following a tick.
 * See also rcl_align_rel() etc. for alternate interfaces to this command.
 * 'year' is the absolute year number (must be greater than 1900). If passed
 *        as 0, the appropriate year will be inferred.
 * 'day' is the absolute day number (1 to 365, 1 to 366 for leap years).
 *       If 'day' is passed as 1 *and* 'year' is passed as 0, the appropriate
 *       day will be inferred.
 * 'hour' is the hour from 0 to 23.
 * 'min' is the minute from 0 to 59.
 * 'sec' is the second from 0 to 59.
 * 'nanosec' is the fractional seconds portion in nanoseconds from 0 to 
 *           999999999.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[12];

   /* basic range check (further checking done by S2) */
   if ((year<1901 && year!=0) || day<1 || day>366 || hour<0 || hour>23
         || min<0 || min>59 || sec<0 || sec>59
         || nanosec<0 || nanosec>999999999L)  {
      return(RCL_ERR_BADVAL);
   }

   parm[0]=0;         /* align type code: absolute alignment */
   parm[1]=(year>>8) & 0xff;
   parm[2]=year & 0xff;
   parm[3]=(day>>8) & 0xff;
   parm[4]=day & 0xff;
   parm[5]=hour;
   parm[6]=min;
   parm[7]=sec;
   parm[8]=(nanosec>>24) & 0xff;
   parm[9]=(nanosec>>16) & 0xff;
   parm[10]=(nanosec>>8) & 0xff;
   parm[11]=nanosec & 0xff;

   err=rcl_simple_cmd(addr,RCL_CMD_ALIGN,(char*)parm,12,RCL_TIMEOUT);

   return(err);
}

int rcl_align_rel(int addr, ibool negative, int hour, int min, int sec,
                  long int nanosec)
/*
 * Performs relative playback tape alignment. Works by slewing the transports
 * and (if necessary) adjusting the station delay setting. Do not use this
 * for small playback delay adjustments (less than about 100 microseconds),
 * use rcl_delay_set() instead.
 * See also rcl_align_abs() etc. for alternate interfaces to this command.
 * Unlike rcl_align_abs(), no synchronization is needed when calling this
 * routine.
 * 'negative' TRUE means move backward in time, FALSE means move forward
 *            in time.
 * 'hour' is the number of hours from 0 to 23.
 * 'min' is the number of minutes from 0 to 59.
 * 'sec' is the number of seconds from 0 to 59.
 * 'nanosec' is the fractional seconds portion in nanoseconds from 0 to 
 *           999999999.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[9];

   /* basic range check (further checking done by S2) */
   if (hour<0 || hour>23 || min<0 || min>59 || sec<0 || sec>59
         || nanosec<0 || nanosec>999999999L)  {
      return(RCL_ERR_BADVAL);
   }

   parm[0]=1;                  /* align type code: relative alignment */
   parm[1]=(negative!=0);      /* sign */
   parm[2]=hour;
   parm[3]=min;
   parm[4]=sec;
   parm[5]=(nanosec>>24) & 0xff;
   parm[6]=(nanosec>>16) & 0xff;
   parm[7]=(nanosec>>8) & 0xff;
   parm[8]=nanosec & 0xff;

   err=rcl_simple_cmd(addr,RCL_CMD_ALIGN,(char*)parm,9,RCL_TIMEOUT);

   return(err);
}

int rcl_align_realign(int addr)
/*
 * Re-aligns the tapes to the previously chosen reference time should one
 * or more transports become un-aligned. This is normally done
 * automatically by the S2's regular playback monitoring, but a way to
 * initiate this manually may sometimes be useful following a ``fatal''
 * align error (STAT_ALIGNFAIL), in which case no further automatic attempts
 * are made to re-align.
 * See also rcl_align_abs() etc. for alternate interfaces to this command.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[1];

   parm[0]=2;                  /* align type code: re-align */

   err=rcl_simple_cmd(addr,RCL_CMD_ALIGN,(char*)parm,1,RCL_TIMEOUT);

   return(err);
}

int rcl_align_selfalign(int addr)
/*
 * Aligns the transports to each other by choosing one of them as a reference.
 * This may either be the earliest transport, latest transport, or the one
 * with the middle tape time, depending on the setting of the 'selfaligntarg'
 * defaults file parameter. This is known as "self-alignment", and is the type
 * of alignment normally performed automatically each time playback starts.
 * Self-alignment does not usually need to be initiated manually, but a way
 * to do this may sometimes be useful following a fatal align error
 * (STAT_ALIGNFAIL), in which case no further automatic attempts are made to
 * re-align. The defaults file parameter 'selfaligntime' controls the maximum
 * time difference allowed between the target transport and the other transports
 * during self-alignment.
 * See also rcl_align_abs() etc. for alternate interfaces to this command.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[1];

   parm[0]=3;                  /* align type code: self-align */

   err=rcl_simple_cmd(addr,RCL_CMD_ALIGN,(char*)parm,1,RCL_TIMEOUT);

   return(err);
}

int rcl_position_set(int addr, int code, long int position)
/*
 * Initiates tape positioning on all currently selected transports.
 * The same position value is used for all transports. Use rcl_state_read()
 * to test completion.
 * 'code' is the type of positioning to perform (normally 0),
 *        0 == absolute positioning,
 *        1 == relative positioning,
 *        2 == position preset.
 * 'position' is the desired position in seconds of recorded tape since BOT
 *            for absolute positioning/position preset, or the signed position
 *            offset for  relative positioning. Valid range is 0 to 43199 sec
 *            (i.e. up to 12 hours) for absolute positioning or position
 *            preset, or -43199 to 43199 seconds for relative positioning.
 *            RCL_POS_UNKNOWN is allowed for position preset.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[6];

   /* basic range checks (further checking done by S2) */
   if (code<0 || code>2)  {
      return(RCL_ERR_BADVAL);
   }

   parm[0]=code;                  /* positioning type code */
   parm[1]=1;                     /* one position being specified */
   parm[2]=(position>>24) & 0xff;
   parm[3]=(position>>16) & 0xff;
   parm[4]=(position>>8) & 0xff;
   parm[5]=position & 0xff;

   err=rcl_simple_cmd(addr,RCL_CMD_POSITION_SET,(char*)parm,6,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_position_set_ind(int addr, int code, long int position[])
/*
 * Initiates tape positioning on currently selected transports. Individual
 * position values may be specified for each transport. The desired position
 * value for each currently selected transport should be passed in the
 * position[] array. Entries corresponding to unselected transports are
 * ignored. To determine which transports are currently selected, use
 * rcl_position_read_ind() (unselected transports will return RCL_POS_UNSEL).
 * Use rcl_state_read() to test completion.
 * 'code' is the type of positioning to perform,
 *        0 == absolute positioning,
 *        1 == relative positioning,
 *        2 == position preset.
 * 'position' is an array of 8 position values, one for each transport.
 *            Array indices correspond to transport addresses. Pass the 
 *            desired position in seconds since BOT for absolute
 *            positioning/position preset, or the signed position offset for 
 *            relative positioning. Valid range is 0 to 43199 seconds
 *            (i.e. up to 12 hours) for absolute positioning or position
 *            preset, or -43199 to 43199 seconds for relative positioning.
 *            Use RCL_POS_UNSEL for transports which are not currently 
 *            selected. RCL_POS_UNKNOWN is allowed for position preset.
 * Return value is local or remote error code.
 */
{
   int err;
   int tran;                  /* transport loop index */
   unsigned char parm[34];

   /* basic range checks (further checking done by S2) */
   if (code<0 || code>2)  {
      return(RCL_ERR_BADVAL);
   }

   parm[0]=code;                  /* positioning type code */
   parm[1]=8;                     /* eight positions being specified */

   for (tran=0; tran<8; tran++)  {
      parm[tran*4+2]=(position[tran]>>24) & 0xff;
      parm[tran*4+3]=(position[tran]>>16) & 0xff;
      parm[tran*4+4]=(position[tran]>>8) & 0xff;
      parm[tran*4+5]=position[tran] & 0xff;
   }

   err=rcl_simple_cmd(addr,RCL_CMD_POSITION_SET,(char*)parm,34,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_position_reestablish(int addr)
/*
 * Re-calculates the current tape position. The tapes are rewound and then
 * automatically returned to their original position, as computed from the
 * distance covered during rewind, and any "unknown" positions are marked
 * "known". This may be useful following a power failure when the S2 has lost
 * track of the current tape position, or when non-rewound tapes are inserted.
 * It can also be used to accurately re-determine the current position if
 * cumulative errors have built up in the position measurement after a long
 * period of repetitive tape activity.
 * Return value is local or remote error code.
 */
{
   int err;
   unsigned char parm[1];

   parm[0]=3;                     /* position re-establish type code */

   err=rcl_simple_cmd(addr,RCL_CMD_POSITION_SET,(char*)parm,1,RCL_TIMEOUT_TC);

   return(err);
}

int rcl_position_read(int addr, long int* position, long int* posvar)
/*
 * Reads the current overall tape position, which is defined as the mid-point
 * of the individual transport tape positions. Only the transports selected
 * under the current mode and group settings are counted in the overall
 * position. A linear variance value is provided which indicates the maximum
 * absolute deviation of any individual tape position from the mid-point.
 * If the variance is small enough (depending on the user's application),
 * then it will be possible to later return to the same position using only
 * rcl_position_set() and the overall position value. If for some reason 
 * the variance is large, it may be necessary to obtain the individual transport
 * tape positions using rcl_position_read_ind() to be able to subsequently
 * return to exactly the same position with rcl_position_set_ind().
 * 'position' returns the overall tape position, expressed as a number of 
 *            seconds of recorded tape since BOT. The value RCL_POS_UNKNOWN
 *            is returned if any of the individual transport positions is
 *            unknown.
 * 'posvar' returns the linear position variance, expressed as a signed number
 *          of seconds. The earliest individual tape position will be (approx.)
 *          position + posvar, and the latest individual position will be
 *          (approx.) position - posvar. The value RCL_POS_UNKNOWN is returned
 *          if any of the individual transport positions is unknown.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char parm;               /* data portion of request packet */
   unsigned char rdata[9];  /* data portion of reply packet */


   parm=0;              /* request overall tape position */
   err=rcl_general_cmd(addr,RCL_CMD_POSITION_READ,&parm,1,&resp_code,
                       (char*)rdata,9/*maxlength*/, &resp_length, RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_POSITION)
      return(RCL_ERR_PKTUNEX);

   /* Check if got right response length */
   if (resp_length!=9)
      return(RCL_ERR_PKTLEN);

   /* Check if got right packet type code */
   if (rdata[0]!=0)
      return(RCL_ERR_PKTFORMAT);

   *position=((long int)rdata[1]<<24)
              | ((long int)rdata[2]<<16)
              | ((long int)rdata[3]<<8)
              | (long int)rdata[4];

   *posvar=  ((long int)rdata[5]<<24)
              | ((long int)rdata[6]<<16)
              | ((long int)rdata[7]<<8)
              | (long int)rdata[8];

   return(RCL_ERR_NONE);
}

int rcl_position_read_ind(int addr, int* num_entries, long int position[])
/*
 * Reads the current tape position of all 8 individual transports.
 * 'num_entries' returns the number of entries in the list, always 8.
 * 'position' returns an array of 8 individual tape positions. Position is
 *            expressed as a number of seconds of recorded tape since BOT.
 *            The value RCL_POS_UNKNOWN is returned if the position is unknown,
 *            or there is no tape in the transport, or the transport is dead.
 *            The value RCL_POS_UNSEL is returned if the transport is not
 *            selected under the current mode and group settings.
 * Return value is local or remote error code.
 */
{
   int err;
   int tran;                /* transport loop index */
   int resp_code;
   int resp_length;
   char parm;               /* data portion of request packet */
   unsigned char rdata[34]; /* data portion of reply packet */


   parm=1;              /* request individual tape positions */
   err=rcl_general_cmd(addr,RCL_CMD_POSITION_READ,&parm,1,&resp_code,
                       (char*)rdata,34/*maxlength*/, &resp_length, RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_POSITION)
      return(RCL_ERR_PKTUNEX);

   /* Check if got right response length */
   if (resp_length!=34)
      return(RCL_ERR_PKTLEN);

   /* Check if got right packet type code */
   if (rdata[0]!=1)
      return(RCL_ERR_PKTFORMAT);

   *num_entries=rdata[1];

   for (tran=0; tran<*num_entries; tran++)  {
      position[tran]=((long int)rdata[tran*4+2]<<24)
                       | ((long int)rdata[tran*4+3]<<16)
                       | ((long int)rdata[tran*4+4]<<8)
                       | (long int)rdata[tran*4+5];
   }

   return(RCL_ERR_NONE);
}

int rcl_esterr_read(int addr, ibool order_chantran, int* num_entries,
                    char* esterr_list)
/*
 * Reads the list of S2 estimated error rates.
 * 'order_chantran' specifies the order of the list: TRUE == by channel,
 *                  FALSE == by transport (normally FALSE).
 * 'num_entries' returns the number of entries in the list.
 * 'esterr_list' returns 'num_entries' strings, each terminated by a NULL,
 *               one after the other. There must be at least 
 *               8*RCL_MAXSTRLEN_ESTERR bytes of space available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char parm;
   char rdata[8*RCL_MAXSTRLEN_ESTERR + 1]; /* data portion of reply packet */


   parm=(order_chantran!=0);       /* convert data size */
   err=rcl_general_cmd(addr,RCL_CMD_ESTERR_READ,&parm,1,&resp_code,rdata,
                       8*RCL_MAXSTRLEN_ESTERR+1/*maxlength*/, &resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_ESTERR)
      return(RCL_ERR_PKTUNEX);

   /* Check if got reasonable response length */
   if (resp_length<1)
      return(RCL_ERR_PKTLEN);

   *num_entries=rdata[0];
   memcpy(esterr_list,rdata+1,resp_length-1);

   return(RCL_ERR_NONE);
}

int rcl_pdv_read(int addr, ibool order_chantran, int* num_entries,
                 char* pdv_list)
/*
 * Reads the list of S2 percent data valid values.
 * 'order_chantran' specifies the order of the list: TRUE == by channel,
 *                  FALSE == by transport (normally FALSE).
 * 'num_entries' returns the number of entries in the list.
 * 'pdv_list' returns 'num_entries' strings, each terminated by a NULL,
 *               one after the other. There must be at least 
 *               8*RCL_MAXSTRLEN_PDV bytes of space available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char parm;
   char rdata[8*RCL_MAXSTRLEN_PDV + 1]; /* data portion of reply packet */


   parm=(order_chantran!=0);       /* convert data size */
   err=rcl_general_cmd(addr,RCL_CMD_PDV_READ,&parm,1,&resp_code,rdata,
                       8*RCL_MAXSTRLEN_PDV+1/*maxlength*/, &resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_PDV)
      return(RCL_ERR_PKTUNEX);

   /* Check if got reasonable response length */
   if (resp_length<1)
      return(RCL_ERR_PKTLEN);

   *num_entries=rdata[0];
   memcpy(pdv_list,rdata+1,resp_length-1);

   return(RCL_ERR_NONE);
}

int rcl_scpll_mode_set(int addr, int scpll_mode)
/*
 * Sets the System Clock PLL mode.
 * 'scpll_mode' is the numeric SC PLL mode code to set, one of RCL_SCPLL_MODE_*.
 * Return value is local or remote error code.
 */
{
   int err;
   signed char parm;

   /* basic range check (further checking done by S2) */
   if (scpll_mode<-128 || scpll_mode>127)
      return(RCL_ERR_BADVAL);

   parm=scpll_mode;        /* convert data size */
   err=rcl_simple_cmd(addr,RCL_CMD_SCPLL_MODE_SET,(char*)&parm,1,RCL_TIMEOUT);

   return(err);
}

int rcl_scpll_mode_read(int addr, int* scpll_mode)
/*
 * Reads the current System Clock PLL mode.
 * 'scpll_mode' returns the numeric SC PLL mode code, one of RCL_SCPLL_MODE_*.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char rcl_scpll_mode;
   
   err=rcl_general_cmd(addr,RCL_CMD_SCPLL_MODE_READ,NULL,0,&resp_code,
                       &rcl_scpll_mode,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_SCPLL_MODE)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *scpll_mode=rcl_scpll_mode;

   return(RCL_ERR_NONE);
}

int rcl_tapetype_set(int addr, const char* tapetype)
/*
 * Sets the tape type. This indicates what type of tape is loaded in the S2
 * using the type codes 0 - 9 and A - Z as listed in the ``Tape'' chapter
 * of the S2 User's Manual. These single-character typecodes should be passed
 * as null-terminated strings of length 1. The tape type controls how much
 * write current should be used when recording. As new tape types are approved
 * software  upgrades will be provided to allow recognition of new type codes.
 * For unlisted tape types it is also possible to specify a 6-digit numeric
 * null-terminated string which indicates the LP and SLP write-current 
 * levels explicitly. For example, "100070" sets LP write current to 100 and
 * SLP write current to 70. The required 6-digit tape type strings will be
 * supplied by ISTS/SGL when new tape types are approved. Note that the tape
 * type reverts to the default value given in the defaults file when the S2
 * reboots. The rcl_tapetype_set() command is not allowed during record.
 */
{
   int err;
   int l;

   /* ensure parameter string is not too long */
   l=strlen(tapetype);
   if (l>=RCL_MAXSTRLEN_TAPETYPE)
      return(RCL_ERR_BADLEN);

   err=rcl_simple_cmd(addr,RCL_CMD_TAPETYPE_SET,tapetype,l+1,RCL_TIMEOUT);

   return(err);
}

int rcl_tapetype_read(int addr, char* tapetype)
/*
 * Reads the current tape type setting.
 * 'tapetype' returns the tape type as a null-terminated string. At least 
 *            RCL_MAXSTRLEN_TAPETYPE bytes of space must be available, 
 *            including the terminating NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_TAPETYPE_READ,NULL,0,&resp_code, tapetype,
                       RCL_MAXSTRLEN_TAPETYPE,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TAPETYPE)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_mk3_form_set(int addr, ibool mk3)
/*
 * Turns the S2 internal Mark III format generator on and off. When turned on,
 * the C2a cable output switches to Mk3-compatible mode.
 * 'mk3' indicates the Mk3 formatter should be 'on' if TRUE, or 'off' if FALSE.
 * Return value is local or remote error code.
 */
{
   int err;
   char data[1];

   data[0]=(mk3!=0);

   err=rcl_simple_cmd(addr,RCL_CMD_MK3_FORM_SET,data,1,5000);

   return(err);
}

int rcl_mk3_form_read(int addr, ibool* mk3)
/*
 * Reads the current Mark III formatter enable/disable state, as set using
 * rcl_mk3_form_set().
 * 'mk3' returns the current Mk3 formatter setting, TRUE meaning 'on'
 *       and FALSE meaning 'off'.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[1];

   err=rcl_general_cmd(addr,RCL_CMD_MK3_FORM_READ,NULL,0,&resp_code,
                       data,1/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_MK3_FORM)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   *mk3=data[0];

   return(RCL_ERR_NONE);
}

int rcl_transport_times(int addr, int* num_entries,
                        unsigned short serial[],
                        unsigned long tot_on_time[],
                        unsigned long tot_head_time[],
                        unsigned long head_use_time[],
                        unsigned long in_service_time[])
/*
 * Reads all 8 transports' total head-use time, total
 * power-on time, last service time and last head-change time.
 * 'num_entries' returns the number of entries in each array, always 8.
 * 'serial' returns each transport's serial number for identification.
 *          A value of 0 means the transport is dead.
 * 'tot_on_time' returns the total power-on time since manufacture for each
 *               transport in minutes. A value of 0 means "unknown".
 * 'tot_head_time' returns the total head-use time since manufacture for each
 *                 transport in minutes. A value of 0 means "unknown".
 * 'head_use_time' returns the active head use time since the last head
 *                 replacement for each transport in minutes.
 *                 This is to be zeroed whenever the head is replaced by 
 *                 entering the 'transport N service lasthead' console command.
 *                 A value of 0 means "unknown".
 * 'in_service_time' returns the active head use time since the last service
 *                   operation for each transport in minutes.
 *                   This is to be zeroed whenever the transport is serviced by
 *                   entering the 'transport N service lastserv' console
 *                   command. A value of 0 means "unknown".
 * Return value is local or remote error code.
 */
{
   int err;
   int tran;                /* transport loop index */
   int resp_code;
   int resp_length;
   unsigned char rdata[RCL_TRANSPORT_TIMES_LEN];
                            /* data portion of reply packet */
   int spacing;


   err=rcl_general_cmd(addr,RCL_CMD_TRANSPORT_TIMES,NULL,0,&resp_code,
                       (char*)rdata,RCL_TRANSPORT_TIMES_LEN/*maxlength*/,
                       &resp_length, RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_TRANSPORT_TIMES)
      return(RCL_ERR_PKTUNEX);

   /* Check if got right response length */
   if (resp_length!=RCL_TRANSPORT_TIMES_LEN)
      return(RCL_ERR_PKTLEN);

   *num_entries=rdata[0];

   spacing=18;
   for (tran=0; tran<*num_entries; tran++)  {
      serial[tran]=((unsigned short)rdata[tran*spacing+1]<<8)
                      | (unsigned short)rdata[tran*spacing+2];
      tot_on_time[tran]=((unsigned long)rdata[tran*spacing+3]<<24)
                      | ((unsigned long)rdata[tran*spacing+4]<<16)
                      | ((unsigned long)rdata[tran*spacing+5]<<8)
                      | (unsigned long)rdata[tran*spacing+6];
      tot_head_time[tran]=((unsigned long)rdata[tran*spacing+7]<<24)
                      | ((unsigned long)rdata[tran*spacing+8]<<16)
                      | ((unsigned long)rdata[tran*spacing+9]<<8)
                      | (unsigned long)rdata[tran*spacing+10];
      head_use_time[tran]=((unsigned long)rdata[tran*spacing+11]<<24)
                      | ((unsigned long)rdata[tran*spacing+12]<<16)
                      | ((unsigned long)rdata[tran*spacing+13]<<8)
                      | (unsigned long)rdata[tran*spacing+14];
      in_service_time[tran]=((unsigned long)rdata[tran*spacing+15]<<24)
                      | ((unsigned long)rdata[tran*spacing+16]<<16)
                      | ((unsigned long)rdata[tran*spacing+17]<<8)
                      | (unsigned long)rdata[tran*spacing+18];
   }

   return(RCL_ERR_NONE);
}

int rcl_station_info_read(int addr, int* station, long int* serialnum,
                          char* nickname)
/*
 * Reads S2 station-related information: station number, system serial
 * number, and system nickname.
 * 'station' returns the station number from 0 to 255.
 * 'serialnum' returns the system serial number from 0 to 65535.
 * 'nickname' returns the nickname. At least RCL_MAXSTRLEN_NICKNAME bytes of
 *            space must be available
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char rdata[RCL_MAXSTRLEN_NICKNAME+3];  /* data portion of reply */

   err=rcl_general_cmd(addr,RCL_CMD_STATION_INFO_READ,NULL,0,&resp_code,
                       (char*)rdata,RCL_MAXSTRLEN_NICKNAME+3,&resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_STATION_INFO)
      return(RCL_ERR_PKTUNEX);

   *station=(int)rdata[0];
   *serialnum=((long int)rdata[1]<<8)
              | (long int)rdata[2];
   strncpy(nickname,(char*)(rdata+3),RCL_MAXSTRLEN_NICKNAME);

   return(RCL_ERR_NONE);
}

int rcl_consolecmd(int addr, const char* command)
/*
 * Executes an arbitrary console command. There are some severe limitations.
 * First, no command output is returned except the error return code, so
 * commands which just display information are of no use. Second, it is up
 * to the caller to ensure that the chosen command is *guaranteed* to complete
 * in less than 3 seconds. For example, during playback, 'setup 0 transport 5'
 * is fine but 'setup transport 5' is bad because it can take more than 3
 * seconds to decode channel information from transport 5. Commands such as
 * 'form berc' are way out --- you will permanently hang the RCL and probably
 * eventually crash the S2 software. Any command already supported by the RCL
 * should not be executed with rcl_consolecmd(), even apparently innocuous
 * commands such as 'play' or 'stop'. Remember: use this feature at your
 * own risk.
 * 'command' is a string containing the console command, up to 255 characters
 *           long (not incl. NULL terminator).
 * Return value is local or remote error code.
 */
{
   int err;
   int l;

   /* ensure parameter string is not too long */
   l=strlen(command);
   if (l>=RCL_MAXSTRLEN_CONSOLECMD)
      return(RCL_ERR_BADLEN);

   err=rcl_simple_cmd(addr,RCL_CMD_CONSOLECMD,command,l+1,3000/*timeout*/);

   return(err);
}

int rcl_postime_read(int addr, int tran, int* year, int* day, int* hour,
                     int* min, int* sec, int* frame, long int* position)
/*
 * **This command is for SGL internal use when running tests to check and
 * calibrate the internal transport positioning software. It is not documented
 * the RCL protocol spec.** rcl_postime_read() returns both
 * the playback tape time and tape position for a particular transport.
 * When test tapes are recorded in such a way that the tape time matches the
 * tape position, this can be used to determine cumulative position sensing
 * errors. The response from the S2 is sent immediately (unlike
 * rcl_time_read_pb() where the command is synchronized to the 1 Hz tick).
 * If the playback tape time is unknown or invalid, the parameters 'year',
 * 'day', 'hour', 'min', 'sec', 'frame' will all return 0. If the transport
 * position is unknown, 'position' will return RCL_POS_UNKNOWN.
 * 'tran' is the address of the transport to read, from 0 to 7.
 * 'year' returns the absolute year number.
 * 'day' returns the absolute day number (1 to 365, 1 to 366 for leap years).
 * 'hour' returns the hour from 0 to 23.
 * 'min' returns the minute from 0 to 59.
 * 'sec' returns the second from 0 to 59.
 * 'frame' returns the frame number from 0 to 63.
 * 'position' returns the tape position for transport 'tran', expressed as a
 *            number of frames of recorded tape since BOT. The value
 *            RCL_POS_UNKNOWN is returned if the position is unknown.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   unsigned char parm[12];
   char data[1];

   /* basic range check (further checking done by S2) */
   if (tran<0 || tran>127)
      return(RCL_ERR_BADVAL);

   data[0]=tran;

   err=rcl_general_cmd(addr,RCL_CMD_POSTIME_READ,data,1,&resp_code,
                       (char*)parm,12/*maxlength*/,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_POSTIME)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=12)
      return(RCL_ERR_PKTLEN);

   /* Note: parm[] must be unsigned for following to work */
   *year=((int)parm[0]<<8) | (int)parm[1];
   *day=((int)parm[2]<<8) | (int)parm[3];
   *hour=parm[4];
   *min=parm[5];
   *sec=parm[6];
   *frame=parm[7];

   *position=((long int)parm[8]<<24)
              | ((long int)parm[9]<<16)
              | ((long int)parm[10]<<8)
              | (long int)parm[11];

   return(RCL_ERR_NONE);
}

int rcl_status(int addr, int* summary, int* num_entries,
               unsigned char* status_list)
/*
 * Reads the current S2 system status (brief report). This should be polled
 * every few seconds, since status conditions accumulate in-between reads
 * and will come out all at once on the next read.
 * Status entries are returned in order of severity from most to least severe,
 * which means in order of increasing status code number, not in order of 
 * occurrence. Reading S2 status with rcl_status() causes all clear-on-read
 * status entries to be cleared, the same as if 'status reset' was typed on
 * the console for the console status. These entries will not appear in
 * the next rcl_status() request unless the condition they represent has
 * occurred again. Non-clear-on-read status entries will persist until the
 * condition they represent has gone away. Note that RCL status is not
 * necessarily the same as the console status window, and is not affected by
 * console commands such as 'status reset'. Similarly, reading the RCL status
 * will not affect the console status window.
 * 'summary' returns a summary word whose bits indicate whether there are
 *           any error conditions (RCL_STATBIT_ERROR) or any fatal error
 *           conditions (RCL_STATBIT_FATAL), or any clear-on-read conditions
 *           (RCL_STATBIT_CLEAR).
 *           Use ((summary & RCL_STATBIT_ERROR)!=0) to check whether overall
 *           system status is OK.
 * 'num_entries' returns the number of status entries in 'status_list'.
 * 'status_list' returns one pair of bytes for each status entry. The first
 *               byte is the status code from 1 to RCL_STATCODE_MAX. The second
 *               byte is the type code as a bit mask, similar to 'summary'.
 *               Status entries are returned in order of severity (increasing
 *               status code numbers).
 *               At least RCL_STATUS_MAX*2 bytes of space should be available
 *               for the returned information.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char status[RCL_STATUS_MAX*2 + 2];

   err=rcl_general_cmd(addr,RCL_CMD_STATUS,NULL,0,&resp_code,status,
                       RCL_STATUS_MAX*2+2/*maxlength*/,&resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_STATUS)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length<2 || resp_length>RCL_STATUS_MAX*2+2)
      return(RCL_ERR_PKTLEN);

   *summary=status[0];
   *num_entries=status[1];
   memcpy(status_list,status+2,status[1]*2);
   
   return(RCL_ERR_NONE);
}

int rcl_status_detail(int addr, int stat_code, ibool reread,
                      ibool shortt, int* summary, int* num_entries,
                      unsigned char* status_det_list)
/*
 * Reads the S2 system status detailed report. This is typically done following
 * rcl_status() if unusual conditions are detected. This routine returns
 * additional information in the form of a 1-5 line descriptive message
 * for each status code. Only those status conditions returned for the last
 * rcl_status() call will be included unless the 'reread' parameter is TRUE.
 * A shorter version of the messages can be requested by passing 'shortt' as
 * TRUE. The short messages are the same as shown on the console and are
 * limited to 34 bytes (not incl. terminating NULL).
 * See also rcl_status_decode().
 * 'stat_code' is the specific status code to obtain detailed information for,
 *             from 1 to RCL_STATCODE_MAX. If that status condition is not
 *             active, no information will be returned ('num_entries' parameter
 *             will be 0). If 'stat_code' is specified as 0 then all active
 *             status conditions will be returned (up to a maximum of
 *             RCL_STATUS_MAX entries, in order of severity from most to
 *             least severe).
 * 'reread' FALSE indicates that only the status conditions from the last
 *          rcl_status() command should be returned. This should be the case
 *          whenever rcl_status_detail() is used to follow up results from
 *          rcl_status(). TRUE indicates that the S2 should re-read its system
 *          status, i.e. implicitly performs rcl_status() first. Pass TRUE
 *          when you want to use rcl_status_detail() by itself, without calling
 *          rcl_status() first.
 * 'shortt' should normally be passed as FALSE to obtain the regular RCL status
 *          messages. TRUE causes a shorter version of the status messages to be
 *          returned (max. 34 characters each, not incl. NULL). Note that the
 *          short messages are the same as the console status messages and
 *          don't have the mnemonic at the start.
 * 'summary' returns a summary word whose bits indicate whether there are
 *           any error conditions (RCL_STATBIT_ERROR) or any fatal error
 *           conditions (RCL_STATBIT_FATAL), or any clear-on-read conditions
 *           (RCL_STATBIT_CLEAR).
 *           Use ((summary & RCL_STATBIT_ERROR)!=0) to check whether overall
 *           system status is OK.
 * 'num_entries' returns the number of status entries in 'status_det_list'.
 *               When stat_code is non-zero this will be either 1 or 0.
 * 'status_det_list' returns a pair of bytes plus a variable-length
 *             null-terminated string for each status entry. The first byte is
 *             the status code from 1 to RCL_STATCODE_MAX and the second is
 *             the type code as a bit mask, similar to 'summary'. The string
 *             follows and can be up to RCL_MAXSTRLEN_STATUS_DECODE bytes long,
 *             including the NULL termination. The next status entry, if any,
 *             immediately follows the NULL. At least RCL_STATUS_DETAIL_MAXLEN
 *             total bytes of space should be available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[3];
   char status[RCL_STATUS_DETAIL_MAXLEN];

   /* basic range check (further checking done by S2) */
   if (stat_code<0 || stat_code>255)
      return(RCL_ERR_BADVAL);

   data[0]=stat_code;
   data[1]=(reread!=0);
   data[2]=(shortt!=0);
   err=rcl_general_cmd(addr,RCL_CMD_STATUS_DETAIL,data,3,&resp_code,status,
                       RCL_STATUS_DETAIL_MAXLEN/*maxlength*/,&resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_STATUS_DETAIL)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length<2 || resp_length>RCL_STATUS_DETAIL_MAXLEN)
      return(RCL_ERR_PKTLEN);

   *summary=status[0];
   *num_entries=status[1];
   memcpy(status_det_list,status+2,resp_length-2);
   
   return(RCL_ERR_NONE);
}

int rcl_status_decode(int addr, int stat_code, ibool shortt, char* stat_msg)
/*
 * Translate a numeric status code to text message. This is useful for
 * building a run-time translation table of status codes and mnemonics/messages.
 * For error reporting or logging purposes use rcl_status_detail() instead
 * since that routine includes occurrence-specific information such as channel
 * numbers in the messages, while this routine just fills in such changeable
 * information with "xxx". 
 * 'stat_code' is the status code to translate, in the range 0 to
 *             RCL_STATCODE_MAX.
 * 'shortt' TRUE causes the shorter version of the status message to be
 *          returned (max. 34 characters, not incl. NULL). Note that the
 *          short messages don't have the mnemonic at the start.
 * 'stat_msg' returns the status message. At least RCL_MAXSTRLEN_STATUS_DECODE
 *            bytes of space must be available. Any string substitutors in
 *            message are set to "xxx". The mnemonic can be extracted by 
 *            taking everything up to but not including the first colon ":".
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char data[2];

   /* basic range check (further checking done by S2) */
   if (stat_code<0 || stat_code>255)
      return(RCL_ERR_BADVAL);

   data[0]=stat_code;       /* convert data size */
   data[1]=(shortt!=0);
   err=rcl_general_cmd(addr,RCL_CMD_STATUS_DECODE,data,2,&resp_code,stat_msg,
                       RCL_MAXSTRLEN_STATUS_DECODE/*maxlength*/,&resp_length,
                       RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_STATUS_DECODE)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_error_decode(int addr, int err_code, char* err_msg)
/*
 * Translate a numeric error code to text message.
 * 'err_code' is the signed error code to translate, in the range -128 to 127.
 * 'err_msg' returns the error message. At least RCL_MAXSTRLEN_ERROR_DECODE
 *           bytes of space must be available.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   signed char parm;

   /* basic range check (further checking done by S2) */
   if (err_code<-128 || err_code>127)
      return(RCL_ERR_BADVAL);

   parm=err_code;       /* convert data size */
   err=rcl_general_cmd(addr,RCL_CMD_ERROR_DECODE,(char*)&parm,1,&resp_code,
                       err_msg,RCL_MAXSTRLEN_ERROR_DECODE/*maxlength*/,
                       &resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_ERROR_DECODE)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_diag(int addr, int type)
/*
 * Initiates S2 internal diagnostic sequences. Currently the
 * only diagnostic sequence which can be run here is self-test 1 (the power-on
 * self test). While self-test 1 is running most RCL commands which affect
 * tape motion or system switch settings are not allowed. Users should poll
 * S2 status to determine when the diagnostic test completes: STAT_DIAGIP
 * indicates that the test is in progress, STAT_DIAGDONE indicates that the
 * test completed successfully, and STAT_DIAGFAIL indicates that the test has
 * found a system fault or aborted due to an error.
 * 'type' is the type of diagnostic to run, must be 1 for self-test 1.
 * Return value is local or remote error code.
 */
{
   int err;
   char data[1];

   data[0]=type;

   err=rcl_simple_cmd(addr,RCL_CMD_DIAG,data,1,RCL_TIMEOUT);

   return(err);
}

int rcl_berdcb(int addr, int op_type, int chan, int meas_time,
               unsigned long* err_bits, unsigned long* tot_bits)
/*
 * Performs one of 3 types of statistical measurements on
 * a given data channel: Formatter bit-error rate, UI bit-error rate, and
 * UI DC-bias. All of these measurements can only be done on one channel
 * at a time. The FORM BER measurement performs a true bit-error rate
 * measurement on one 16 Mbit/s internal S2 data channel (0 - 7) by comparing
 * against the Formatter test vector sequence. The UI BER measurement performs
 * a true bit-error rate measurement on one user data channel (0 - 15) by
 * comparing against the UI test vector sequence. Both BER measurements
 * always count both detected and undetected errors (i.e. data validity flag are
 * ignored). In the case of FORM BER the formatter Test Vector Generator is
 * automatically turned on for the duration of the measurement if required.
 *     The UI DC-bias measurement counts the number of bits with value 1
 * in the specified user data channel (0<196>15). This is useful to determine
 * the ratio of 1-bits to 0-bits to check if data is reasonable. Note that both
 * the UI DC-bias and UI BER measurements are made on UI output data
 * (similar to the data at the C2a cable port). To make measurements of
 * UI input data (similar to the data at the C1 cable port) you should turn
 * UI feed-through mode on. Since there is currently no RCL command to set
 * UI feed-through, you will have to use the rcl_consolecmd() feature with the
 * console command strings ``uic feedthru on'' or ``uic feedthru off''.
 * 'op_type` is the desired operation type:
 *             1 == FORM BER measurement
 *             2 == UI BER measurement
 *             3 == UI DC-bias measurement
 * 'chan' is the internal data channel 0 through 7 for FORM BER, or
 *        user data channel 0 through 15 for UI BER and UI DC-bias.
 * 'meas_time' is the measurement time in seconds, recommended value 1 second,
 *             recommended maximum value 10 seconds. It is important to
 *             understand that **while the BERDCB measurement is in progress no
 *             other RCL commands are allowed**.
 * 'err_bits' returns the number of bits in error during the measurement
 *            interval in the case of FORM BER and UI BER, or the number of
 *            1-bits in the case of UI DC-bias. 
 * 'tot_bits' returns the total number of bits measured in the time interval.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char parms[3];           /* data portion of request packet */
   unsigned char rdata[8];  /* data portion of reply packet */


   /* basic range checks (further checking done by S2) */
   if (op_type<0 || op_type>255 || chan<0 || chan>255
         || meas_time<0 || meas_time>255)
      return(RCL_ERR_BADVAL);

   parms[0]=op_type;
   parms[1]=chan;
   parms[2]=meas_time;
   /* note that the timeout (in ms) depends on the measurement time! */
   err=rcl_general_cmd(addr,RCL_CMD_BERDCB,parms,3,&resp_code,
                       (char*)rdata,8/*maxlength*/, &resp_length, 
                       (meas_time+2)*1000);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_BERDCB)
      return(RCL_ERR_PKTUNEX);

   /* Check if got right response length */
   if (resp_length!=8)
      return(RCL_ERR_PKTLEN);

   *err_bits=((long int)rdata[0]<<24)
              | ((long int)rdata[1]<<16)
              | ((long int)rdata[2]<<8)
              | (long int)rdata[3];

   *tot_bits=  ((long int)rdata[4]<<24)
              | ((long int)rdata[5]<<16)
              | ((long int)rdata[6]<<8)
              | (long int)rdata[7];

   return(RCL_ERR_NONE);
}

int rcl_ident(int addr, char* devtype)
/*
 * Returns the RCL device type as a string, which determines what command set
 * it responds to. All RCL devices should implement this command.
 * 'devtype' returns the device type string, for example "S2-PT". At least
 *           RCL_MAXSTRLEN_IDENT bytes of space must be available, including
 *           the terminating NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_IDENT,NULL,0,&resp_code,
                       devtype,RCL_MAXSTRLEN_IDENT,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_IDENT)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}

int rcl_version(int addr, char* version)
/*
 * Reads the S2 ROS software version string, which includes version number
 * and compilation date. 
 * 'version' returns the version string. At least RCL_MAXSTRLEN_VERSION bytes
 *           of space must be available, including the terminating NULL.
 * Return value is local or remote error code.
 */
{
   int err;
   int resp_code;
   int resp_length;

   err=rcl_general_cmd(addr,RCL_CMD_VERSION,NULL,0,&resp_code,
                       version,RCL_MAXSTRLEN_VERSION,&resp_length,RCL_TIMEOUT);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code */
   if (resp_code!=RCL_RESP_VERSION)
      return(RCL_ERR_PKTUNEX);

   return(RCL_ERR_NONE);
}


/*
 * General message formatting routines:
 */

int rcl_general_cmd(int addr, int cmd_code, const char* cmd_data,
                    int cmd_length, int* resp_code, char* resp_data,
                    int resp_maxlength, int* resp_length, int timeout)
/*
 * General routine to send any command. Automatically performs retries if
 * no respose is received within 'timeout' milliseconds, except for the
 * commands RCL_CMD_PING, RCL_CMD_TIME_SET, RCL_CMD_TIME_READ, 
 * RCL_CMD_TIME_READ_PB, and RCL_CMD_ALIGN (absolute) which implicitly
 * cannot be retried. The caller must interpret the response in 'resp_data'.
 * This routine *does* interpret error responses, so there is no need for the
 * caller to check for them, i.e. if the function return value is RCL_ERR_NONE
 * then no error occurred and you can assume the type of packet normally
 * obtained on success has been returned, not an error packet.
 *
 * 'addr' is the address of the RCL device to which to send the command,
 *        in the range 0-253.
 * 'cmd_code' is the desired command code.
 * 'cmd_data' is the data portion of the command, always of fixed known 
 *            length as specified by 'cmd_length'.
 * 'cmd_length' is the exact length of the 'data' buffer. No variable-length
 *              data is allowed.
 * 'timeout' is the length of time to wait for the reply in milliseconds.
 * 'resp_code' returns the response code.
 * 'resp_data' returns the un-decoded data portion of the response.
 * 'resp_maxlength' specifies the maximum size of the 'resp_data' buffer.
 *                  Any data longer than 'resp_maxlength' is truncated.
 * 'resp_length' returns the length of the received 'resp_data' buffer *before*
 *               truncation. Thus the actual length is
 *               min(*resp_length,resp_maxlength).
 *
 * Return value is error code:
 * > RCL_ERR_NONE indicates a local error code (codes of the form RCL_ERR_*)
 * < RCL_ERR_NONE indicates an error code returned by the S2 (codes of the
 *                  form ERR_*)
 * RCL_ERR_TIMEOUT means that we were unable to communicate with the S2
 *                   recorder after several retries (it should be considered
 *                   dead).
 * RCL_ERR_NONE means no error has occurred.
 */
{
   int err;
   char rcl_err;
   int retry_count;
   int length;
   
   retry_count=0;
   length=cmd_length;

retry:
   err=rcl_packet_write(addr,cmd_code,cmd_data,length);
   if (err!=RCL_ERR_NONE)
      return(err);

   err=rcl_packet_read(addr,resp_code,resp_data,resp_maxlength,resp_length,
                       timeout);
   if (err!=RCL_ERR_NONE)  {
      /* check if we need to retry (we never retry ping commands, and other
           commands whose meaning may change if re-issued after a delay) */
      if (err==RCL_ERR_TIMEOUT && retry_count<RCL_RETRIES
            && cmd_code!=RCL_CMD_PING      && cmd_code!=RCL_CMD_TIME_SET
            && cmd_code!=RCL_CMD_TIME_READ && cmd_code!=RCL_CMD_TIME_READ_PB
            && (cmd_code!=RCL_CMD_ALIGN || cmd_data[0]!=0))  {
         retry_count++;
         RclNumRetries++;
         if (RclDebug>=1) 
            printf("*** RCL retry, command code %d.\n",cmd_code);
         length=-1;      /* special value means retransmit previous packet
                              using same sequence number */
         goto retry;
      }
      return(err);
   }

   /* Check if got error response code. If so, decode S2 error & return */
   if (*resp_code==RCL_RESP_ERR && *resp_length==1)  {
      rcl_err=resp_data[0];      /* will be ERR_NONE if command successful */
      return(rcl_err);
   } 

   return(RCL_ERR_NONE);
}

int rcl_simple_cmd(int addr, int cmd_code, const char* cmd_data,
                   int cmd_length, int timeout)
/*
 * General routine to send commands that expect only an RCL_RESP_ERR response.
 * See also rcl_general_cmd().
 *
 * 'addr' is the address of the RCL device to which to send the command,
 *        in the range 0-253.
 * 'cmd_code' is the desired command code.
 * 'cmd_data' is the data portion of the command, always of fixed known 
 *            length as specified by 'length'.
 * 'cmd_length' is the exact length of the data buffer. No variable-length
 *              data is allowed.
 * 'timeout' is the length of time to wait for the reply in milliseconds.
 * Return value is error code:
 * > RCL_ERR_NONE indicates a local error code (codes of the form RCL_ERR_*)
 * < RCL_ERR_NONE indicates an error code returned by the S2 (codes of the
 *                  form ERR_*)
 * RCL_ERR_TIMEOUT means that we were unable to communicate with the S2
 *                   recorder after several retries (it should be considered
 *                   dead).
 * RCL_ERR_NONE means no error has occurred.
 */
{
   int err;
   int resp_code;
   int resp_length;
   char rcl_err;
   
   err=rcl_general_cmd(addr,cmd_code,cmd_data,cmd_length,&resp_code,
                       &rcl_err,1/*maxlength*/,&resp_length,timeout);
   if (err!=RCL_ERR_NONE)
      return(err);      /* abort immediately on local or S2 errors */

   /* Check if got correct response code (should be RCL_RESP_ERR[ERR_NONE] */
   if (resp_code!=RCL_RESP_ERR)
      return(RCL_ERR_PKTUNEX);

   /* Check if got correct response length */
   if (resp_length!=1)
      return(RCL_ERR_PKTLEN);

   return(RCL_ERR_NONE);
}


