#include <stdlib.h>
#include <stdio.h>
#include <string.h>

echo_out(rw,bin,dev,buffer,buflen)
int rw, bin, dev, buflen;
unsigned char buffer[];
{
  char echo[512-sizeof("98001000000#ibcon#")];
  int inext,iout;

/*  printf("echo_out: rw %c bin %d dev %d buflen %d\n",rw,bin,dev,buflen);
*/

  if(rw == 'r')
    sprintf(echo,"<%d=",dev);
  else if(rw == 'w')
    sprintf(echo,"[%d=",dev);
  else if(rw == 'c')
    sprintf(echo,"{%d=",dev);

  if(bin==0) {
    for(inext=strlen(echo),iout=0;inext<sizeof(echo)-8 && iout <buflen;iout++) {
      if(buffer[iout] == '\\') {
	echo[inext++]='\\';
	echo[inext++]='\\';
      } else if(buffer[iout] == '\r') {
	echo[inext++]='\\';
	echo[inext++]='r';
      } else if(buffer[iout] == '\n') {
	echo[inext++]='\\';
	echo[inext++]='n';
      } else if(!isprint(buffer[iout])) {
	sprintf(echo+inext,"\\x%2.2x",buffer[iout]);
	inext+=4;
      } else
	echo[inext++]=buffer[iout];
    }
  } else {
    for(inext=strlen(echo),iout=0;inext<sizeof(echo)-5 && iout <buflen;
	iout++) {
      sprintf(echo+inext,"%2.2x,",buffer[iout]);
      inext+=3;
    }
    inext--;
  }

  if(iout>=buflen) 
    if(rw == 'r')
      echo[inext++]='>';
    else if(rw == 'w')
      echo[inext++]=']';
    else if(rw == 'c')
      echo[inext++]='}';
  else
    echo[inext++]='\\';
  
  echo[inext++]=0;
  logit(echo,0,NULL);
}



