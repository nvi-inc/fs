#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef DOS
# include <conio.h>
# include <dos.h>
#endif DOS
#include <ctype.h>
#include <assert.h>
#include <math.h>

#include "main.h"
#include "rcl_def.h"
#include "rcl_cmd.h"
#include "rcl_sys.h"
#include "rcl_util.h"
#include "lib.h"
#include "softkey.h"
#include "input.h"
#include "version.h"
#ifdef DOS
# include "comio.h"
#endif DOS

#include "cmd.h"



int cmd_parse_init(void)
/*
 * Must call this function to initialize before calling readln_cmd().
 */
{
   CmdStree=stree_build(Commands,NumCmds);

   return(ERR_NONE);
}

int control(char* command)
/*
 * This function inputs commands from the keyboard and checks their syntax.
 * Interactive command input is aided by a syntax-directed softkey system.
 * 'command' returns the command string to be executed (valid only if function
 *           return value is ERR_NONE). The caller should automatically
 *           retry whenever the empty string is returned (command[0]==NULL),
 *           or when an error is returned.
 * Return value is error code.
 */
{
   int i;

   do  {
      command[0]=(char)NULL;

      /* prompt for and input command, with softkeys */
      if (S2Addr==RCL_ADDR_BROADCAST)
         printf("\nRCLCO[broadcast]> ");
      else
         printf("\nRCLCO[%d]> ",S2Addr);

      readln_cmd(CmdStree,command,MAXSTRLEN);

      /* strip trailing spaces */
      i=strlen(command);
      while (i>0 && command[i-1]==' ')
         i--;
      command[i]=(char)NULL;


   } while (command[0]==(char)NULL || command[0]==COMMENT_DELIM);

   return(ERR_NONE);
}

