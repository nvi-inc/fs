/* MCBCN  MCB communication daemon CAK 16 Dec 91*/
/* Copyright 1991, 1992 Interferometrics Inc. */

/* include files */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <fcntl.h>
#include <termio.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"


/* defines */
#define SYN 0x16 /* SYN character */
#define ACK 0x06 /* ACK character */
#define NAK 0x15 /* NAK character */
#define DC1 0x11 /* DC1 character */
#define DC2 0x12 /* DC2 character */
#define ESCP 0xff /* special escape character for the protocol translator */
/* #define DEBUG 1 */  /* define to turn on debug printout */

#define SEND 0  /* message type */
#define SENDB 7 /* total bytes in message */
#define RECV 1
#define RECVB 5
#define INIT 2
#define INITB 3
#define CKUN 3
#define CKUNB 1
#define CHKA 4
#define CHKAB 3
#define TIME 5
#define TIMEB 5
#define SRAW 6
#define SRAWB 5
#define TIMEW 7
#define TIMEWB 5
#define MON 0      /* mcb monitor request */
#define CMD 1      /* mcb command request */
#define BUFSIZE 512 /* size of the input and output buffers */
#define TIME_OUT 20 /* time-out in centiseconds */

/* function prototypes */
struct MCBAD *get_mcbad (); /* read the mcbad.ctl file */
long fjuldat(); /* get Julian date - 0.5 */
int isahexnum ();  /* check for valid hexadecimal number */
int getad ();
int doinit(); /* process rmpar case 0 */
int doproc(); /* process rmpar case 1 */
int open_mcb(); /* open mcb unit */
int write_mcb();  /* raw write mcb */
int read_mcb();   /* raw read mcb */
void mcb_put ();  /* write command to mcb */
void mcb_get ();  /* write request to mcb */
void set_mcb();   /* set tty line parameters */
void close_mcb(); /* close mcb tty unit */
void send_echo(); /* echo output formatting */
time_t fdate();   /* get unix 'calendar date'  */
void setup_ids();
void cls_snd();
int cls_rcv();
void cls_clr();
void skd_wait();
long times();
int putout();    /* fill and dispatch output buffer */
void wait_mcb(); /* wait a fraction of a second */

/* global variables */
static struct MCBAD
{
    char name[3];        /* module name 2 char */
    unsigned short id;   /* module id */
    unsigned short base; /* module base addr */
    unsigned short len;  /* module addr block len */
} *dev[25];    /* pointers to MCB address blocks */

static struct termio mcb;     /* mcb tty line attributes structure */
static char mcbad_file[] = {
        "/usr2/control/mcbad.ctl"};   /* initialization file name */
static char mcb_dev[65];   /* MCB tty unit */
static unsigned char inbuf[BUFSIZE];   /* input message buffer */
static unsigned char outbuf[BUFSIZE];  /* output message buffer */
static int inptr;             /* input message buffer pointer */
static int outptr;            /* output message buffer pointer */
static int initialized; /* has program been initialized? */
static int mcb_fildes;  /* mcb file descriptor */
static long outclass;   /* output class number */
static long inclass;    /* input class number */
static long ip[5];      /* scheduling parameters */
static int nbufout;     /* number of output buffers */
static unsigned char secho[80];
static int necho;
static int iecho;

/* external variables */
extern struct fscom *shm_addr;    /* shared memory segment */
void skd_wait();


main()

