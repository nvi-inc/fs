/* holog external program *
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  100524  created from onoff.c
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

main()
{
  int ip[5],ip1[5];
  struct holog_cmd holog;
  int i,it[6], ierr, j, ierr1, nwt, koff;
  double az,el, xoff, yoff, azoff, eloff, haoff, decoff;
  char buff[256];
  float rut,rut1,astep,estep,astep1,estep1;
  int azp,elp;

/* connect to the FS */

  putpname("holog");
  setup_ids();
 
 loop:
  skd_wait("holog",ip,0);

  if ( 1 == nsem_take("holog",1)) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-3;
    memcpy(ip+3,"hl",2);
    logita(NULL,ip[2],ip+3,ip+4);
    goto loop;
  }

  /* save offsets immediately, so error_recovery won't misbehave */
  
  savoff(&xoff,&yoff,&azoff,&eloff,&haoff,&decoff);

  /* remove breaks that are hanging around */

  (void) brk_chk("holog");

  koff=FALSE;
  memcpy(&holog,&shm_addr->holog,sizeof(holog));

  ierr=0;

  /* wait for onsource */

  nwt=holog.wait;
  if(onsor(nwt,&ierr)) 
    goto error_recover;

  if(local(&az,&el,"azel",&ierr))
    goto error_recover;

  rte_time(it,it+5);
  rut=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;

  strcpy(buff,holog.proc);
  strcat(buff,"i=");
  int2str(buff,it[5],-4,1);
  strcat(buff,".");
  int2str(buff,it[4],-3,1);
  strcat(buff,".");
  int2str(buff,it[3],-2,1);
  strcat(buff,":");
  int2str(buff,it[2],-2,1);
  strcat(buff,":");
  int2str(buff,it[1],-2,1);
  scmd(buff);

  sprintf(buff,"AzEl",rut);
  strcat(buff," ");
  jr2as((float) az*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) el*RAD2DEG,buff,-9,5,sizeof(buff));
  logit(buff,0,NULL);

  savoff(&xoff,&yoff,&azoff,&eloff,&haoff,&decoff);
 
  sprintf(buff,"Origin %7.1lf",rut);
  strcat(buff," ");
  jr2as((float) xoff*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) yoff*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) azoff*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) eloff*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) haoff*RAD2DEG,buff,-9,5,sizeof(buff));
  strcat(buff," ");
  jr2as((float) decoff*RAD2DEG,buff,-9,5,sizeof(buff));
  logit(buff,0,NULL);

  azp=abs(holog.azp);
  elp=abs(holog.elp);

  if(holog.elp >= 1)
    astep=(holog.az/cos(el))/(azp-1);
  else
    astep=holog.az/(azp-1);

  estep=holog.el/(elp-1);

  if( holog.ical > 0) {
    rte_time(it,it+5);
    rut1=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
    if(rut1 < rut)
      rut1 += 86400.;
    sprintf(buff,"First %7.1lf",rut1);
    logit(buff,0,NULL);
    next(buff,0.0,0.0,sizeof(buff));
    if(gooff(azoff,eloff,"azel",holog.wait,&ierr))
      goto error_recover;

    scmds(holog.proc,0.0,0.0);
    rte_time(it,it+5);
    rut=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
  }

  if((holog.azp > 1)) { /*furrow in az */
    for(j=-elp/2;j<=elp/2;j++) {
      if(elp == 1) {           /* one row */
	astep1=astep;
	estep1=0.0;
      } else {                /* multiple rows */
	astep1=astep*(1-2*abs((j+elp/2)%2)); /* alternate directions */
	estep1=estep;
      }

      for(i=-azp/2;i<=azp/2;i++) {
	if(holog.ical > 0) {
	  if(i==0 && j==0)
	    continue;
	  rte_time(it,it+5);
	  rut1=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
	  if(rut1 < rut)
	    rut1 += 86400.;
	  if(rut1-rut >= holog.ical) {
	    sprintf(buff,"Recalibrate %7.1lf",rut1);
	    logit(buff,0,NULL);
	    next(buff,0.0,0.0,sizeof(buff));
	    if(gooff(azoff,eloff,"azel",holog.wait,&ierr))
	      goto error_recover;

	    koff=FALSE;
	    scmds(holog.proc,0.0,0.0);
	    rut=rut1;
	  }
	}
	next(buff,i*astep1,j*estep1,sizeof(buff));
	koff=TRUE;
	if(gooff(azoff+i*astep1,eloff+j*estep1,"azel",
		 shm_addr->holog.wait,&ierr))
	  goto error_recover;
	scmds(holog.proc,i*astep1,j*estep1);
      }
    }
  } else { /* furrow in elevation */
    for(i=-azp/2;i<=azp/2;i++) {
      if(elp == 1 && azp == 1) { /* one point */
	astep1=0.0;
	estep1=0.0;
      } else if(azp == 1) {  /* one column */
	astep1=0.0;
	estep1=estep;
      } else  {                 /* multiple columns */
	astep1=astep;
	estep1=estep*(1-2*abs((i+azp/2)%2)); /* alternate directions */
      }

      for(j=-elp/2;j<=elp/2;j++) {
	if(holog.ical > 0) {
	  if(i==0 && j==0)
	    continue;
	  rte_time(it,it+5);
	  rut1=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
	  if(rut1 < rut)
	    rut1 += 86400.;
	  if(rut1-rut >= holog.ical) {
	    sprintf(buff,"Recalibrate %7.1lf",rut1);
	    logit(buff,0,NULL);
	    next(buff,0.0,0.0,sizeof(buff));
	    if(gooff(azoff,eloff,"azel",holog.wait,&ierr))
	      goto error_recover;

	    koff=FALSE;
	    scmds(holog.proc,0.0,0.0);
	    rut=rut1;
	  }
	}
	next(buff,i*astep1,j*estep1,sizeof(buff));
	koff=TRUE;
	if(gooff(azoff+i*astep1,eloff+j*estep1,"azel",
		 shm_addr->holog.wait,&ierr))
	  goto error_recover;
	scmds(holog.proc,i*astep1,j*estep1);
      }
    }
  }

  if( holog.ical > 0) {
    rte_time(it,it+5);
    rut1=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
    if(rut1 < rut)
      rut1 += 86400.;
    sprintf(buff,"Last %7.1lf",rut1);
    logit(buff,0,NULL);
    next(buff,0.0,0.0,sizeof(buff));
#ifdef WEH
    rte_sleep(500);
#else
    if(gooff(azoff,eloff,"azel",holog.wait,&ierr))
      goto error_recover;
#endif
    koff=FALSE;
    scmds(holog.proc,0.0,0.0);
  }

 error_recover:
 
  ip1[2]=0;
  if(koff)
#ifdef WEH
  rte_sleep(500);
#else
    if(gooff(azoff,eloff,"azel",holog.wait,&ierr1)) {
      ip1[0]=0;
      ip1[1]=0;
      ip1[2]=ierr1;
      ip1[4]=0;
      memcpy(ip1+3,"hl",2);
    }
#endif

  if(ip1[2]!=0) {
    logita(NULL,ip1[2],ip1+3,ip1+4);
    ip1[0]=0;
    ip1[1]=0;
    ip1[2]=-4;
    memcpy(ip1+3,"hl",2);
    ip1[4]=0;
    logita(NULL,ip1[2],ip1+3,ip1+4);
  }
  if(ierr!=0) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"hl",2);
    logita(NULL,ip[2],ip+3,ip+4);
  }

  nsem_put("holog");
  logit("Finished",0,NULL);

  goto loop;

}  /* end main */
