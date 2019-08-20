/* dscon.c - initial
 *
 * This is the ATNF DataSet CONtrol program DSCON.
 *   JFHQ 000721  - Started development.
 *   JFHQ 010621  - Extensively re-written to allow streaming
 *   JFHQ 010716  - Change to use dataset address file / renumber errors.
 *   JFHQ 011031  - Completed integration into FS-9.5.3
 *
 * Input :
 *  IP(0) = type of request
 *		0 - initialize
 *		1 - process request buffer
 *		2 - terminate
 *  IP(1) = class number of input buffer ( true unterminated ASCII string )
 *            '[request data...]'
 *               four opaque bytes to transmit to dataset bus
 *  IP(2) = number of records in class
 *  IP(3) - not used
 *  IP(4) - not used
 *
 * Output :
 *  IP(0) = class number of output buffer ( true unterminated ASCII string )
 *            '[response data...]'
 *		two opaque bytes containing:
 *		      monitor data (monitor point request) or
 *		      error and warning register data (control point request)
 *  IP(0) = class number of output buffer
 *  IP(1) = number of records in class
 *  IP(2) = error number
 *          0 - no error
 *         -1 - unable to open dsad.ctl address file
 *         -2 - too many devices in dsad.ctl address file
 *         -3 - trouble with class buffer
 *         -4 - dataset interface is not initialized
 *         -5 - unrecognised device mnemonic
 *         -6 - error in request buffer format
 *         -7 - cannot open dataset interface device
 *        -11 - time-out or error on reading from dataset interface
 *        -12 - dataset response was corrupted
 *        -21 - problems writing to dataset interface
 *        -22 - dataset interface is /dev/null, devices inaccessible
 *  IP(3) = 2HDS for errors, found in FSERR.CTL
 *  IP(4) - not used
 *
 */

/* include files */
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <time.h>
#include <fcntl.h>
#include <termio.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>

clock_t rte_times(struct tms *);

#include "../include/params.h"   /* FS parameters            */
#include "../include/fs_types.h" /* FS header files          */
#include "../include/fscom.h"    /* FS shared mem. structure */
#include "../include/shm_addr.h" /* FS shared mem. pointer   */

/* defines */
#define PACKET_SIZE 	10	/* no of bytes in dataset bus packet */
#define REQUEST_SIZE 	4	/* no of bytes in opaque request data */
#define RESPONSE_SIZE 	2	/* no of bytes in opaque response data */

#define TIME_OUT	30	/* device timeout in centiseconds */

#define MAX_DEV		32	/* maximum no of entries in address file */

/* request/response byte definitions */
#define	NUL	0x00
#define	ESC	0x1B
#define	ESC_ESC	'0'
#define	SYN	0x16
#define	ESC_SYN	'1'
#define	ACK	0x06
#define ESC_ACK '2'
#define	BEL	0x07
#define ESC_BEL '3'
#define	NAK	0x15
#define ESC_NAK '4'

/* function prototypes */
void setup_ids();
int rte_prior();
void putpname();
void logit(), logita();
void skd_wait();
int cls_rcv();
void cls_snd();

struct DSAD *get_dsad ();	/* read the dsad.ctl file */
int getad ();			/* lookup address from name */
int doinit();			/* perform program initialization */
void close_ds();		/* close Dataset device */
int open_ds();			/* open Dataset device */
int set_ds();			/* set Dataset device settings */
int doproc();
int read_bus();			/* read character buffer from Dataset device */
int write_bus();		/* write character buffer to Dataset device */
void send_echo();

/* global variables */
static char dsad_file[] = {	/* initialization file name */
        "/usr2/control/dsad.ctl"};
static struct DSAD		/* pointers to dataset address blocks */
{
    char name[3];			/* module name 2 char */
    unsigned char addr;			/* module addr */
} *dev[MAX_DEV+1];
static char ds_dev[65];		/* Dataset device name */
static int knull;		/* is device name actually /dev/null ? */
struct termio ds;		/* Dataset device attributes structure */
static int ds_filedes;		/* Dataset device file descriptor */ 
static int initialized;		/* has program been initialized ? */

static int no_pending = 0;	/* No of packets written but not read */

static int ip[5];		/* scheduling parameters */
static int outclass;		/* output class number */
static int nbufout;		/* number of output buffers */

