#include <stdio.h>
#include <string.h>
#define MAX_STRING  256

void nohelp_(infile,ierr,inum,len)
char *infile;
int *ierr;
int *inum;
int len;
{
  char string[MAX_STRING+1],*s1;
  FILE *idum;
  int freq,system();
  char outbuf[80];

  *ierr=0;
  if (len > MAX_STRING) {
    *ierr=-2;
    return;
  }

  s1=strcpy(string,infile,len);
  string[len]='\0';

  strcpy(outbuf[0],"ls /usr2/fs/help/");
  strcat(outbuf,string);
  strcat(outbuf,".* | wc -l > LS.NUM");

  freq = system(outbuf);

  idum=fopen("LS.NUM","r");
  *ierr=fscanf(idum,"%d",inum);
  fclose(idum);
  unlink("LS.NUM");

}
