#include <stdio.h>
#include <memory.h>
#define NULLPTR (char *) 0

void wandwr_(port, buffer, buflen, error)

  int *buffer;
  int *port;
  int *buflen;
  int *error;

{
/*  printf("\nbuflen = %d\n",*buflen); printf("buffer = %x\n",buffer);*/ 

  *error = write(*port, buffer, *buflen); 
  if (*error < 0 ){
    printf(" error writing to port \n");
    perror("");
  } else if (*error != *buflen) {
    printf(" wrong number characters written to port\n");
    *error=-1;
  } else {
    *error=0;
  }
  return;
}