static unsigned char secho[80];
static int iecho;
static int necho;

#ifdef DEBUG
static struct timeval start, now;
#endif

/* Main program starts here */
int main()
{

  int doresult; /* return code for rmpar processors */

  /* loop forever for message received */

  putpname("dscon");
  setup_ids();    /* attach to the shared memory */
  rte_prior(FS_PRIOR);
  initialized = FALSE;

#ifdef DEBUG
  printf("DSCON: Entering service loop\n");
#endif

  while (TRUE)
  {
        skd_wait("dscon",ip,(unsigned) 0);
        iecho=shm_addr->KECHO;
        if(iecho) necho=0;
                
        switch (ip[0])
        {

            case 0:  /* initialize */
#ifdef DEBUG
                printf("DSCON: initialize request received\n");
#endif
                if (initialized) {
                    doresult = 0;
                } else {
                    doresult = doinit();
                }
                if (doresult < 0) {
                    initialized = FALSE;
                    ip[0] = 0;
                    ip[1] = 0;
                    ip[2] = doresult;
                    memcpy(ip+3,"ds",2);
                    ip[4] = 0;
                } else {
                    initialized = TRUE;
                }
                break;

            case 1:  /* process communication request buffers */
#ifdef DEBUG
                printf("DSCON: process %d buffer(s) request received\n",ip[2]);
#endif
                doresult = doproc();
                ip[0] = outclass;
                ip[1] = nbufout;
                ip[2] = doresult;
                memcpy(ip+3,"ds",2);
                ip[4]=0;
                break;

            case 2:  /* terminate */
            {
#ifdef DEBUG
                printf("DSCON: terminate request received\n");
#endif
                close_ds();
                exit(0);
            }

            default: /* error */
#ifdef DEBUG
                printf ("DSCON: illegal message received %d %d %d %d %d\n",
                         ip[0],ip[1],ip[2],ip[3],ip[4]);
#endif
                ip[0] = 0;
                ip[1] = 0;
                ip[2] = -6;
                memcpy(ip+3,"ds",2);
                ip[4] = 0;
                break;
        }
  }
}

/* ********************************************************************* */

struct DSAD *get_dsad(fp) /* get an entry from the dataset address file */
FILE *fp; /* file pointer to dataset address block file */

{
    char temp[50];        /* temp storage for input strings */
    int taddr; /* temp storage for address */
    struct DSAD *ptr; /* pointer to memory obtained */
    char check;

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
      return( (struct DSAD*) NULL);
    else if(ungetc(check, fp)==EOF)
      return( (struct DSAD*) NULL);
 
    if ( fscanf(fp,"%s %x %*[^\r\n]",temp,&taddr) != 2) /* read a line */
    {
        return( (struct DSAD*) NULL);
    }
    if ( strlen(temp) != 2 ) {
#ifdef DEBUG
        printf("DSCON: illegal module name %s\n",temp);
#endif
        return(NULL);
    }

    if ( (ptr = (struct DSAD *)malloc(sizeof(struct DSAD))) ==
        (struct DSAD *)NULL ) {
#ifdef DEBUG
        printf("DSCON: memory allocation failure\n");
#endif
        return(NULL);
    }
    strcpy (ptr->name,temp);
    ptr->addr = taddr;
    return(ptr);
}

/* ********************************************************************* */

int getad (s, addr) /* get address from name */
char *s;   /* first char of mnemonic */
unsigned char *addr;  /* module address */

{
    int cnt; /* general purpose counter */

    cnt = 0;
    while ( dev[cnt] != (struct DSAD *)NULL ) {
        if ( (*s == dev[cnt]->name[0]) && (*(s+1) == dev[cnt]->name[1]) ) {
            *addr = dev[cnt]->addr;
            return(TRUE);
        }
        cnt++;
    }
    return(FALSE);
}

/* ********************************************************************* */

int doinit()

