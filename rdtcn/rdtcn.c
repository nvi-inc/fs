/* Receiver/client multicast Datagram example. */
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <errno.h>
#include <math.h>

#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define TO_CENTISECONDS  420

extern struct fscom *shm_addr;

double rdbe_freqz(double);

struct mcast {
   char read_time[20];
   unsigned short pkt_size;
   unsigned short epoch_ref;
   unsigned long epoch_sec;
   unsigned int interval;
   char tsys_header[20];
   unsigned long tsys_on[64];
   unsigned long tsys_off[64];
   char pcal_header[20];
   unsigned short pcal_ifx;
   unsigned short pcal_ifx_pad;
   int pcal_sin[1024];
   int pcal_cos[1024];
   char stat_str[3000];
   char raw_header[24]; // extra bytes for old python
   unsigned short raw_ifx;
   unsigned short raw_ifx_pad;
   double mu;
   double sigma;
   double pps_offset;
   double gps_offset;
   unsigned short raw_size;
   unsigned char raw_samples[4096];
   unsigned char raw_samples_pad[6];
  };
 
static unsigned short xbe16toh(unsigned short big_endian)
{
   static union {
//     uint32_t i;
     unsigned int i;
     char c[4];
   } bint = {0x01020304};

  static union {
    unsigned short us;
    char c[2];
  } result, temp;

  if(bint.c[0]!=1) {
    temp.us=big_endian;
    result.c[0]=temp.c[1];
    result.c[1]=temp.c[0];
    return result.us;
  } else
    return big_endian;
}
static unsigned long xbe32toh(unsigned long big_endian)
{
   static union {
//     uint32_t i;
     unsigned int i;
     char c[4];
   } bint = {0x01020304};

  static union {
    unsigned long ul;
    char c[4];
  } result, temp;

  if(bint.c[0]!=1) {
    temp.ul=big_endian;
    result.c[0]=temp.c[3];
    result.c[1]=temp.c[2];
    result.c[2]=temp.c[1];
    result.c[3]=temp.c[0];
    return result.ul;
  } else
    return big_endian;
}
static unsigned long long xbe64toh(unsigned long long big_endian)
{
   static union {
//     uint32_t i;
     unsigned int i;
     char c[4];
   } bint = {0x01020304};

  static union {
    unsigned long long ull;
    char c[8];
  } result, temp;

  if(bint.c[0]!=1) {
    temp.ull=big_endian;
    result.c[0]=temp.c[7];
    result.c[1]=temp.c[6];
    result.c[2]=temp.c[5];
    result.c[3]=temp.c[4];
    result.c[4]=temp.c[3];
    result.c[5]=temp.c[2];
    result.c[6]=temp.c[1];
    result.c[7]=temp.c[0];
    return result.ull;
  } else
    return big_endian;
}
struct sockaddr_in localSock;
struct ip_mreq group;
int sd;
int datalen;
char databuf[sizeof(struct mcast)];

static char who[ ]="cn";
static char what[ ]="ad";
static char me[]="rdtcn" ; /* My name */ 
static char letter;
static  int irdbe;
 
int main(int argc, char *argv[])
{

  struct rdbe_tsys_cycle local;
  unsigned long tpi[MAX_RDBE_CH*MAX_RDBE_IF][2];
  int iping;
  char multicast_addr[129];
  long ip[5];
  char secho[512];
  char buf[512], *start, slen;
  int i,j;
  unsigned long long llvalue;
  double dot2pps,dot2gps, sigma, mu;
  int multicast_error;
  double sum_on[MAX_RDBE_IF];
  double sum_off[MAX_RDBE_IF];
  double sum_tcal[MAX_RDBE_IF];
  double rsum_tsys[MAX_RDBE_IF];
  int tsys_count[MAX_RDBE_IF];
  int loop_count=-1;
  double lo[MAX_LO];
  char epoch[14];

  setup_ids();    /* attach to the shared memory */
  rte_prior(FS_PRIOR);

  if(argc >= 2) {
    memcpy(me+3,argv[1],2);
    memcpy(who,argv[1],2);
    if(argv[1][1]!='n')
      memcpy(what,argv[1],2);
    letter=me[4];
  }
  putpname(me);

  skd_wait(me,ip,(unsigned) 0);
  
/* Create a datagram socket on which to receive. */
sd = socket(AF_INET, SOCK_DGRAM, 0);
if(sd < 0)
{
perror("Opening datagram socket error");
exit(1);
}
//else
//printf("Opening datagram socket....OK.\n");
 
/* Enable SO_REUSEADDR to allow multiple instances of this */
/* application to receive copies of the multicast datagrams. */
{
int reuse = 1;
if(setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, (char *)&reuse, sizeof(reuse)) < 0)
{
perror("Setting SO_REUSEADDR error");
close(sd);
exit(1);
}
//else
//printf("Setting SO_REUSEADDR...OK.\n");
 }
 