{
    int doresult; /* return code for rmpar processors */

    /* loop forever for message received */

    setup_ids();    /* attach to the shared memory */
    initialized = FALSE;
    while (TRUE)
    {
        skd_wait("mcbcn",ip,(unsigned) 0);
        iecho=shm_addr->KECHO;
        if(iecho) necho=0;
                
        inclass = ip[1];
        switch (ip[0])
        {

            case 0:  /* initialize */
#ifdef DEBUG
printf("initialize request received\n");
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
                    memcpy(ip+3,"mc",2);
                    ip[4] = 0;
                } else {
                    initialized = TRUE;
                }
                break;

            case 1:  /* process communication request buffers */
#ifdef DEBUG
                printf("process %d buffer request received\n",ip[2]);
#endif
                ip[4] = 0;
                doresult = doproc(ip+4);
                ip[0] = outclass;
                ip[1] = nbufout;
                ip[2] = doresult;
                memcpy(ip+3,"mc",2);
                break;

            case 2:  /* terminate */
            {
#ifdef DEBUG
                printf("terminate request received\n");
#endif
                close_mcb();
                exit(0);
            }

            default: /* error */
#ifdef DEBUG
                printf ("MCBCN: illegal message received %d %d %d %d %d\n",
                         ip[0],ip[1],ip[2],ip[3],ip[4]);
#endif
                ip[0] = 0;
                ip[1] = 0;
                ip[2] = -106;
                memcpy(ip+3,"mc",2);
                ip[4] = 0;
                break;
        }
    }
}

/* ********************************************************************* */

struct MCBAD *get_mcbad(fp) /* get an entry from the mcb address file */
FILE *fp; /* file pointer to mcb address block file */

{
    char temp[50];        /* temp storage for input strings */
    char tname[3];        /* temp storage for 2 character name string */
    int tid;   /* temp storage for module id */
    int tbase; /* temp storage for base address */
    int tlen;  /* temp storage for block length */
    struct MCBAD *ptr; /* pointer to memory obtained */

    if ( fscanf(fp,"%s %x %x %x",temp,&tid,&tbase,&tlen) != 4) /* read a line */
    {
        return( (struct MCBAD*) NULL);
    }
    if ( strlen(temp) != 2 ) {
#ifdef DEBUG
        printf("MCBCN: illegal module name %s\n",temp);
#endif
        return(NULL);
    }
    strcpy(tname,temp);


    if ( (ptr = (struct MCBAD *)malloc(sizeof(struct MCBAD))) ==
        (struct MCBAD *)NULL ) {
#ifdef DEBUG
        printf("MCBCN: memory allocation failure\n");
#endif
        return(NULL);
    }
    strcpy (ptr->name,tname);
    ptr->id = tid;
    ptr->base = tbase;
    ptr->len = tlen;
    return(ptr);
}

/* ********************************************************************* */

int isahexnum(s) /* is the string s a hex number */
char *s; /* string to check */

{
    int i;   /* general purpose counter */
    int len;   /* length of string */

    len = strlen(s);
    for (i = 0; i < len; i++) {
        if (  !(((*s >= 'a') && (*s <= 'f')) || ((*s >= 'A') && (*s <= 'F')) ||
                ((*s >= '0') && (*s <= '9'))) ) return(FALSE);
                s++;
    }
    return(TRUE);
}

/* ********************************************************************* */

int getad (s, id, addr, len) /* get address from name */
char *s;   /* first char of mnemonic */
unsigned short *id;    /* module id code */
unsigned short *addr;  /* module base address */
unsigned short *len;   /* address block len */

