
#include <stdio.h>

main (argc,argv)
int argc;
char *argv[];
{
  char *cfile,*cstn,*command;
  char *r1,*r2,*r3,*r4;
  int len1,len2,len3,len4;
  int clen1,clen2,clen3;

  if (argc > 1)
    cfile = argv[1];
  else
    cfile = NULL;
  if (argc > 2)
    cstn = argv[2];
  else
    cstn = NULL;
  if (argc > 3)
    command = argv[3];
  else
    command = NULL;
  if (argc > 4)
    r1 = argv[4];
  else
    r1 = NULL;
  len1 = strlen(r1);
  if (argc > 5)
    r2 = argv[5];
  else
    r2 = NULL;
  len2 = strlen(r2);
  if (argc > 6)
    r3 = argv[6];
  else
    r3 = NULL;
  len3 = strlen(r3);
  if (argc > 7)
    r4 = argv[7];
  else
    r4 = NULL;
  len4 = strlen(r4);
  clen1 = strlen(cfile);
  clen2 = strlen(cstn);
  clen3 = strlen(command);
  fdrudg(cfile,cstn,command,r1,r2,r3,r4,
  clen1,clen2,clen3,len1,len2,len3,len4);
}
