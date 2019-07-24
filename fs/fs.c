#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <termio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_PIDS    30
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
/*                                                                  */

long cls_alc();
void shm_att(),sem_att(),cls_ini(),brk_ini();
long rte_secs();
int parse();
char *fgets();
FILE *fopen();
static void nullfcn();

static int npids, pids[ MAX_PIDS], ipids;
static char p_names[MAX_PIDS][6];
extern struct fscom *shm_addr;
static long ip[]={0,0,0,0,0};

main()
{
    int i, ampr, wpid, status, size, err, okay, nsems, les, lesm, lesam, lesm2;
    int klesam;
    FILE *fp;
    char *s1, line[ MAX_LINE], line2[ 5+MAX_LINE];
    char *argv[ MAX_PROG_ARGS], *name;
    key_t key;

    klesam=FALSE;
    okay = FALSE;
    npids=0;
    ipids=-1;

    setup_ids();

    if(shm_addr->time.secs_off == 0)
      shm_addr->time.secs_off = rte_secs();

             /* ignore signals that might accidently abort */
             /* note this behaviour trickles down by default to all children */

    if (-1==sigignore(SIGINT)) {
      perror("fs: ignoring SIGINT");
      exit(-1);
    }

    if (-1==sigignore(SIGQUIT)) {
      perror("fs: ignoring SIGQUIT");
      exit(-1);
    }

    if ( 1 == nsem_take("fs   ",1)) {
       fprintf( stderr,"fs already running\n");
         exit( -1);
    }

    key=CLS_KEY;
    cls_ini( key);

    key = SKD_KEY;
    skd_ini( key);

    key = BRK_KEY;
    brk_ini( key);

    if( -1 == (shm_addr->iclopr=cls_alc())) {
      fprintf( stderr," iclopr allocation failed\n");
        exit( -1);
    }

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
        if(0 != parse(&line2[5],MAX_LINE,line, &ampr,&les,&name)) goto cleanup;
        if (!ampr) {
           fprintf( stderr,"running %5.5s\n",name);
           if( (err=start_prog(argv,'n')) < 0) {
             fprintf( stderr," error return %d\n", err);
             goto cleanup;
           }
        } else {
          if( ++ipids >= MAX_PIDS) {
             fprintf( stderr,"too many programs, max is %d\n",MAX_PIDS);
             goto cleanup;
          }
          fprintf( stderr,"getting %s\n",name);
          pids[ ipids]=start_prog(argv,'w');
          if( pids[ ipids] <= 0) {
            fprintf( stderr," error starting process\n");
            goto cleanup;
          }
          s1=strncpy( p_names[ ipids], name, 6);
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
          if(0!= parse(&line2[5],MAX_LINE,line, &ampr,&les,&name)) goto cleanup;
          if (!ampr) {
             fprintf( stderr,"running %5.5s\n",name);
             if( (err=start_prog(argv,'n')) < 0) {
               fprintf( stderr," error return %d\n", err);
               goto cleanup;
             }
          } else {
            if( ++ipids >= MAX_PIDS) {
               fprintf( stderr,"too many programs, max is %d\n",MAX_PIDS);
               goto cleanup;
            }
            fprintf( stderr,"getting %s\n",name);
            pids[ ipids]=start_prog(argv,'w');
            if( pids[ ipids] <= 0) {
              fprintf( stderr," error starting process\n");
              goto cleanup;
            }
            s1=strncpy( p_names[ ipids], name, 6);
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
          cls_snd( &(shm_addr->iclbox), "", -1, 'fs', -1);

    if (SIG_ERR==sigset(SIGINT,SIG_DFL)) {
      perror("fs: restoring default action for SIGINT");
    }

    if (SIG_ERR==sigset(SIGQUIT,SIG_DFL)) {
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
    exit( 0);
}

int parse(line2,maxl,line,ampr,les,name)
char *line2,*line,**name;
int maxl,*ampr,*les;
{
    int i;
    char *ptr;

    if(NULL==(*name=strtok(line," "))) {
      printf(" error1\n");
      return -1;
    }

    
    if(NULL==(ptr=strtok(NULL," "))) {
      printf(" error 2\n");
      return -1;
    } else if (strlen(ptr) == 1 && *ptr == 'n') {
      *les=0;
    } else if (strlen(ptr) == 1 && *ptr == 'l') {
      *les=1;
    } else if (strlen(ptr) == 2 && *ptr == 'l' && *(ptr+1) == 'a') {
      *les=-1;
    } else {
      printf(" error 2a\n");
      return -1;
    }

    if(NULL==(ptr=strtok(NULL,""))) {
      printf(" error 3\n");
      return -1;
    } else if (strlen(ptr) >= maxl) {
      printf(" error 3a\n");
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
        fprintf(2,"exec failed on %s\n",argv[0]);
        _exit(-2);
    }
    if (w != 'n') return chpid;

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
