/*  This subroutine finds the correct, if only, help file to list */
/*  with the help command. It uses the rack and drive variables   */
/*  passed in by the calling program to match with the extensions */
/*  of the help filenames to find the correct file for listing.   */
/*  The first extension character matches the rack and the second */
/*  the drive. An underscore for an extension character is for    */
/*  any type of equipment. An m is for Mark III, and a v is for   */
/*  VLBA.                                                         */

#include <stdio.h>
#include <string.h>
#define MK3  0x01
#define MK4  0x04
#define VLBA 0x02
#define MAX_STRING  256

void helpstr_(cnam,clength,runstr,rack,drive,ierr,clen,rlen)
char *cnam;
int *clength;
char *runstr;
int *rack;
int *drive;
int *ierr;
int clen;
int rlen;
{
  char string[MAX_STRING+1],*s1;
  char *decloc;
  int inum;
  FILE *idum;
  int freq,system();
  int i;
  char outbuf[80];

  *ierr=0;
  if (*clength > MAX_STRING) {
    *ierr=-2;
    return;
  }

  s1=strcpy(string,cnam,*clength);
  string[*clength]='\0';

  decloc = strchr(string,'.');
  if (decloc != NULL) {    /* an extension accompanied the help <name> */
    strcpy(runstr,string);
    return;
  }
  else {               /* check for number of help files with same name */
    strcpy(outbuf,"ls /usr2/fs/help/");
    strcat(outbuf,string);
    strcat(outbuf,".* | wc -l > LS.NUM");
    freq = system(outbuf);
    idum=fopen("LS.NUM","r");
    *ierr=fscanf(idum,"%d",&inum);
    fclose(idum);
    unlink("LS.NUM");
    if (inum==1) {                /* if only one, has '__' as extension */
      strcpy(runstr,string);
      strcat(runstr,".__");
      return;
    }
    else if (inum > 1) {          /* if more than one, find appropriate */
      strcpy(outbuf,"ls /usr2/fs/help/");
      strcat(outbuf,string);
      strcat(outbuf,".* > LS.NUM");
      freq = system(outbuf);

      idum=fopen("LS.NUM","r");
      for (i=0;i<inum;i++) {
        *ierr=fscanf(idum,"%s",outbuf);
        decloc = strchr(outbuf,'.');
        if (((*(decloc+1)=='4') && (MK4==*rack))  ||
           ((*(decloc+2)=='4') && (MK4==*drive))) {
          strcpy(runstr,string);
          strcat(runstr,decloc);
          break;
        }
        else if (((*(decloc+1)=='m') && (MK3==*rack))  ||
           ((*(decloc+1)=='v') && (VLBA==*rack))  ||
           ((*(decloc+2)=='m') && (MK3==*drive))  ||
           ((*(decloc+2)=='v') && (VLBA==*drive))) { 
          strcpy(runstr,string);
          strcat(runstr,decloc);
          break;
        }
      }
      fclose(idum);
      unlink("LS.NUM");
    }
    else
      strcpy(runstr,string);
  }
}
