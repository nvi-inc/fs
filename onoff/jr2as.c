#include <stdlib.h>
#include <string.h>

void jr2as(re,lbuf,it,id,isbuf)
     float re;
     char lbuf[];
     int it,id,isbuf;
{
  int ita, icn;

  icn=strlen(lbuf);
  flt2str(lbuf,re,it,id);
  if(lbuf[icn]!='$')
    return;
  ita=abs(it)+abs(id)+1;
  ita=ita<isbuf-(icn+1)?ita:isbuf-(icn+1);
  lbuf[icn]=0;
  flt2str(lbuf,re,ita,id);
  lbuf[icn+abs(it)]=0;
}     