{
    FILE *fp;   /* general purpose file pointer */
    int cnt;    /* counter for file entries */
    char *end;

    if ( (fp = fopen(dsad_file,"r")) == NULL) {
#ifdef DEBUG
        printf("cannot open dataset address file %s\n",dsad_file);
#endif
        return(-1);
    }

    cnt = 0;

    while ( ((dev[cnt] = get_dsad(fp)) != NULL) && (cnt++ < MAX_DEV) )
         ;
    fclose (fp);
    if ( cnt > MAX_DEV ) {
#ifdef DEBUG
        printf("too many dataset devices\n");
#endif
        return(-2);
    }
        /* print initialization information */
    cnt = 0;

#ifdef DEBUG
    printf ("DSCON: initialization for the following devices\n");
    printf ("NM ID ");
    printf ("NM ID ");
    printf ("NM ID ");
    printf ("NM ID\n");
    while ( dev[cnt] != (struct DSAD *)NULL) {
        if ( (cnt+1)%4 == 0)
            printf("%2s %2x\n",
                dev[cnt]->name,dev[cnt]->addr);
        else
            printf("%2s %2x ",
                dev[cnt]->name,dev[cnt]->addr);
        cnt++;
    }
    if (cnt%4) printf("\n");
#endif
    end=memccpy(ds_dev,shm_addr->ds_dev,' ',sizeof(ds_dev)-1);
    if (end != NULL)
        *(end-1) = '\0';
    else
        *(ds_dev+sizeof(ds_dev)-1)= '\0';
 
#ifdef DEBUG
    printf("DSCON: Attempting to open device %s\n",ds_dev);
#endif

    if (!open_ds(ds_dev)) { /* open Dataset device */
#ifdef DEBUG
        printf("DSCON: Cannot open Dataset device %s\n",ds_dev);
#endif
        return(-7);
    }
    return(0);
}

/* ************************************************************************** */

int doproc()	/* process the input class buffers */
{
  int inclass;		/* input class number */
  int nbufin;		/* number of input buffers */
  unsigned char inbuf[REQUEST_SIZE+2];		/* input buffer */
  unsigned char addr;	/* address of dataset */
  int ierr;		/* return error */
  int bufcnt;		/* input buffer number counter */
  int nchar;		/* no of characters in input buffer */
  int dum;              /* dummy returns from cls_rcv - unused */
  int warn, err;	/* warning & error byte traversal counters */

  struct ds_xfer {
  	char		mnem[3];
	unsigned char	request[REQUEST_SIZE];
	unsigned char	response[RESPONSE_SIZE+1];
	int		ierr;
  }   prev, curr;

  inclass = ip[1];
  nbufin = ip[2];
  outclass = 0;
  nbufout = 0;
  ierr = 0;

  /* Clear all stray input/output */
  if (tcflush(ds_filedes,TCIOFLUSH)==-1) {
	perror("DSCON, doproc(), tcflush()");
	exit(-1);
  }
	
  /* loop over class request buffers */
  for (bufcnt=0; bufcnt<nbufin+1; bufcnt++) {

          curr.ierr = 0;

          /* Retrieve and interpret next class buffer except last time round */
          if (bufcnt<nbufin) {

             inbuf[0] = '\0';
             if ((nchar=cls_rcv(inclass,inbuf,REQUEST_SIZE+2,&dum,&dum,0,0)) <= 0) {
#ifdef DEBUG
                printf("DSCON: failed to get request buffer\n");
#endif
                curr.ierr = -3;
             } else if (!initialized) {
#ifdef DEBUG
                printf("DSCON: interface not initialized\n");
#endif
                curr.ierr = -4;
             } else if (knull) {
#ifdef DEBUG
                printf("DSCON: interface is /dev/null\n");
#endif
                curr.ierr = -22;
             } else if (nchar<REQUEST_SIZE+2) { /* did we get it all */
#ifdef DEBUG
                printf("DSCON: request data too short\n");
#endif
                curr.ierr = -6;
             } else if (!getad(inbuf,&addr)) {
#ifdef DEBUG
                printf("DSCON: unrecognised device mnemonic %c%c\n",inbuf[0],inbuf[1]);
#endif
                curr.ierr = -5;
             } else {
#ifdef DEBUG
                printf("DSCON: Mnemonic %c%c maps to dataset address %d\n",
                       inbuf[0],inbuf[1],addr);
#endif
                /* Fill in correct dataset address into opaque request data */
                memcpy(curr.request,&inbuf[2],REQUEST_SIZE);
		curr.request[0] = (curr.request[0]&0xC1)|((addr&0x1F)<<1);
#ifdef DEBUG
                printf("DSCON: Received >");
                for (nchar=0; nchar<REQUEST_SIZE-1; nchar++)
                    printf("0x%02.2x;",curr.request[nchar]);
	        printf("0x%02.2x<\n",curr.request[nchar]);
#endif
                /* Transmit the request data to the dataset bus */
		if (!write_bus(curr.request,REQUEST_SIZE)) {
#ifdef DEBUG
                   printf("DSCON: Problems writing to Dataset device\n");
#endif
                   curr.ierr = -21;
                }
             }
             strncpy(curr.mnem,inbuf,2);
          }

          /* Always check for dataset acknowledge / collect last response */
          if (!read_bus(prev.response,RESPONSE_SIZE+1)) {
#ifdef DEBUG
             printf("DSCON: Time-out on reading from Dataset device\n");
#endif
             curr.ierr = -11;
           }



	  /* No response available for return first time round */
	  if (bufcnt > 0) {

             /* Check for corrupt response from dataset */
             if (prev.ierr==0) switch (prev.response[0]) {
                case ACK:
                case BEL:
	          if (!(prev.request[0]&0x80)) break;	/* MON returns data */
                case NAK:
#ifdef DEBUG
	          printf("DSCON: Warning register contains 0x%0.2x\n",prev.response[1]);
#endif
	          if (prev.response[1])
                    for (warn=0; warn<8; warn++)
                      if (prev.response[1]&(0x01<<warn))
                         logita(NULL,-801-warn,"ds",prev.mnem);
#ifdef DEBUG
	          printf("DSCON: Error register contains 0x%0.2x\n",prev.response[2]);
#endif
	          if (prev.response[2])
                    for (err=0; err<8; err++)
                      if (prev.response[2]&(0x01<<err))
                         logita(NULL,-901-err,"ds",prev.mnem);
	          break;
                case NUL:
	          prev.ierr = -12;
                  break;
                default:
	          prev.ierr = -11;
                  break;
             }
             if (prev.ierr < 0) {
                for (nchar=0; nchar<RESPONSE_SIZE+1; nchar++)
                    prev.response[nchar] = NUL;
		prev.response[RESPONSE_SIZE] = -prev.ierr;
                logita(NULL, prev.ierr, "ds", prev.mnem);
		ierr = prev.ierr;
             }
#ifdef DEBUG
             printf("DSCON: Returning >");
             for (nchar=0; nchar<RESPONSE_SIZE; nchar++)
                 printf("0x%02.2x;",prev.response[nchar]);
             printf("0x%02.2x<\n",prev.response[nchar]);
#endif
             /* Queue the response data returned by the dataset */
             cls_snd(&outclass,prev.response,RESPONSE_SIZE+1,0,0);
             nbufout++;
          }
          prev = curr;
          send_echo();
  } /* end of for */

  return(ierr);
}

