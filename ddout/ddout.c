#include <memory.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define NULLPTR (char *) 0
#define PERMISSIONS 0666
#define MAX_BUF 512
/* not Y10K compliant */
#define FIRST_CHAR 21

extern struct fscom *shm_addr;

main()
{
    int i;
    int cls_rcv();
    int kp=0, kack=0, kxd=FALSE, kxl=FALSE, fd=-1, kpd=FALSE;
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
    char *ich, *cp1, *cp2, ch, iwhat[5], *ptrs;
    long class;
    long offset;
    long lseek();
    void dxpm();
    int kdebug;
    char *st;
    int kpcald;
    char ierrch[2];
    int ierrnum;
    struct list {
      char ch[2];
      int num;
      struct list *next;
      struct list *previous;
      char *string;
      int on;
      int count;
    } *last = NULL;
    struct list *first=NULL;
    struct list *ptr;
    int display, count;
    char *offon[ ]= {"off","on"};
    int knl=FALSE;

/* SECTION 1 */
    
    setup_ids();
    sig_ignore();
    lnamef[0]=0;
    umask(0);

/* SECTION 2 */

    llog0[0]=0;

Messenger:
    /* get next message */
    
    status = cls_rcv(shm_addr->iclbox,buf,MAX_BUF,&rtn1,&rtn2,0,1);
    bufl = status;
    /* set buf up as a string */
    buf[bufl]=0;
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
    if (memcmp(cp2,"pn",2)==0) {
      kpd = TRUE;
      goto Messenger;
    }
    if (memcmp(cp2,"pf",2)==0) {
      kpd = FALSE;
      goto Messenger;
    }
    if (memcmp(cp2,"tn",2)==0) {
      short ix, iy;
      memcpy(&ix,buf+2,2);
      memcpy(&iy,buf+4,2);
      for(ptr=last;ptr!=NULL;ptr=ptr->previous) {
	if(ptr->num == ix && memcmp(ptr->ch,buf,2)==0) {
	  if(iy == 0) {
	    if(ptr->count==1) {
	      if(ptr->on == 1) {
		logit(NULL,-311,"bo");
		goto Messenger;
	      }
	      ptr->on=1;
	      break;
	    } else {
	      sprintf(buf2,"tnx/more than one %2.2s,%d occurred, use 'tnx=%2.2s,%d,on,#num' to select from list below",ptr->ch,ix,ptr->ch,ix);
	      logitf(buf2);
	      for(ptr=first;ptr!=NULL;ptr=ptr->next) {
		if(ptr->num == ix && memcmp(ptr->ch,buf,2)==0) {
		  sprintf(buf2,"tnx/%2.2s,%d,%s,#%d,%s",
			  ptr->ch,ptr->num,offon[ptr->on],ptr->count,ptr->string);
		  logitf(buf2);
		}
	      }
	      goto Messenger;
	    }
	  } else if(ptr->count == iy || iy < 0) {
	      if(iy > 0 && ptr->on == 1) {
		logit(NULL,-311,"bo");
		goto Messenger;
	      }
	      ptr->on=1;
	      if(iy > 0 || ptr->count == 1)
		break;
	  }
	}
      }
      if(ptr == NULL) { /* not found */
	logit(NULL,-304,"bo");
	goto Messenger;
      }
      goto Messenger;
    }
    if (memcmp(cp2,"tf",2)==0) {
      short ix, iy;
      memcpy(&ix,buf+2,2);
      memcpy(&iy,buf+4,2);
      for(ptr=last;ptr!=NULL;ptr=ptr->previous) {
	if(ptr->num == ix && memcmp(ptr->ch,buf,2)==0) {
	  if(iy == 0) {     
	    if(ptr->count==1) {
	      if(ptr->on == 0) {
		logit(NULL,-312,"bo");
		goto Messenger;
	      }
	      ptr->on=0;
	      break;
	    } else {
	      sprintf(buf2,"tnx/more than one %2.2s,%d, exists, use 'tnx=%2.2s,%d,off,#num' to select from list below",ptr->ch,ix,ptr->ch,ix);
	      logitf(buf2);
	      for(ptr=first;ptr!=NULL;ptr=ptr->next) {
		if(ptr->num == ix && memcmp(ptr->ch,buf,2)==0) {
		  sprintf(buf2,"tnx/%2.2s,%d,%s,#%d,%s",
			  ptr->ch,ptr->num,offon[ptr->on],ptr->count,ptr->string);
		  logitf(buf2);
		}
	      }
	      goto Messenger;
	    }
	  } else if(ptr->count == iy || iy < 0) {
	      if(iy > 0 && ptr->on == 0) {
		logit(NULL,-312,"bo");
		goto Messenger;
	      }
	      ptr->on=0;
	      if(iy > 0 || ptr->count == 1)
		break;
	  }
	}
      }
      if(ptr == NULL) { /* not found */
	logit(NULL,-303,"bo");
	goto Messenger;
      }
      goto Messenger;
    }
    if (memcmp(cp2,"tl",2)==0) {
      int some=0;
      for(ptr=first;ptr!=NULL;ptr=ptr->next) {
	if(ptr->on == 0) {
	  sprintf(buf,"tnx/%2.2s,%d,%s,#%d,%s",
		  ptr->ch,ptr->num,offon[ptr->on],ptr->count,ptr->string);
	  logitf(buf);
	  some=1;
	}
      }
      if(some==0)
	logitf("tnx/disabled");

      goto Messenger;
    }
   
/* SECTION 3 */

    if(memcmp(cp2,"nl",2)==0 || rtn2 == -1){
      knl=TRUE;
      if (fd >=0) {
	fd=recover_log(lnamef,fd);  /* recover log if necessary */
	if(close(fd) < 0) {
	  shm_addr->abend.other_error=1;
	  perror("!! help! ** closing file, ddout");
	}
      }

      if(rtn2 == -1)
	goto Bye;

      strcpy(lnamef,"/usr2/log/");
      llogndx = memccpy(sllog, shm_addr->LLOG, ' ', 8);
      if(llogndx!=NULLPTR) {
	if(llogndx!=sllog)
	  *(llogndx-1)=0;
	else
	  llogndx[0]=0;
      } else
	sllog[8]=0;

      strcat(lnamef, sllog);
      strcat(lnamef, ".log");
      fd = open(lnamef, O_RDWR|O_SYNC|O_CREAT,PERMISSIONS);
      if (fd < 0) {  /* if open/create failed, try recovering */
	shm_addr->abend.other_error=1;
	fprintf(stderr,
		"\007!! help! ** error opening/creating log file %.8s\n",
		sllog);
	perror("!! help! ** ddout");
	  
	/* try previous log file now */
	llogndx = memccpy(sllog0,llog0, ' ', 8);
	if(llogndx!=NULLPTR) {
	  if(llogndx!=sllog0)
	    *(llogndx-1)=0;
	  else
	    llogndx[0]=0;
	} else
	  sllog0[8]=0;
	if (strcmp(sllog, sllog0)!=0 && llog0[0]!=0) {
	  strcpy(sllog, sllog0);
	  strcpy(lnamef, "/usr2/log/");
	  strcat(lnamef, sllog);
	  strcat(lnamef, ".log");
	  fprintf(stderr,
		  "\007!! help! ** now trying to re-open log file %.8s\n",
		  sllog);
	  fd = open(lnamef, O_RDWR|O_SYNC|O_CREAT,PERMISSIONS);
	  if(fd >=0) {
	    memcpy(shm_addr->LLOG,llog0,8);
	    fprintf(stderr,
		    "\007!! help! ** succesfully re-opened log file %.8s\n",
		    sllog);
	  } else {
	    fprintf(stderr,
		    "\007!! help! ** error re-opening log file %.8s\n",sllog);
	    perror("!! help! ** ddout");
	  }
	}
      }
      if(fd >= 0) {
	memcpy(llog0, shm_addr->LLOG,8);
	offset= lseek(fd, 0L, SEEK_END);
	if (offset > 0) {
	  offset=lseek(fd, -1L, SEEK_END);
	  if (offset < 0) {
	    shm_addr->abend.other_error=1;
	    perror("!! help! ** error positioning log file, ddout");
	  }
	  read(fd,&ch,1);
	  if(ch != '\n')
	    write(fd, "\n", 1);
	  if(offset > 1024L*1024L*10L)
	    logit(NULL,-999,"bo");
	} else if(offset < 0) {
	  shm_addr->abend.other_error=1;
	  perror("finding end of log file, ddout");
	}
      } else
	fprintf(stderr,"\007!! help! ** no file is now open\n");
      
      goto Append;  /* always write first message */
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
    kpcald = strncmp(buf+FIRST_CHAR-1,"#pcald#",7)==0 ||
      strncmp(buf+FIRST_CHAR-1,"#tpicd#",7)==0;
    if(((!kpcald) && (kxd || (rtn2 == -1) || (!kp && !kack &&!kdebug))) ||
       (kpcald && kpd)){
      ierrnum=0;
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

      strncpy(ibur,buf+FIRST_CHAR+8,5);
      ibur[5]='\0';
      sscanf(ibur,"%d",&ierrnum);
      memcpy(&ierrch,buf+FIRST_CHAR+6,2);
      if(strncmp(buf+FIRST_CHAR+6,"un",2)==0) {
	int ierr;
        strncpy(ibur,buf+FIRST_CHAR+8,5);
	ibur[5]='\0';
	if(1==sscanf(ibur,"%d",&ierr)) {
	  strncpy(ibur,strerror(ierr),80);
	  if(strlen(strerror(ierr))>(80-1))
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

      display=1;
      count=0;
      if(ierrnum!=0) { 
	for(ptr=last;ptr!=NULL;ptr=ptr->previous)
	  if(ptr->num == ierrnum && memcmp(ptr->ch,ierrch,2)==0) {
	    if(count ==0)
	      count=ptr->count;
	    if(strcmp(ptr->string,ibur)==0) {
	      display=ptr->on;
	      break;
	    }
	  }
	if(ptr == NULL) { /* not found */
	  ptr= (struct list *)malloc(sizeof(struct list));
	  if(ptr!=NULL) {
	    memcpy(ptr->ch,ierrch,2);
	    ptr->num=ierrnum;
	    ptr->previous=last;
	    ptr->next=NULL;
	    ptr->on=1;
	    ptr->count=count+1;
	    ptr->string=strdup(ibur);
	    if(ptr->string != NULL) {
	      if(first == NULL)
		first=ptr;
	      else
		last->next=ptr;
	      last=ptr;
	    } else {
	      free(ptr);
	      shm_addr->abend.other_error=1;
	      perror("!! help! ** getting tnx structure string, ddout");
	    }
	  } else {
	    shm_addr->abend.other_error=1;
	    perror("!! help! ** getting tnx structure, ddout");
	  }
	}
      }

      if(display && *cp2 == 'b' && shm_addr->sterp !=0) {
        class=0;
        cls_snd(&class, buf, strlen(buf), 0, 0);
        ip[0]=class;
        skd_run("sterp", 'n', ip); 
      }
      /* send message to station erchk program */
      if(display && *cp2 == 'b' && shm_addr->erchk !=0) {
        class=0;
        cls_snd(&class, buf, strlen(buf), 0, 0);
        ip[0]=class;
        skd_run("erchk", 'n', ip); 
      }

      if(display) {
/* not Y10K compliant */
	printf("%.8s",buf+9);
/* not Y10K compliant */
	printf("%s",buf+20);
	if (*cp2 == 'b')
	  printf("\007");
	printf("\n");
      }
    }

/* SECTION 6 */
/*  write information to the log file if conditions are met */

    if (kxl || (!kp && !kack) || memcmp(cp2,"nl",2)==0) {
      if (fd <0)
	goto Trouble;
      strcat(buf,"\n");
      bull = strlen(buf);
      if(bull != write(fd, buf, bull)) {
	shm_addr->abend.other_error=1;
	fprintf(stderr,"!! wrong length written, file probably too large\n");
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
    if(knl) {
      shm_addr->abend.other_error=1;
      fprintf(stderr,
	      "\007!! help! ** log file '%.8s' not open, can't write to disk\n",
	     sllog);
    }
    if (rtn2 != -1)
      goto Messenger;

/* SECTION 9 */
/*  exit from program */

Bye:
    ip[0]=-1;
    skd_run("fserr", 'n', ip); 

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