/* Bind to the proper port number with the IP address */
/* specified as INADDR_ANY. */
memset((char *) &localSock, 0, sizeof(localSock));
localSock.sin_family = AF_INET;

 {
   int i;
   char lets[]="abcdefghijklm";
   int octet,dum;
   irdbe=-1;
   for(i=0;i<MAX_RDBE;i++)
     if(me[4]==lets[i]) {
       if(0!=shm_addr->rdbehost[i][0]) {
	 sprintf(multicast_addr,"239.0.2.%d",(i+1)*10);
	 localSock.sin_port = htons(20020+i+1);
	 irdbe=i;
	 break;
       }
     }
   if(irdbe<0) {
     printf(" no rdbe found %s\n",me);
     exit(-1);
   }
   //   printf("%s addr %s  port %d\n",me,multicast_addr,ntohs(localSock.sin_port));
 }

 //1 localSock.sin_addr.s_addr = INADDR_ANY;
 localSock.sin_addr.s_addr = htonl(INADDR_ANY);
if(bind(sd, (struct sockaddr*)&localSock, sizeof(localSock)))
{
perror("Binding datagram socket error");
close(sd);
exit(1);
}
//else
  //printf("Binding datagram socket...OK.\n");
 
/* Join the multicast group 226.1.1.1 on the local 203.106.93.94 */
/* interface. Note that this IP_ADD_MEMBERSHIP option must be */
/* called for each local interface over which the multicast */
/* datagrams are to be received. */
group.imr_multiaddr.s_addr = inet_addr(multicast_addr);
//group.imr_multiaddr.s_addr = inet_addr("239.0.4.20");
//group.imr_interface.s_addr = inet_addr("203.106.93.94");
//1 group.imr_interface.s_addr = inet_addr("192.168.1.21");
 group.imr_interface.s_addr = htonl(INADDR_ANY);
 //printf("IPPROTO_IP %d IP_ADD_MEMBERSHIP %d\n",IPPROTO_IP,IP_ADD_MEMBERSHIP);
if(setsockopt(sd, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *)&group, sizeof(group)) < 0)
{
printf(" errno %d\n",errno);
perror("Adding multicast group error");
close(sd);
exit(1);
}
//else
  //printf("Adding multicast group...OK.\n");
 
/* Read from the socket. */
  datalen = sizeof(databuf);
 multicast_error=FALSE;

