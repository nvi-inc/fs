/* ib or k4ib utilities */

#define MAX_BUF 512

ib_req1(ip,device)
long int ip[5];
char device[2];
/* read ASCII */
{
  short int buffer[2];

  buffer[0]=1;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req2(ip,device,ptr)
long int ip[5];
char device[2];
char ptr[];
/* write ASCII */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=2;
  memcpy(buffer+1,device,2);
  nch=strlen(ptr);
  nch=nch>MAX_BUF-2? MAX_BUF-2:nch;
  memcpy(buffer+2,ptr,nch);

  cls_snd(ip+0,buffer,4+nch);
  ip[1]++;
}

ib_req3(ip,device)
long int ip[5];
char device[2];
/* read binary */
{
  short int buffer[2];

  buffer[0]=3;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req4(ip,device,ptr,n)
long int ip[5];
char device[2];
char ptr[];
int n;
/* write binary */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=4;
  memcpy(buffer+1,device,2);
  memcpy(buffer+2,ptr,n);

  cls_snd(ip+0,buffer,4+n);
  ip[1]++;
}

ib_req5(ip,device,ilen)
long int ip[5];
char device[2];
int ilen;
/* read ASCII with a max length */
{
  short int buffer[3];

  buffer[0]=5;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;

  cls_snd(ip+0,buffer,6);
  ip[1]++;
}

ib_req6(ip,device,ilen)
long int ip[5];
char device[2];
int ilen;
/* read BINARY with a max length */
{
  short int buffer[3];

  buffer[0]=6;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;

  cls_snd(ip+0,buffer,6);
  ip[1]++;
}

ib_req7(ip,device,ilen,ptr)
long int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read ASCII with a max length */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=7;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}

ib_req8(ip,device,ilen,ptr)
long int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read BINARY with a max length */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=8;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}

ib_req9(ip,device)
long int ip[5];
char device[2];
/* bus status */
{
  short int buffer[2];

  buffer[0]=9;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}
ib_req10(ip,device)
long int ip[5];
char device[2];
/* poll for SRQ */
{
  short int buffer[2];

  buffer[0]=10;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req11(ip,device,ilen,ptr)
long int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read ASCII with a max length and get time*/
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=11;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}
ib_req12(ip,device)
long int ip[5];
char device[2];
/* device clear */
{
  short int buffer[2];

  buffer[0]=12;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}


ib_res_ascii(out,max,ip)
char *out;
int *max;
long ip[5];
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    *max=*max-1;
    *max=*max>nch-2? nch-2: *max;
    memcpy(out,buffer+1,*max);
    out[*max]=0;
    *max=nch-2;
    ip[1]--;
  }
}
ib_res_bin(out,max,ip)
char *out;
long ip[5];
int *max;
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    *max=*max>nch-2? nch-2: *max;
    memcpy(out,buffer+1,*max);
    *max=nch-2;
    ip[1]--;
  }
}
ib_res_time(centisec,ip)
long centisec[2];
long ip[5];
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    memcpy(centisec,buffer,2*sizeof(long));
    ip[1]--;
  }
}





