/* getvtime.c - get vlba formatter time */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */

extern unsigned char inbuf[512];      /* class i-o buffer */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern char *timecmd;
extern long inclass;         /* input class number */
extern long outclass;        /* output class number */
extern long ip[5];           /* parameters for fs communications */
extern int rtn1, rtn2, msgflg, save; /* unused cls_get args */

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

void getvtime(unixtime,unixhs,formtime,formhs)
time_t *unixtime; /* system time received from mcbcn */
int    *unixhs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
        unsigned short fmtyya; /* formatter BCD YYYY */
        unsigned short fmtdda; /* formatter BCD 0DDD */
        unsigned short fmthha; /* formatter BCD 00HH */
        unsigned short fmtmsa; /* formatter BCD MMSS */
        unsigned short fmtyyb; /* formatter BCD YYYY */
        unsigned short fmtddb; /* formatter BCD 0DDD */
        unsigned short fmthhb; /* formatter BCD 00HH */
        unsigned short fmtmsb; /* formatter BCD MMSS */
	int nbytes;            /* bytes received from mcbcn */
        int cnt;               /* counter for the repeat loop */
	int i;                 /* general purpose counter */
        time_t time1;          /* time from the first formatter reading */
        time_t time2;          /* time from the second formatter reading */
        int dt;                /* difference in times */
	unsigned long ly,ld,lh,lm,ls,lmsa,lmsb; /* temporaries */
	int it[6];

        dt = 100;
        cnt = 0;
        while ( (dt > 10) && (cnt++ < 5) ) /* iterate until two consecutive */
        {                                  /* readings are about the same   */
	for (i = 0; i < 40; i++)
		{
		outbuf[i] = timecmd[i];
		}

/* create class and send command */
	outclass = 0;
	cls_snd(&outclass, outbuf, 40, 0, 0); 

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
	if( ip[2] != 2 )
		{
		endwin();
		printf("Error %d from formatter\n",ip[2]);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}
	msgflg = save = 0;
	if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                               &rtn1, &rtn2, msgflg, save)) != 88)
		{
		endwin();
		printf("Wrong len msg - %d bytes received\n" ,nbytes);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}

/* the way mcbcn is written, getting the right length message         */
/* is enough to insure that each of the eight requests was successful */

	cls_clr(outclass); /* clear class numbers just in case */
	cls_clr(inclass);

/* get the two times bracketing the commands with bytes in the right order */
	memcpy ( (char*) &time1, inbuf+ 1, 4);
	memcpy ( (char*) &time2, inbuf+84, 4);
	*unixtime = time1 + (time2-time1)/2;

/* get the various formatter times with bytes in the right order */
	swab ( inbuf+ 5, inbuf+ 5, 2);
	swab ( inbuf+16, inbuf+16, 2);
	swab ( inbuf+27, inbuf+27, 2);
	swab ( inbuf+38, inbuf+38, 2);
	swab ( inbuf+49, inbuf+49, 2);
	swab ( inbuf+60, inbuf+60, 2);
	swab ( inbuf+71, inbuf+71, 2);
	swab ( inbuf+82, inbuf+82, 2);
	memcpy ( (char*) &fmtyya, inbuf+ 5, 2);
	memcpy ( (char*) &fmtdda, inbuf+16, 2);
	memcpy ( (char*) &fmthha, inbuf+27, 2);
	memcpy ( (char*) &fmtmsa, inbuf+38, 2);
	memcpy ( (char*) &fmtyyb, inbuf+49, 2);
	memcpy ( (char*) &fmtddb, inbuf+60, 2);
	memcpy ( (char*) &fmthhb, inbuf+71, 2);
	memcpy ( (char*) &fmtmsb, inbuf+82, 2);

/* convert year from BCD to integer */
        fmtyya = (fmtyya >> 12 & 0xf) * 1000 + (fmtyya >>  8 & 0xf) * 100
                 +(fmtyya >>  4 & 0xf) *   10 + (fmtyya       & 0xf);
        fmtyyb = (fmtyyb >> 12 & 0xf) * 1000 + (fmtyyb >>  8 & 0xf) * 100
                 +(fmtyyb >>  4 & 0xf) *   10 + (fmtyyb       & 0xf);

/* convert day number from BCD to integer */
        fmtdda = (fmtdda >>  8 & 0xf) * 100
                 +(fmtdda >>  4 & 0xf) *   10 + (fmtdda      & 0xf);
        fmtddb = (fmtddb >>  8 & 0xf) * 100
                 +(fmtddb >>  4 & 0xf) *   10 + (fmtddb      & 0xf);

/* convert hours, minutes, and seconds from BCD to integer seconds */
        fmthha = (fmthha >>  4 & 0xf) *   10 + (fmthha      & 0xf);
                 fmthhb = (fmthhb >>  4 & 0xf) *   10 + (fmthhb      & 0xf);
        fmtmsa = (fmtmsa >> 12 & 0xf) *  600 + (fmtmsa >>  8 & 0xf) * 60
                 +(fmtmsa >>  4 & 0xf) *   10 + (fmtmsa       & 0xf);
        fmtmsb = (fmtmsb >> 12 & 0xf) *  600 + (fmtmsb >>  8 & 0xf) * 60
                 +(fmtmsb >>  4 & 0xf) *   10 + (fmtmsb       & 0xf);
        lmsa = fmtmsa + (fmthha*3600);
        lmsb = fmtmsb + (fmthhb*3600);

 /* get time in seconds since 1 Jan 1970 */
	it[5] = fmtyya;
	it[4] = fmtdda;
	it[3] = 0;
	it[2] = 0;
	it[1] = 0;
	it[0] = 0;
        rte2secs_(it,&time1);
        time1 += lmsa;
	it[5] = fmtyyb;
	it[4] = fmtddb;
        rte2secs_(it,&time2);
        time2 +=  lmsb;
	*formtime = time1 + (time2-time1);
	*formhs = 0;
        dt = abs( (double)time2 -  (double)time1);
        }

        if (cnt >= 5) *formtime = 1;
}