while (1) {
  char time[15];
  unsigned short intg;
  struct timeval tv;
  int len;
  struct rdtcn_control rdtcn_control;
  struct timeval to;
  fd_set rfds;
  int iretsel;
  double x[1024],y[1024];
  unsigned short usvalue,pcal_ifx,raw_ifx,epoch_vdif;
  double pcaloff,pcal_spacing;

  memcpy(&rdtcn_control,
	 &shm_addr->rdtcn[irdbe].control[shm_addr->rdtcn[irdbe].iping],
	 sizeof(rdtcn_control));

  //2 int localSocklen=sizeof(localSock);

  to.tv_sec=TO_CENTISECONDS/100;
  to.tv_usec=(TO_CENTISECONDS%100)*10000;
  
  /* Read when data available */
  FD_ZERO(&rfds);
  FD_SET(sd, &rfds);
  
  iretsel = select(sd + 1, &rfds, NULL, NULL, &to);
  if (iretsel < 0) { /* error */
    multicast_error=multicast_error%5 + 1;
    if(1==multicast_error) {
      logita(NULL,errno,"un",who);
      logita(NULL,-1,"rz",who);
    }
    continue;
  } else if(iretsel == 0) {
    long now_raw;
    rte_rawt(&now_raw);
    if(shm_addr->rdbe_sync[irdbe]==0 ||
       shm_addr-> rdbe_sync[irdbe]+4500< now_raw) {/* wait 45 seconds after a
						      sync */
      multicast_error=multicast_error%5 + 1;
      if(1==multicast_error) {
	logita(NULL,-2,"rz",who);
      }
    }
    continue;
  }
  if(multicast_error) {
    multicast_error=0;
    logita(NULL,2,"rz",who);
  }

  if((len = read(sd, databuf, datalen)) < 0)
    //2 if((len = recvfrom(sd, databuf, datalen,0,
    //2		     (struct sockaddr *) &localSock,&localSocklen)) < 0)
    {
      perror("Reading datagram message error");
      close(sd);
      exit(1);
    }
  else
    {
      unsigned short ifc,pad, ch2;
      unsigned int ch, pad4;
      unsigned long long on, off;
      int i;

      /* message structure, big endian
   char read_time[20];                    0   20
   unsigned short pkt_size;              20    2
   unsigned short epoch_ref;             22    2
   unsigned long epoch_sec;              24    4
   unsigned int interval;                28    4
   char tsys_header[20];                 32   20
   unsigned long tsys_on[64];            52  256
   unsigned long tsys_off[64];          308  256 
   char pcal_header[20];                564   20
   unsigned short pcal_ifx;             584    4
   unsigned short pcal_ifx_pad;
   int pcal_sin[1024];                  588 4096
   int pcal_cos[1024];                 4684 4096
   char stat_str[3000];                8782 3000
   char raw_header[24];               11782   24
   unsigned short raw_ifx;            11804    4 
   unsigned short raw_ifx_pad;
   double mu;                         11808    8
   double sigma;                      11816    8
   double pps_offset;                 11824    8
   double gps_offset;                 11832    8
   unsigned short raw_size;           11840    2
   unsigned char raw_samples[4096];   11842 4102
   unsigned char raw_samples_pad[6];
                                      15944
      */
      memcpy(epoch,databuf,14);
      memcpy(&local.epoch,databuf,14);
      //      if (shm_addr->KECHO) {
      //char epoch[16];
      //memcpy(epoch,"<",1);
      //memcpy(epoch+1,databuf,13);
      //strcpy(epoch+14,">");
      //logit(epoch,0,NULL);
      //      }
      memcpy(&usvalue,databuf+22,2);
      epoch_vdif=xbe16toh(usvalue);
      local.epoch_vdif=epoch_vdif;

      for (j=0;j<MAX_RDBE_IF;j++) {
	int ifchain;

	sum_on[j]=0.0;
	sum_off[j]=0.0;
	sum_tcal[j]=0.0;
	rsum_tsys[j]=0.0;

	ifchain=irdbe*MAX_RDBE_IF+j+1;
	lo[ifchain-1]=shm_addr->lo.lo[ifchain-1];
      }

      for(i=0;i<MAX_RDBE_CH*MAX_RDBE_IF;i++) {
        unsigned long value;
	double diff;
	int ifchain;
	double center;
	float fwhm, tcal, dpfu, gain;

        memcpy(&value,databuf+52+i*4,4);
	tpi[i][1]=xbe32toh(value); /* on */
	memcpy(&value,databuf+308+i*4,4);
	tpi[i][0]=xbe32toh(value); /* off */

	ifchain=irdbe*MAX_RDBE_IF+i/MAX_RDBE_CH+1;
	if(lo[ifchain-1] >= 0.0) {
	  center=lo[ifchain-1]+1024-32*(i%MAX_RDBE_CH);
	  get_gain_par(ifchain,center,
		       &fwhm,&dpfu,NULL,&tcal);

	  //  	    printf(" irdbe %d i %d ifchan %d center %f tcal %f\n",
	  //	   irdbe,i,ifchain,center,tcal);

	  diff=(double) tpi[i][1]-(double) tpi[i][0];
	  if (tcal <=0.0)
	    local.tsys[i%MAX_RDBE_CH][i/MAX_RDBE_CH]=-9e12;
	  else if(diff <= 0.5)  /* no divide by zero or negative values */
	    local.tsys[i%MAX_RDBE_CH][i/MAX_RDBE_CH]=-9e6;
	  else {
	    local.tsys[i%MAX_RDBE_CH][i/MAX_RDBE_CH]=
	      (tcal/diff)*0.5*(tpi[i][1]+tpi[i][0]);
	  }

	  sum_on[i/MAX_RDBE_CH]+=tpi[i][1];
	  sum_off[i/MAX_RDBE_CH]+=tpi[i][0];

	  if(tcal <=0.0)
	    sum_tcal[i/MAX_RDBE_CH]=-9e12;
	  else if(sum_tcal[i/MAX_RDBE_CH] > -1e12)
	    sum_tcal[i/MAX_RDBE_CH]+=tcal;

	  if(tcal <=0.0)
	    rsum_tsys[i/MAX_RDBE_CH]=-9e12;
	  else if(rsum_tsys[i/MAX_RDBE_CH] > -1e12)
	    rsum_tsys[i/MAX_RDBE_CH]+=diff/(tcal*0.5*(tpi[i][1]+tpi[i][0]));

	} else {
	  local.tsys[i%MAX_RDBE_CH][i/MAX_RDBE_CH]=-9e12;
	  sum_tcal[i/MAX_RDBE_CH]=-9e12;
	  rsum_tsys[i/MAX_RDBE_CH]=-9e12;
	}  
      }
      for (j=0;j<MAX_RDBE_IF;j++) {
	double diff;
	int ifchain;

	ifchain=irdbe*MAX_RDBE_IF+j+1;
	if(lo[ifchain-1] >= 0.0) {
	  diff=sum_on[j]-sum_off[j];

	  if (sum_tcal[j] <= 0.0)
	    local.tsys[MAX_RDBE_CH+1][j]=-9e12;
	  else if(diff <= 0.5) /* no divide by zero or negative values */
	    local.tsys[MAX_RDBE_CH+1][j]=-9e6;
	  else {
	    local.tsys[MAX_RDBE_CH+1][j]=
	      (sum_tcal[j]/(MAX_RDBE_CH*diff))*0.5*(sum_on[j]+sum_off[j]);
	  }

	  if(rsum_tsys[j] < -1e12)
	    local.tsys[MAX_RDBE_CH][j]=-9e12;
	  else if(rsum_tsys[j] < 1e-6)
	    local.tsys[MAX_RDBE_CH][j]=-9e6;
	  else
	    local.tsys[MAX_RDBE_CH][j]=MAX_RDBE_CH/rsum_tsys[j];

	} else {
	  local.tsys[MAX_RDBE_CH][j]=-9e12;
	  local.tsys[MAX_RDBE_CH+1][j]=-9e12;
	}
	// printf(" irdbe %d j %d local.tsys[MAX_RDBE_CH][j] %f\n",
	//       irdbe, j,  local.tsys[MAX_RDBE_CH][j]);
      }
    }

    memcpy(&usvalue,databuf+584,2);
    pcal_ifx=xbe16toh(usvalue);
    local.pcal_ifx=pcal_ifx;

    memcpy(&usvalue,databuf+11804,2);
    raw_ifx=xbe16toh(usvalue);
    local.raw_ifx=raw_ifx;

    memcpy(&llvalue,databuf+11808,8);
    llvalue=xbe64toh(llvalue);
    memcpy(&mu,&llvalue,8);

    memcpy(&llvalue,databuf+11816,8);
    llvalue=xbe64toh(llvalue);
    memcpy(&sigma,&llvalue,8);
    local.sigma=sigma;

    //printf(" sigma %f\n",sigma);

  for(i=0;i<1024;i++) {
    unsigned int uvalue;
    int value;
    
    memcpy(&uvalue,databuf+588+i*4,4);
    uvalue=xbe32toh(uvalue); /* cos */
    memcpy(&value,&uvalue,4);
    y[i]=-value;
    
    memcpy(&uvalue,databuf+4684+i*4,4);
    uvalue=xbe32toh(uvalue); /* sin */
    memcpy(&value,&uvalue,4);
    x[i]=value;
    //    if(i==0)
    //printf(" i %d x %f y %f\n",i,x[i],y[i]);
  }
  pcaloff=0.0;
  for (j=0;j<MAX_RDBE_IF;j++) {
    int ifchain=irdbe*MAX_RDBE_IF+j+1;
    if(pcaloff < 0.1
       && shm_addr->lo.lo[ifchain-1] >= 0.0
       && shm_addr->lo.spacing[ifchain-1] > 0 ) {
      pcaloff=fmod(shm_addr->lo.lo[ifchain-1]+1024.0,
		   shm_addr->lo.spacing[ifchain-1])*1e6;
      pcal_spacing=shm_addr->lo.spacing[ifchain-1]*1e6;
    } /* take the first valid value */
  }
  local.pcaloff=pcaloff;
  local.pcal_spacing=pcal_spacing;

  if(pcaloff > 0.1) {
    for(i=0;i<1024;i++) {
      double xt,yt, theta, cost,sint;
      
      theta=-2*M_PI*pcaloff*(i%4)/1024e6;
      cost=cos(theta);
      sint=sin(theta);
      
      xt=x[i]*cost-y[i]*sint;
      yt=x[i]*sint+y[i]*cost;
      
      x[i]=xt;
      y[i]=yt;
      //    if(i==1)
	//  printf(" epoch %14.14s i %d x %f y %f\n",databuf,i,x[i],y[i]);
    }

    FFT(1,10,&x,&y);

    //  i=1;
    //    printf(" epoch %14.14s i %d x %f y %f\n",databuf,i,x[i],y[i]);

    for(i=0;i<512;i+=1) {

      if(pcaloff+i*1e6>512e6)
	break;

      if(shm_addr->rdbe_equip.pcal_amp[0]=='r'||
	 shm_addr->rdbe_equip.pcal_amp[0]=='n'||
	 shm_addr->rdbe_equip.pcal_amp[0]=='c')
	local.pcal_amp[i]=1e-7*sqrt(pow(x[i],2.0)+pow(y[i],2.0));

      if(shm_addr->rdbe_equip.pcal_amp[0]=='n'||
	 shm_addr->rdbe_equip.pcal_amp[0]=='c') {
	int ibin; /* find channel of tone, critical cases round up */
	ibin=fmod((pcaloff+i*1e6+16e6)/32e6+1e-12,(double)MAX_RDBE_CH);
	/* Brian determined 1.25e-5 empirically, independent of RMS level */
	local.pcal_amp[i]*=1.25e2/
	  sqrt((double) tpi[ibin][0]+(double)tpi[ibin][1]);
      }
      if(shm_addr->rdbe_equip.pcal_amp[0]=='c') {
	float freq;
	/* correct for 32 Mhz channel roll-off so reported value agrees
	   with correlator, roll-off from Russ */
	freq=fmod(pcaloff+i*1e6+16e6,32e6)-16e6; 
	local.pcal_amp[i]*=rdbe_freqz(freq);
      }
      // old, agrees roughly with correlator for RMS 32:
      // 3.346e-8 = 60/1.793e9 =correlator/(example_raw_amp at with RMS 32)
      // local.pcal_amp[i]=3.346e-8*sqrt(pow(x[i],2.0)+pow(y[i],2.0));

      local.pcal_phase[i]=atan2(y[i],x[i])*180/M_PI;
      //  printf(" epoch %14.14s i %4d amp %f phase %f\n",databuf,i,amp,phase);
    }
  }

  memcpy(&llvalue,databuf+11824,8);
  llvalue=xbe64toh(llvalue);
  memcpy(&dot2pps,&llvalue,8);
  local.dot2pps=dot2pps;

  memcpy(&llvalue,databuf+11832,8);
  llvalue=xbe64toh(llvalue);
  memcpy(&dot2gps,&llvalue,8);
  local.dot2gps=dot2gps;

  iping=1-shm_addr->rdbe_tsys_data[irdbe].iping;
  if(iping!=0 && iping !=1)
    iping=0;
  memcpy(&shm_addr->rdbe_tsys_data[irdbe].data[iping],&local,
	 sizeof(struct rdbe_tsys_cycle));
  shm_addr->rdbe_tsys_data[irdbe].iping=iping;

  /* check control again to get the last state */

  memcpy(&rdtcn_control,
	 &shm_addr->rdtcn[irdbe].control[shm_addr->rdtcn[irdbe].iping],
	 sizeof(rdtcn_control));

  if(1==rdtcn_control.stop_request ||
     (rdtcn_control.continuous == 0 &&
      (rdtcn_control.data_valid.user_dv ==0 || shm_addr->KHALT !=0 ||
       0==strncmp(shm_addr->LSKD,"none    ",8)))) {
    loop_count=-1;
    continue;
  }
  if(loop_count < -1 || loop_count >= (rdtcn_control.cycle+99)/100)
     loop_count=-1;
  ++loop_count;
  loop_count=loop_count%((rdtcn_control.cycle+99)/100);
  if(loop_count!=0)
     continue;

  sprintf(buf,"dot/%.14s,%hu",epoch,epoch_vdif);
  logit(buf,0,NULL);

  sprintf(buf,"dot2pps/%12.9e",dot2pps);
  logit(buf,0,NULL);

  sprintf(buf,"dot2gps/%12.9e",dot2gps);
  logit(buf,0,NULL);

  sprintf(buf,"sigma/%hu%c,%4.1f,%4.1f",raw_ifx,letter,sigma,mu);
  logit(buf,0,NULL);

  buf[0]=0;
  for (i=0;i<32; i++ ) {
    if(strlen(buf) >  100 || i == 16 && buf[0]!=0 ) {
      buf[strlen(buf)-1]=0;
      logit(buf,0,NULL);
      buf[0]=0;
    }
    if(buf[0]==0) {
      strcpy(buf,"tpcont/");
      slen=strlen(buf);
    }
    
    start=buf+strlen(buf);
    snprintf(start,sizeof(buf)-strlen(buf)," %02d%c%d,",i%16,letter,i/16);
    if(tpi[i][1] >= 16*100000)
      strcat(buf,"$$$$$,");
    else {
      int2str(buf,tpi[i][1],-7,0);
      strcat(buf,",");
    }
    if(tpi[i][1] >= 16*100000)
      strcat(buf,"$$$$$,");
    else {
      int2str(buf,tpi[i][0],-7,0);
      strcat(buf,",");
    }
  }
  if(strlen(buf)>slen){
    buf[strlen(buf)-1]=0;
    logit(buf,0,NULL);
  } 

  /* tsys */
  buf[0]=0;
  slen=0;
  for (i=0;i<2*(MAX_RDBE_CH+2); i++ ) {
    int ifchan=i/(MAX_RDBE_CH+2);
    int ichan=i%(MAX_RDBE_CH+2);

    if(strlen(buf) > 100 || 0==ichan && buf[0]!=0 ) {
      buf[strlen(buf)-1]=0;
      logit(buf,0,NULL);
      buf[0]=0;
    }
    if(local.tsys[ichan][ifchan] < -1e12)
      continue;

    if(buf[0]==0) {
      strcpy(buf,"tsys/");
      slen=strlen(buf);
    }
    
    start=buf+strlen(buf);
    if(MAX_RDBE_CH>ichan)
      snprintf(start,sizeof(buf)-strlen(buf)," %02d%c%d,",ichan,letter,ifchan);
    else if(MAX_RDBE_CH==ichan)
      snprintf(start,sizeof(buf)-strlen(buf)," AV%c%d,",letter,ifchan);
    else if(MAX_RDBE_CH+1==ichan)
      snprintf(start,sizeof(buf)-strlen(buf)," SM%c%d,",letter,ifchan);

    flt2str(buf,local.tsys[ichan][ifchan],-5,1);
    strcat(buf,",");
  }
  if(strlen(buf)>slen){
    buf[strlen(buf)-1]=0;
    logit(buf,0,NULL);
  }

/* pcal */

  if(pcaloff > 0.1) {
    buf[0]=0;
    for (i=0;i<512; i+=5 ) {
      if(pcaloff+i*1e6>512e6)
	break;
      if(strlen(buf) > 100 || i == 16 && buf[0]!=0 ) {
	buf[strlen(buf)-1]=0;
	logit(buf,0,NULL);
	buf[0]=0;
      }
      if(buf[0]==0) {
	strcpy(buf,"pcal/");
	slen=strlen(buf);
      }
      
      start=buf+strlen(buf);
      snprintf(start,sizeof(buf)-strlen(buf)," %hu%c%04d, %7.3f, %6.1f,",
	       local.pcal_ifx,letter,i,local.pcal_amp[i],local.pcal_phase[i]);
    }
    if(strlen(buf)>slen){
      buf[strlen(buf)-1]=0;
      logit(buf,0,NULL);
    }
  }
 }
return 0;
}
