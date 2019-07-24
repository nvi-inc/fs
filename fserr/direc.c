#define NULLPTR (char *) '\0'
#define LOCLIM 1230

int direc(iopt, entry, ierr, tdcb)

  int iopt;
  int *ierr, tdcb;
  struct
  {
    char buf[8];
    long off;
  } *entry;

{
  long irec, loc;

/* IOPT
    9999 - close index file
    1    - set to record 1 and read first record
    2    - set to record 1, write, and post
    3    - call Find for hash for making index file
    4    - call find for hash for extracting from index file
*/
  if(iopt==1){
    irec=0;
    *ierr = lseek(tdcb, 0L, 0);
    for(loc=0;loc<LOCLIM;++loc) {
      read(tdcb, entry, 12);
      if((*entry).buf[0]!='0')
         ++irec; }
    (*entry).off = irec;
  }
  if(iopt==2){
    *ierr=lseek(tdcb, 0L, 0);
    *ierr=write(tdcb, entry, 12);
  }
  if(iopt==3){
    if((*ierr=find(tdcb, entry, &loc))<0)
      goto Done;
    if((*ierr=lseek(tdcb, loc, 0))<0) 
      goto Done;
    *ierr=write(tdcb, entry, 12);
  }
  if(iopt==4){

    if((*ierr=find(tdcb, entry, &loc))<=0){
      (*entry).buf[0]= '\0';
      goto Done;}
    if(((*entry).buf[0]=='0')||(loc<=0))
      (*entry).buf[0]= '\0';
    else {
      *ierr=lseek(tdcb, loc, 0);
      *ierr=read(tdcb, entry, 12);
    }
  }
  if(iopt==9999){
    close(tdcb);
  }

Done:
  return *ierr;
}
