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

#define NULLPTR (char *) 0
#define PERMISSIONS 0666
#define ULIMIT 40960L
#define MAX_BUF 512
/* not Y10K compliant */
#define FIRST_CHAR 21

extern struct fscom *shm_addr;
long ulimit();

main()
{
    int i;
    int cls_rcv();
    int kp=0, kack=0, kxd=FALSE, kxl=FALSE, fd=-1;
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
    int kdebug;
    char *st;

/* SECTION 1 */
    
    setup_ids();
    sig_ignore();
    lnamef[0]='\0';
    if(ULIMIT > ulimit(1,ULIMIT))
	ulimit(2, ULIMIT); /* set maximum log size to 20 megabytes */

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
      printf("%s\n", buf);
      goto Messenger;
    }
    if (memcmp(cp2,"tr",2)==0){
      printf("%s", buf);
      goto Messenger;
    }
    if(rtn2 == -1) goto Bye;
   
/* SECTION 3 */

    if(memcmp(cp2,"nl",2)==0){
      if (*lnamef != '\0') 
        {
          err = close(fd);
          if(err<0) perror("closing file");
        }
      strcpy(lnamef,"/usr2/log/");
      memcpy(sllog, shm_addr->LLOG, 8);
      llogndx = memccpy(sllog, shm_addr->LLOG, ' ', 8);
      if(llogndx==NULLPTR) *(sllog+8) = '\0';
      else *(llogndx-1) = '\0';
      strcat(lnamef, sllog);
      strcat(lnamef, ".log");
      fd = open(lnamef, O_RDWR|O_SYNC );
      if(fd >= 0) {
        offset= lseek(fd, 0L, SEEK_END);
        if (offset > 0) {
          offset=lseek(fd, -1L, SEEK_END);
          if (offset < 0) perror("DDOUT: error positioning log file");
          read(fd,&ch,1);
          if(ch != '\n') write(fd, "\n", 1);
        }
        if(strcmp(shm_addr->LLOG, llog0)!=0) memcpy(llog0, shm_addr->LLOG,8);
        goto Append;  /* always write first message */
      }
      while (fd < 0) {  /* if open failed, try creating the file */
        fd = creat(lnamef, PERMISSIONS);
        if(fd<0){
          /* try previous log file now */
          memcpy(sllog0, llog0, 8);
          llogndx = memccpy(sllog0,llog0, ' ', 8);
          if(llogndx==NULLPTR) *(sllog0+8) = '\0';
          if (strcmp(sllog, sllog0)==0) {
            printf("trouble creating file\n");
            strcpy(lnamef, "        ");
            goto Trouble;
          }
          strcpy(sllog, sllog0);
          strcpy(lnamef, "/usr2/log/");
          strcat(lnamef, sllog);
          strcat(lnamef, ".log");
          fd = open(lnamef, O_RDWR|O_SYNC );
        }
        chmod(lnamef,PERMISSIONS);
      }    /* end while   */
      if(strcmp(shm_addr->LLOG, llog0)!=0) memcpy(llog0, shm_addr->LLOG,8);
    }

/* SECTION 4 */

    strcpy(buf2,buf);
    kack = (buf[FIRST_CHAR-1] == '/');
    if(kack) {
      ich = memchr(buf+FIRST_CHAR, '/', bufl-FIRST_CHAR);
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

    st="/form/debug:";
    kdebug=strncmp(buf+FIRST_CHAR-1,st,strlen(st))==0;
    st="#matcn#debug:";
    kdebug = kdebug || strncmp(buf+FIRST_CHAR-1,st,strlen(st))==0;

/* SECTION 5 */
/*  error recognition and message expansion */

    kp = (buf[FIRST_CHAR-1] == '$');
    if(kxd || (rtn2 == -1) || (!kp && !kack &&!kdebug)){
      if (*cp2 != 'b') goto Append;
      iwhe = NULL;
      iwhs = NULL;
      iwl =  0;
      iwhs = memchr(buf+FIRST_CHAR, '(', bufl-FIRST_CHAR);
      if(iwhs != NULL) {
        iwhe = memchr(iwhs+1, ')',bufl-(iwhs+1-buf));
        if (iwhe != NULL){
          iwl = 4 < iwhe-iwhs+1 ? 4 : iwhe-iwhs-1;
          strncpy(iwhat, iwhs+1, iwl);
        }
      }
      else iwhs = buf + bufl + 1;

      if(strncmp(buf+FIRST_CHAR+6,"un",2)==0) {
	int ierr;
        strncpy(ibur,buf+FIRST_CHAR+8,5);
	ibur[5]='\0';
	if(1==sscanf(ibur,"%d",&ierr) && ((sys_nerr>=ierr) && (ierr >=0))) {
	  strncpy(ibur,sys_errlist[ierr],80);
	  if(strlen(sys_errlist[ierr])>(80-1))
	    ibur[79]='\0';
	} else {
	  ibur[0]='\0';
	}
      } else {
	class=0;
	cls_snd(&class, buf, 80, 0, 0);
	ip[0]=class;
	skd_run("fserr", 'w', ip); 
	skd_par(ip);
	iburl=cls_rcv(ip[0], ibur, 118, &rtn1f, &rtn2f, 0,0);
	/*      iburl=0;
	 */
	ibur[iburl]='\0';
	if((iburl==4) && (strncmp(ibur, "nono", 4) == 0)) {
	  ibur[0]='X';
	  goto Append;
	}

	if(iwl != 0){
	  dxpm(ibur, "?W", &ptrs, &irgb); 
	  if(ptrs != NULL) {
	    iwm= irgb < iwl? irgb: iwl;
	    memcpy(ptrs,iwhat,iwm);
	  }
	}
	memcpy(iwhs,"  ",2);
      }
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
/* not Y10K compliant */
      printf("%.8s",buf+9);
/* not Y10K compliant */
      printf("%s",buf+20);
      if (*cp2 == 'b')
	printf("\007");
      printf("\n");
    }

/* SECTION 6 */
/*  write information to the log file if conditions are met */

    if (fd >= 0 && (kxl || (!kp && !kack) || memcmp(cp2,"nl",2)==0)) {
      strcat(buf,"\n");
      bull = strlen(buf);
      if(bull != write(fd, buf, bull)) {
	printf("!! wrong length written, file probably too large\n");
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
    printf("\007!! help! ** error writing log file %.8s\n",sllog);
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
