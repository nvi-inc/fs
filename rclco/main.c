#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef DOS
# include <conio.h>
# include <signal.h>
#endif DOS
#ifdef UNIX
# include <curses.h>
# undef bool          /* defined by curses.h, nasty! */
#endif UNIX

#define MAIN

#include "main.h"

#include "rcl_def.h"
#include "rcl_cmd.h"
#include "rcl_pkt.h"
#include "rcl_sys.h"
#ifdef DOS
# include "comio.h"
#endif DOS
#include "lib.h"
#include "cmd.h"
#include "input.h"
#include "softkey.h"
#include "version.h"

#undef MAIN


int main(int argc, char* argv[])
/*
 * Important note: Don't use printf() until after initscr() call, below,
 * because printf() redefined as printw() in Unix version. Use
 * fprintf(stderr,...) up until that point (but not after).
 */
{
   extern int RclDebug;
   int err;
   char command[MAXSTRLEN];  /* command typed by user */
#ifdef UNIX
   int i;                    /* loop index */
   char hostname[MAXSTRLEN]; /* name of last S2 connected to, "" if none */
   int dumaddr;              /* dummy address return (not used) */
   char errmsg[MAXSTRLEN];   /* error message from rcl_open() */
   char* term;               /* terminal type from getenv() */
   char parm[MAXSTRLEN];     /* parameter parsed */
   int pos;                  /* position in parsing */
   int naddr;                        /* # addresses from rcl_open_list() */
   int addr_list[RCL_MAX_CONNECT];   /* address list from rcl_open_list() */
#endif


#ifdef DOS
   signal(SIGINT,chandler);   /* handle control-C */
#endif DOS

   err=rcl_init();            /* initialize RCL */
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Error initializing RCL: %d\n",err);
      exit(err);
   }

   RclDebug = 1;              /* debug level 1 by default */
   
   err=cmd_parse_init();      /* initialize command parsing */
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Error initializing command parsing: %d\n",err);
      exit(err);
   }

#ifdef UNIX
   /* check command arguments (hosts to open) */
   hostname[0]=(char)NULL;
   for (i=1; i<=RCL_MAX_CONNECT; i++)  {
      if (argv[i]==(char*)NULL || argv[i][0]==(char)NULL)  {
         /* no more hostnames */
         break;
      }
      else  {
         strcpy(hostname,argv[i]);

         /* open RCL socket */
         err=rcl_open(hostname, &dumaddr, errmsg);
         if (err!=RCL_ERR_NONE)  {
            fprintf(stderr,"Error opening network connection for %s: %s\n",
                                                            hostname, errmsg);
            exit(err);
         }
      }
   }

   /* get current terminal type */
   term=getenv("TERM");
   if (term==NULL)  {
      fprintf(stderr,"Terminal type (environment variable TERM) not defined\n");
      exit(1);
   }

   fprintf(stderr,"Using terminal type %s\n",term);
   rcl_delay(1500);    /* wait a bit so user can see */

   /* initialize curses (don't use fprintf(stderr,...) anymore after this) */
#ifdef SYSV
   /* Solaris */
   if (initscr()==NULL)  {
#else
   /* SunOS 4.x, Linux */
   strcpy(Def_term,term);
   if (initscr()==ERR)  {
#endif
      fprintf(stderr,"Error from curses initscr() (not enough memory?)\n");
      exit(1);
   }

   /* set character-by-character mode, no echoing */
   cbreak();
   noecho();
   scrollok(stdscr,TRUE);         /* allow scrolling */
   printf("\n\n");       /* move down a couple of lines */

   if (hostname[0]!=(char)NULL)  {
      /* list currently open network connections */
      execute("open");
   }
   else  {
     printf("Use 'open' command to establish RCL network connections.");
   }
#endif UNIX

#ifdef DOS
   clrscr();                  /* clear the screen */
#endif DOS
   printf("\n\n");            /* move down a couple of lines */

   /* Main loop: input user commands and execute them */
   while (!EndProgram)  {
      err=control(command);
      /* retry until we get a valid non-null command */
      if (err!=RCL_ERR_NONE || command[0]==(char)NULL)
         continue;

#ifdef UNIX
      /* for UNIX (network RCL) case we support sending the same command to
           several S2s if broadcast address is selected */
      if (S2Addr==RCL_ADDR_BROADCAST)  {
         /* Get first parm (the command word) */
         pos=0;
         nextparm(command,parm,&pos,PARM_DELIM);

         /* skip for the following (local) commands */
         if (strne(parm,"addr") && strne(parm,"open") && strne(parm,"close")
               && strne(parm,"debug") && strne(parm,"version")
               && strne(parm,"end") && strne(parm,"quit"))  {
            rcl_open_list(&naddr, addr_list);
            if (naddr==0)  {
               printf("Local error: No network connections open\n");
               continue;
            }

            /* cycle through all reference addresses */
            for (i=0; i<naddr; i++)  {
               S2Addr=addr_list[i];
               printf("\n");
               printf("(%s:)\n",rcl_addr_to_hostname(S2Addr));
               /* We don't examine error code --- execute() should print msg */
               execute(command);
            }
            S2Addr=RCL_ADDR_BROADCAST;
            continue;
         }
      }
#endif UNIX

      printf("\n");

      /* We don't examine error code --- execute() should print message */
      execute(command);
   }


   err=rcl_shutdown();
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Error shutting down RCL: %d\n",err);
      exit(err);
   }

#ifdef UNIX
   /* shut down curses */
   nocbreak();
   echo();
   endwin();
   fflush(stdout);     /* Just in case exit cuts off last bit of I/O */
#endif UNIX

   return(0);             /* end program */
}

#ifdef DOS
void chandler(void)
{
   printf("\n*** Control-C pressed, RCLCO terminating ***\n");
   ttclose();      /* reset serial port and vector */
   fcloseall();    /* close any files (Borland library call) */
   exit(1);
}
#endif DOS


