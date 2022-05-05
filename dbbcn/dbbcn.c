/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* dbbcn: based on mk5cn */

/* FS Linux 1 is not supported. However, you can probably make it work
 * by finding and changing the call below:

    if(getsockopt(sock, SOL_SOCKET, SO_ERROR,
		  (void *) &error,(socklen_t *) &serror) < 0) {

 * to

    if(getsockopt(sock, SOL_SOCKET, SO_ERROR,
		  (void *) &error,(int *) &serror) < 0) {

 * This will at least allow the program to compile. It has not been tested
 * beyond that. Any other Linux 1 issues are *hoped* to be benign.
 */ 
 
#include <stdio.h> 
#include <fcntl.h>
#include <string.h> /* For strrchr() */ 
#include <errno.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/types.h> /* For socket() and connect() */

#include <sys/socket.h> /* For socket() and connect() */
#ifndef SHUT_RDWR
#define SHUT_RDWR 2
#endif

#include <netinet/in.h> /* For socket() with PF_INET */ 
#include <netdb.h> /* For getservbyname() and gethostbyname() */ 
#include <unistd.h> /* For close() */ 
#include <stdlib.h>

clock_t rte_times(struct tms *);

extern int h_errno; /* From gethostbyname() for herror() */ 
extern void herror(const char * s); /* Needed on HP-UX */ 
    /* Why (!) isn't this in one of these includes on HP-UX? */ 

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define BUFSIZE 1024 /* size of the input and output buffers */
/*#define DEBUG
 */
static unsigned char inbuf[BUFSIZE];   /* input message buffer */
static unsigned char outbuf[BUFSIZE];  /* output message buffer */
static unsigned char saved[BUFSIZE];  /* copy of output message buffer for mode 4 */

static char who[ ]="cn";
static char what[ ]="ad";

char me[]="dbbcn" ; /* My name */ 
int iecho;
int fail;

static void nullfcn();
static jmp_buf sig_buf;

int sock; /* Socket */ 
FILE * fsock; /* Socket also as a stream */ 
char host[129]; /* maximum width plus one */
int port;
int is_open=FALSE;
int first_transaction=FALSE;
int time_out;
int is_init=FALSE;

static char control_file[65];

static void close_socket();
static int read_response(char*, int, FILE*, int, int, int, int);
static int drain_input_stream(FILE*);

int main(int argc, char * argv[])
{

  int i, len, result;
  int ip[5];
  
  setup_ids();    /* attach to the shared memory */
  rte_prior(FS_PRIOR);
  host[0]=0;

  if(argc >= 2) {
    memcpy(me+3,argv[1],2);
    memcpy(who,argv[1],2);
    if(argv[1][1]!='n')
      memcpy(what+1,argv[1]+1,1);
  }
  putpname(me);

  strcpy(control_file,FS_ROOT);
  strcat(control_file,"/control/dbb");
  strcat(control_file,what);
  strcat(control_file,".ctl");

  while (TRUE)    {
    skd_wait(me,ip,(unsigned) 0);
    iecho=shm_addr->KECHO;

#ifdef DEBUG
    fprintf(stderr,"entering dbbcn ip[0]=%d ip[1]=%d ip[2]=%d\n",
	    ip[0],ip[1],ip[2]);
#endif
    switch (ip[0]) {
    case 0:
      /* ** Initialize ** */ 
      fail=TRUE;
      result = doinit();
      break;
    case 1:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
      if(!is_init) {
	cls_clr(ip[1]);
	ip[0]=ip[1]=0;
	result=-98;
      } else
	result = doproc(ip);
      break;
    case 2:
      if(!is_init) {
	cls_clr(ip[1]);
	ip[0]=ip[1]=0;
	result=-98;
      } else
	result = dorelink(ip);
      break;
    case 3:
      if(!is_init) {
	cls_clr(ip[1]);
	ip[0]=ip[1]=0;
	result=-98;
      } else
	result = doclose(ip);
      break;
    default:
      cls_clr(ip[1]);
      ip[0]=ip[1]=0;
      result = -99;
      break;
    }
    ip[2] = result;
    memcpy(ip+3,"db",2);
    if(result<-3||-1<result) 
      memcpy(ip+4,who,2);
    else
      memcpy(ip+4,what,2);
#ifdef DEBUG
    fprintf(stderr,"leaving dbbcn ip[0]=%d ip[1]=%d ip[2]=%d\n",
	    ip[0],ip[1],ip[2]);
#endif
  }
}