/* ********************************************************************* */

int read_bus(buffer,nbyte)	/* Receive nbyte bytes from Datsset device */
  unsigned char *buffer; /* response data buffer to fill in */
  int nbyte;	/* number of bytes to read into data buffer */
{
   static unsigned char next_ack = NUL;
   int cnt, ibyte, esc;
   struct tms tms_buff;
   int end;
   int iret;

   end = rte_times(&tms_buff)+TIME_OUT+1;	/* calculate end time */

   /* Loop until enough response bytes have been collected */
   if ((buffer[0] = next_ack) != NUL) {
      ibyte = 0;
      while (++ibyte < nbyte) {
         esc = 0;
         while (TRUE) {
            iret = 0;
            while (iret<=0) {
               iret = read(ds_filedes,&buffer[ibyte],1);
               if (iecho && iret == 1) secho[necho++] = buffer[ibyte];
#ifdef DEBUG
               gettimeofday(&now,NULL);
               printf("\n%.4d-",now.tv_usec-start.tv_usec+1000000*(now.tv_sec-start.tv_sec));
               if (iret == 1) printf("DSCON: got >0x%02.2x<\n", buffer[ibyte]);
               else {
                  printf(".");
                  fflush(stdout);
               }
#endif
               if (end-rte_times(&tms_buff) <= 0) {
#ifdef DEBUG
                  printf("DSCON: Timed out after %3.1fs\n",(float)(rte_times(&tms_buff)-(end-TIME_OUT-1))/100.0);
#endif
                  next_ack = NUL;
                  buffer[0] = NUL;
                  return(FALSE);
               }
               if (iret == -1 && errno != EAGAIN) {
#ifdef DEBUG
                  perror("DSCON: read_bus(): reading response");
#endif
                  next_ack = NUL;
                  buffer[0] = NUL;
                  return(FALSE);
               }
            }
	    if (buffer[ibyte] == ACK || buffer[ibyte] == BEL || buffer[ibyte] == NAK) {
               /* truncated response */
               next_ack = buffer[ibyte];
	       buffer[0] = NUL;
	       return(TRUE);
            }
	    if (!esc && buffer[ibyte] == ESC) esc = 1;
            else if (esc) {
               switch (buffer[ibyte]) {
                  case ESC_ESC:
                     buffer[ibyte] = ESC;
                     break;
                  case ESC_SYN:
                     buffer[ibyte] = SYN;
                     break;
                  case ESC_ACK:
                     buffer[ibyte] = ACK;
                     break;
                  case ESC_BEL:
                     buffer[ibyte] = BEL;
                     break;
                  case ESC_NAK:
                     buffer[ibyte] = NAK;
                     break;
                  default:
                     /* Corrupt response */
                     buffer[0] = NUL;
                     break;
               }
               esc = 0;
            }
            if (iret == 1 && !esc)
               break;
         } /* while(TRUE) */
      } /* while (ibyte<nbyte) */
   }

   next_ack = NUL;

   /* Look for start of pending reply (ACK/NAK/BEL) only if required */
   if (no_pending > 0) {
      no_pending--;
      for (cnt = 0; cnt < 3; cnt++ ) {
         iret=0;
         while (iret<=0) {
            iret = read(ds_filedes,&next_ack,1);
            if (iecho && iret == 1) secho[necho++] = next_ack;
#ifdef DEBUG
            gettimeofday(&now,NULL);
            printf("\n%.4d-",now.tv_usec-start.tv_usec+1000000*(now.tv_sec-start.tv_sec));
            if (iret == 1) printf("DSCON: got >0x%02.2x<\n",next_ack);
            else {
               printf(".");
               fflush(stdout);
            }
#endif
            if (iret == 1 && next_ack == ESC) iret=0;
            else if (end-rte_times(&tms_buff) <= 0) {
#ifdef DEBUG
               printf("DSCON: Timed out after %3.1fs\n",(float)(rte_times(&tms_buff)-(end-TIME_OUT-1))/100.0);
#endif
               next_ack = NUL;
               return(FALSE);
            } else if (iret == -1 && errno != EAGAIN) {
#ifdef DEBUG
               perror("DSCON: read_bus(): reading ACK");
#endif
               next_ack = NUL;
               return(FALSE);
            }
         }
         if (next_ack == ACK || next_ack == NAK || next_ack == BEL) break;
      }
      /* If we receive 3 (non-escaped) characters without seeing ACK/NAK/BEL */
      if (next_ack != ACK && next_ack != NAK && next_ack != BEL) {
           /* Corrupt response */
	   next_ack = NUL;
	   return(FALSE);
      }
#ifdef DEBUG
      printf("DSCON: actual read delay %6.4fs\n",(float)(rte_times(&tms_buff)-(end-TIME_OUT-1))/100.0);
#endif
   }

   return(TRUE);
}

