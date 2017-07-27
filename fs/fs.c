#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <termio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdbool.h>

#include "../include/ipckeys.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_PIDS    60
#define MAX_LINE    82
#define MAX_PROG_ARGS    4

/*                                                                  */
/*   FS acts like a UNIX shell, initializing and starting the       */
/*   required Field System programs. FS activates the programs      */
/*   listed in the files fspgm.ctl and stpgm.ctl. Each line in      */
/*   these control files is a system command to start a program.    */
/*                                                                  */

/*                                                                  */
/* HISTORY:                                                         */
/* WHO  WHEN    WHAT                                                */
/* weh  92????  Created                                             */
/* gag  920922  Added code for stpgm.ctl, station control file.     */
/* rdg  010521  Modified start_prog status check from <0 to !=0     */
/*              and added statusprt() to the error condition.       */
/* rdg  010529  Interchange of 'n' for nowait and 'w' for wait      */
/*              status for consistency.                             */

long cls_alc();
void shm_att(),sem_att(),cls_ini(),brk_ini();
int parse();
char *fgets();
FILE *fopen(), *tee;
static void nullfcn();

void setup_ids();
void skd_ini(int);

static int npids, pids[ MAX_PIDS], ipids;
static char p_names[MAX_PIDS][6];
extern struct fscom *shm_addr;
static long ip[]={0,0,0,0,0};


#ifndef FS_NO_DISPLAY_SERVER
void start_server(bool, bool);
#endif

#ifdef FS_NO_DISPLAY_SERVER
#define USAGE_SHORT "Usage: %s [-nh]\n"
#else
#define USAGE_SHORT "Usage: %s [-bnh]\n"
#endif

const char *usage_long_str = USAGE_SHORT "\n"
"Start the VLBI Field System and programs listed in and stnpgm.ctl\n"
"  -n, --no-x          Do not start programs requiring X11\n"
"  -h, --help          print this message\n"
#ifndef FS_NO_DISPLAY_SERVER
"  -b, --background    run the Field System in background/daemon mode\n"
#endif
;