/* ********************************************************************* */

int doinit()
{
    FILE *fp;   /* general purpose file pointer */
    char check;
    int error;

    if ( (fp = fopen(control_file,"r")) == NULL) {
#ifdef DEBUG
        printf("cannot open MK5 address file %s\n",control_file);
#endif
        return -1 ;
    }

    check=fgetc(fp);
    while(check == '*' && check != EOF) {
      check=fgetc(fp);
      while(check != '\n' && check != EOF)
	check=fgetc(fp);
      if(check != EOF) 
	check=fgetc(fp);
    }
    if (check == EOF)
      /* ended in comment */      
      return 0;
    else if(ungetc(check, fp)==EOF)
      return -2;
   
    if ( fscanf(fp,"%80s %d %d",host,&port, &time_out)!=3) /* read a line */
      return -3;

    if(time_out <200)
      time_out= 200;
    
#ifdef DEBUG
    printf ("Host %s port %d time_out %d\n",host,port,time_out);
#endif

    fclose (fp);
 
    is_init=TRUE;
    if(who[1]=='n')
      shm_addr->dbbc_defined=1;
    else
      shm_addr->dbbc2_defined=1;

    if (0 > (error = open_mk5(host,port))) { /* open mk5 unit */
#ifdef DEBUG
      printf ("Cannot open mk5 host %s port %d error %d\n",host,port,error);
#endif
      fail=FALSE;
      return error;
    }
    return 0;
}