/* ************************************************************************** */

int write_bus(buffer,nbyte)	/* Send nbyte bytes from buffer to Dataset device */
  unsigned char *buffer;	/* Request data buffer to send from */
  int nbyte;	/* No of bytes to send */
{
    unsigned char packet[PACKET_SIZE];
    int ibyte, ipkt, iret;
    unsigned int statusReg;

    /* Construct dataset bus packet */
    ipkt = 0;
    packet[ipkt++] = SYN;
    for (ibyte=0; ibyte<nbyte; ibyte++) {
	switch(buffer[ibyte]) {
	   case ESC:
		packet[ipkt++] = ESC;
		packet[ipkt++] = ESC_ESC;
		break;
	   case SYN:
		packet[ipkt++] = ESC;
		packet[ipkt++] = ESC_SYN;
		break;
	   default:
		packet[ipkt++] = buffer[ibyte];
	}
    }
    for ( ; ipkt < PACKET_SIZE; ipkt++) packet[ipkt] = NUL;

    /* Transmit packet on bus */
    if (write(ds_filedes,packet,PACKET_SIZE) != PACKET_SIZE) {
	perror("DSCON, write_bus(), write()");
    	return(FALSE);
    }
#ifdef DEBUG
    gettimeofday(&start,NULL);
    printf("DSCON: Wrote >");
    for (ipkt=0; ipkt<PACKET_SIZE-1; ipkt++) printf("0x%02.2x;",packet[ipkt]);
    printf("0x%02.2x<\n",packet[ipkt]);
#endif
    if (iecho)
       for (ipkt=0; ipkt < PACKET_SIZE; ipkt++) secho[necho++] = packet[ipkt];
    no_pending++;
    return(TRUE);
}

