#include <memory.h>
#include <stdio.h>

#define LOCLIM 1230

int find(tdcb, entry, loc)

  int tdcb;
  long *loc;
  struct{
    char buf[8];
    long off;
  } *entry;

{
  int i;
  long ierr;
  long locold;
  struct{
    char cbuf[8];
    long off;
  } entry2;

/* hash section */
  *loc=0;
  for(i=0;i<8;++i){
    *loc+=((*entry).buf[i])<<(4*i);
  }
  *loc&=~(~0 << 31);
  *loc = *loc %LOCLIM;
  *loc = (*loc)*(sizeof((*entry)));
  locold = *loc;
  ierr=lseek(tdcb, *loc, 0);
/*  while((ierr=read(tdcb, &entry2, sizeof(entry2)))>=0){ */
  while((ierr=read(tdcb, &entry2, sizeof(entry2)))>0){
    if(entry2.cbuf[0]=='0'){
      ierr=0;
      goto Done;}
    if(memcmp(entry2.cbuf, (*entry).buf, strlen((*entry).buf))==0) goto Done;

    *loc+=12;
    if(*loc>((LOCLIM*12)-12)) *loc = *loc - (LOCLIM*12);
    if(*loc==locold){
      printf("index table overflow!!!!  oooooh, you've really done it now!\n");
      ierr=-2;
      goto Done;
      /* stop */
    }
    ierr=lseek(tdcb, *loc, 0);
  }

Done:
/*  memcpy((*entry).buf, entry2.cbuf, 8); */
  return (int) ierr;
}
