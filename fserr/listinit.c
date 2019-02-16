#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "fserr.h"

/*                                                                 */
/*  LISTINIT subroutine will read the file of the descriptor       */
/*  passed in and place the contents into the array for use by     */
/*  FSERR. Essentially, this is the initialization subroutine      */
/*  of the array for FSERR.                                        */
/*                                                                 */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Created.                                          */
/*                                                                 */

struct errorlst{
  char mnemonic[2];
  int ierr;
  char message[120];
};

void listinit(tdcb,list)
FILE *tdcb;
struct errorlst list[MAXERRORS];
{

  int hashcount;
  int hash;
  int inum;
  char dquote[2];
  int errnum;
  char buffer[MAXSTR];
  int err;

  struct {
    char buf[2];
    int off;
  } entryfs;

  while (fgets(buffer,MAXSTR,tdcb)!=NULL) {
    inum = sscanf(buffer,"%s",dquote);

    if (fgets(buffer,MAXSTR,tdcb)==NULL) {
      printf("ERROR reading control file\n");
      exit(-1);
    }

    inum = sscanf(buffer,"%s%d",entryfs.buf,&entryfs.off);

    if (fgets(buffer,MAXSTR,tdcb)==NULL) {
      printf("ERROR reading control file\n");
      exit(-1);
    }

    hashcode(&entryfs,&hash);

    hashcount = 0;
    while (list[hash].ierr!=0) {
      hash+=1;
      if (hash==MAXERRORS) 
        hash=0;
      hashcount+=1;
      if (hashcount==MAXERRORS) {
        printf("index table overflow!!!! oooooh, you've really done it now!\n");
        exit(-1);
      }
    }
    memcpy(list[hash].mnemonic,entryfs.buf,2);
    list[hash].ierr=entryfs.off;
    memcpy(list[hash].message,buffer,120);
  }
}
