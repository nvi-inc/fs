#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
  int ierr;
  char buf[512];

  setup_ids();

  putpname("lgerr");

  if (nsem_test("fs   ") != 1) {
    printf("fs isn't running\n");
    exit(-1);
  }
  if (argc <= 1) {
    sprintf(buf,"lgerr: no information provided");
    logite(buf,-1,"lg");
    exit(-1);
  }

  if(argc>=3)
    if(1!=sscanf(argv[2],"%d",&ierr)) {
      sprintf(buf,"lgerr: error decoding '%s'",argv[2]);
      logite(buf,-1,"lg");
      exit(-1);
    }

  if(argc==2)
    logit(argv[1],0,NULL);
  else if(argc==3)
    logit(NULL,ierr,argv[1]);
  else if(argc==4)
    logite(argv[3],ierr,argv[1]);

  exit(0);
    
}


