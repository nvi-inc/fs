/* setvtime.c - set vlba formmatter time */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <errno.h>       /* error code definition header file */
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */

extern unsigned char inbuf[512];      /* class i-o buffer */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern char *setcmd;
extern long inclass;         /* input class number */
extern long outclass;        /* output class number */
extern long ip[5];           /* parameters for fs communications */
extern int rtn1, rtn2, msgflg, save; /* unused cls_get args */

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

void setvtime(formtime)
time_t formtime;
{
struct tm *fmtime;  /* pointer to tm structure */
int i;              /* general purpose counter */
int nbytes;         /* number of bytes received from mcbcn */
unsigned short bcd; /* holder for BCD digits   */

/* convert calendar time to conventional time */
fmtime = gmtime(&formtime);

for (i = 0; i < 28; i++)  /* get set time message */
	{
	outbuf[i] = setcmd[i];
	}

fmtime->tm_year += 1900;  /* gmtime returns years since 1900 */
bcd = 0;
for (i = 1000; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_year / i;
	fmtime->tm_year = fmtime->tm_year % i;
	}
memcpy(outbuf+5,&bcd,2);
swab(outbuf+5,outbuf+5,2);

/* stuff address & BCD day # into message */
fmtime->tm_yday += 1;  /* gmtime returns days since 1 january */
bcd = 0;
for (i = 100; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_yday / i;
	fmtime->tm_yday = fmtime->tm_yday % i;
	}
memcpy(outbuf+12,&bcd,2);
swab(outbuf+12,outbuf+12,2);

/* stuff address & BCD hour into message */
bcd = fmtime->tm_hour / 10 << 4 | fmtime->tm_hour % 10;
memcpy(outbuf+19,&bcd,2);
swab(outbuf+19,outbuf+19,2);

/* stuff address & BCD minute-second into message */
bcd = fmtime->tm_min / 10 << 12 |
      fmtime->tm_min % 10 << 8  |
      fmtime->tm_sec / 10 << 4  |
      fmtime->tm_sec % 10;
memcpy(outbuf+26,&bcd,2);
swab(outbuf+26,outbuf+26,2);

/* send request buffer to MCB */
/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, 28, 0, 0); 

ip[0] = 1;        /* process command buf */
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;
skd_run("mcbcn",'w',ip);

/* get reply from mcbcn */
ip[0] = ip[1] = ip[2] = ip[3] = ip[4] = 0;
skd_par(ip);
inclass = ip[0];
if( ip[1] != 1 )
	{
	endwin();
	printf("No reply from formatter - error %d\n", ip[2] );
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
if( ip[2] != 0 )
	{
	endwin();
	printf("Error %d from formatter\n",ip[2]);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
msgflg = save = 0;
if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                       &rtn1, &rtn2, msgflg, save)) != 4)
	{
	endwin();
	printf("Wrong len msg - %d bytes received\n" ,nbytes);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}

if( inbuf[0] | inbuf[1] | inbuf[2] | inbuf[3] ) /* check completion code */
	{
	endwin();
	printf("Bad completion code from formatter %d %d %d %d\n",
               inbuf[0],inbuf[1],inbuf[2],inbuf[3]);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}
