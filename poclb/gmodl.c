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
/* gmodl

   Open the model parameter file and read it. Store the contents
   in the pmodel structure in ST common.
   Copied from FORTRAN.
  
*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include "../include/dpi.h"
#include "../include/pmodel.h"

#define NLINE   5
#define NPLINES MAX_MODEL_PARAM/NLINE

int gmodl(model_file,pmodel)
char *model_file;
struct pmdl *pmodel;

{
  FILE *mdlfile;
  char inbuf[80],msg[40];
  int iline;         /* counts model parameter lines  */
  int irec;          /* switch for the type of record */
  int n,i,j;
  float f;
  char c;
  int nc;
  int mpar,ipar;
  /*
  fprintf(stderr,"pmodel pointer=%8x\n",pmodel);
    fprintf(stderr,"Trying to open %s\n",model_file);
  */
  mdlfile = fopen(model_file,"r");
  if (mdlfile == (FILE *)NULL) {
    msg[0]=0;
    strcat(msg,"Open failed for ");
    strcat(msg,model_file);
    perror(msg);
    return (-1);
  }

  iline=0;
  irec=1;
  mpar=0;
  ipar=-1;
  while ((c=getc(mdlfile)) != EOF && iline < NPLINES+1) {
    n = 1;
    if (c != '*') {                       /* a comment line        */
      ungetc(c,mdlfile); /* put back the character we just got */
      if (irec == 1) {                    /* MODEL # AND DATE */
        if (fscanf(mdlfile,"%d",&pmodel->imdl) != 1)
          goto Ferror;
	/*
        fprintf(stderr,"pmodel.imdl=%5d\n",pmodel->imdl); 
	*/
        n++;
        for (i=5; i>0; i--) {
          if (fscanf(mdlfile,"%d",pmodel->t+i) != 1)
            goto Ferror;
          n++;
	  /*
          fprintf(stderr,"t[%d]=%5d\n",i,pmodel->t[i]); 
	  */
        }
        pmodel->t[0]=0;
      }
      else if (irec == 2) {              /* Parameter Control Record */
	mpar=0;
        if (fscanf(mdlfile,"%f",&f) != 1)
          goto Ferror;
        n++;
        pmodel->phi = f*DEG2RAD;
	/*
	fprintf(stderr,"phi=%f\n",f);
	*/
        for (i=0; i<MAX_MODEL_PARAM+1; i++) {
	  ;
	  while((c=fgetc(mdlfile)) !=EOF && (c == ' ' || c == '\t')) ;
	  if(c==EOF)
	    goto Ferror;
	  if(c == '\n') {
	    mpar=i;
	    for(j=mpar;j<MAX_MODEL_PARAM;j++)    pmodel->ipar[j]=0;
	    break;
	  }
	  ungetc(c,mdlfile);
	  if(i >= MAX_MODEL_PARAM) {
	    fprintf(stderr,"Extra parameter fields in record %d\n",irec);
	    return (-1);
	  }
          if (fscanf(mdlfile,"%d",pmodel->ipar+i) != 1)
            goto Ferror;
          n++;
        }
      } else {         /* Parameter value records (NLINE values per line) */
        iline++;
        i=(iline-1)*NLINE;
        for (j=0; j<NLINE; j++) {
          if (fscanf(mdlfile,"%f",&f) != 1) 
            goto Ferror;
          n++;
	  ipar++;
	  if(ipar>=mpar) {
	    fprintf(stderr, "too many pointing parameter values \n");
	    return (-1);
	  }
          pmodel->pcof[ipar] = f*DEG2RAD;
/*
          fprintf(stderr,"f=%f",f); 
          fprintf(stderr,"pcof[%2d]=%f\n",ipar,pmodel->pcof[ipar]); 
*/
        }
      }
      irec++;
    }  /* end of processing this line  */
    while ((c=fgetc(mdlfile)) != '\n') {
      if(c == EOF) /* read the rest of the line */
	goto Ferror;
    }
  } /* end of while reading file to the end */

Ferror: 
  if(feof(mdlfile)) {
    if (irec>=3 && ipar+1 == mpar) {
      for(j=mpar;j<MAX_MODEL_PARAM;j++)
	pmodel->pcof[j]=0.0;
      return (0);
    } else {
      fprintf(stderr,"Premature end of file.\n");
    }
  }
  fprintf(stderr,"Failed to decode field %2d in record %1d.\n",n,irec);
  return (-1);
}
