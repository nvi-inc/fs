#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_PNTS 1000
#define MAX_PAR 10

extern double fpoly();
extern double ftau();
int fit();

/* Allow main stubs to keep linker happy */
void MAIN__(){}
void MAIN_(){}

int
main(int argc, char **argv)
{
  FILE *fp,*fpw;
  char buff[100],type[11];
  int ierr,iread, ipoints;
  double gain[MAX_PNTS],elev[MAX_PNTS];

  int ntry, npar, i,ifit,npts;
  double par[MAX_PAR],epar[MAX_PAR],yavg,yrms,rchi,randx;

  int icount;
  double start, stop, step, xmax, ymax, best_ymax, dpfu, x, val, old_ymax;

  double a[MAX_PAR*(MAX_PAR+1)/2],b[MAX_PAR],scale[MAX_PAR],aux[MAX_PAR];
  int nfree,zero;
  float rcond, tol;

  float trec,tau,tatm;

  zero=0;
  if(argc < 3) {
    fprintf(stderr," not enough arguments\n");
    exit(-1);
  }
  
  ipoints=0;

  if( (fp= fopen(argv[1],"r"))==NULL ) {
    perror(argv[1]);
    exit(-1);
  }

  if( (fpw= fopen(argv[2],"w"))==NULL ) {
    perror(argv[2]);
    exit(-1);
  }

  ierr=find_next_noncomment(fp,buff,sizeof(buff));
  if(ierr!=0 && ierr!=-1)
    goto read_error;

  iread=sscanf(buff,"%d %10s %f %f %f ",&npar, &type, &trec, &tau, &tatm);

  if(iread<2) {
    fprintf(fpw,
   " steps -10, didn't get enough parameters in (non-comment) line 1\n");
    exit(-1);
  }

  if(npar <= 0 || npar > MAX_PAR) {
    fprintf(fpw," steps -16, wrong number of parameters for gnfit\n");
    exit(-1);
  }

  if(strcmp(type,"ALTAZ")!=0 && strcmp(type,"ELEV")!=0 && 
     strcmp(type,"tau")!=0) {
    fprintf(fpw," steps -17, unknown fit type in gnfit\n");
    exit(-1);
  }

  if(strcmp(type,"tau")==0 && iread != 5) {
    fprintf(fpw,"steps -18, wrong number of parameter for tau in gnfit\n");
    exit(-1);
  }
    
  ierr=find_next_noncomment(fp,buff,sizeof(buff));
  if(ierr!=0 && ierr!=-1)
    goto read_error;
  while(!feof(fp)) {

    if(++ipoints > MAX_PNTS) {
      fprintf(fpw,
         " steps -11, exceeded max. number of points %d in gnfit\n",MAX_PNTS);
      exit(-1);
    }
    iread=sscanf(buff,"%lf %lf",gain+ipoints-1,elev+ipoints-1);

    if(strcmp(type,"ALTAZ")== 0) {
      elev[ipoints-1]=90.0-elev[ipoints-1];
    }
    if(iread!=2) {
      fprintf(stderr,
	      "didn't get enough data fields on (non-comment) line %d",
	      ipoints+1);
      fprintf(fpw,
     " steps -12, didn't get enough data fields on (non-comment) line %d",
	      ipoints+1);
      exit(-1);
    }
    
    ierr=find_next_noncomment(fp,buff,sizeof(buff));
    if(ierr!=0 && ierr!=-1)
      goto read_error;
  }

#if 0
  printf(" at end of file\n");
  printf(" generate gain data\n");
  ipoints=20;

  for(i=0;i<ipoints;i++) {
    elev[i]=90.0*(((double) i)/((double) ipoints));
    gain[i]=1.0+elev[i]*-0.01+elev[i]*elev[i]*-0.002;
    randx=0.0*(.5-((double)rand())/RAND_MAX);
    gain[i]+=randx;
    printf(" i %d elev %lf gain %lf randx %lf \n",i,elev[i],gain[i],randx);
    fprintf(fpw," %lf %lf\n",gain[i],elev[i]);
  }
  npar=3;

#endif
#if 0
  printf(" at end of file\n");
  printf(" generate tau data\n");
  ipoints=20;
  trec=0.0.;
  tatm=273.0;
  tau=0.0;
  
  for(i=0;i<ipoints;i++) {
    elev[i]=1.0+2.0*(((double) i)/((double) ipoints));
    gain[i]=51.0+273.0*(1.0-exp(-0.1*elev[i]));
    randx=0.0*(.5-((double)rand())/RAND_MAX);
    gain[i]+=randx;
    printf(" i %d Air mass %lf Tsys %lf randx %lf \n",i,elev[i],gain[i],randx);
  }
  npar=2;
  strcpy(type,"tau");

#endif

  /*now fit data */

  npts=ipoints;
  tol=1e-4;
  ntry=20;
  for(i=0;i<10;i++) {
    par[i]=0;
    epar[i]=0.0;
  }
  if(npts <npar) {
    fprintf(fpw," steps -15\n");
    exit(-1);
  }

  if(strcmp(type,"tau")==0) {
    par[0]=trec;
    par[1]=tau;
    par[2]=tatm;
    npar=2;
    ifit=fit2_(elev, gain, ftau, &npts, par, epar, aux, scale, a, b,
	       &npar, &tol, &ntry, &rchi, &nfree, &ierr, &rcond);
  } else
    ifit=fit2_(elev, gain, fpoly, &npts, par, epar, aux, scale, a, b,
	       &npar, &tol, &ntry, &rchi, &nfree, &ierr, &rcond);

  if(!(ierr>0 && ierr <ntry)) {
    fprintf(fpw," steps -1, gnfit failed to converge\n");
    close(fpw);
    exit(-1);
  }

#if 0
  for(i=0;i<10;i++) {
    printf(" par %lf epar %lf\n",par[i],epar[i]);
  }
  printf(" rchi %f nfree %d steps %d\n",rchi,nfree, ierr);
  exit(0);
#endif

  if(strcmp(type,"tau") != 0) {
    /* find maximum */

    best_ymax=-2.0;
    ymax=-2.0;
    start=0.0;
    stop=90.0;
    icount=0;
    
    while(++icount<4
	  || best_ymax<=1e-16 || fabs(best_ymax-old_ymax)/best_ymax >0.0001) {
      step=(stop-start)/99;
      xmax=-1.0;
      ymax=-1.0;
      for(i=0;i<100;i++) {
	x=start+i*step;
	val=fpoly(&zero,&x,par,&npar);
	if(val >ymax) {
	  xmax=x;
	  ymax=val;
	}
      }
      if(ymax <1e-16) {
	fprintf(fpw,
       " steps -13, polynomial does not have positive gain in gnfit\n");
	exit(-1);
      }
      
      start=xmax-step*1.05;
      stop=xmax+step*1.05;
      if(start<0.0)
	start=0.0+step*0.01;
      if(stop>90.0)
	stop=90.0-step*0.01;
      old_ymax=best_ymax;
      if(ymax>=best_ymax) {
	best_ymax=ymax;
      }
    }

    if(best_ymax <= 1e-16) {
      fprintf(fpw," steps -14, best found gain not positive in gnfit\n");
      exit(-1);
    }

    dpfu=best_ymax;

    fprintf(fpw," steps %d rchi %.6lf dpfu %lf coeff",ierr, rchi,dpfu);
    for(i=0;i<npar;i++)
      fprintf(fpw," %.8lg",par[i]/dpfu);
    fprintf(fpw,"\n");
    close(fpw);
    exit(0);
  } else {
    fprintf(fpw,
	    "steps %d rchi %.6lf trec %lf tau %f trec-sigma %lf",
	    ierr, rchi,par[0],par[1],epar[0]);
      fprintf(fpw,"\n");
    close(fpw);
    exit(0);
  }
   

  fprintf(fpw," steps -25, can't get here\n");
  exit(-1);

 read_error:
  switch(ierr) {
  case 0: /* all right now */
    break;
  case -1: /* ended in comment, is okay */
    break;
  case -2: /* error ungetting */
    perror("problem ungetting input file character");
    fprintf(fpw," steps -20, problem ungetting input file character");
    exit(-1);
    break;
  case -3: /* error  reading */
    perror("reading input file");
    fprintf(fpw," steps -21, problem reading input file\n");
    exit(-1);
    break;
  case -4:
    fprintf(fpw," steps -22, input file line too long\n");
    exit(-1);
    break;
  default:
    fprintf(fpw,
	    " steps -23, unknown error %d from find_next_noncomment()\n",ierr);
    exit(-1);
    break;
  }

  fprintf(fpw," steps -24, can't get here\n");
  exit(-1);
}