{
    int cnt; /* general purpose counter */

    cnt = 0;
    while ( dev[cnt] != (struct MCBAD *)NULL ) {
        if ( (*s == dev[cnt]->name[0]) && (*(s+1) == dev[cnt]->name[1]) ) {
            *id   = dev[cnt]->id;
            *addr = dev[cnt]->base;
            *len  = dev[cnt]->len;
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

    if ( (fp = fopen(mcbad_file,"r")) == NULL) {
#ifdef DEBUG
        printf("cannot open mcb address file %s\n",mcbad_file);
#endif
        return(-101);
    }

    cnt = 0;

    while ( ((dev[cnt] = get_mcbad(fp)) != NULL) && (cnt++ < 25) ) ;

    fclose (fp);
    if ( cnt >= 25 ) {
#ifdef DEBUG
        printf("too many mcb devices\n");
#endif
        return(-102);
    }
        /* print initialization information */
    cnt = 0;

#ifdef DEBUG
    printf ("MCBCN Copyright 1991, 1992 Interferometrics Inc.\n");
    printf ("MCBCN: initialization for the following devices\n");
    printf ("\nNM ID base  len  ");
    printf ("NM ID base  len  ");
    printf ("NM ID base  len  ");
    printf ("NM ID base  len\n");
    while ( dev[cnt] != (struct MCBAD *)NULL) {
        if ( (cnt+1)%4 == 0)
            printf("%2s %2x %4x %4x\n",
                dev[cnt]->name,dev[cnt]->id,dev[cnt]->base,dev[cnt]->len);
        else
            printf("%2s %2x %4x %4x  ",
                dev[cnt]->name,dev[cnt]->id,dev[cnt]->base,dev[cnt]->len);
            cnt++;
    }
#endif
    end=memccpy(mcb_dev,shm_addr->mcb_dev,' ',sizeof(mcb_dev)-1);
    if (end != NULL)
        *(end-1) = '\0';
    else
        *(mcb_dev+sizeof(mcb_dev)-1)= '\0';
/*    strcpy(mcb_dev,"/dev/cui1e");
*/
 
    if (!open_mcb(mcb_dev)) { /* open mcb unit */
#ifdef DEBUG
        printf ("Cannot open mcb device %s\n",mcb_dev);
#endif
        return(-107);
    }
    return(0);
}

/* ********************************************************************* */

int doproc(ip4)    /* process the input class buffers */
long ip4;
{
    time_t fmt1; /* formatter time first try */
    time_t sys1; /* system time first try */
    time_t sys2; /* system time second try */
    int cnt;     /* general purpose counter */
    int nmess;   /* number of messages processed */
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg;  /* argument for cls_rcv - unused */
    int save;    /* argument for cls_rcv - unused */
    int result;  /* return code for mcb_put and mcb_get */
    int bufcnt;  /* message buffer counter */
    int nchars;  /* number of characters in the class buffer received */
    unsigned short devid;   /* device ID number */
    unsigned short devad;   /* device base address */
    unsigned short devlen;  /* device address block length */
    unsigned short devdata; /* data value sent or received */
    char *tptr; /* char pointer to time_t */
    unsigned char outmess[100]; /* output message holder */
    int numbuf;       /* number of buffers */
    int iscmd;        /* is RAW request a command? */
    int it1[5],it61,it2[5],it62; /* arguments of rte_time */
    unsigned short devdatap;      /* temporary for TIMEW command */
    int done;                    /* TIMEW has completed */
    struct tms tms_buff;
    long end;

    inptr = outptr = msgflg = save = outclass = nbufout = 0;
    numbuf = ip[2];

    for(bufcnt = 0; bufcnt < numbuf; bufcnt++) {
        if ( (nchars = cls_rcv(ip[1],inbuf,512,&rtn1,&rtn2,msgflg,save)) <= 0) {
#ifdef DEBUG
            printf ("MCBCN failed to get a request buffer\n");
#endif
            return(-103);
        }

#ifdef DEBUG
        printf ("Buffer contains %d chars\n",nchars);
#endif
        inptr=0;
        while (inptr < nchars) {
            switch (inbuf[inptr]) {
                case SEND:   /* send data to an MCB address */
#ifdef DEBUG
                    printf("SEND request received\n");
#endif
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (SEND): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    devad += inbuf[inptr+4] + (inbuf[inptr+3]<<8);
                    devdata = inbuf[inptr+6] + (inbuf[inptr+5]<<8);
                    mcb_put (devad,devdata,&result);
                    outmess[0] = result;
                    putout ( outmess, 1);
                    inptr += SENDB;
                    break;

                case RECV:   /* get data from an MCB address */
#ifdef DEBUG
                    printf("RECV request received\n");
#endif
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (RECV): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    devad += inbuf[inptr+4] + 0x100*inbuf[inptr+3];
                    devdata = inbuf[inptr+6] + 0x100*inbuf[inptr+5];
                    mcb_get (devad, &devdata, &result);
                    outmess[0] = result;
                    outmess[1] = (devdata>>8) & 0xff;
                    outmess[2] = devdata & 0xff;
                    putout(outmess,3);
                    inptr += RECVB;
                    break;

                case INIT:   /* initialize the specified interface */
#ifdef DEBUG
                    printf("INIT request received\n");
#endif
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (INIT): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    mcb_put (devid*2,devlen,&result);
                    if (result == 0) {
                        mcb_put (devid*2+1,devad,&result);
                        outmess[0] = result;
                        putout(outmess, 1);
                    } else {
                        outmess[0] = result;
                        putout(outmess, 1);
                    }
                    inptr += INITB;
                    break;

                case CKUN:   /* check for an uninitialized interface */
#ifdef DEBUG
                    printf("CKUN request received\n");
#endif
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (CKUN): not initialized\n");
#endif
                        return(-104);
                    }
                    cnt = 0;
                    while ( dev[cnt] != (struct MCBAD *)NULL) {
                        devad = 2*(dev[cnt]->id)+1;
                        mcb_get (devad, &devdata, &result);
                        if (result != 1) {
                            outmess[0] = result;
                            putout(outmess, 1);
                            inptr += CKUNB;
                            break;
                        }
                        if (devdata == 0x7ff0) {
                            outmess[0] = result;
                            putout(outmess, 1);
                            inptr += CKUNB;
                            break;
                        }
                        cnt++;
                    }
                    break;
    
                case CHKA:   /* verify the address of an interface */
#ifdef DEBUG
                    printf("CHKA request received\n");
#endif
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (CHKA): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    mcb_get (2*devid + 1, &devdata, &result);
                    if (result == 1 && devdata != devad)
                        result = -18;
                    else if(result == 1)
                        result = 3;
                    if(result < 0) {
                        outmess[0] = result;
                        putout(outmess,1);
                        inptr += CHKAB;
                        break;
                    }
                    outmess[0] = result;
                    putout(outmess, 1);

                    devad = 2*devid;
                    mcb_get (devad, &devdata, &result);
                    if (result == 1 && devdata != devlen)
                        result = -19;
                    else if(result == 1)
                        result = 3;
                    outmess[0] = result;
                    putout(outmess, 1);
                    inptr += CHKAB;
                    break;

                case TIME:   /* get formatter time */
#ifdef DEBUG
                    printf("TIME request received\n");
#endif
/* system time immediately before data request */
                    sys1 = time(0);
                    outmess[0] = 2;
                    memcpy( outmess+1, (char*) &sys1, 4);
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (TIME): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    devad += inbuf[inptr+4] + (inbuf[inptr+3]<<8);
                    devdata = inbuf[inptr+6] + (inbuf[inptr+5]<<8);
                    mcb_get (devad, &devdata, &result);
                    outmess[5] = (devdata>>8) & 0xff;
                    outmess[6] = devdata & 0xff;

/* system time immediately after data request */
                    sys2 = time(0);
                    memcpy( outmess+7, (char*) &sys2, 4);
                    if (result >= 0) {
                        putout(outmess, 11);
                        result = 2;
                    } else {
                        outmess[0] = result;
                        putout(outmess,1);
                    }
                    inptr += TIMEB;
                    break;

                case SRAW:   /* send bytes to the MCB */
#ifdef DEBUG
                    printf("SRAW request received\n");
#endif
                /* detect command vs monitor request */
                    devad = inbuf[inptr+2] + (inbuf[inptr+1]<<8);
                    devdata = inbuf[inptr+4] + (inbuf[inptr+3]<<8);
                    if ( (devad & 0x8000) !=0) {
                        mcb_put(devad,devdata,&result);
                        outmess[0] = result;
                        putout ( outmess, 1);
                    } else {
                        mcb_get(devad,&devdata,&result);
                        outmess[0] = result;
                        outmess[1] = (devdata>>8) & 0xff;
                        outmess[2] = devdata & 0xff;
                        putout ( outmess, 3);
                    }
                    inptr += SRAWB;
                    break;

                case TIMEW:   /* synchronize command */
#ifdef DEBUG
                    printf("TIMEW request received\n");
#endif
                    outmess[0] = 4;
                    if (!initialized) {
#ifdef DEBUG
                        printf("MCBCN (TIMEW): not initialized\n");
#endif
                        return(-104);
                    }
                    memcpy(ip4,inbuf+inptr+1,2);
                    if (!getad(inbuf+inptr+1, &devid, &devad, &devlen)) {
#ifdef DEBUG
                        printf("MCBCN bad device mnemonic %c %c\n",
                            inbuf[inptr+1],inbuf[inptr+2]);
#endif
                        return(-105);
                    }
                    devad += inbuf[inptr+4] + (inbuf[inptr+3]<<8);
                    devdata = inbuf[inptr+6] + (inbuf[inptr+5]<<8);
                    
                    end=times(&tms_buff)+110;  /* calculate ending time */
                    while(end>times(&tms_buff)) {
                        done = FALSE;
			rte_time (it1,&it61);
                        mcb_get (devad, &devdata, &result);
                        rte_time (it2,&it62);
                        if(result < 0){
                            outmess[0]=result;
                            putout(outmess,1);
                            inptr += TIMEWB;
                            goto done_timew;
                        }
                        if (cnt == 0) devdatap = devdata;
                        if (devdatap != devdata)
                            {
                            outmess[1] = (devdata>>8) & 0xff;
                            outmess[2] = devdata & 0xff;
                            memcpy( outmess+ 3, (char*) it1, 24);
                            memcpy( outmess+23, (char*) &it61, 4);
                            memcpy( outmess+27, (char*) it2, 24);
                            memcpy( outmess+47, (char*) &it62, 4);
                            if (result >= 0) 
                                {
                                putout(outmess, 51);
                                result = 1;
                                } 
                            else  
                                {
                                outmess[0] = result;
                                putout(outmess,1);
                                }
                            inptr += TIMEWB;
                            done = TRUE;
                            break;
                            }
                        devdatap = devdata;
                        rte_sleep(1);         /* wait 0.01 sec and try again */
                        }
                    if (!done)
                        {
                        outmess[0] = -20;
                        result = -20;
                        putout(outmess, 1);
                        inptr += TIMEWB;
                        }
done_timew:
                    break;

                default:
#ifdef DEBUG
                    printf("MCBCN bad request buffer format %c at %d\n",
                        inbuf[inptr],inptr);
#endif
                    return(-108);
            }
            if( result <0) {
              cls_clr( ip[1]);
              return (result);
            }
        }
    }
    putout(NULL,-1);
    return(result);
}

/* ********************************************************************* */

int read_mcb(ch,nch)
char *ch; /* character buffer to fill in */
int nch;  /* number of characters to read */

{
    int cnt; /* character counter */
    int ict;
    struct tms tms_buff;
    long end;


/*
    set_mcb (5);    
*/

    cnt = 0;

    end=times(&tms_buff)+TIME_OUT;  /* calculate ending time */

    while (cnt < nch) {
        while( end-times(&tms_buff)>0 && ioctl(mcb_fildes,FIORDCHK,NULL) == 0) 
            rte_sleep( (unsigned) 1);

/* if we timed-out, but there are still characters on the input queue */
/* it might not be the device's fault it timed-out, we might have been */
/* delayed by a busy system, so we won't give-up until the queue is empty */

        if( end-times(&tms_buff)<=0  && ioctl(mcb_fildes,FIORDCHK,NULL) == 0){
           return (FALSE);
        }
        read(mcb_fildes,ch++,1);   
        if(iecho) secho[necho++]=*(ch-1);
        cnt++;
    }
#ifdef DEBUG
    printf(" actual delay %d \n",times(&tms_buff)-(end-TIME_OUT));
#endif
    return(TRUE);
}
/* ********************************************************************* */

int write_mcb(addr,val,mode) /* write to mcb */
unsigned short addr; /* address to write to */
unsigned short val;  /* value to write (if mode==CMD) */
int mode;            /* command or monitor */

{
    unsigned char messo1[5];  /* output chars in the right order */
    unsigned char messo2[10];  /* output chars with ESCP as necessary */
    int nch;                  /* number of char to send */
    int i;                    /* general purpose counter */

    /* prepare the buffer */
    messo1[0] = SYN;
    messo1[1] = (addr>>8) & 0xff;
    messo1[2] = addr & 0xff;
    messo1[3] = (val>>8) & 0xff;
    messo1[4] = val & 0xff;

    if (mode == CMD) messo1[1] |= 0x80;  /* write flag for commands */

    /* add ESCP characters as necessary */
    for (i = nch = 0; i < 5; i++,nch++)
    {
        messo2[nch] = messo1[i];
        if (messo2[nch] == ESCP) {
            messo2[++nch] = ESCP;
        }
        if ( (messo2[nch] == SYN) && (i != 0) ) {
            messo2[nch] = ESCP;
            messo2[++nch] = SYN;
        }
    }

    ioctl(mcb_fildes,TIOCFLUSH,NULL);

        /* write the characters to the MCB */
    if ( write(mcb_fildes,messo2,nch) != nch) {
        return(FALSE);
    }  

#ifdef DEBUG
    for(i = 0; i < nch; i++) {
        printf("[%2.2x]",messo2[i]);
    }
    printf("\n");
#endif

    if(iecho)
        for(i=0;i<5;i++) 
            secho[necho++]=messo1[i];

    return(TRUE);
}

/* ********************************************************************* */

void set_mcb(nread) /* set communication parameters */
int nread;

{
/* 9600 baud, 8 char, no parity, read enabled,   */
/*       direct connection, disconnect on close. */

    mcb.c_cflag = B9600 | CS8 | CREAD | CLOCAL | HUPCL;

    mcb.c_lflag = 0;

/* char functions are INTR, QUIT, ERASE, KILL,    */
/* EOF(min), EOL(time), (reserved), SWTCH.  min=min # char, time = timeout */
/* value in 0.1 second units */

    mcb.c_cc[0] = 0; /* INTR */
    mcb.c_cc[1] = 0; /* QUIT */
    mcb.c_cc[2] = 0; /* ERASE */
    mcb.c_cc[3] = 0; /* KILL */
    mcb.c_cc[4] = 1; /* min number of char necessary for completion */
    mcb.c_cc[5] = 10;    /* timeout value in 0.1 sec units */
    mcb.c_cc[7] = 0;     /* SWTCH */

    ioctl (mcb_fildes,TCSETA,&mcb);  /* set terminal settings */

}

/* ********************************************************************* */

void close_mcb()

{
    close(mcb_fildes);
}

/* ********************************************************************* */

int open_mcb(devnm)    /* open mcb tty line CAK 16OCT91 */
char *devnm;

{
    if ( (mcb_fildes = open(devnm, O_NDELAY | O_RDWR)) < 0 ) {
        return(FALSE);
    } else {
        ioctl (mcb_fildes,TCGETA,&mcb);   /* get terminal settings */
            set_mcb (1);                      /* set baud, etc */
        return(TRUE);
    }
}

/* ********************************************************************* */

void mcb_get (addr, val, result) /* monitor request */
unsigned short addr; /* address to read */
unsigned short *val; /* value read */
int *result;         /* return code */

{
    unsigned char ch[3]; /* temporary storage */
    unsigned short dummy;

    dummy = 0;
    *val = 0;
    if ( !write_mcb(addr,dummy,MON) ) { /* send monitor request */
#ifdef DEBUG
        printf("write failed on MCB\n");
#endif
        *result = -121;
        goto done;
    }

    ch[0] = ch[1] = ch[2] = 0;
    if ( !read_mcb(ch,2) ) { /* get reply */
#ifdef DEBUG
        printf("timeout on MCB\n");
#endif
        *result = -1;
        goto done;
    }
    if(!read_mcb(ch+2,1)){ /* short monitor reponse */
       if(ch[1]==NAK)
         *result = -5;    /* it was a NAK */
       else
         *result = -6;    /* a special type of time-out */
       goto done;
    }

    *val = (ch[1]<<8) + ch[2];
    *result = 1;
done:
       send_echo();
       return;
}

/* ********************************************************************* */

void mcb_put (addr, val, result) /* command request */
unsigned short addr; /* address to write */
unsigned short val;  /* value to write */
int *result;         /* return code */

{
    unsigned char ch[3]; /* temporary storage */

    if ( !write_mcb(addr,val,CMD) ) {
#ifdef DEBUG
        printf("write failed on MCB\n");
#endif
        *result = -121;
        goto done;
    }
    if (!read_mcb(ch,2)) {
#ifdef DEBUG
        printf("timeout on MCB\n");
#endif
        *result = -1;
        goto done;
    } 

    if ( ch[0] != ACK) {  /* an ACK is required */
        *result = -2;
        goto done;
    } else if ( ch[1] == DC1 ) { 
        *result = 0;
    } else if ( ch[1] == NAK ) {
        *result = -5;
    } else if ( ch[1] == DC2 ) {
        *result = -4;
    }
done:
    send_echo();
    return;
}

/* ********************************************************************* */

int putout (chars,nchar)
unsigned char *chars;
int nchar;

{
    int cnt; /* character counter */

    if (nchar <= 0) {
        if( outptr > 0) {
            cls_snd(&outclass, outbuf, outptr , 0, 0);
            nbufout++;
        }
        outptr = 0;
        return(TRUE);
    } else {
        if ( (outptr+nchar) >= BUFSIZE) {
            if ( !putout(chars,0) ) return (FALSE);
            if ( !putout(chars,nchar)) return(FALSE);
            return(TRUE);
        }
        for (cnt = 0; cnt < nchar; cnt++) {
            outbuf[outptr++] = *(chars+cnt);
        }
    }
    return(TRUE);
}

void send_echo()
{
char secho_out[79];
int iparm,i,inext,ilast;

    if(!iecho || necho <=0)  return;
    secho_out[0]='\0';
    if(secho[0]==SYN)
        strcat(secho_out,"[SYN]");
    else
        sprintf(secho_out+strlen(secho_out),"[ %2.2x]",secho[0]);
    if(necho<2) goto report;

    if(0 != (0x80 & secho[1]))
        sprintf(secho_out+strlen(secho_out),"[+%2.2x]",0x7f &secho[1]);
    else
        sprintf(secho_out+strlen(secho_out),"[ %2.2x]",secho[1]);
    if(necho<3) goto report;

    for(i=2;i<5;i++) 
        if(necho>=i+1)
            sprintf(secho_out+strlen(secho_out),"[ %2.2x]",secho[i]);
        if(necho<6) goto report;

    if(secho[5]==ACK)
        strcat(secho_out,"<ACK>");
    else
        sprintf(secho_out+strlen(secho_out),"< %2.2x>",secho[5]);
    if(necho<7) goto report;
        
    inext=6;
    if(0!=(0x80 &secho[1])) {
        if(secho[6]==DC1) strcat(secho_out,"<DC1>");
        else if(secho[6]==DC2) strcat(secho_out,"<DC2>");
        else if(secho[6]==NAK) strcat(secho_out,"<NAK>");
        else
            sprintf(secho_out+strlen(secho_out),"< %2.2x>",secho[6]);
        inext=7;
    }

    ilast=necho;
    if(necho>15) ilast=15;
    for(i=inext;i<ilast;i++)
        sprintf(secho_out+strlen(secho_out),"< %2.2x>",secho[i]);

    if(ilast>necho) strcat(secho_out,"...");

report:
    memcpy(&iparm,"to",2);
    cls_snd(&shm_addr->iclbox,secho_out,strlen(secho_out),0,iparm);
    necho=0;
}