/* ********************************************************************* */
int open_mk5(char *host, int port)
{   
  struct servent * set; /* From getservbyname() */ 
  struct sockaddr_in socaddin; /* For connect() info */ 
  struct hostent * hostinfo; /* From gethostbyname() */ 
  unsigned char * uc; /* To debug print IP address */ 
  int i;
  fd_set wfds;
  struct timeval tv;
  int retval, iret;
  int error,serror;
  int flags;

  /* * Create a socket * */ 
  if ((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0) { /* Errors? */ 

#ifdef DEBUG
    (void) fprintf(stderr, /* Yes */ 
		   "%s ERROR: \007 socket() returned %d ", me, sock); 
    perror("error"); 
#endif

    logit(NULL,errno,"un");
    return -11; /* Error */ } 

#ifdef DEBUG
  (void) fprintf(stderr, "%s DEBUG:  sock is %d \n", me, sock); 
#endif

  socaddin.sin_family = PF_INET; /* To agree with socket() */ 

  /* * Get service number for socket m5drive * */ 
  socaddin.sin_port = htons(port); /* Port m5drive's number */
#ifdef DEBUG
  (void) fprintf(stderr, "%s DEBUG:  m5drive port is %d \n", 
		 me, ntohs(socaddin.sin_port)); 
#endif

  /* * Find IP address of host to connect to * */ 
  if(signal(SIGALRM,nullfcn) == SIG_ERR){
    fprintf( stderr,"%s: setting up signals, gethostbyname()\n",me);
    exit(-1);
  }
  rte_alarm( time_out);
    
  if (setjmp(sig_buf)) {
    hostinfo=NULL;
    errno = EINTR;
    goto gethostbyname_return;
  }

#ifdef DEBUG
  { int itb[6],ita[6];
  rte_time(itb,itb+5);
#endif

  hostinfo = gethostbyname(host);

  gethostbyname_return:    

#ifdef DEBUG
  rte_time(ita,ita+5);
  printf(" itb[5...0] = %d %d %02d %02d %02d %02d\n",
	 itb[5],itb[4],itb[3],itb[2],itb[1],itb[0]);
  printf(" ita[5...0] = %d %d %02d %02d %02d %02d\n",
	 ita[5],ita[4],ita[3],ita[2],ita[1],ita[0]);
   }
#endif

  rte_alarm((unsigned) 0);
  if(signal(SIGALRM,SIG_DFL) == SIG_ERR){
    fprintf( stderr,"%s: setting default signals, gethostbyname()\n",me);
    exit(-1);
  }

  if( hostinfo == NULL && errno == EINTR ) {
#ifdef DEBUG
    (void) fprintf(stderr, /* Nope */ 
		   "%s ERROR: \007 gethostbyname() on %s timed-out ",
		   me, host);
#endif
    (void) close(sock); 
    logit(NULL,errno,"un");
    return -25 ; /* Error */ }
  else if (hostinfo == NULL) { /* Get IP, OK? */

#ifdef DEBUG
    (void) fprintf(stderr, /* Nope */ 
		   "%s ERROR: \007 gethostbyname() on %s returned NULL ",
		   me, host);
    herror("error"); /* Error */ 
#endif

    switch (h_errno) { /* Which error? */
    case HOST_NOT_FOUND :
#ifdef DEBUG
      (void) fprintf(stderr, "%s ERROR:  host %s not found \n", me, host);
#endif
      (void) close(sock); 
      return -17;
      break;
    case TRY_AGAIN :
#ifdef DEBUG
      (void) fprintf(stderr,
		     "%s ERROR:  no response, try again later \n", me);
#endif
      (void) close(sock); 
      return -18;
      break;
    case NO_RECOVERY :
#ifdef DEBUG
      (void) fprintf(stderr,
		     "%s ERROR:  unknown error, not recoverable \n", me);
#endif
      (void) close(sock); 
      return -19;
      break;
    case NO_ADDRESS : /* = NO_DATA */
#ifdef DEBUG
      (void) fprintf(stderr, "%s:  No Internet address available \n", me);
#endif
      (void) close(sock); 
      return -20;
    } /* End of switch */ 
    (void) close(sock); 
    logit(NULL,errno,"un");
    return -13 ; /* Error */
  } /* End of if hostinfo NULL */
    
  if (hostinfo->h_addr_list[0] == NULL) { /* First IP address OK? */ 
#ifdef DEBUG
    (void)
      fprintf(stderr, /* Nope */ 
	      "%s ERROR: \007 gethostbyname() on %s returned NULL IP \n", 
	      me, host); 
#endif
    (void) close(sock); 
    return -14 ; /* Error */ } 
    
#ifdef DEBUG
  uc = (unsigned char *) hostinfo->h_addr_list[0]; /* Yes */ 
  (void) fprintf(stderr, /* Yes */ 
		 "%s DEBUG:  IP address of %s is [", me, host); 
  for (i = 0; i < hostinfo->h_length; i++) { 
    if (i > 0) 
      (void) printf("."); 
    (void) printf("%u", uc[i]); } 
  (void) printf("] \n");
#endif
  
  socaddin.sin_addr.s_addr = *((unsigned int *) hostinfo->h_addr_list[0]); 
  /* Use first address */ 
  /* * Connect this socket to Mark5A on host * */ 
#ifdef DEBUG
  (void) fprintf(stderr, "%s DEBUG:  Trying to connect() \n", me); /* Yes */ 
#endif

  /* set-up select() */
  flags=fcntl(sock,F_GETFL);
  flags |= O_NONBLOCK;
  fcntl(sock,F_SETFL,flags);
  FD_ZERO(&wfds);
  FD_SET(sock, &wfds);
  /* Wait up to time_out centiseconds  */
  tv.tv_sec = time_out/100;
  tv.tv_usec = (time_out%100)*10000;

#ifdef DEBUG
  { int itb[6],ita[6];
  printf ("time-out sec %d usec %d\n",tv.tv_sec,tv.tv_usec);
  rte_time(itb,itb+5);
#endif

  iret=connect(sock, (const struct sockaddr *) &socaddin, 
	       sizeof(struct sockaddr_in));
#ifdef DEBUG
  rte_time(ita,ita+5);
  printf(" itb[5...0] = %d %d %02d %02d %02d %02d\n",
	 itb[5],itb[4],itb[3],itb[2],itb[1],itb[0]);
  printf(" ita[5...0] = %d %d %02d %02d %02d %02d\n",
	 ita[5],ita[4],ita[3],ita[2],ita[1],ita[0]);
  }
#endif

#ifdef DEBUG
  printf(" iret %d errno %d EINPROGRESS %d\n",iret,errno,EINPROGRESS);
#endif

  if(iret<0 && errno == EINPROGRESS) {
#ifdef DEBUG
    { int itb[6],ita[6];
    rte_time(itb,itb+5);
#endif
    retval = select(sock+1, NULL, &wfds, NULL, &tv);
    /* Don't rely on the value of tv now! */
#ifdef DEBUG
    rte_time(ita,ita+5);
    printf(" itb[5...0] = %d %d %02d %02d %02d %02d\n",
	   itb[5],itb[4],itb[3],itb[2],itb[1],itb[0]);
    printf(" ita[5...0] = %d %d %02d %02d %02d %02d\n",
	   ita[5],ita[4],ita[3],ita[2],ita[1],ita[0]);
    }
    printf(" retval %d \n",retval);
#endif
    if(retval == -1) {
      close(sock);
      logit(NULL,errno,"un");
      return -24; /* Error */ } 
    else if (!retval) {
      close(sock);
      return -21;
    }
    
#ifdef DEBUG
    printf(" sock %d\n",sock);
#endif
    serror=sizeof(error);
    if(getsockopt(sock, SOL_SOCKET, SO_ERROR,
		  (void *) &error,(socklen_t *) &serror) < 0) {
      close(sock);
      logit(NULL,errno,"un");
      return -22; /* Error */ } 
    if(error!=0) {
      close(sock);
      logit(NULL,error,"un");
      return -23;
    }
  } else if (iret < 0) { /* Connect, errors? */ 
#ifdef DEBUG
    (void) fprintf(stderr, /* Yes */
		   "%s ERROR: \007 connect() returned ", me);
    perror("error"); 
#endif
    logit(NULL,errno,"un");
    (void) close(sock); 
    return -15; /* Error */ } 

#ifdef DEBUG
  (void) fprintf(stderr, /* Yes */ 
		 "%s DEBUG:  Got a connect() on sock %d \n", me, sock); 
#endif
  
  /* * Open socket also to read as a stream * */ 
  if ((fsock = fdopen(sock, "r")) == NULL) { /* OK? */
#ifdef DEBUG
    (void) fprintf(stderr, /* Nope */
		   "%s ERROR: \007 fdopen() on sock %d returned ", me, sock);
    perror("error");
#endif
    logit(NULL,errno,"un");
	(void) shutdown(sock, SHUT_RDWR);
    (void) close(sock); /* Error */ 
    return -16; /* Error */ } 
#ifdef DEBUG
  (void) fprintf(stderr, /* Yes */ 
		   "%s DEBUG:  Socket %d open also as a stream \n", me, sock); 
#endif

  /* End of initialization */ 
#ifdef DEBUG
  (void) printf("%s Ready\n", me); 
#endif

  is_open=TRUE;
  first_transaction=TRUE;
  return 0;
}
int doproc(ip)
int ip[5];
{

  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg;  /* argument for cls_rcv - unused */
  int save;    /* argument for cls_rcv - unused */
  char secho[3*BUFSIZE];
  char lbuf[10+BUFSIZE];
  int in_class;
  int out_class=0;
  int in_recs;
  int out_recs=0;
  int i, j, nchars;

  int retval;
  int error;
  int flags;

  int time_out_local;
  static struct {
    char string[80];
    int to;
  } list[ ] = {
    "",                0
  };
  char *ptr,*ptrcolon;
  int ierr, mode;
  int centisec[6];             /* arguments of rte_tick rte_cmpt */
  int itbefore[6];
  int fila10g;
  int newline;
  int dbbc3;

  struct tms tms_buff;
  int first, changed;
  int end;

  unsigned int now;
  static unsigned int last_dbbctrk;
  static int dbbctrk=0;

  secho[0]=0;
  mode=ip[0];
  in_class=ip[1];
  in_recs=ip[2];

  secho[0]=0;
    
  i = 0; /* to detect unread class messages */

  if(!is_open) {
    if (0 > (error = open_mk5(host,port))) { /* open mk5 unit */
#ifdef DEBUG
      printf ("Cannot open mk5 host %s port %d error %d\n",host,port,error);
#endif
      ip[2]=error;
      goto error;
    }
    rte_sleep(100); /* seem to need a 100 centisecond sleep here, is this
                      a Mark 5 or Linux problem? */
  }

  msgflg = save = 0;
  for (i=0;i<in_recs;i++) {
    if ((nchars = cls_rcv(in_class,inbuf,BUFSIZE-2,&rtn1,&rtn2,msgflg,save)) <= 0) {
#ifdef DEBUG
      printf ("%s failed to get a request buffer\n",me);
#endif
      ip[2] = -101;
      goto error;
    }
#ifdef DEBUG
    { int j;
      (void) fprintf(stderr, /* Yes */ 
		     "%s DEBUG:  Got inbuf [] = ", me); 
      for (j=0;j<nchars;j++)
	fprintf(stderr,"%c",inbuf[j]);
      fprintf(stderr,"\n");
    }
#endif
    // not needed as v101    inbuf[nchars++]='\n';  /* new-line */
    inbuf[nchars++]=0;  /* zero */

    /* * Send command * */ 
    flags=0;
#ifdef MSG_NOSIGNAL
    flags|=MSG_NOSIGNAL;
#endif
#ifdef MSG_DONTWAIT
    flags|=MSG_DONTWAIT;
#endif
    if(!first_transaction) {
      ip[2] = drain_input_stream(fsock);
      if(ip[2]!=0) {
	logita(NULL,ip[2],"db",who);
	close_socket();
	if (0 > (error = open_mk5(host,port))) { /* open mk5 unit */
	  ip[2]=error;
	  goto error;
	} else {
	  rte_sleep(100); /* seem to need a 100 centisecond sleep here, is this
			     a Mark 5 or Linux problem? */
	  logita(NULL,-114,"db",who);
	  first_transaction=FALSE;
	}
      }
    } else {
      first_transaction=FALSE;
    }
      
    /* determine time-out */

    time_out_local=time_out;
    for (j=0;list[j].string[0]!=0;j++) {
      if(NULL!=strstr(inbuf,list[j].string)) {
	time_out_local+=list[j].to;
      }
    }

    /*check for ddctrk... to allow delay */

    if(NULL != strstr(inbuf,"dbbctrk")) {
 /* make sure "dbbctrk" commands have at least a one second between
    them, we might be able to save a little time by distinguishing
    between dbbctrk1, dbbctrk2, abd dbbctrk commands, but it is very
    little savings and a lot more complication (and testing), so not
    for now, this may also need some adjustment if these commands get
    a monitor form so that isn't too slow */
      rte_ticks(&now);
      if(dbbctrk) {
	if(now-last_dbbctrk < 102) {
	  rte_sleep(102-(now-last_dbbctrk));
	}
      }
      last_dbbctrk=now;
      dbbctrk=TRUE;
    }
    
    if(6 == mode || 4 == mode | 7 == mode)
      fila10g=TRUE;
    else
      fila10g=FALSE;

    if(8 == mode)
      dbbc3=TRUE;
    else
      dbbc3=FALSE;

    newline = 7 == mode || 8 == mode;

    first=TRUE;
    changed=FALSE;
    end=rte_times(&tms_buff)+130;  /* calculate ending time */
    while(first ||
	  (mode==4 && ip[2]==0 && end > rte_times(&tms_buff) && !changed) ) {
      outbuf[0]=0;

      if(iecho && strlen(secho)> 0) {
	logit(secho,0,NULL);
	secho[0]=0;
      }
      if(iecho) {
	int in, out;
	strcpy(secho,"[");
	for(in=0,out=strlen(secho);in <nchars;in++) {
	  if(inbuf[in]=='\n') {
	    secho[out++]='\\';
	    secho[out++]='n';
	  } else if(inbuf[in]==0) {
	    secho[out++]='\\';
	    secho[out++]='0';
	  } else
	    secho[out++]=inbuf[in];
	}
	secho[out]=0;
	strcat(secho,"]");
      }

      if(mode==4) {
	rte_cmpt(centisec+2,centisec+4);
	rte_ticks (centisec);
      }

      if (send(sock, inbuf, nchars, flags) < nchars) { /* Send to socket, OK? */ 
#ifdef DEBUG
	(void) fprintf(stderr, /* Nope */ 
		       "%s ERROR: \007 send() on socket returned ",me); 
	perror("error"); 
#endif
	logit(NULL,errno,"un");
	ip[2] = -102; /* Error */
	goto error0;
      }
#ifdef DEBUG
      (void) fprintf(stderr, /* Yes */ 
		     "%s DEBUG:  Sent inLine[%s] to socket\n",
		     me, inbuf,sock); 
#endif

      /* * Read reply * */ 
    read:
      ip[2] = read_response(outbuf, sizeof(outbuf), fsock, time_out_local,
			    fila10g, newline, dbbc3);
      
      if(mode==4) {
	rte_ticks (centisec+1);
	rte_cmpt(centisec+3,centisec+5);
      }

      if(mode == 4)
	if(first)
	  strcpy(saved,outbuf);
	else
	  changed = strcmp(saved,outbuf);

      first=FALSE;

      if(iecho) {
	int in, out;
	strcat(secho,"<");
	for(in=0,out=strlen(secho);outbuf[in]!=0;in++) {
	  if(outbuf[in]=='\n') {
	    secho[out++]='\\';
	    secho[out++]='n';
	  } else if(outbuf[in]=='\r') {
	    secho[out++]='\\';
	    secho[out++]='r';
	  } else if(outbuf[in]==0) {
	    secho[out++]='\\';
	    secho[out++]='0';
	  } else
	    secho[out++]=outbuf[in];
	}
	secho[out]=0;
	strcat(secho,">");
	logit(secho,0,NULL);
	secho[0]=0;
      }
    }

#ifdef DEBUG
    /* * Print reply * */ 
    (void) fputs(outbuf, stdout); /* Print to stdout */ 
#endif

    /*trim a trailing new-line */

    if(outbuf[0]!=0 && outbuf[strlen(outbuf)-1]=='\n')
      outbuf[strlen(outbuf)-1]=0;
    if(1==ip[2]) {
      int i, is;
      char *failed =strstr(outbuf,"Failed");

      if(8==mode)
        strcpy(lbuf,"dbbc3/");
      else
        strcpy(lbuf,"fila10g/");
      is=strlen(lbuf);
      for(i=0;outbuf[i]!=0;i++)
	if(isprint(outbuf[i]))
	  lbuf[is++]=outbuf[i];
      lbuf[is]=0;
      logit(lbuf,0,NULL);
      if(failed!=NULL) {
	logite(failed,-200,"db");
	logita(NULL,-201,"db",who);
      }
      outbuf[0]=0;
      goto read;
    }

    outbuf[1023]=0; /* truncate to maximum class record size, cls_snd
                      can't do this because it doesn't know it is a string,
                      cls_rcv() calling should do it either since this 
                      would require many more changes */
    cls_snd(&out_class, outbuf, strlen(outbuf)+1 , 0, 0);
    out_recs++;
    if(mode==4) {
      cls_snd(&out_class, centisec, sizeof(centisec) , 0, 0);
      out_recs++;
    }

    /* check errors */

    if(ip[2]!=0) {
      if(ip[2]!=-109)
	close_socket();
      goto error;
    }

    if(mode==5)   /* no error report here */
      continue;

    if(7!= mode && 6 != mode && 8!= mode &&
       (index(outbuf,'/')==NULL || strstr(outbuf,"ERROR")!=NULL)) {
      logite(outbuf,-200,"db");
      ip[2]=-201;
      goto error;
    } else if ((7==mode || 6==mode || 8==mode) &&
	       (strstr(outbuf,"Failed")!=NULL 
		||strstr(outbuf,"ERROR")!=NULL
		||strstr(outbuf,"WARNING")!=NULL)
	       ) {
      char *failed=strstr(outbuf,"Failed");
      char *warning=strstr(outbuf,"WARNING");
      int i;

      if(NULL==failed)
	failed=strstr(outbuf,"ERROR");
      if(NULL!=failed) {
	for(i=0;failed[i]!=0;i++)
	  if(index("\r\n",failed[i])!=NULL) {
	    failed[i]=0;
	    break;
	  }
	  logite(failed,-200,"db");
      } else if(NULL!=warning) {
	for(i=0;warning[i]!=0;i++)
	  if(index("\r\n",warning[i])!=NULL) {
	    warning[i]=0;
	    break;
	  }
	  logite(warning,-200,"db");
      } else
	logite(outbuf,-200,"db"); /* for safety, just in case */
      ip[2]=-201;
      goto error;
    }

  } /* End of for loop  */ 

  ip[0]=out_class;
  ip[1]=out_recs;
  ip[2]=0;
  return 0;

error0:
  if(iecho && strlen(secho)> 0) {
    logit(secho,0,NULL);
    secho[0]=0;
  }
error:
  if(i<in_recs)
    cls_clr(in_class);
  ip[0]=out_class;
  ip[1]=out_recs;
  return ip[2];
}
int dorelink(ip)
int ip[5];
{

  int error;

  ip[0]=ip[1]=0;

  /* re-open */
  close_socket();
  if (0 > (error = open_mk5(host,port))) { /* open mk5 unit */
#ifdef DEBUG
    printf ("Cannot open mk5 host %s port %d error %d\n",host,port,error);
#endif
    ip[2]=error;
    return ip[2];
  }

  ip[2]=0;
  return 0;

}
int doclose(ip)
int ip[5];
{

  ip[0]=ip[1]=0;

  if(is_open) {
    is_open=FALSE;
    first_transaction=FALSE;
    fclose(fsock);
    shutdown(sock, SHUT_RDWR);
    close(sock);
  }

  ip[2]=0;
  return 0;

}
static void nullfcn(sig)
int sig;
{

  if(signal(sig,SIG_IGN) == SIG_ERR ) {
    perror("nullfcn: error ignoring signal");
    exit(-1);
  }
  
  longjmp (sig_buf, 1);

  fprintf(stderr,"nullfcn: can't get here\n");

  exit(-1);
}

////////////////////////////////////////////////////////////////////////////////////
// close_socket: cleanly close the TCP socket, can be used _after_ a open_mk5()
////////////////////////////////////////////////////////////////////////////////////

static void close_socket()
{
   if (FALSE != is_open) {
      is_open = FALSE;
      first_transaction=FALSE;
      (void) fclose(fsock);
      (void) shutdown(sock, SHUT_RDWR);
      (void) close(sock);
      sock = -1;
      fsock = NULL;
   }
   return;
}

////////////////////////////////////////////////////////////////////////////////
// read_response:
//  Reads a single Mk5 response delimited by a newline.
//  All characters are preserved.
//  Underlying fd (or stream itself?) must be non-blocking
//  On any error, the last (partial) response is returned.
////////////////////////////////////////////////////////////////////////////////
// Features of this implementation:
// (1) Does not us the dreaded fgets(), thanks to Jan Wagner
// (2) select() is never called unless there is no input available
//     (but that is almost sure to happen on the first call)
// (3) if there is no data available when a time-out is first detected
//     it polls one more time in case we were swapped if select()
//     times-out, it polls one more time, I don't have any guarantee that
//     that select() didn't return early so the code will try again just
//     in case. This also means there is only one time-out exit from the
//     loop. Oddly, "man select_tut" seems to think you should not use
//     select() for time-outs if you can avoid it
// (4) a server crash does not cause an infinite loop
// (5) assumes anything after \n in the response is cleared by
//    draining the input buffer before the next write to the Mark 5
//    (drain_input_stream() below).
//
// It is a bit pendantic on checking all the cases of EOF and error,
// including using clearerr() before each fgetc(). It seems like it
// would be safe to not call clearerr(), and then check feof() first
// after fgetc(). Maybe better safe than sorry though.
////////////////////////////////////////////////////////////////////////////////

static int read_response(char *str, int num, FILE* stream,
			 int time_out_local, int fila10g, int newline,
                         int dbbc3)
{
  int c, iret;
    char* cs = str;
    struct timeval to;
    unsigned int start,end,now;
    fd_set rfds;
    char fila10g_term[ ]= "FiLa10G % ";
    int term_count;
    char term_start;

    term_count=0;
    iret=0;
    rte_ticks(&start);

    /* we don't know where we are in current tick, so add one to be safe */ 
    end=start+time_out_local+1; 
    
    while(num > 2) {

      clearerr(stream);
      c=fgetc(stream);
      if(c==EOF && !feof(stream) && ferror(stream) && errno == 11) {

 /* some early firmwares has no \n terminator
  * so we assume that once we have some data the next pause means we are done */

        if(cs!=str)
          goto done;
	rte_ticks(&now);
	if(end <= now)       /* poll one more time */
	  time_out_local=0;
	else
	  time_out_local=end-now;

	to.tv_sec=time_out_local/100;
	to.tv_usec=(time_out_local%100)*10000;

	/* Read when data available */
	FD_ZERO(&rfds);
	FD_SET(fileno(stream), &rfds);

	c = select(fileno(stream) + 1, &rfds, NULL, NULL, &to);
	if (c < 0) { /* error */
	  logit(NULL,errno,"un");
	  iret = -103;
	  goto done;
	} else if(c == 0) {
	  if(end <= now) {  /* last poll failed, we can be sure we are done */
	    iret = -104;
	    goto done;
	  } else        /* select() returned early so not timed-out yet */
	    continue; 
	} else 	       /* there is data, we check at the top */
	  continue;

      } else if(c==EOF) {
	if(!feof(stream) && ferror(stream)) { /* error */
	  logit(NULL,errno,"un");
	  iret = -105;
	} else if(feof(stream) && ferror(stream)) { /* error & EOF */
	  logit(NULL,errno,"un");
	  iret = -106;
	} else if(feof(stream)) { /* EOF, server probably crashed */
	  iret = -107;
	} else if(c==EOF) { /* not sure what this is, but not valid input */
	  iret = -108;
	}
	goto done;
      }  
	   
      /* Append */
      *cs++ = c;
      num--;

      if(!fila10g && !dbbc3) {
	if(c=='\n')
	  goto done;
      } else if (dbbc3) {
	if(c=='\n' && newline) {
          iret=1;
          goto done;
	} else if (c==';')
          goto done;
      }	else { /* fila10g comm ends with a string rather than a \n */
	if(c=='\n' && newline) {
	  iret=1;
	  goto done;
	}
 	if(c==fila10g_term[term_count]) { /* got one */
	  if(++term_count>=sizeof(fila10g_term)-1) /* if full match: done */
	    goto done;
	} else /* start over */
	  term_count=0;
      }
    }
    iret = -109; /* ended before newline */
   
 done:
    *cs = '\0';
    return iret;
}
////////////////////////////////////////////////////////////////////////////////
// drain_input_stream:
//  Empties input stream of any lingering characters
//  Underlying fd (or stream itself?) must be non-blocking
////////////////////////////////////////////////////////////////////////////////
static int drain_input_stream(FILE* stream)
{
  int iret;

  clearerr(stream);
  while(EOF != fgetc(stream))
    ;
  if(!feof(stream) && ferror(stream) && errno == 11) {
    iret= 0;
  } else if(!feof(stream) && ferror(stream)) { /* error */
    logit(NULL,errno,"un");
    iret = -110;
  } else if(feof(stream) && ferror(stream)) { /* error & EOF */
    logit(NULL,errno,"un");
    iret = -111;
  } else if(feof(stream)) { /* EOF, server probably crashed */
    iret = -112;
  } else {         /* not sure what this is, but not possible */
    iret = -113;
  }

  return iret;
}