int execute(const char* command)
/*
 * This function parses commands semantically and executes them.
 * All cases in main switch statement below must exit with a valid error code
 * in 'err', or ERR_NONE if successful.
 * Return value is error code.
 */
{
   int err;                 /* error return holder */
   int i,k;                 /* loop vars */
   int pos;                 /* parse position */
   int cmdnum;
   char parm[MAXSTRLEN];


   /* Get first parm (the command word) */
   pos=0;
   nextparm(command,parm,&pos,PARM_DELIM);
   err=cmdnum=scan_cmd(parm,Commands,NumCmds); 
   if (err<ERR_NONE)  {
      /* error should only be possible here if the syntax check somehow 
           allows an illegal command to get by (?) */
      printf("execute(): Error code %d from scan_cmd(\"%s\",...)?!?\n",err,parm);
      return(err);
   }

   switch (cmdnum)  {

   case CMD_PING:
      err=rcl_ping(S2Addr,0);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_STOP:
      err=rcl_stop(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_PLAY:
      err=rcl_play(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_RECORD:
      err=rcl_record(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_REWIND:
      err=rcl_rewind(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_FF:
      err=rcl_ff(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_PAUSE:
      err=rcl_pause(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_UNPAUSE:
      err=rcl_unpause(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);
      return(err);

   case CMD_EJECT:
      err=rcl_eject(S2Addr);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);

   case CMD_STATE_READ:
   {
      int rstate;              /* recorder state */

      err=rcl_state_read(S2Addr,&rstate);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }
      printf("Recorder state is %s\n",rcl_rstate_to_str(rstate));

      return(ERR_NONE);
   }

   case CMD_SPEED_SET:
   {
      nextparm(command,parm,&pos,PARM_DELIM);
      if (streq(parm,"lp"))
         err=rcl_speed_set(S2Addr,RCL_SPEED_LP);
      else if (streq(parm,"slp"))
         err=rcl_speed_set(S2Addr,RCL_SPEED_SLP);
      else
         assert(FALSE);

      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_SPEED_READ:
   {
      int speed;               /* tape speed */

      err=rcl_speed_read(S2Addr,&speed);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Record tape speed is %s\n",rcl_speed_to_str(speed));

      return(ERR_NONE);
   }

   case CMD_SPEED_READ_PB:
   {
      int speed;               /* tape speed */

      err=rcl_speed_read_pb(S2Addr,&speed);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Playback tape speed is %s\n",rcl_speed_to_str(speed));

      return(ERR_NONE);
   }

   case CMD_TIME_SET:
   {
      int year;
      int day;
      int hour;
      int min;
      int sec;

      nextparm(command,parm,&pos,PARM_DELIM);
      year=(int)str_to_int(parm);
      nextparm(command,parm,&pos," -");
      day=(int)str_to_int(parm);
      nextparm(command,parm,&pos," :");
      hour=(int)str_to_int(parm);
      nextparm(command,parm,&pos," :");
      min=(int)str_to_int(parm);
      nextparm(command,parm,&pos,PARM_DELIM);
      sec=(int)str_to_int(parm);

      err=rcl_time_set(S2Addr,year,day,hour,min,sec);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_TIME_READ:
   {
      int year;
      int day;
      int hour;
      int min;
      int sec;
      ibool validated;

      err=rcl_time_read(S2Addr,&year,&day,&hour,&min,&sec,&validated);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("S2 system time is %04d %03d-%02d:%02d:%02d   ",year,day,hour,
                                                              min,sec);
      if (validated)
         printf("(validated)\n");
      else
         printf("(not validated)\n");

      return(ERR_NONE);
   }

   case CMD_TIME_READ_PB:
   {
      int year;
      int day;
      int hour;
      int min;
      int sec;
      ibool validated;

      err=rcl_time_read_pb(S2Addr,&year,&day,&hour,&min,&sec,&validated);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("S2 playback tape time is %04d %03d-%02d:%02d:%02d   ",year,day,
                                                                hour,min,sec);
      if (validated)
         printf("(validated at record)\n");
      else
         printf("(not validated at record)\n");

      return(ERR_NONE);
   }

   case CMD_MODE_SET:
   {
      char mode_str[MAXSTRLEN];

      nextparm(command,mode_str,&pos,PARM_DELIM);
      err=rcl_mode_set(S2Addr,mode_str);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_MODE_READ:
   {
      char mode_str[RCL_MAXSTRLEN_MODE];

      err=rcl_mode_read(S2Addr,mode_str);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Current S2 mode is %s\n",mode_str);

      return(ERR_NONE);
   }

   case CMD_TAPEID_SET:
   {
      char tapeid[MAXSTRLEN];

      nextparm(command,tapeid,&pos,"");    /* ignore delimiters */
      err=rcl_tapeid_set(S2Addr,tapeid);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_TAPEID_READ:
   {
      char tapeid[RCL_MAXSTRLEN_TAPEID];

      err=rcl_tapeid_read(S2Addr,tapeid);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Record tape ID is: %s\n",tapeid);

      return(ERR_NONE);
   }

   case CMD_TAPEID_READ_PB:
   {
      char tapeid[RCL_MAXSTRLEN_TAPEID];

      err=rcl_tapeid_read_pb(S2Addr,tapeid);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Playback tape ID is: %s\n",tapeid);

      return(ERR_NONE);
   }

   case CMD_USER_INFO_SET:
   {
      int field;
      ibool label;
      char user_info[MAXSTRLEN];
      int lpos;

      nextparm(command,parm,&pos,PARM_DELIM);
      field=(int)str_to_int(parm);

      label=FALSE;
      lpos=pos;
      nextparm(command,parm,&pos,PARM_DELIM);
      if (pos!=LAST_PARM && streq(parm,"label"))  {
         label=TRUE;
      }
      else  {
         pos=lpos;        /* re-parse parameter, ignoring delimiters */
      }
      nextparm(command,user_info,&pos,"");    /* ignore delimiters */

      err=rcl_user_info_set(S2Addr,field,label,user_info);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_USER_INFO_READ:
   {
      int i;
      int field;
      ibool label;
      char user_info[RCL_MAXSTRLEN_USER_INFO];

      nextparm(command,parm,&pos,PARM_DELIM);

      if (parm[0]==(char)NULL)  {
         printf("Record user info fields & labels:\n\n");
         /* no parms, read all user info fields & labels */
         for (i=1; i<=4; i++)  {
            err=rcl_user_info_read(S2Addr,i,TRUE,user_info);
            if (err!=RCL_ERR_NONE)  {
               printerr(err);
               return(err);
            }
            printf("%-16s: ",user_info);
            err=rcl_user_info_read(S2Addr,i,FALSE,user_info);
            if (err!=RCL_ERR_NONE)  {
               printf("\n");
               printerr(err);
               return(err);
            }
            printf("%s\n",user_info);
         }

         return(ERR_NONE);
      }

      field=(int)str_to_int(parm);

      nextparm(command,parm,&pos,PARM_DELIM);
      label=streq(parm,"label");

      err=rcl_user_info_read(S2Addr,field,label,user_info);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      if (label)
         printf("Record user info field %d label is: %s\n",field,user_info);
      else
         printf("Record user info field %d is: %s\n",field,user_info);

      return(ERR_NONE);
   }

   case CMD_USER_INFO_READ_PB:
   {
      int i;
      int field;
      ibool label;
      char user_info[RCL_MAXSTRLEN_USER_INFO];

      nextparm(command,parm,&pos,PARM_DELIM);

      if (parm[0]==(char)NULL)  {
         printf("Playback user info fields & labels:\n\n");
         /* no parms, read all user info fields & labels */
         for (i=1; i<=4; i++)  {
            err=rcl_user_info_read_pb(S2Addr,i,TRUE,user_info);
            if (err!=RCL_ERR_NONE)  {
               printerr(err);
               return(err);
            }
            printf("%-16s: ",user_info);
            err=rcl_user_info_read_pb(S2Addr,i,FALSE,user_info);
            if (err!=RCL_ERR_NONE)  {
               printf("\n");
               printerr(err);
               return(err);
            }
            printf("%s\n",user_info);
         }

         return(ERR_NONE);
      }

      field=(int)str_to_int(parm);

      nextparm(command,parm,&pos,PARM_DELIM);
      label=streq(parm,"label");

      err=rcl_user_info_read_pb(S2Addr,field,label,user_info);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      if (label)
         printf("Playback user info field %d label is: %s\n",field,user_info);
      else
         printf("Playback user info field %d is: %s\n",field,user_info);

      return(ERR_NONE);
   }

   case CMD_USER_DV_SET:
   {
      ibool user_dv;
      ibool pb_enable;

      nextparm(command,parm,&pos,PARM_DELIM);
      user_dv=streq(parm,"true");

      nextparm(command,parm,&pos,PARM_DELIM);
      pb_enable=streq(parm,"pb_enable");

      err=rcl_user_dv_set(S2Addr,user_dv,pb_enable);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_USER_DV_READ:
   {
      ibool user_dv;
      ibool pb_enable;

      err=rcl_user_dv_read(S2Addr,&user_dv,&pb_enable);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Record user data-valid flag is %s\n",
                                              (user_dv ? "TRUE" : "FALSE"));
      printf("Playback user DV-enable flag is %s\n",bool_to_enab(pb_enable));

      return(ERR_NONE);
   }

   case CMD_USER_DV_READ_PB:
   {
      ibool user_dv;

      err=rcl_user_dv_read_pb(S2Addr,&user_dv);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Playback user data-valid flag is %s\n",
                                                (user_dv ? "TRUE" : "FALSE"));

      return(ERR_NONE);
   }

   case CMD_GROUP_SET:
   {
      int newgroup;

      nextparm(command,parm,&pos,PARM_DELIM);
      newgroup=(int)str_to_int(parm);

      err=rcl_group_set(S2Addr,newgroup);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_GROUP_READ:
   {
      int group;
      int num_groups;

      err=rcl_group_read(S2Addr,&group,&num_groups);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Currently selected transport group is %d (of %d groups total)\n",
                                                        group, num_groups);

      return(ERR_NONE);
   }

   case CMD_TAPEINFO_READ_PB:
   {
      int i;                                    /* misc loop index */
      int tran;                                 /* transport loop index */
      unsigned char table[RCL_TAPEINFO_LEN];    /* big info table */
      int offset;                               /* base offset in table */
      ibool printcentury;
      int year;
      int day;
      int s2ser;
      int tcpser;
      int delay;                           /* station delay in ns */

      err=rcl_tapeinfo_read_pb(S2Addr,table);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      /* print headings */
      printf(                                                                  "T C     Tape ID          Mode        Tape Time      Rec Strt   S2  TCP  Delay ns");
      printf(                                                                  "- -     -------          ----        ---------      --------   --  ---  --------");

      /* print table, e.g.
1 7 Tape-ID-------------16x8-2-1995 224-15:23:01.52 15:00:29  345 2252 123456789
2 7 Tape-ID-------------c1test32-95 224-15:23:01.52 15:00:29  345 2252 123456789
3 *** no aux data ***          1995 224-15:23:07.29
4 *** no aux data ***          *** no tape time ***
       */
      for (tran=0; tran<8; tran++)  {
         printcentury=FALSE;
         offset=(RCL_TAPEINFO_LEN/8)*tran;

         /* transport address */
         printf("%d",(int)table[offset]);

         if (table[offset+1]==0xff)  {
            printf(" *** no aux data ***          ");
            printcentury=TRUE;
         }
         else  {
            /* channel ID */
            printf("%2d ",(int)table[offset+1]);

            /* tape ID */
            printf("%s",table+offset+2);
            for (i=1; i<=20-strlen((char*)table+offset+2); i++)
               printf(" ");

            /* mode, with special handling to include century if short enough */
            printf("%s",(char*)table+offset+23);
            printcentury = (strlen((char*)table+offset+23)<=6);
            for (i=1; i<=(printcentury ? 7 : 9)-strlen((char*)table+offset+23); i++)
               printf(" ");
         }

         /* Note: table[] must be unsigned for following to work */
         year=((int)table[offset+33]<<8) | (int)table[offset+34];

         if (year==0)  {
            printf("*** no tape time ***");
         }
         else  {
            /* print tape time */
            if (printcentury)
               printf("%04d",year);
            else
               printf("%02d",year % 100);

            day=((int)table[offset+35]<<8) | (int)table[offset+36];
            printf(" %03d-%02d:%02d:%02d.%02d ", day,
                                                 (int)table[offset+37],
                                                 (int)table[offset+38],
                                                 (int)table[offset+39],
                                                 (int)table[offset+40]);
         }

         if (table[offset+1]==0xff)  {
            printf("\n");
         }
         else  {
            /* print record start time */
            printf("%02d:%02d:%02d", (int)table[offset+41],
                                     (int)table[offset+42],
                                     (int)table[offset+43]);

            /* print S2 serial number */
            s2ser=((int)table[offset+44]<<8) | (int)table[offset+45];
            printf("%5d", s2ser);

            /* print transport (TCP) serial number */
            tcpser=((int)table[offset+46]<<8) | (int)table[offset+47];
            printf("%5d", tcpser);

            /* print station delay in nanoseconds; assemble bytes to make 
                 long int. Note: table[] must be unsigned for this to work. */
            delay=((int)table[offset+48]<<24)
                   | ((int)table[offset+49]<<16)
                   | ((int)table[offset+50]<<8)
                   | (int)table[offset+51];
            if (delay==0x7fffffffL)
               printf("  unknown ");
            else
               printf("%10ld", delay);

            /* we end up exactly on next line, so no need for \n */
         }
      }

      return(ERR_NONE);
   }

   case CMD_DELAY_SET:
   {
      int nanosec;

      nextparm(command,parm,&pos,PARM_DELIM);
      nanosec=str_to_int(parm);

      nextparm(command,parm,&pos,PARM_DELIM);

      err=rcl_delay_set(S2Addr,streq(parm,"relative"),nanosec);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_DELAY_READ:
   {
      int nanosec;

      err=rcl_delay_read(S2Addr,&nanosec);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Current station delay setting is %ld ns\n",nanosec);

      return(ERR_NONE);
   }

   case CMD_DELAYM_READ:
   {
      int nanosec;

      err=rcl_delaym_read(S2Addr,&nanosec);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Current station delay measurement is %ld ns\n",nanosec);

      return(ERR_NONE);
   }

   case CMD_BARRELROLL_SET:
   {
      ibool barrelroll;

      nextparm(command,parm,&pos,PARM_DELIM);
      barrelroll=streq(parm,"on");

      err=rcl_barrelroll_set(S2Addr,barrelroll);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_BARRELROLL_READ:
   {
      ibool barrelroll;

      err=rcl_barrelroll_read(S2Addr,&barrelroll);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Barrel-roll is %s\n", (barrelroll ? "ON" : "OFF"));

      return(ERR_NONE);
   }

   case CMD_ERRMES:
   {
      int error;
      int nanosec;
      int chanrate;
      ibool async;
      int reprate;        /* in ms */
      int repcount;       /* count up to reprate for sync mode, in ms */
      int dumyear;
      int dumday;
      int dumhour;
      int dummin;
      int dumsec;

      nextparm(command,parm,&pos,PARM_DELIM);

      if (streq(parm,"auto"))  {
         /* send error measurements once per second based on UI delay
              measurement */
         nextparm(command,parm,&pos,PARM_DELIM);
         chanrate=(int)str_to_int(parm);
         nextparm(command,parm,&pos,PARM_DELIM);
         if (streq(parm,"async"))  {
            async=TRUE;
            nextparm(command,parm,&pos,PARM_DELIM);
         }
         else  {
            async=FALSE;
         }
         /* get repetition rate */
         if (parm[0]!=0)  {
            reprate=str_to_double(parm)*1000;
         }
         else  {
            reprate=1000;
         }


         printf("Sending ERRMES commands every %g sec based on station delay measurement.\n",(double)reprate/1000);
         printf("*Assumes mode %d-? (hit any key to stop)\n",chanrate);

         if (async)  {
            reprate-=150;  /* compensate for non-delay parts of loop */
         }
         else  {
            /* synchronize by performing dummy time read */
            err=rcl_time_read(S2Addr,&dumyear,&dumday,&dumhour,&dummin,&dumsec,
                              NULL);
            if (err==RCL_ERR_TIMEOUT)  {
               /* perform retry since time reads aren't automatically retried */
               printf("*rcl_time_read() timed out -- retrying once*\n");
               err=rcl_time_read(S2Addr,&dumyear,&dumday,&dumhour,&dummin,
                                 &dumsec,NULL);
            }
            if (err!=RCL_ERR_NONE)  {
               printf("*rcl_time_read(): ");
               printerr(err);
               return(err);
            }

            repcount=0;

            /* wait until about half way through one-second interval, 
                 because that's where delay measurement is made */
            rcl_delay(500);
         }

         while (kbhit()==0)  {
            err=rcl_delaym_read(S2Addr,&nanosec);
            if (err!=RCL_ERR_NONE)  {
               printf("*rcl_delaym_read(): ");
               printerr(err);
            }
            else  {
               /* Convert to bits. We divide by 10 first to prevent overflow
                    when multiplying by chanrate, then divide by 100 more
                    for a total divisor of 1000. */
               error=-(nanosec/10)*chanrate/100;

               if (!async)
                  printf("*[%02d] ",dumsec);
               printf("Sending ERRMES %ld\n",error);
               err=rcl_errmes(S2Addr,error);
               if (err!=RCL_ERR_NONE)  {
                  printf("*rcl_errmes(): ");
                  printerr(err);
                  return(err);
               }
            }

            if (async)  {
               /* delay (asynchronous) */
               rcl_delay(reprate);
            }
            else  {
               while (repcount<reprate)  {
                  /* synchronize by performing dummy time read */
                  err=rcl_time_read(S2Addr,&dumyear,&dumday,&dumhour,&dummin,
                                    &dumsec,NULL);
                  if (err==RCL_ERR_TIMEOUT)  {
                     /* perform retry since time reads aren't automatically
                          retried */
                     printf("*rcl_time_read() timed out -- retrying once\n");
                     err=rcl_time_read(S2Addr,&dumyear,&dumday,&dumhour,&dummin,
                                       &dumsec,NULL);
                  }
                  if (err!=RCL_ERR_NONE)  {
                     printf("*rcl_time_read(): ");
                     printerr(err);
                     return(err);
                  }
                  repcount+=1000;
               }

               repcount-=reprate;

               /* wait until about half way through one-second interval, 
                    because that's where delay measurement is made */
               rcl_delay(500);
            }
         }

         /* clear keyboard buffer */
         while (kbhit()!=0)  {
#ifdef DOS
            getch();
#else
            getchar();
#endif 
         }
      }
      else  {
         error=str_to_int(parm);

         err=rcl_errmes(S2Addr,error);
         if (err!=RCL_ERR_NONE)  {
            printerr(err);
            return(err);
         }
      }

      return(ERR_NONE);
   }

   case CMD_ALIGN:
   {
      ibool negative;
      int year;
      int day;
      int hour;
      int min;
      int sec;
      int nanosec;

      nextparm(command,parm,&pos,PARM_DELIM);

      if (streq(parm,"abs"))  {
         nextparm(command,parm,&pos,PARM_DELIM);
         year=(int)str_to_int(parm);
         nextparm(command,parm,&pos," -");
         day=(int)str_to_int(parm);
         nextparm(command,parm,&pos," :");
         hour=(int)str_to_int(parm);
         nextparm(command,parm,&pos," :");
         min=(int)str_to_int(parm);
         nextparm(command,parm,&pos," :.");
         sec=(int)str_to_int(parm);
   
         nextparm(command,parm,&pos,PARM_DELIM);
         /* truncate to max. 9 digits */
         parm[9]=(char)NULL;
         /* convert to nanoseconds (pad on right with zeroes) */
         while (strlen(parm)<9)  {
            strcat(parm,"0");
         }
         nanosec=str_to_int(parm);
   
         err=rcl_align_abs(S2Addr,year,day,hour,min,sec,nanosec);
      }
      else if (streq(parm,"rel"))  {
         nextparm(command,parm,&pos," :");
         negative=(parm[0]=='-');
         if (parm[0]=='-' || parm[0]=='+')  {
            strcpy(parm,parm+1);
            if (parm[0]==(char)NULL)  {
               /* must be a space after sign */
               nextparm(command,parm,&pos," :");
            }
         }

         hour=(int)str_to_int(parm);
         nextparm(command,parm,&pos," :");
         min=(int)str_to_int(parm);
         nextparm(command,parm,&pos," :.");
         sec=(int)str_to_int(parm);
   
         nextparm(command,parm,&pos,PARM_DELIM);
         /* truncate to max. 9 digits */
         parm[9]=(char)NULL;
         /* convert to nanoseconds (pad on right with zeroes) */
         while (strlen(parm)<9)  {
            strcat(parm,"0");
         }
         nanosec=str_to_int(parm);
   
         err=rcl_align_rel(S2Addr,negative,hour,min,sec,nanosec);
      }
      else if (streq(parm,"realign"))  {
         err=rcl_align_realign(S2Addr);
      }
      else if (streq(parm,"selfalign"))  {
         err=rcl_align_selfalign(S2Addr);
      }
      else  {
         assert(FALSE);
      }

      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_POSITION_SET:
   {
      int tran;             /* transport loop index */
      int code;
      ibool negative;        /* TRUE if relative positioning value is neg */
      int hour;
      int min;
      int sec;
      int position;
      int posarray[8]; /* individual position array */

      nextparm(command,parm,&pos," :");

      if (streq(parm,"reestablish"))  {
         err=rcl_position_reestablish(S2Addr);
      }
      else  {
         if (streq(parm,"preset"))  {
            code=2;    /* position preset */
            nextparm(command,parm,&pos," :");
         }
         else if (parm[0]=='+' || parm[0]=='-')  {
            code=1;    /* relative positioning */
            negative=(parm[0]=='-');
            strcpy(parm,parm+1);
            if (parm[0]==(char)NULL)
               nextparm(command,parm,&pos," :");
         }
         else  {
            code=0;    /* absolute positioning */
         }

         if (streq(parm,"unknown"))  {
            position=RCL_POS_UNKNOWN;
         }
         else  {
            assert(isdigit(parm[0]));

            hour=(int)str_to_int(parm);
            nextparm(command,parm,&pos," :");
            min=(int)str_to_int(parm);
            nextparm(command,parm,&pos," :.");
            sec=(int)str_to_int(parm);

            position=sec+60*min+60*60*hour;
            if (code==1 && negative)
               position=-position;
         }

         nextparm(command,parm,&pos,PARM_DELIM);

         if (streq(parm,"indtest"))  {
            /* it's too complicated to allow entry of 8 separate positions,
                 so we generate 7 other positions from the one entered by
                 adding steps of one minute */
            printf("Sending individual positions at one minute increments\n");

            for (tran=0; tran<8; tran++)  {
               posarray[tran]=position;
               if (position!=RCL_POS_UNKNOWN)
                  position+=60;
            }
            err=rcl_position_set_ind(S2Addr,code,posarray);
         }
         else  {
            err=rcl_position_set(S2Addr,code,position);
         }

      }

      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_POSITION_READ:
   {
      int tran;             /* transport loop index */
      int hour;
      int min;
      int sec;
      ibool negative;        /* TRUE if position is (was) negative */
      int position;    /* overall position holder */
      int posvar;      /* overall position variance holder */
      int posarray[8]; /* individual position array */
      int pos_n;            /* number of entries filled in above */

      nextparm(command,parm,&pos,PARM_DELIM);

      if (streq(parm,"individual"))  {
         err=rcl_position_read_ind(S2Addr,&pos_n,posarray);
         if (err!=RCL_ERR_NONE)  {
            printerr(err);
            return(err);
         }

         printf("Individual transport tape positions: \n\n");

         for (tran=0; tran<pos_n; tran++)  {
            printf("  %d: ",tran);
            position=posarray[tran];

            if (position==RCL_POS_UNSEL)  {
               printf("not selected\n");
            }
            else if (position==RCL_POS_UNKNOWN)  {
               printf("unknown\n");
            }
            else  {
               /* remember if position was negative, then make it positive
                    so we work only with positive values */
               if ((negative=(position<0)))
                  position=-position;
   
               /* Display position as [-]hours:minutes:seconds. (int) casts
                    are to prevent warnings from Borland C++ compiler. */
               hour = (int)(position/60/60);
               position -= hour*60*60;
               min = (int)(position/60);
               sec = (int)(position-min*60);
               printf("%s%01d:%02d:%02d\n",(negative ? "-" : " "),hour,min,sec);
            }
         }
      }
      else  {
         err=rcl_position_read(S2Addr,&position,&posvar);
         if (err!=RCL_ERR_NONE)  {
            printerr(err);
            return(err);
         }

         printf("Current overall tape position: ");

         if (position==RCL_POS_UNKNOWN)  {
            printf("unknown\n");
            return(ERR_NONE);
         }
   
         /* remember if position was negative, then make it positive so we work
              only with positive values */
         if ((negative=(position<0)))
            position=-position;
   
         /* Display position as [-]hours:minutes:seconds. (int) casts
              are to prevent warnings from Borland C++ compiler. */
         hour = (int)(position/60/60);
         position -= hour*60*60;
         min = (int)(position/60);
         sec = (int)(position-min*60);
         printf("%s%01d:%02d:%02d +-",(negative ? "-" : ""),hour,min,sec);
   
         if (posvar<60)  {
           /* show variance as 00 s */
            printf("%02ld s\n",posvar);
         }
         else  {
           /* show variance as 0h00 (00 s) */
           hour = (int)(posvar/60/60);
           posvar -= hour*60*60;
           min = (int)(posvar/60);
           sec = (int)(posvar-min*60);
           printf("%01dh%02d (%02d s)\n",hour,min,sec);
         }
      }

      return(ERR_NONE);
   }

   case CMD_ESTERR_READ:
   {
      int i;               /* loop index */
      int list_len;
      char esterr_list[8*RCL_MAXSTRLEN_ESTERR];
      int spos;            /* position in scanning esterr_list[] */

      nextparm(command,parm,&pos,PARM_DELIM);

      err=rcl_esterr_read(S2Addr,streq(parm,"bychan"),&list_len,esterr_list);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("# of estimated error rates: %d",list_len);
      if (streq(parm,"bychan"))
         printf("  (in order of internal recorder chans)\n");
      else
         printf("  (in order of transports)\n");
      spos=0;
      for (i=0; i<list_len; i++)  {
         printf("%d: %s\n",i,esterr_list+spos);
         spos += strlen(esterr_list+spos)+1;
      }

      return(ERR_NONE);
   }

   case CMD_PDV_READ:
   {
      int i;               /* loop index */
      int list_len;
      char pdv_list[8*RCL_MAXSTRLEN_PDV];
      int spos;            /* position in scanning pdv_list[] */

      nextparm(command,parm,&pos,PARM_DELIM);

      err=rcl_pdv_read(S2Addr,streq(parm,"bychan"),&list_len,pdv_list);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("# of %% data valid values: %d",list_len);
      if (streq(parm,"bychan"))
         printf("  (in order of internal recorder chans)\n");
      else
         printf("  (in order of transports)\n");
      spos=0;
      for (i=0; i<list_len; i++)  {
         printf("%d: %s\n",i,pdv_list+spos);
         spos += strlen(pdv_list+spos)+1;
      }

      return(ERR_NONE);
   }

   case CMD_SCPLL_MODE_SET:
   {
      nextparm(command,parm,&pos,PARM_DELIM);
      if (streq(parm,"xtal"))
         err=rcl_scpll_mode_set(S2Addr,RCL_SCPLL_MODE_XTAL);
      else if (streq(parm,"manual"))
         err=rcl_scpll_mode_set(S2Addr,RCL_SCPLL_MODE_MANUAL);
      else if (streq(parm,"refclk"))
         err=rcl_scpll_mode_set(S2Addr,RCL_SCPLL_MODE_REFCLK);
      else if (streq(parm,"1hz"))
         err=rcl_scpll_mode_set(S2Addr,RCL_SCPLL_MODE_1HZ);
      else if (streq(parm,"errmes"))
         err=rcl_scpll_mode_set(S2Addr,RCL_SCPLL_MODE_ERRMES);
      else
         assert(FALSE);

      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_SCPLL_MODE_READ:
   {
      int scpll_mode;               /* tape speed */

      err=rcl_scpll_mode_read(S2Addr,&scpll_mode);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("System Clock PLL mode is %s\n",rcl_scpll_mode_to_str(scpll_mode));

      return(ERR_NONE);
   }

   case CMD_TAPETYPE_SET:
   {
      char tapetype[MAXSTRLEN];

      nextparm(command,tapetype,&pos,PARM_DELIM);
      err=rcl_tapetype_set(S2Addr,tapetype);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_TAPETYPE_READ:
   {
      char tapetype[RCL_MAXSTRLEN_TAPETYPE];

      err=rcl_tapetype_read(S2Addr,tapetype);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Current tape type is: %s\n",tapetype);

      return(ERR_NONE);
   }

   case CMD_MK3_FORM_SET:
   {
      ibool mk3;

      nextparm(command,parm,&pos,PARM_DELIM);
      mk3=streq(parm,"on");

      err=rcl_mk3_form_set(S2Addr,mk3);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      return(ERR_NONE);
   }

   case CMD_MK3_FORM_READ:
   {
      ibool mk3;

      err=rcl_mk3_form_read(S2Addr,&mk3);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Mark III formatter is %s\n", (mk3 ? "ON" : "OFF"));

      return(ERR_NONE);
   }

   case CMD_TRANSPORT_TIMES:
   {
      int tran;                 /* transport loop index */
      unsigned short serial[8]; /* serial numbers */
      unsigned int tot_on_time[8];
      unsigned int tot_head_time[8];
      unsigned int head_use_time[8];
      unsigned int in_service_time[8];
      int time_n;               /* number of entries filled in above */

      nextparm(command,parm,&pos,PARM_DELIM);

      err=rcl_transport_times(S2Addr,&time_n,serial,tot_on_time,tot_head_time,
                              head_use_time,in_service_time);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Tran  Serial#   Tot On Time  Tot Head Time  Head-Use Time   In-Service Time\n");
      printf("----  -------   -----------  -------------  -------------   ---------------\n");

      for (tran=0; tran<time_n; tran++)  {
         /* this doesn't work unless we do it in two pieces for some reason! */
         printf(" %2d %7u  %7luh %02lum  %7luh %02lum",
                tran, serial[tran],
                tot_on_time[tran]/60, tot_on_time[tran] % 60,
                tot_head_time[tran]/60, tot_head_time[tran] % 60);
         printf(" %8luh %02lum  %9luh %02lum\n",
                head_use_time[tran]/60, head_use_time[tran] % 60,
                in_service_time[tran]/60, in_service_time[tran] % 60);
      }

      return(ERR_NONE);
   }

   case CMD_STATION_INFO_READ:
   {
      int station;
      int serialnum;
      char nickname[RCL_MAXSTRLEN_NICKNAME];

      err=rcl_station_info_read(S2Addr,&station,&serialnum,nickname);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Info for S2 at %s address %d:\n\n",
                         (RclSocketCnt>0 ? "reference" : "RCL"), S2Addr);
      printf("   S2 station #: %d\n",station);
      printf("System serial #: %ld\n",serialnum);
      printf("       Nickname: \"%s\"\n",nickname);

      return(ERR_NONE);
   }

   case CMD_CONSOLECMD:
   {
      char cmdstr[MAXSTRLEN];

      nextparm(command,cmdstr,&pos,"");  /* get cmd string, ignore delimiters */

      err=rcl_consolecmd(S2Addr,cmdstr);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_POSTIME_READ:
   {
      int tran;
      int year;
      int day;
      int hour;
      int min;
      int sec;
      int frame;
      int position;    /* position holder */
      ibool negative;        /* TRUE if position is (was) negative */
      int phour;
      int pmin;
      int psec;
      int pframe;

      nextparm(command,parm,&pos,PARM_DELIM);
      tran=(int)str_to_int(parm);

      err=rcl_postime_read(S2Addr,tran,&year,&day,&hour,&min,&sec,&frame,
                           &position);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("     Transport %d tape position: ",tran);
      if (position==RCL_POS_UNKNOWN)  {
         printf("unknown\n");
      }
      else  {
         /* remember if position was negative, then make it positive so we work
              only with positive values */
         if ((negative=(position<0)))
            position=-position;
   
         /* Display position as [-]hours:minutes:seconds.frames
              (int) casts are to prevent warnings from Borland C++ compiler. */
         phour = (int)(position/(60*60*64));
         position -= phour*(60*60*64);
         pmin = (int)(position/(60*64));
         position -= pmin*(60*64);
         psec = (int)(position/64);
         pframe = (int)(position-psec*64);
         printf("        %s%2d:%02d:%02d.%02d\n",(negative ? "-" : " "),
                                                   phour,pmin,psec,pframe);
      }

      printf("Transport %d playback tape time: ",tran);
      if (year==0 && day==0)
         printf("unknown\n");
      else
         printf("%04d %03d-%02d:%02d:%02d.%02d\n",year,day,hour,min,sec,frame);

      return(ERR_NONE);
   }

   case CMD_STATUS:
   {
      int i,j;                      /* loop indices */
      int summary;                  /* summary bits */
      int num_entries;              /* number of status codes */
      unsigned char status_list[RCL_STATUS_MAX*2];
                                    /* list of status codes & types */
      char stat_msg[RCL_MAXSTRLEN_STATUS_DECODE];  /* status message */
      int code;
      int typecode;

      err=rcl_status(S2Addr,&summary,&num_entries,status_list);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Summary: ");
      if (summary & RCL_STATBIT_FATAL)
         printf("fatal error status");
      else if (summary & RCL_STATBIT_ERROR)
         printf("error status");
      else 
         printf("status OK");
      printf("\n\n");

      if (num_entries==0)  {
         printf("No status conditions to report.\n");
      }

      /* We make extra RCL calls to decode each status code into its
           mnemonic, because plain numbers are not at all informative.
           This is not very efficient. We should really cache the returned
           strings (so that they are remembered in the future) or go through
           all status codes building a table at the start. */
      for (i=0; i<num_entries; i++)  {
         code=status_list[i*2];

         err=rcl_status_decode(S2Addr,code,FALSE,stat_msg);
         if (err==ERR_NONE)  {
            /* truncate to mnemonic only */
            for (j=0; stat_msg[j]!=(char)NULL; j++)  {
               if (stat_msg[j]==':')  {
                  stat_msg[j]=(char)NULL;
                  break;
               }
            }
         }
         else  {
            strcpy(stat_msg,"??????");
         }
         printf("Status code: %s (%d)  Type: ",stat_msg,code);

         typecode=status_list[i*2+1];
         if (typecode & RCL_STATBIT_FATAL)
            printf("fatal error");
         else if (typecode & RCL_STATBIT_ERROR)
            printf("error");
         else 
            printf("informational");
         if (typecode & RCL_STATBIT_CLEAR)
            printf(", clear-on-read");
         printf("\n");
      }

      return(ERR_NONE);
   }

   case CMD_STATUS_DETAIL:
   {
      int i;                    /* loop index */
      int len;                  /* string length holder */
      int stat_code;            /* code to get info for */
      ibool reread;              /* TRUE == re-read status */
      ibool shortt;              /* TRUE == use short messages */
      int summary;              /* summary bits */
      int num_entries;          /* number of status codes */
      unsigned char status_det_list[RCL_STATUS_DETAIL_MAXLEN];
      int spos;                 /* position in scanning status_det_list[] */
      int typecode;

      nextparm(command,parm,&pos,PARM_DELIM);
      if (isdigit(parm[0]))  {
         stat_code=(int)str_to_int(parm);
         nextparm(command,parm,&pos,PARM_DELIM);
      }
      else  {
         stat_code=0;    /* read all codes */
      }

      reread=streq(parm,"reread");
      if (reread)
         nextparm(command,parm,&pos,PARM_DELIM);

      shortt=streq(parm,"short");

      err=rcl_status_detail(S2Addr,stat_code,reread,shortt,
                            &summary,&num_entries,status_det_list);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Summary: ");
      if (summary & RCL_STATBIT_FATAL)
         printf("fatal error status");
      else if (summary & RCL_STATBIT_ERROR)
         printf("error status");
      else 
         printf("status OK");
      printf("\n\n");

      if (num_entries==0)  {
         if (stat_code!=0)
            printf("Status code %d not active, no detailed info available.\n",
                                                                  stat_code);
         else
            printf("No status conditions to report.\n");
      }

      spos=0;
      for (i=0; i<num_entries; i++)  {
         printf("Status code:%4d   Type: ",status_det_list[spos++]);

         typecode=status_det_list[spos++];
         if (typecode & RCL_STATBIT_FATAL)
            printf("fatal error");
         else if (typecode & RCL_STATBIT_ERROR)
            printf("error");
         else 
            printf("informational");
         if (typecode & RCL_STATBIT_CLEAR)
            printf(", clear-on-read");

         len=strlen((char*)status_det_list+spos);
         printf("\n%s\n",status_det_list+spos);

         spos+=len+1;
      }

      return(ERR_NONE);
   }

   case CMD_STATUS_DECODE:
   {
      int stat_code;
      ibool shortt;              /* TRUE == use short messages */
      char stat_msg[RCL_MAXSTRLEN_STATUS_DECODE];

      nextparm(command,parm,&pos,PARM_DELIM);
      stat_code=(int)str_to_int(parm);

      nextparm(command,parm,&pos,PARM_DELIM);
      shortt=streq(parm,"short");

      err=rcl_status_decode(S2Addr,stat_code,shortt,stat_msg);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Status code %d: \n%s",stat_code,stat_msg);

      return(ERR_NONE);
   }

   case CMD_ERROR_DECODE:
   {
      int err_code;
      char err_msg[RCL_MAXSTRLEN_ERROR_DECODE];

      nextparm(command,parm,&pos,PARM_DELIM);
      err_code=(int)str_to_int(parm);

      err=rcl_error_decode(S2Addr,err_code,err_msg);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("Error code %d: %s\n",err_code,err_msg);

      return(ERR_NONE);
   }

   case CMD_DIAG:
   {
      err=rcl_diag(S2Addr,1);
      if (err!=RCL_ERR_NONE)
         printerr(err);

      return(err);
   }

   case CMD_BERDCB:
   {
      int op_type;
      int chan;
      int meas_time;
      unsigned int err_bits;
      unsigned int tot_bits;

      nextparm(command,parm,&pos,PARM_DELIM);
      if (streq(parm,"formber"))
         op_type=1;
      else if (streq(parm,"uiber"))
         op_type=2;
      else if (streq(parm,"dcbias"))
         op_type=3;
      else
         return(ERR_OPFAIL);

      nextparm(command,parm,&pos,PARM_DELIM);
      chan=(int)str_to_int(parm);

      nextparm(command,parm,&pos,PARM_DELIM);
      meas_time=(int)str_to_int(parm);

      err=rcl_berdcb(S2Addr,op_type,chan,meas_time,&err_bits,&tot_bits);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      /* prevent divide-by-zero */
      if (tot_bits==0)  {
         printf("Null measurement?!\n");
         return(ERR_OPFAIL);
      }

      switch (op_type)  {
      case 1:
         printf("Results of %d-second FORM BER measurement on channel %d:\n",
                meas_time, chan);
         printf("Raw error count: %lu  (out of %lu bits)\n",err_bits,tot_bits);
         printf("     Error rate: %.2e\n",(float)err_bits/tot_bits);
         break;
      case 2:
         printf("Results of %d-second UI BER measurement on user channel %d:\n",
                meas_time, chan);
         printf("Raw error count: %lu  (out of %lu bits)\n",err_bits,tot_bits);
         printf("     Error rate: %.2e\n",(float)err_bits/tot_bits);
         break;
      case 3:
         printf("Results of %d-second UI DC-bias measurement on user channel %d:\n",
                meas_time, chan);
         printf("Raw 1-bit count: %lu  (out of %lu bits)\n",err_bits,tot_bits);
         printf("        DC bias: %4.1f%%\n",(float)err_bits*100/tot_bits);
         break;
      }

      return(ERR_NONE);
   }

   case CMD_IDENT:
   {
      char ident[RCL_MAXSTRLEN_IDENT];

      err=rcl_ident(S2Addr,ident);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("RCL address %d device identifier: %s\n",S2Addr,ident);

      return(ERR_NONE);
   }

   case CMD_VERSION:
   {
      char version[RCL_MAXSTRLEN_VERSION];

      err=rcl_version(S2Addr,version);
      if (err!=RCL_ERR_NONE)  {
         printerr(err);
         return(err);
      }

      printf("S2 ROS version: %s\n",version);

      return(ERR_NONE);
   }


   case CMD_HELP:
      if (nextparm(command,parm,&pos,PARM_DELIM)==EOF)  {
         k=0;
         for (i=0; i<NumCmds; i++)  {
            pos=0;
            nextparm(Commands[i].name,parm,&pos,PARM_DELIM);
            if (k+strlen(parm)>77)  {
               printf("\n");
               k=0;
            }
            printf("  %s",parm);
            k=k+strlen(parm)+2;
         }
         printf("\n");
         parm[0]=(char)NULL;
      }
      else if (streq(parm,"all"))  {
         for (i=0; i<NumCmds; i++)  {
            printf(" %s\n",Commands[i].name);
         }
      }
      else  {
         k=scan_cmd(parm,Commands,NumCmds);
         if (k>=0)  {
            for (i=0; Commands[i].num!=k; i++);
            printf("%s\n",Commands[i].name);
         }
         else
            printf("No help on command, does not exist!\n");
      }

      return(ERR_NONE);

   case CMD_ADDR:
   {
      int addr;

      nextparm(command,parm,&pos,PARM_DELIM);
      if (parm[0]!=(char)NULL)  {
         if (streq(parm,"broadcast"))  {
            addr=RCL_ADDR_BROADCAST;
         }
         else  {
            addr=(int)str_to_int(parm);
            if (addr<0 || addr>=RCL_ADDR_MASTER)  {
               printf("Address must be from 0 to %d\n",RCL_ADDR_MASTER-1);
               return(ERR_OPFAIL);
            }
         }
         S2Addr=addr;
      }

#ifdef DOS
      printf("Selected S2 RCL address is %d\n",S2Addr);
#else
      printf("Selected S2 reference address is %d (%s)\n",
                                         S2Addr, rcl_addr_to_hostname(S2Addr));
#endif DOS

      return(ERR_NONE);
   }

#ifdef DOS
   /* for DOS (serial port) RCL applications only */
   case CMD_BAUD:
      nextparm(command,parm,&pos,PARM_DELIM);
      if (parm[0]!=NULL)  {
         err=ttclose();           /* close comm port */
         if (err==-1)  {
            printf("Error in ttclose(), couldn't set baud rate!\n");
            return(RCL_ERR_IO);
         }

         speed=(unsigned int)str_to_int(parm);    /* set new speed */

         err=ttopen();            /* re-open comm port to update baud rate */
         if (err==-1)  {
            printf("Error in ttopen(), couldn't set baud rate!\n");
            return(RCL_ERR_IO);
         }
      }
         
      printf("Local RCL port baud rate set to %u\n",speed);

      return(ERR_NONE);

   case CMD_PORT:
      nextparm(command,parm,&pos,PARM_DELIM);
      if (parm[0]!=NULL)  {
         err=ttclose();           /* close comm port */
         if (err==-1)  {
            printf("Error in ttclose(), couldn't reset port!\n");
            return(RCL_ERR_IO);
         }

         port=(int)str_to_int(parm);    /* set new port */

         err=ttopen();            /* re-open new port */
         if (err==-1)  {
            printf("Error in ttopen(), couldn't reset port!\n");
            return(RCL_ERR_IO);
         }
      }
         
      printf("Serial port %d selected for RCL\n",port);

      return(ERR_NONE);
#endif DOS

#ifdef UNIX
   /* for UNIX (network) RCL applications only */
   case CMD_OPEN:
   {
      int newaddr;
      char errmsg[MAXSTRLEN];           /* error message from rcl_open() */
      int naddr;                        /* # addresses from rcl_open_list() */
      int addr_list[RCL_MAX_CONNECT];   /* address list from rcl_open_list() */

      nextparm(command,parm,&pos,PARM_DELIM);

      if (parm[0]==(char)NULL)  {
         /* no parameter, list open connections */
         rcl_open_list(&naddr, addr_list);
         if (naddr==0)  {
            printf("No currently open network connections\n");
         }
         else  {
            printf("Reference addresses and host names for currently open connections:\n");
            for (i=0; i<naddr; i++)  {
               printf("   %d   %s\n",addr_list[i], 
                                     rcl_addr_to_hostname(addr_list[i]));
            }
         }
         return(ERR_NONE);
      }
         
      /* open RCL socket */
      err=rcl_open(parm, &newaddr, errmsg);
      if (err!=RCL_ERR_NONE)  {
         printf("Error opening network connection: %s\n",errmsg);
         return(err);
      }

      printf("Opened network connection for %s, reference address %d.\n",
                                                              parm,newaddr);
      if (newaddr!=S2Addr)  {
         printf("Switching to new address");
         if (RclSocketCnt>1)
            printf(" (return to previous connection with 'addr %d', or send\nto all with 'addr broadcast')", S2Addr);
         printf(".\n");
      }

      S2Addr=newaddr;

      return(ERR_NONE);
   }

   case CMD_CLOSE:
   {
      nextparm(command,parm,&pos,PARM_DELIM);

      /* close RCL socket */
      err=rcl_close((int)str_to_int(parm));
      if (err!=RCL_ERR_NONE)  {
         printf("Error closing network connection for %s: ",parm);
         printerr(err);
         return(err);
      }

      printf("Closed network connection for reference address %s (%d connections remain open).\n", parm, RclSocketCnt);

      return(ERR_NONE);
   }
#endif UNIX

   case CMD_DEBUG:
   {
      extern int RclDebug;

      nextparm(command,parm,&pos,PARM_DELIM);
      if (parm[0]!=(char)NULL)  {
         RclDebug=(int)str_to_int(parm);    /* set new port */
      }

      printf("Local RCL debug flag is %d\n",RclDebug);

      return(ERR_NONE);
   }

   case CMD_VERSIONL:
      printf("  RCLCO version %s\n",rclco_version());
      return(ERR_NONE);

   case CMD_END:
      printf("Terminating\n");
      EndProgram=TRUE;
      return(ERR_NONE);

   default:
      printf("Error: Unimplemented command '%s' (%d) !?\n",parm,cmdnum);
      return(ERR_OPFAIL);
   }

   /** execution should never reach here (should return at the end of each
         case) **/
}

void printerr(int err_code)
{
   int err;
   char err_msg[RCL_MAXSTRLEN_ERROR_DECODE];

   if (err_code>=RCL_ERR_NONE)  {
      switch (err_code)  {
      case RCL_ERR_NONE:
         printf("No error has occurred\n");
         break;
      case RCL_ERR_OPFAIL:
         printf("Local error: Operation failed (non-specific error)\n");
         break;
      case RCL_ERR_IO:
         printf("Local error: I/O error\n");
         break;
      case RCL_ERR_TIMEOUT:
         printf("Local error: Communications timeout, S2 probably dead\n");
         break;
      case RCL_ERR_BADVAL:
         printf("Local error: Parameter value is illegal or out of range\n");
         break;
      case RCL_ERR_BADLEN:
         printf("Local error: String parameter is too long/short\n");
         break;
      case RCL_ERR_NETIO:
         printf("Local error: Network I/O error\n");
         break;
      case RCL_ERR_NETBADHOST:
         printf("Local error: Unknown host name\n");
         break;
      case RCL_ERR_NETBADREF:
         printf("Local error: No network connection open for current reference address\n");
         break;
      case RCL_ERR_NETMAXCON:
         printf("Local error: No more network connections can be opened (max. %d)\n", RCL_MAX_CONNECT);
         break;
      case RCL_ERR_NETREMCLS:
         printf("Local error: Network connection closed by remote host\n");
         break;
      case RCL_ERR_PKTUNEX:
         printf("Local error: Unexpected response packet from RCL device (update local software)\n");
         break;
      case RCL_ERR_PKTLEN:
         printf("Local error: Wrong packet length returned by RCL device (update local software)\n");
         break;
      case RCL_ERR_PKTFORMAT:
         printf("Local error: Bad format in packet returned by RCL device (update local software)\n");
         break;
      default:
         printf("Local error: Undefined error code: %d\n",err_code);
      }
   }
   else  {
      err=rcl_error_decode(S2Addr,err_code,err_msg);
      if (err!=RCL_ERR_NONE)  {
         printf("Error: code %d\n",err_code);
      }
      else  {
         printf("Error: %s\n",err_msg);
      }
   }
}
