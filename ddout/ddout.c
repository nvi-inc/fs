#include <memory.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

extern char *sys_errlist[];

#define NULLPTR (char *) 0
#define PERMISSIONS 0666
#define ULIMIT 40960L
#define MAX_BUF 120

long ulimit();
unsigned short getgid(), getuid();

FILE *stream[5];

main()
{
    int i;
    int cls_rcv();
    int kp=0, kack=0, kxd=FALSE, kxl=FALSE, fd;
    int iwl, iw1, iwm;
    char *llogndx;
    int irga;
    long ip[5];
    char lnamef[65];
    char ibur[120];
    char buf[MAX_BUF+2];
    char buf2[MAX_BUF+2];
    char *iwhs, *iwhe;
    char bul[MAX_BUF+2];
    char llog0[9];
    char sllog[9], sllog0[9];
    int rtn1, rtn2, status, bufl, bull, rtn1f, rtn2f;
    int irgb, iburl;
    int err=0;
    char *ich, *cp1, *cp2, ch, iwhat[5], *ptrs;
    long class;
    long offset;
    long lseek();
    void dxpm();
    FILE *streamt;
    char idevlog[5][65];
    char holds[15];
    int fdt, iret, lineset(), n, j;
    struct {
       long iclass;
       long baud;
       int  iadd;
       int  bits;
       int  stop;
       int  parity;
       char dev[66];
       char wora[2];
    } logout;

/* SECTION 1 */
    
    setup_ids();
    sig_ignore();
    if(ULIMIT > ulimit(1,ULIMIT))
	ulimit(2, ULIMIT); /* set maximum log size to 20 megabytes */
    if(-1 == setgid((int) getgid())){
        printlo("Error reseting gid%s\n","");
        printlo("ddout:%s\n",sys_errlist[errno]);
    }
    if(-1 == setuid((int) getuid())){ 
        printlo("Error reseting uid%s\n","");
        printlo("ddout:%s\n",sys_errlist[errno]);
    }


/* SECTION 2 */

    memcpy(llog0, shm_addr->LLOG, 8);

Messenger:
    /* get next message */
    
    status = cls_rcv(shm_addr->iclbox,buf,MAX_BUF,&rtn1,&rtn2,0,1);
    bufl = status;
    /* set buf up as a string */
    *(buf+bufl)='\0';
    strcpy(bul,buf);
    bull=bufl;
    cp2 = (char *) &rtn2;
    if (memcmp(cp2,"dn",2)==0){
      kxd = TRUE;
      goto Messenger;
    }
    if (memcmp(cp2,"df",2)==0){
      kxd = FALSE;
      goto Messenger;
    }
    if (memcmp(cp2,"ln",2)==0){
      kxl = TRUE;
      goto Messenger;
    }
    if (memcmp(cp2,"lf",2)==0){
      kxl = FALSE;
      goto Messenger;
    }
    if (memcmp(cp2,"to",2)==0){
      printlo("%s\n", buf);
      goto Messenger;
    }
    if (memcmp(cp2,"tr",2)==0){
      printlo("%s", buf);
      goto Messenger;
    }
    if (memcmp(cp2,"lo",2)==0){		/* open new log output */
      memcpy(&logout,buf,sizeof(logout));
      if (logout.iadd == 0) {			/* close existing files */
        for (i=0;i<shm_addr->ndevlog;i++) {
           if(0 != fclose(stream[i])) {
             printlo("Error closing log out file: %s\n",idevlog[i]);
             printlo("ddout:%s\n",sys_errlist[errno]);
           }
        }
        shm_addr->ndevlog=0;
      }
      if (shm_addr->ndevlog >=5) {
        ip[2]=1;			/* too many files already open */
        cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
      } else if (strlen(logout.dev) == 0) {
        ip[2]=0;			/* no new file to open */
        cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
        goto Messenger;
      } else {
        if (logout.baud != 0L) {
          fdt=open(logout.dev,O_WRONLY);
        } else if (logout.wora[0]=='a') {
          fdt=open(logout.dev,O_WRONLY|O_APPEND);
        } else {
          fdt=open(logout.dev,O_WRONLY|O_TRUNC);
        }
        if(fdt < 0) {
          if (errno == ENOENT && logout.baud == 0L) {
             fdt = open(logout.dev, O_WRONLY|O_CREAT|O_TRUNC, PERMISSIONS);
             if( fdt < 0) {
               ip[2]=2;			/* error creating file */
               cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
               printlo("ddout:%s\n",sys_errlist[errno]);
               goto Messenger;
             }
             if(-1 == chmod(logout.dev,PERMISSIONS)) {
               ip[2]=3;			/* error setting permissions */
               cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
               printlo("ddout:%s\n",sys_errlist[errno]);
               goto Messenger;
             }
          } else {
            ip[2]=4;			/* error opening file */
            cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
            printlo("ddout:%s\n",sys_errlist[errno]);
            goto Messenger;
          }
        }
        if (logout.baud != 0L) {
          iret=lineset(fdt,logout.baud,logout.parity,logout.bits,logout.stop);
          if(iret != 0) {
            ip[2]=5;			/* error adjusting line protocol */
            cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
            if (iret < 0)
              printlo("ddout:%s\n",sys_errlist[errno]);
            else if(iret == 1)
              printlo("ddout:%s\n","Bad stop bits");
            else if(iret == 2)
              printlo("ddout:%s\n","Bad data bits");
            else if(iret == 3)
              printlo("ddout:%s\n","Bad parity");
            else if(iret == 4)
              printlo("ddout:%s\n","Bad BAUD rate");
            else {
              sprintf(holds,"%d",iret);
              printlo("ddout:lineset returned unknown error %s\n","");
            }
            goto Messenger;
          }
          streamt=fdopen(fdt,"a");
        } else {
          streamt=fdopen(fdt,logout.wora);
        }
        if(streamt == NULL) {
          ip[2]=6;		/* error associating file with stream */
          cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
          printlo("ddout:%s\n",sys_errlist[errno]);
          goto Messenger;
        } else {
          j=sizeof(shm_addr->idevlog[n]);
          strncpy(shm_addr->idevlog[n=shm_addr->ndevlog],logout.dev,j);
          i=strlen(logout.dev);
          if ( i < j)
               memset(shm_addr->idevlog[n]+i,' ',j-i);
          strncpy(idevlog[n],logout.dev,sizeof(idevlog[n]));
          stream[n++]=streamt;
          shm_addr->ndevlog=n;
          ip[2]=0;			/* everything okay */
          cls_snd(&logout.iclass, ip, sizeof(ip), 0, 0);
          goto Messenger;
        }
      }
    }
      
    if(rtn2 == -1)
      goto Bye;
   
/* SECTION 3 */

    if(memcmp(cp2,"nl",2)==0){
      if (*lnamef != '\0') {
          err = close(fd);
          if(err<0) {
            printlo("Error closing old log file: %s\n",lnamef);
            printlo("ddout:%s\n",sys_errlist[errno]);
          }
      }
      strcpy(lnamef,"/usr2/log/");
      memcpy(sllog, shm_addr->LLOG, 8);
      llogndx = memccpy(sllog, shm_addr->LLOG, ' ', 8);
      if(llogndx==NULLPTR)
        *(sllog+8) = '\0';
      else
        *(llogndx-1) = '\0';
      strcat(lnamef, sllog);
      strcat(lnamef, ".log");
      fd = open(lnamef, O_RDWR|O_SYNC );
      if(fd > 0) {
        offset= lseek(fd, 0L, SEEK_END);
        if (offset > 0) {
          offset=lseek(fd, -1L, SEEK_END);
          if (offset < 0) {
            printlo("Error positioning to last byte in log file: %s\n",lnamef);
            printlo("ddout:%s\n",sys_errlist[errno]);
          }
          ch=0;
          n=read(fd,&ch,1);
          if (n< 0) {
            printlo("Error reading last byte in log file: %s\n",lnamef);
            printlo("ddout:%s\n",sys_errlist[errno]);
          }
          if(ch != '\n')
            write(fd, "\n", 1);
        } else if (offset < 0) {
           printlo("Error positioning to end of log file: %s\n",lnamef);
           printlo("ddout:%s\n",sys_errlist[errno]);
        }
        if(strcmp(shm_addr->LLOG, llog0)!=0)
          memcpy(llog0, shm_addr->LLOG,8);
        goto Post;  /* log exists, don't write first message */
      }
      while (fd < 0) {  /* if open failed, try creating the file */
        fd = open(lnamef, O_WRONLY|O_CREAT|O_TRUNC|O_SYNC, PERMISSIONS);
        if(fd<0){
           printlo("Error creating log file: %s\n",lnamef);
           printlo("ddout:%s\n",sys_errlist[errno]);

     /* try previous log file now */

          memcpy(sllog0, llog0, 8);
          llogndx = memccpy(sllog0,llog0, ' ', 8);
          if(llogndx==NULLPTR)
            *(sllog0+8) = '\0';
          if (strcmp(sllog, sllog0)==0) {
            printlo("New log file is old log file and it can't be opened%s\n","");
            strcpy(lnamef, "        ");
            goto Trouble;
          }
          strcpy(sllog, sllog0);
          strcpy(lnamef, "/usr2/log/");
          strcat(lnamef, sllog);
          strcat(lnamef, ".log");
          fd = open(lnamef, O_RDWR|O_SYNC );
          if (fd <0 ) {
            printlo("Error re-opening log file: %s\n",lnamef);
            printlo("ddout:%s\n",sys_errlist[errno]);
          }
        }
        if(-1 == chmod(lnamef,PERMISSIONS)) {
           printlo("Error setting permissions on log file: %s\n",lnamef);
           printlo("ddout:%s\n",sys_errlist[errno]);
        }
      }    /* end while   */
      if(strcmp(shm_addr->LLOG, llog0)!=0)
        memcpy(llog0, shm_addr->LLOG,8);
    }

/* SECTION 4 */

    strcpy(buf2,buf);
    kack = (buf[9] == '/');
    if(kack) {
      ich = memchr(buf+10, '/', bufl-11);
      /* ich now points to spot '/' */
      kack = (ich != NULLPTR);
      ich++;
      if (kack) kack = ((ich = strtok(ich, ","))!=NULLPTR && strncmp(ich, "ack ",3)==0);
      if(kack) {
Ack:    ich = strtok(NULL, ",");
        if (ich != NULLPTR) {
          if (strncmp(ich, "ack ", 3) == 0) goto Ack;
          else kack = 0;
        }
      }
    }
    strcpy(buf,buf2);

/* SECTION 5 */
/*  error recognition and message expansion */

    kp = (buf[9] == '$');
    if(kxd || (rtn2 == -1) || (!kp && !kack)){
      if (*cp2 != 'b') goto Append;
      iwhe = NULL;
      iwhs = NULL;
      iwl =  0;
      iwhs = memchr(buf+10, '(', bufl-10);
      if(iwhs != NULL) {
        iwhe = memchr(buf+10, ')', bufl-10);
        if (iwhe != NULL){
          iwl = 4 < iwhe-iwhs+1 ? 4 : iwhe-iwhs-1;
          strncpy(iwhat, iwhs+1, iwl);
        }
      }
      else iwhs = buf + bufl + 1;

      class=0;
      cls_snd(&class, buf, 80, 0, 0);
      ip[0]=class;
      skd_run("fserr", 'w', ip); 
      skd_par(ip);
      iburl=cls_rcv(ip[0], ibur, 80, &rtn1f, &rtn2f, 0,0);
/*      iburl=0;
*/
      ibur[iburl]='\0';
      if((iburl==4) && (strncmp(ibur, "nono", 4) == 0)) { ibur[0]='X';
         goto Append;}
      if(iwl != 0){
        dxpm(ibur, "?W", &ptrs, &irgb); 
        if(ptrs != NULL) {
          iwm= irgb < iwl? irgb: iwl;
          memcpy(ptrs,iwhat,iwm);
        }
      }
      memcpy(iwhs,"  ",2);

/* move returned info into output message for display */
Move:
/*      memcpy(&buf[(int) iwhs+1], ibur, iburl); */
        *iwhs='\0';
        strcat(buf, " ");
        strcat(buf, ibur);
/*      bufl = iwhs - buf + iburl + 1; */

/* append bell if an error */

Append:           /* send message to station error program */
      if(*cp2 == 'b' && shm_addr->sterp !=0) {
        class=0;
        cls_snd(&class, buf, strlen(buf), 0, 0);
        ip[0]=class;
        skd_run("sterp", 'n', ip); 
      }
      if (*cp2 == 'b') strcat(buf, "\007");
      printlo("%s\n", buf);
    }

/* SECTION 6 */
/*  write information to the log file if conditions are met */

    if (kxl || (!kp && !kack)) {
      bull = strlen(bul);
      if(bull != write(fd, bul, bull)) {
	printlo("!! wrong length written, file probably too large%s\n","");
	goto Trouble;
      }
      if(1 != write(fd, "\n", 1)) {
	printlo("!! wrong length written, file probably too large%s\n","");
        goto Trouble;
      }
    }

/* SECTION 7 */
/*  post message to disk, return to caller or to main loop */

Post:
    goto Messenger;

/* SECTION 8 */
/*  routine called if trouble occurs with log file */

Trouble:
    printlo("\007!! help! ** error writing log file %.8s\n",sllog);
    if (rtn2 != -1) goto Messenger;

/* SECTION 9 */
/*  exit from program */

Bye:
    ip[0]=-1;
    skd_run("fserr", 'n', ip); 
    close(fd);

    exit( -1);
}
void dxpm(ibur, ipt, ptrs, len)
char *ibur, *ipt, **ptrs;
int *len;
{
  char last;

  *len=strlen(ipt);
  last=ipt[(*len)-1];
  *ptrs=NULL;
  while(strlen(ibur) >= *len) {
    *ptrs=strchr(ibur,ipt[0]);
    if( *ptrs == NULL) return;
    ibur=*ptrs+*len;
    if(strncmp(*ptrs,ipt,*len) == 0) {
      while (*ibur == last){
        (*len)++;
        ibur++;
      }
      return;
    }
    *ptrs=NULL;
  }
  return;
}
