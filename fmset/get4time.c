/* get4time.c - get mk4 formatter time */

#include <sys/types.h>   /* data type definition header file */

extern long ip[5];
extern char inbuf[512];
extern long outclass;
extern long inclass;
extern int rtn1, rtn2, msgflg, save;

void cls_clr();
int cls_rcv();
void cls_snd();
void skd_run();
void skd_par();
void rte2secs();
static short tmget[]= {0,'fm','/t','im'};

void get4time(unixtime,unixhs,formtime,formhs)
time_t *unixtime; /* system time */
int *unixhs;
time_t *formtime; /* formatter time */
int *formhs;
{
	int itm[13],it[6],ms,nbytes,nrecs,ierr;
	long timea, timeb;
	double timeavg;
	int cnt=0;
	
	if (tmget[0] == 0) {
		tmget[0]=-54;
		memcpy(tmget+1,"fm",2);
		memcpy(tmget+2,"/tim",4);
	}
tryagain:
	outclass = 0;
	cls_snd(&outclass, tmget ,sizeof(tmget), 0, 0); 

	ip[0] = outclass; /* class number */
	ip[1] = 1;        /* only one buf */
	ip[2] = 0;
	ip[3] = 0;
	ip[4] = 0;
	skd_run("matcn",'w',ip);

/* get reply from matcn */
	skd_par(ip);
	inclass = ip[0];
        nrecs = ip[1];
        ierr= ip[2];
	if( ierr < 0 )
		{
		endwin();
		printf("Error reply from matcn - error %d\n", ierr );
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}
	msgflg = save = 0;
	if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                               &rtn1, &rtn2, msgflg, save)) <0)
		{
		endwin();
		printf("Error rec. msg - %d bytes received\n" ,nbytes);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}
	inbuf[nbytes]='\0';

	if ( (nbytes = cls_rcv(inclass, itm, 52, 
                               &rtn1, &rtn2, msgflg, save)) <0)
		{
		endwin();
		printf("Error rec. time - %d bytes received\n" ,nbytes);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}

	sscanf(inbuf+2,"%d %d %d:%d:%d.%d",it+5,it+4,it+3,it+2,it+1,&ms);
        it[0]=ms/10;
        rte2secs(it,formtime);
        *formhs = it[0];

	cls_clr(outclass); /* clear class numbers just in case */
	cls_clr(inclass);

        if(*formtime<0) 
		if(cnt++>5) {
		endwin();
		printf("Error year less than 1900 for 5 tries\n");
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		} else
			goto tryagain;

        rte2secs(itm,&timeb);
        rte2secs(itm+6,&timea);
        timeavg=(((double) timea)+((double) timeb)+0.01*(itm[0]+itm[6]))/2.0;
        *unixtime=timeavg;
        *unixhs=(timeavg-*unixtime)*100.0;
        if(*unixhs<0)
		*unixhs = 0;
	else if(*unixhs>99) {
		*unixtime = *unixhs/100;
		*unixhs = *unixhs % 100;
	}
        
}
