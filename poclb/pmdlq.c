/* pmdlq
 
   Format and log buffers with pointing model
*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "../include/dpi.h"
#include "../include/pmodel.h"

#define  NLINE 5

void logit();
void flt2str();
void int2str();

void pmdlq(pmodel)
struct pmdl *pmodel;

{
  char buf[80];
  int i,j;

/* PM 1 nnnnn yyyy ddd hh mm ss
   PM 2 xxxx.xxxx n n n n n n n n n n n n n n n n n n n n
   PM 3 xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx
   PM 4 xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx
   PM 5 xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx
   PM 6 xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx xx.xxxxxxx
*/

  buf[0]='\0';
  strcat(buf,"PM 1 ");
  int2str(buf,pmodel->imdl,-5,1);
  strcat(buf," ");
  /* not Y10K compliant */
  int2str(buf,pmodel->t[5],4,0);         /* year    */
  strcat(buf," ");
  int2str(buf,pmodel->t[4],-3,1);        /* day     */
  strcat(buf," ");
  int2str(buf,pmodel->t[3],-2,1);        /* hours   */
  strcat(buf," ");
  int2str(buf,pmodel->t[2],-2,1);        /* minutes */
  strcat(buf," ");
  int2str(buf,pmodel->t[1],-2,1);        /* seconds */
  strcat(buf," ");
  int2str(buf,pmodel->t[0],-2,1);        /* centisec */
  logit(buf,0,'\0');

  buf[0]='\0';
  strcat(buf,"PM 2 ");
  flt2str(buf,(float)(pmodel->phi*RAD2DEG),-9,4);
  strcat(buf," ");
  for (i=0; i<MAX_MODEL_PARAM; i++) {
    int2str(buf,pmodel->ipar[i],1,0);
    strcat(buf," ");
  }
  logit(buf,0,'\0');

  for (i=0; i<MAX_MODEL_PARAM; i+=NLINE) {
    buf[0]='\0';
    strcat(buf,"PM ");
    int2str(buf,2+(i+NLINE-1)/NLINE,1,0);
    strcat(buf," ");
    for (j=0; j<NLINE; j++) {
      if (i+j>MAX_MODEL_PARAM)
        break;
      flt2str(buf,(float)(pmodel->pcof[i+j]*RAD2DEG),-10,7);
      strcat(buf," ");
    }
  logit(buf,0,'\0');
  } 
}
