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
#include "../include/params.h"

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
  char equip1, equip2, ch1, ch2;

  *ierr=0;
  if (*clength > MAX_STRING) {
    *ierr=-2;
    return;
  }

  s1=strncpy(string,cnam,*clength);
  string[*clength]='\0';

  decloc = strchr(string,'.');
  if(decloc==NULL)
    strcat(string,".*");

  strcpy(outbuf,"ls ");
  strcat(outbuf,FS_ROOT);
  strcat(outbuf,"/st/help/");
  strcat(outbuf,string);

  strcat(outbuf," > /tmp/LS.NUM 2> /dev/null");
  freq = system(outbuf);

  strcpy(outbuf,"ls ");
  strcat(outbuf,FS_ROOT);
  strcat(outbuf,"/fs/help/");
  strcat(outbuf,string);

  strcat(outbuf," >> /tmp/LS.NUM 2> /dev/null");
  freq = system(outbuf);

  idum=fopen("/tmp/LS.NUM","r");

  if(decloc != NULL)
    equip1=*(decloc+1);
  else if(MK3==*rack)
    equip1='m';
  else if(MK4==*rack)
    equip1='4';
  else if(VLBA==*rack)
    equip1='v';

  if(decloc != NULL)
    equip2=*(decloc+2);
  else if(MK3==*drive)
    equip2='m';
  else if(MK4==*drive)
    equip2='4';
  else if(VLBA==*drive)
    equip2='v';

  *ierr = -3;
  while(-1!=fscanf(idum,"%s",outbuf)){
    decloc = strchr(outbuf,'.');
    if(decloc != NULL) {
      ch1=*(decloc+1);
      ch2=*(decloc+2);
 
      if ((ch1==equip1 || ch1=='_' || (ch1 =='m' && equip1 == '4')) &&
          (ch2==equip2 || ch2=='_' || (ch2 =='m' && equip2 == '4'))   ) {
        strcpy(runstr,outbuf);
        *ierr = 0;
        break;
      }
    }
  }
  fclose(idum);
  unlink("/tmp/LS.NUM");
}