/* ************************************************************************** */

int set_ds()			/* set Dataset device settings */
{
    /* get terminal device settings */
    if (ioctl(ds_filedes,TCGETA,&ds)==-1) {
    	perror("DIOCN, set_ds(): getting terminal");
    	exit(-1);
    }

    ds.c_iflag = 0;
    ds.c_oflag = 0;
    /* set baud rate, 8 bit char, odd parity, one stop bits,     */
    /*  receiver enable, no modem control, hangup on close. */
    if (shm_addr->ibds == 2400) 
    		ds.c_cflag = B2400|CS8|PARENB|PARODD|CREAD|CLOCAL|HUPCL;
    else	ds.c_cflag = B38400|CS8|PARENB|PARODD|CREAD|CLOCAL|HUPCL;
    ds.c_lflag = 0;

    /* no minimum length, initial (1)s timeout   */
    ds.c_cc[VMIN] = 0;		/* MIN - min no of characters */
    ds.c_cc[VTIME] = (TIME_OUT+9)/10;	/* TIME - timeout in 0.1s units */

    /* set terminal device settings */
    if (ioctl(ds_filedes,TCSETA,&ds)==-1) { 
    	perror("DIOCN, set_ds(): setting terminal");
    	exit(-1);
    }

#ifdef DEBUG
       printf("DSCON: Successfully configured device\n");
#endif
    return(TRUE);
}

/* ************************************************************************** */

void close_ds()			/* close Dataset device */

{
    close(ds_filedes);
}

/* ************************************************************************** */

int open_ds(devnm)		/* open Dataset device */
  char *devnm;
{
    knull = strcmp(devnm,"/dev/null") == 0;
    if (knull)
       return(TRUE);

    if ( (ds_filedes = open(devnm, O_RDWR | O_NONBLOCK)) < 0 ) {
       return(FALSE);
    } else {
#ifdef DEBUG
       printf("DSCON: %s successfully opened\n",devnm);
#endif
       return(set_ds());			/* set baud rate, etc */
    }
}

/* ************************************************************************** */

void send_echo()
{
char secho_out[79];
int i,ilast;

    if(!iecho || necho <=0)  return;

    secho_out[0]='\0';

    if (necho>=PACKET_SIZE)
       for (i=0; i<PACKET_SIZE; i++) {
          if (secho[i]==NUL)
             strcat(secho_out,"[NUL]");
          else if (secho[i]==ESC)
             strcat(secho_out,"[ESC]");
          else if (secho[i]==SYN)
             strcat(secho_out,"[SYN]");
          else if (secho[i]==ACK)
             strcat(secho_out,"[ACK]");
          else if (secho[i]==BEL)
             strcat(secho_out,"[BEL]");
          else if (secho[i]==NAK)
             strcat(secho_out,"[NAK]");
          else
             sprintf(secho_out+strlen(secho_out),"[ %2.2x]",secho[i]);
       } else i=0;

    ilast=necho;
    if (ilast>15) ilast=15;
    for ( ;i<ilast;i++) {
       if (secho[i]==NUL)
          strcat(secho_out,"<NUL>");
       else if (secho[i]==ESC)
          strcat(secho_out,"<ESC>");
       else if (secho[i]==SYN)
          strcat(secho_out,"<SYN>");
       else if (secho[i]==ACK)
          strcat(secho_out,"<ACK>");
       else if (secho[i]==BEL)
          strcat(secho_out,"<BEL>");
       else if (secho[i]==NAK)
          strcat(secho_out,"<NAK>");
       else
          sprintf(secho_out+strlen(secho_out),"< %2.2x>",secho[i]);
    }
    if(ilast<necho) strcat(secho_out,"...");

    logit(secho_out,0,NULL);
    necho=0;
}
