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

void helpstr_(cnam,clength,runstr,rack,drive1,drive2,ierr,clen,rlen)
char *cnam;
int *clength;
char *runstr;
int *rack;
int *drive1;
int *drive2;
int *ierr;
int clen;
int rlen;
{
  char string[MAX_STRING+1],*s1;
  char *decloc, *declocstr;
  int inum;
  FILE *idum;
  int freq,system();
  int i;
  char outbuf[80];
  char equip1, equip2, ch1, ch2, ch3;

  *ierr=0;
  if (*clength > MAX_STRING) {
    *ierr=-2;
    return;
  }

  s1=strncpy(string,cnam,*clength);
  string[*clength]='\0';

  declocstr = strchr(string,'.');
  if(declocstr==NULL)
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
  unlink("/tmp/LS.NUM");
  *ierr = -3;
  while(-1!=fscanf(idum,"%s",outbuf)){
    decloc = strrchr(outbuf,'.');
    if(declocstr !=NULL) {
      strcpy(runstr,outbuf);
      *ierr = 0;
      break;
    } else if(decloc != NULL) {
      ch1=*(decloc+1);
      ch2=*(decloc+2);
      ch3=*(decloc+3);
      if((ch1== '_' ||
	  (ch1 == '3' &&  K4K3  == *rack) ||
	  (ch1 == 'm' &&  MK3   == *rack) ||
	  (ch1 == 'n' && (MK3   == *rack || MK4   == *rack)) ||
	  (ch1 == 'e' && (MK3   == *rack || MK4   == *rack ||
			  VLBA  == *rack || VLBA4 == *rack )) ||
	  (ch1 == 'f' && (MK3   == *rack || MK4   == *rack ||
			  K4K3  == *rack || K4MK4 == *rack ||
			  K4    == *rack)) ||
	  (ch1 == '4' &&  MK4   == *rack) ||
	  (ch1 == 'g' && (MK4   == *rack || VLBA  == *rack ||
			  VLBA4 == *rack || K4MK4 == *rack)) ||
	  (ch1 == 'h' && (MK4   == *rack || VLBA4 == *rack ||
			  K4MK4 == *rack)) ||
	  (ch1 == 'v' && (VLBA  == *rack)) ||
	  (ch1 == 'w' && (VLBA  == *rack || VLBA4 == *rack)) ||
	  (ch1 == 'k' && (K4K3  == *rack || K4MK4 == *rack ||
			  K4    == *rack)) ||
	  (ch1 == 'a' &&  0     != *rack)) &&
	 (ch2 == '_' || ch2 == '+' ||
	  (ch2 == 'k' &&  K4    == *drive1) ||
	  (ch2 == 'm' &&  MK3   == *drive1) ||
	  (ch2 == 'n' && (MK3   == *drive1 || MK4 == *drive1)) ||
	  (ch2 == '4' &&  MK4   == *drive1) ||
	  (ch2 == 's' &&  S2    == *drive1) ||
	  (ch2 == 'w' && (VLBA  == *drive1 || VLBA4 == *drive1)) ||
	  (ch2 == 'a' &&  0     != *drive1) ||
	  (ch2 == 'l' && (MK3   == *drive1 || MK4   == *drive1 ||
			  VLBA  == *drive1 || VLBA4 == *drive1 ))) &&
	 (ch3 == '_' || ch3 == '+' ||
	  (ch3 == 'k' &&  K4    == *drive2) ||
	  (ch3 == 'm' &&  MK3   == *drive2) ||
	  (ch3 == 'n' && (MK3   == *drive2 || MK4 == *drive2)) ||
	  (ch3 == '4' &&  MK4   == *drive2) ||
	  (ch3 == 's' &&  S2    == *drive2) ||
	  (ch3 == 'w' && (VLBA  == *drive2 || VLBA4 == *drive2)) ||
	  (ch3 == 'a' &&  0     != *drive2) ||
	  (ch3 == 'l' && (MK3   == *drive2 || MK4   == *drive2 ||
			  VLBA  == *drive2 || VLBA4 == *drive2 )))
	 &&
	 ((*drive1 !=0 && *drive2 !=0 && ((ch2 == '+' || ch3 == '+') ||
					  (ch2 =='_' && ch3 == '_'))) ||
	  ((*drive1 ==0 || *drive2 == 0) && (ch2 != '+' && ch3 != '+')))
	 ) {
        strcpy(runstr,outbuf);
        *ierr = 0;
        break;
      }
    }
  }
  fclose(idum);
}
