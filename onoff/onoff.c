/* onoff external program *
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  020823  created from tpicd.c
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"


main()
{
  long ip[5],ip1[5],ip2[5];
  struct onoff_cmd onoff;
  int i,it[6],isgn, ierr, ksem, kresult,j, ierr1, ierr2;
  double az,el, xoff, yoff, azoff, eloff, haoff, decoff;
  char buff[256],buff2[256],source_type[MAX_DET];
  float rut,astep,estep;
  struct sample sample,ons,onscal,ofs,ofscal,zero;
  float gcmp[MAX_DET],tsys[MAX_DET],sefd[MAX_DET],tclj[MAX_DET];
  float tclk[MAX_DET],calr[MAX_DET];
  float gcmp_sig[MAX_DET],tsys_sig[MAX_DET],sefd_sig[MAX_DET];
  float tclj_sig[MAX_DET],tclk_sig[MAX_DET],calr_sig[MAX_DET];
  char lsorna[sizeof(shm_addr->lsorna)+1];
  float beam;

/* connect to the FS */

  putpname("onoff");
  setup_ids();
 

 loop:
  skd_wait("onoff",ip,0);

  if ( 1 == nsem_take("onoff",1)) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-3;
    memcpy(ip+3,"nf",2);
    logita(NULL,ip[2],ip+3,ip+4);
    goto loop;
  }
  kresult=FALSE;
  memcpy(&onoff,&shm_addr->onoff,sizeof(onoff));

  ierr=0;

  if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4)
    if(agc(onoff.itpis,0,&ierr))
      goto error_recover;

  if(local(&az,&el,"azel",&ierr))
    goto error_recover;

  el*=RAD2DEG;
  az*=RAD2DEG;

  
  memcpy(lsorna,shm_addr->lsorna,sizeof(lsorna)-1);
  lsorna[sizeof(lsorna)-1]=0;
  for(j=0;j<sizeof(lsorna)-1;j++)
    if(lsorna[j]==' ') {
      lsorna[j]=0;
      break;
    }

  for(j=0;j<MAX_DET;j++) {
    if(onoff.itpis[j]!=0) {
      source_type[j]='x';
      for(i=0;i<MAX_FLUX;i++){
	if(shm_addr->flux[i].name[0]==0)
	  break;
	if(strcmp(lsorna,shm_addr->flux[i].name)==0
	   && onoff.devices[j].center >= shm_addr->flux[i].fmin
	   && onoff.devices[j].center <= shm_addr->flux[i].fmax) {
	  source_type[j]=shm_addr->flux[i].type;
	  break;
	}
      }
    }
  }

  sprintf(buff2,
 "    De    Center  TCal    Flux    DPFU     Gain    Product   LO    T   FWHM");
  logit(buff2,0,NULL);

  for(i=0;i<MAX_DET;i++) {
    if(onoff.itpis[i]!=0) {
      /*      sprintf(buff,
	      "APR %-10.10s %5.1f %4.1f %2.2s %d %c %9.2lf ",
	      shm_addr->lsorna,az,el,
	      onoff.devices[i].lwhat,
	      onoff.devices[i].ifchain,
	      onoff.devices[i].pol,
	      onoff.devices[i].center); */
      
      sprintf(buff,
	      "APR %2.2s %9.2lf ",
	      onoff.devices[i].lwhat,onoff.devices[i].center);
      jr2as(onoff.devices[i].tcal,buff,-5,3,sizeof(buff));
      strcat(buff," ");
      jr2as(onoff.devices[i].flux,buff,-7,1,sizeof(buff));
      strcat(buff," ");
      jr2as(onoff.devices[i].dpfu,buff,-9,6,sizeof(buff));
      strcat(buff," ");
      jr2as(onoff.devices[i].gain,buff,-7,5,sizeof(buff));
      strcat(buff," ");
     jr2as(onoff.devices[i].dpfu*onoff.devices[i].gain,buff,-9,6,sizeof(buff));

     sprintf(buff+strlen(buff)," %.2f %c %.5f",
	     shm_addr->lo.lo[onoff.devices[i].ifchain-1],
	     source_type[i],
	     onoff.devices[i].fwhm*RAD2DEG);

      logit(buff,0,NULL);
    }
  }

  /* wait for onsource */

  printf(" wait %d\n",shm_addr->onoff.wait);
  if(onsor(2*shm_addr->onoff.wait,&ierr)) 
    goto error_recover;

  rte_time(it,it+5);
  rut=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;

  scmds("caloffnf");

  savoff(&xoff,&yoff,&azoff,&eloff,&haoff,&decoff);
 
  sprintf(buff,"ORIG %7.1lf",rut);
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

  beam=sqrt(shm_addr->onoff.fwhm*shm_addr->onoff.fwhm+
	    shm_addr->onoff.ssize*shm_addr->onoff.ssize);

  if(el>shm_addr->onoff.cutoff) {
    astep=0.0;
    estep=shm_addr->onoff.step*beam;
  } else {
    estep=0.0;
    astep=shm_addr->onoff.step*beam/cos(el*DEG2RAD);
  }

  ini_accum(&onoff.itpis,&ons);
  ini_accum(&onoff.itpis,&onscal);
  ini_accum(&onoff.itpis,&ofs);
  ini_accum(&onoff.itpis,&ofscal);
  ini_accum(&onoff.itpis,&zero);

  isgn=-1;

  for(i=0;i<shm_addr->onoff.rep;i++) {

    if(i!=0) { 
      if(gooff(azoff,eloff,"azel",shm_addr->onoff.wait,&ierr))
	goto error_recover;
    }

    if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
      goto error_recover;
    wcounts("ONSO",0.0,0.0,&onoff,&sample);
    inc_accum(&onoff.itpis,&ons,&sample);

    scmds("calonnf");
    if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
      goto error_recover;
    wcounts("ONSC",0.0,0.0,&onoff,&sample);
    inc_accum(&onoff.itpis,&onscal,&sample);

    isgn=-isgn;

    if(gooff(azoff+isgn*astep,eloff+isgn*estep,"azel",shm_addr->onoff.wait,&ierr))
      goto error_recover;

    if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
      goto error_recover;
    wcounts("OFFC",isgn*astep,isgn*estep,&onoff,&sample);
    inc_accum(&onoff.itpis,&ofscal,&sample);

    scmds("caloffnf");
    if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
      goto error_recover;
    wcounts("OFFS",isgn*astep,isgn*estep,&onoff,&sample);
    inc_accum(&onoff.itpis,&ofs,&sample);

    if(i==0) {
      if(tzero(ip,&onoff,rut,&sample,&ierr)) {
	goto error_recover;
      }
      wcounts("ZERO",isgn*astep,isgn*estep,&onoff,&sample);
      inc_accum(&onoff.itpis,&zero,&sample);
    }

  }

  /*last point onsource */
  if(gooff(azoff,eloff,"azel",shm_addr->onoff.wait,&ierr))
    goto error_recover;

  if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
    goto error_recover;
  wcounts("ONSO",0.0,0.0,&onoff,&sample);
  inc_accum(&onoff.itpis,&ons,&sample);
  
  scmds("calonnf");
  if(get_samples(ip,&onoff.itpis,onoff.intp,rut,&sample,&ierr))
    goto error_recover;
  wcounts("ONSC",0.0,0.0,&onoff,&sample);
  inc_accum(&onoff.itpis,&onscal,&sample);

  red_accum(&onoff.itpis,&ons);
  red_accum(&onoff.itpis,&onscal);
  red_accum(&onoff.itpis,&ofs);
  red_accum(&onoff.itpis,&ofscal);
  red_accum(&onoff.itpis,&zero);

  for (i=0;i<MAX_DET;i++)
    if(onoff.itpis[i]!=0) {
      double num,den;
#if 0
  sprintf(buff," i %d onscal.avg %f ons.avg %f ofscal.avg %f ofs.avg %f zero.avg %f",
	   i,  onscal.avg[i],ons.avg[i],ofscal.avg[i],ofs.avg[i],zero.avg[i]);
      logit(buff,0,NULL);
  sprintf(buff," i %d onscal.sig %f ons.sig %f ofscal.sig %f ofs.sig %f zero.sig %f",
	  i,  onscal.sig[i],ons.sig[i],ofscal.sig[i],ofs.sig[i],zero.sig[i]);
      logit(buff,0,NULL);
#endif
      	gcmp[i]=(onscal.avg[i]-ons.avg[i])
	  /(ofscal.avg[i]-ofs.avg[i]);
	num=(onscal.avg[i]-ons.avg[i]);
	den=ofscal.avg[i]-ofs.avg[i];
	gcmp_sig[i]=sqrt(
			 pow(onscal.sig[i]/den,2.0)
			 +pow(ons.sig[i]/den,2.0)
			 +pow(ofscal.sig[i]*num/(den*den),2.0)
			 +pow(ofs.sig[i]*num/(den*den),2.0)
			 );
	
	tsys[i]=(ofs.avg[i]-zero.avg[i])*onoff.devices[i].tcal
	  /(ofscal.avg[i]-ofs.avg[i]);
	num=(ofs.avg[i]-zero.avg[i])*onoff.devices[i].tcal;
	den=ofscal.avg[i]-ofs.avg[i];
	tsys_sig[i]=sqrt(
			 pow(ofs.sig[i]*
			     (onoff.devices[i].tcal/den+num/(den*den)),2.0)
			 +pow(zero.sig[i]*onoff.devices[i].tcal/den,2.0)
			 +pow(ofscal.sig[i]*num/(den*den),2.0));

	sefd[i]=(ofs.avg[i]-zero.avg[i])*onoff.devices[i].flux
	  /(ons.avg[i]-ofs.avg[i]);
	num=(ofs.avg[i]-zero.avg[i])*onoff.devices[i].flux;
	den=onscal.avg[i]-ofs.avg[i];
	sefd_sig[i]=sqrt(
			 pow(ofs.sig[i]*
			     (onoff.devices[i].flux/den+num/(den*den)),2.0)
			 +pow(zero.sig[i]*onoff.devices[i].flux/den,2.0)
			 +pow(ons.sig[i]*num/(den*den),2.0));

	tclj[i]=(ofscal.avg[i]-ofs.avg[i])*onoff.devices[i].flux
	  /(ons.avg[i]-ofs.avg[i]);
	num=(ofscal.avg[i]-ofs.avg[i])*onoff.devices[i].flux;
	den=ons.avg[i]-ofs.avg[i];
	tclj_sig[i]=sqrt(
			 pow(ofscal.sig[i]*onoff.devices[i].flux/den,2.0)
			 +pow(ofs.sig[i]*(onoff.devices[i].flux/den
					  -num/(den*den)),2.0)
			 +pow(ons.sig[i]*num/(den*den),2.0));

	tclk[i]=onoff.devices[i].dpfu*tclj[i]*onoff.devices[i].gain;
	tclk_sig[i]=onoff.devices[i].dpfu*tclj_sig[i]*onoff.devices[i].gain;

	calr[i]=tclk[i]/onoff.devices[i].tcal;
	calr_sig[i]=tclk_sig[i]/onoff.devices[i].tcal;

    }
  kresult=TRUE;

 error_recover:
 
  ip1[2]=0;
  if(!kresult)
    if(gooff(azoff,eloff,"azel",shm_addr->onoff.wait,&ierr1)) {
      ip1[0]=0;
      ip1[1]=0;
      ip1[2]=ierr1;
      ip1[4]=0;
      memcpy(ip1+3,"nf",2);
    }

  ip2[2]=0;
  if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4)
    if(agc(onoff.itpis,1,&ierr2)) {
      ip2[0]=0;
      ip2[1]=0;
      ip2[2]=ierr2;
      ip2[4]=0;
      memcpy(ip2+3,"nf",2);
    }

  if(kresult) {
    for (i=0;i<MAX_DET;i++)
      if(onoff.itpis[i]!=0) {
	sprintf(buff,
		"SIG %-10.10s %5.5s %4.4s %2.2s %1.1s %1.1s %9.9s ",
		" "," "," ",
		onoff.devices[i].lwhat,
		" ",
		" ",
		" ");
	jr2as(gcmp_sig[i],buff,-5,2,sizeof(buff));
	strcat(buff," ");
	jr2as(tsys_sig[i],buff,-5,2,sizeof(buff));
	strcat(buff," ");
	jr2as(sefd_sig[i],buff,-6,1,sizeof(buff));
	strcat(buff," ");
	jr2as(tclj_sig[i],buff,-7,3,sizeof(buff));
	strcat(buff," ");
	jr2as(tclk_sig[i],buff,-5,3,sizeof(buff));
	strcat(buff," ");
	jr2as(calr_sig[i],buff,-5,2,sizeof(buff));
	logit(buff,0,NULL);
      }

    sprintf(buff2,
 "    source       Az   El  De I P   Center   Comp   Tsys  SEFD  Tcal(j) Tcal(r)");
    logit(buff2,0,NULL);

    for (i=0;i<MAX_DET;i++)
      if(onoff.itpis[i]!=0) {
	sprintf(buff,
		"VAL %-10.10s %5.1f %4.1f %2.2s %d %c %9.2lf ",
		shm_addr->lsorna,az,el,
		onoff.devices[i].lwhat,
		onoff.devices[i].ifchain,
		onoff.devices[i].pol,
		onoff.devices[i].center);
	jr2as(gcmp[i],buff,-6,4,sizeof(buff));
	strcat(buff," ");
	jr2as(tsys[i],buff,-5,2,sizeof(buff));
	strcat(buff," ");
	jr2as(sefd[i],buff,-6,1,sizeof(buff));
	strcat(buff," ");
	jr2as(tclj[i],buff,-7,3,sizeof(buff));
	strcat(buff," ");
	/*
	jr2as(tclk[i],buff,-5,3,sizeof(buff));
	strcat(buff," ");
	*/
	jr2as(calr[i],buff,-6,4,sizeof(buff));
	logit(buff,0,NULL);
	if(onoff.devices[i].corr>=1.2) {
	  memcpy(ip+3,"nf",2);
	  logita(NULL,-7,ip+3,onoff.devices[i].lwhat);
	}
      }
    logit(buff2,0,NULL);
  }

  if(ip1[2]!=0) {
    logita(NULL,ip1[2],ip1+3,ip1+4);
    ip1[0]=0;
    ip1[1]=0;
    ip1[2]=-4;
    memcpy(ip1+3,"nf",2);
    ip1[4]=0;
    logita(NULL,ip1[2],ip1+3,ip1+4);
  }
  if(ip2[2]!=0) {
    logita(NULL,ip2[2],ip2+3,ip2+4);
    ip2[0]=0;
    ip2[1]=0;
    ip2[2]=-5;
    memcpy(ip2+3,"nf",2);
    ip2[4]=0;
    logita(NULL,ip2[2],ip2+3,ip2+4);
  }
  if(ierr!=0) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"nf",2);
    logita(NULL,ip[2],ip+3,ip+4);
  }
  nsem_put("onoff");

  goto loop;

}  /* end main */