main(int argc_in,char *argv_in[])
{
    int i, ampr, wpid, status, size, err, okay, nsems;
    int les=-1, lesm=-1, lesam=-1, lesm2=-1;
    int klesam;
    FILE *fp;
    char *s1, line[ MAX_LINE], line2[ 5+MAX_LINE], file[MAX_LINE];
    char *argv[ MAX_PROG_ARGS], *name;
    short fs;
    key_t key;
    time_t ti;
    struct tm *tm;
    int kfirst=TRUE;
    int normal=FALSE;
    int iret;
    int val;

	bool arg_background = false;
	bool arg_no_x11 = false;

	static struct option long_options[] = {
	    {"background", no_argument, NULL, 'b'},
	    {"no-x",       no_argument, NULL, 'n'},
	    {"help",       no_argument, NULL, 'h'},

	    {NULL, 0, NULL, 0},
	};

    /*
    if( (val = fcntl(STDERR_FILENO, F_GETFL, 0)) <0) {
      perror("STDERR F_GETFL");
      exit(-1);
    }
    val |= O_SYNC;
    if( fcntl(STDERR_FILENO, F_SETFL, val) <0) {
      perror("STDERR F_SETFL");
      exit(-1);
    }
    */

	int opt;
	int option_index;
	while ((opt = getopt_long(argc_in, argv_in, "bnh", long_options,
	                          &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are handled by their short form
			break;
		case 'b':
#ifdef FS_NO_DISPLAY_SERVER
            fprintf(stderr, "fs build without server, background option not available");
			exit(EXIT_FAILURE);
#endif
			arg_background = true;
			arg_no_x11     = true;
			break;
		case 'n':
			arg_no_x11 = true;
			break;
		case 'h':
			fprintf(stderr, usage_long_str, argv_in[0]);
			exit(EXIT_SUCCESS);
			break;
		default: /* '?' */
			fprintf(stderr, USAGE_SHORT, argv_in[0]);
			exit(EXIT_FAILURE);
		}
	}


    ti=time(NULL);
    tm=gmtime(&ti);
    (void) strftime(file,MAX_LINE,"~/fs.%Y.%b.%d.%H.%M.%S.err",tm);
    strcpy(line,"/usr/bin/tee ");
    strcat(line,file);
    
             /* ignore signals that might accidently abort */
             /* note this behaviour trickles down by default to all children */

    if (SIG_ERR==signal(SIGINT,SIG_IGN)) {
      perror("fs: ignoring SIGINT");
      exit(-1);
    }

    if (SIG_ERR==signal(SIGQUIT,SIG_IGN)) {
      perror("fs: ignoring SIGQUIT");
      exit(-1);
    }

    tee = popen(line,"w");
    if(tee!=NULL) {
      setvbuf(tee, NULL, _IONBF, BUFSIZ);
      dup2(fileno(tee),STDERR_FILENO);
    } else
      perror("opening tee to fs.err file");

    strncpy((char *)&fs,"fs",2);


    klesam=FALSE;
    okay = FALSE;
    npids=0;
    ipids=-1;

    setup_ids();


    if(100!=sysconf(_SC_CLK_TCK)) {
      printf("sysconf(_SC_CLK_TCK) not equal to 100 on this system,");
      printf(" measured value is %ld.\nFS can't run, aborting.\n",
	      sysconf(_SC_CLK_TCK));
	exit(-1);
    }
    if(shm_addr->time.init_error==-1) {
      errno=shm_addr->time.init_errno;
      perror("fsalloc: rte_secs() using times()");
      exit(-1);
    } else if(shm_addr->time.init_error ==-2) {
      errno=shm_addr->time.init_errno;
      perror("fsalloc: rte_secs() using gettimeofday()");
      exit(-1);
    } else if(shm_addr->time.init_error != 0) {
      perror("fsalloc: rte_secs() unknown error()");
      exit(-1);
    }
    //    exit(-1);

#ifndef FS_NO_DISPLAY_SERVER
	if (nsem_test("fs   ")) {
		printf("fs already running, reconnect with `fsclient`\n");
		exit(EXIT_FAILURE);
	}
	start_server(arg_background, arg_no_x11);
    // With the server, "fs" should not start any X11 programs itself
    arg_no_x11 = true;
#endif

    if ( 1 == nsem_take("fs   ",1)) {
       fprintf( stderr,"fs already running\n");
         exit( -1);
    }
    if ( 1 == nsem_test("fmset")) {
      fprintf( stderr,
	       "fmset is still running, fs can't start until it terminates\n");
      exit(-1);
    }

    if ( 1 == nsem_take("fsctl",1)) {
       fprintf( stderr,"fsctl semaphore failed\n");
         exit( -1);
    }

    key=CLS_KEY;
    cls_ini( key);

    key = SKD_KEY;
    skd_ini( key);

    key = BRK_KEY;
    brk_ini( key);

    shm_addr->iclopr=-1;

    if( -1 == (shm_addr->iclbox=cls_alc())) {
      fprintf( stderr," iclbox allocation failed\n");
        exit( -1);
    }
/*  fprintf( stderr," iclopr %d iclbox %d\n",shm_addr->iclopr,
    shm_addr->iclbox);
*/
    argv[0]="sh";
    argv[1]="-c";
    argv[2]=line2;
    argv[3]=NULL;
    lesm=-1;
    lesam=-1;
    s1=strcpy( line2, "exec ");
    if((fp = fopen( FSPGM_CTL, "r")) == NULL) {
       fprintf( stderr, " can't open %s\n", FSPGM_CTL);
        exit( -1);
    }
  
    while( NULL != fgets( line, MAX_LINE, fp) ) {
      if (line[0] != '*') {
        if( (s1= strrchr( line, '\n')) != NULL) 
           *s1='\0';
	if(0 != parse(&line2[5],MAX_LINE,line, &ampr,&les,&name))
	  goto cleanup;
	if(les==2) {
	  if(arg_no_x11) {
#ifdef FS_NO_DISPLAY_SERVER
	    fprintf(stderr, "skipping %5.5s, the -No_X option selected\n",name);
#endif
	    continue;
	  } else
	    les=0;
	}
        if (!ampr) {
           fprintf( stderr,"running %5.5s\n",name);
           if( (err=start_prog(argv,'w')) != 0) {
	     fprintf(stderr,"%5.5s terminated",name);
	     statusprt(err);
	     fprintf(stderr,"\n");
             goto cleanup;
           }
        } else {
          if( ++ipids >= MAX_PIDS) {
             fprintf( stderr,"too many programs, max is %d\n",MAX_PIDS);
             goto cleanup;
          }
          fprintf( stderr,"getting %s\n",name);
          pids[ ipids]=start_prog(argv,'n');
          if( pids[ ipids] <= 0) {
            fprintf( stderr," error starting process\n");
            goto cleanup;
          }
          s1=strncpy( p_names[ ipids], name, 6);
          p_names[ ipids][5]=0;
          if (les >0) {
            if (lesm < 0) lesm=ipids;
             else {
               lesm2=ipids;
               fprintf( stderr," more than one LES Manager\n");
              /* goto cleanup;*/
             }
          }

          if (les <0) {
             if (lesam < 0) lesam=ipids;
             else {
               fprintf( stderr," more than on LES Assistant Manager\n");
               goto cleanup;
             }
          }
          npids++;
        }
      }
    }

    s1=strcpy( line2, "exec ");
    if((fp = fopen( STPGM_CTL, "r")) == NULL) {
       fprintf( stderr, " can't open %s\n", STPGM_CTL);
    }
    else {
      while( NULL != fgets( line, MAX_LINE, fp) ) {
        if (line[0] != '*') {
          if( (s1= strrchr( line, '\n')) != NULL) 
             *s1='\0';
	  if(0!= parse(&line2[5],MAX_LINE,line, &ampr,&les,&name))
	    goto cleanup;
	  if(les==2) {
	    if(arg_no_x11) {
#ifdef FS_NO_DISPLAY_SERVER
	      fprintf( stderr,"skipping %5.5s, the -No_X option was selected\n",name);
#endif
	      continue;
	    } else
	      les=0;
	  }
          if (!ampr) {
             fprintf( stderr,"running %5.5s\n",name);
	     if( (err=start_prog(argv,'w')) != 0) {
	       fprintf(stderr,"%5.5s terminated",name);
	       statusprt(err);
	       fprintf(stderr,"\n");
               goto cleanup;
             }
          } else {
            if( ++ipids >= MAX_PIDS) {
               fprintf( stderr,"too many programs, max is %d\n",MAX_PIDS);
               goto cleanup;
            }
            fprintf( stderr,"getting %s\n",name);
            pids[ ipids]=start_prog(argv,'n');
            if( pids[ ipids] <= 0) {
              fprintf( stderr," error starting process\n");
              goto cleanup;
            }
            s1=strncpy( p_names[ ipids], name, 6);
	    p_names[ ipids][5]=0;
            npids++;
          }
        }
      }
    }
     okay=TRUE;
     skd_run("boss ",'n',ip);
     goto waitfor;

/* kill everybody, except LES and LESAM who are terminated by LES when    */
/* we send the message to LES, however, if LES is already dead then  kill */
/* LESAM */

cleanup:
       okay=FALSE;
       if (npids > 0)
         for (i=0;i<=ipids;i++)
           if (i != lesm && i != lesam && i!= lesm2 && pids[ i] != 0 ||
               i == lesam && pids[ lesm] == 0 ) {
             if ( -1 == kill( pids[ i], SIGKILL))
                fprintf( stderr,"can't kill pid %d\n", pids[ i]);
             else if(i==lesam)
                klesam=TRUE;
           }

/* send a message to LES manager to terminate */
       if(lesm >=0 && pids[lesm] != 0 )
          cls_snd( &(shm_addr->iclbox), "", -1, fs, -1);

    if (SIG_ERR==signal(SIGINT,SIG_DFL)) {
      perror("fs: restoring default action for SIGINT");
    }

    if (SIG_ERR==signal(SIGQUIT,SIG_DFL)) {
      perror("fs: restoring default action for SIGQUIT");
    }

waitfor:    
     while (npids > 0) {
       if(npids==1 && pids[lesam] !=0) {
         if(signal(SIGALRM,nullfcn) == SIG_ERR){
            perror("fs: setting up alarm catch fcn");
            exit(-1);
         }
         rte_alarm( (unsigned) 200);
         if((wpid=wait(&status))==pids[lesam]) {
            if(!klesam)
              fprintf(stderr,"%s terminated\n",p_names[lesam]);
            else
              fprintf(stderr,"%s killed\n",p_names[lesam]);
            goto exit;
         }
         if (-1 == kill( pids[ lesam], SIGKILL))
            fprintf( stderr,"can't kill pid %d\n", pids[ lesam]);
         else
            klesam=TRUE;
       }
       while((wpid=wait(&status)) == -1);
       if(kfirst) {
	 normal=WIFEXITED(status) && (WEXITSTATUS(status)==0);
#ifdef DEBUG
	 fprintf(stderr," status %x %d %d \n",status,WIFEXITED(status),
		 WEXITSTATUS(status));
#endif
	 kfirst=FALSE;
       }
       for (i=0;i<=ipids;i++) {
          if(wpid==pids[i]) {
            pids[i]=0;
            if(okay) {
              fprintf(stderr,"%s terminated",p_names[i]);
              statusprt(status);
              fprintf(stderr,"\n");
            } else if(i==lesm||i==lesam && !klesam)
              fprintf(stderr,"%s terminated\n",p_names[i]);
            else
              fprintf(stderr,"%s killed\n",p_names[i]);
            break;
         }
       }
       npids--;
       if(okay) goto cleanup;
     }
 exit:
     if(ioctl(0,TCFLSH,0)==-1)
       perror("fs: flushing input queue");
    
     if(normal && shm_addr->abend.normal_end && !shm_addr->abend.other_error) {
       strcpy(line,"rm ");
       strcat(line,file);
       
       iret=system(line);
       if(iret==-1)
	 perror("deleting fs.err file");
       else if(iret==127)
	 perror("execve() call for /bin/sh failed deleting fs.err file");
       else if(iret!=0)
	 fprintf(stderr,"rm returned %d deleting fs.err file\n",iret);
     }
     
     /*     fsync(STDERR_FILENO);*/
     rte_sleep(1);
     exit( 0);
    
}

int parse(line2,maxl,line,ampr,les,name)
char *line2,*line,**name;
int maxl,*ampr,*les;
{
    int i;
    char *ptr;

    if(NULL==(*name=strtok(line," "))) {
      fprintf(stderr," error1\n");
      return -1;
    }

    
    if(NULL==(ptr=strtok(NULL," "))) {
      fprintf(stderr," error 2\n");
      return -1;
    } else if (strlen(ptr) == 1 && *ptr == 'n') {
      *les=0;
    } else if (strlen(ptr) == 1 && *ptr == 'x') {
      *les=2;
    } else if (strlen(ptr) == 1 && *ptr == 'l') {
      *les=1;
    } else if (strlen(ptr) == 2 && *ptr == 'l' && *(ptr+1) == 'a') {
      *les=-1;
    } else {
      fprintf(stderr," error 2a, for program '%s', non-allowed program type '%s'\n",
	      *name,ptr);
      return -1;
    }

    if(NULL==(ptr=strtok(NULL,""))) {
      fprintf(stderr," error 3\n");
      return -1;
    } else if (strlen(ptr) >= maxl) {
      fprintf(stderr," error 3a\n");
      return -1;
    }
    ptr=strncpy(line2,ptr,maxl);

    for (i=strlen(line2)-1; i >= 0 && line2[ i] == ' '; i--)
        ;
    if( *ampr = (i >= 0 && line2[ i] == '&')) 
      line2[i]='\0';
     
    return 0;
}
int start_prog(argv,w)
char **argv,w;
{
    int chpid,i,wpid,status;

    switch(chpid=fork()){
      case -1:
        return -1;
      case 0:
        i=execvp(argv[0],argv);
        fprintf(stderr,"exec failed on %s\n",argv[0]);
        _exit(-2);
    }
    if (w == 'n') return chpid;

    while((wpid=wait(&status))!=chpid && wpid != -1) {
       for (i=0;i<=ipids;i++) {
          if(wpid==pids[i]) {
            pids[i]=0;
            fprintf(stderr,"%5.5s terminated",p_names[i]);
            statusprt(status);
            fprintf(stderr,"\n");
            return -4;
            break;
          }
       }
       npids--;
    }

    if(wpid == -1) return -3;

    return ( status);
}
static void nullfcn(sig)
int sig;
{

  if(signal(SIGALRM,SIG_DFL) == SIG_ERR){
    perror("fs: setting default alarm signal action");
    exit(-1);
  }
  return;
}

