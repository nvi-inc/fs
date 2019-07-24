/* gmodl

   Open the model parameter file and read it. Store the contents
   in the pmodel structure in ST common.
   Copied from FORTRAN.
  
*/

#include <stdio.h>
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
/*
  fprintf(stderr,"pmodel pointer=%8x\n",pmodel);
    fprintf(stderr,"Trying to open %s\n",model_file);
*/
  mdlfile = fopen(model_file,"r");
  if (mdlfile == (FILE *)NULL) {
    msg[0]=NULL;
    strcat(msg,"Open failed for ");
    strcat(msg,model_file);
    perror(msg);
    return (-1);
  }

  iline=0;
  irec=0;
  while ((c=getc(mdlfile)) != EOF && iline < NPLINES) {
    if (c == '*') {                       /* a comment line        */
      msg[0]=c; msg[1]=NULL;
      n=1;
      while ((c=getc(mdlfile)) != '\n') {
/*
        msg[n]=c; n++;
*/
      }
/*
        nc++; msg[n]=NULL;
        fprintf(stderr,"Comment line # %3d:\n%s\n",nc,msg);
*/
    }
    else {                                 /* process this line     */
      ungetc(c,mdlfile); /* put back the character we just got */
      irec++;

      if (irec == 1) {                    /* MODEL # AND DATE */
        n = 0;
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
        n = 0;
        if (fscanf(mdlfile,"%f",&f) != 1)
          goto Ferror;
        n++;
        pmodel->phi = f*DEG2RAD;
/*
        fprintf(stderr,"phi=%f\n",f*RAD2DEG);
*/
        for (i=0; i<MAX_MODEL_PARAM; i++) {
          if (fscanf(mdlfile,"%d",pmodel->ipar+i) != 1)
            goto Ferror;
          n++;
        }
      }

      else {               /* Parameter value records (NLINE values per line) */
        iline++;
        i=(iline-1)*NLINE;
        n=0;
        for (j=0; j<NLINE; j++) {
          if (fscanf(mdlfile,"%f",&f) != 1) 
            goto Ferror;
          n++;
          pmodel->pcof[i+j] = f*DEG2RAD;
/*
          fprintf(stderr,"f=%f",f); 
          fprintf(stderr,"pcof[%2d]=%f\n",i+j,pmodel->pcof[i+j]); 
*/
        }
      }
      while ((c=fgetc(mdlfile)) != '\n')
        ; /* read the rest of the line */
    }  /* end of processing this line  */
  } /* end of while reading file to the end */

  if (iline != NPLINES) {
    fprintf(stderr,"Premature end of file before all parameters were found.\n");
    return (-1);
  }
  else
    return (0);

Ferror: 
  fprintf(stderr,"Only the first %2d fields in record %1d were valid.\n",n,irec);
  return (-1);
}
