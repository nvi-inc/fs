/* rclcn.c - rcl control program */

/* include files */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#undef TRUE
#undef FALSE

#include "../rclco/rcl/rcl_def.h"
#include "../rclco/rcl/rcl.h"
#include "../rclco/rcl/rcl_cmd.h"

#define MAX_NAME 65
#define RCLAD_FILE "/usr2/control/rclad.ctl"
#define RES_MAXLEN RCL_STATUS_DETAIL_MAXLEN+sizeof(int)

void setup_ids();
void cls_snd();
int cls_rcv();
void cls_clr();
void skd_wait();
int rte_prior();

struct  rclad {
  char name[3];
  char hostname[MAX_NAME];
  int addr;
  struct rclad *next;
};

struct rclad *rclad_base;

struct error_struct {
  int value;
  char *mnem;
  struct error_struct *next;
};

struct error_struct *error_base=NULL;

int iecho;

/* external variables */
extern struct fscom *shm_addr;    /* shared memory segment */
void skd_wait();

main()
{
    int ierr;
    long ip[5];

    /* loop forever for message received */

    setup_ids();    /* attach to the shared memory */
    rte_prior(FS_PRIOR);

    ierr=0;

    while (TRUE) {
      ip[2]=ierr;
      memcpy(ip+3,"rl",2);
      skd_wait("rclcn",ip,(unsigned) 0);                
      iecho=shm_addr->KECHO;
#ifdef DEBUG
      printf("rclcn scheduled,\n ip: %d %d %d %d %d\n iecho %d",
	     ip[0],ip[1],ip[2],ip[3],ip[4],iecho);
#endif
      switch (ip[0]) {
      case 0:  /* initialize */
	ierr=init(ip);
	break;
      case 1:  /* process communication request buffers */
	ierr=process(ip);
	break;
      case 2:  /* terminate */
	rcl_close();
	exit(0);
      default: /* error */
	ierr=-300;
	break;
      }
    }
  }

/* ********************************************************************* */

int get_rclad(fp)
FILE *fp;
{
  char buffer[132];
  char hostname[128];
  char name[3];
  char *s;
  int count;
  struct rclad *ptr, *rptr;

#ifdef DEBUG
  printf(" enter get_rclad, fp: %d\n",fp);
#endif
  buffer[0]='*';
  while(buffer[0]=='*') {
    s=fgets(buffer,132,fp);
    if(s==NULL)
      if(feof(fp))
	return 1;
      else {
	logit(NULL,errno,"un");
	return -5;
      }
    if(strchr(buffer,'\n')==NULL)
      return -6;
#ifdef DEBUG
    printf(" line read: '%s'\n",buffer);
#endif
    
  }
  
  count = sscanf(buffer,"%3s %128s",&name,&hostname);
#ifdef DEBUG
  printf(" fscanf'd, count: %d, name: %s, hostanme: %s\n",
	 count,name,hostname);
#endif

  if (count != 2)
    return -1;
  
  if ( strlen(name) != 2 ) {
    return -2;
  }

  if(strlen(hostname) > (MAX_NAME-1)) {
    return -3;
  }
  
  ptr = (struct rclad *)malloc(sizeof(struct rclad));
  if (ptr == NULL)
    return -4;

  strcpy(ptr->name,name);
  strcpy(ptr->hostname,hostname);
  ptr->addr=-1;
  ptr->next=NULL;

  if(rclad_base == NULL ) {
    rclad_base=ptr;
#ifdef DEBUG
    printf(" added to rclad_base\n");
#endif
  } else 
    for (rptr=rclad_base;rptr!=NULL;rptr=rptr->next)
      if(rptr->next==NULL) {
#ifdef DEBUG
	printf(" added to rclad_base list\n");
#endif
	rptr->next=ptr;
	break;
      }
  
  return 0;
}

/* ********************************************************************* */

int get_addr(char *inbuf, int *inpos_ptr)
{
  int inpos=*inpos_ptr;
  struct rclad *rptr;
  
#ifdef DEBUG
  printf(" enter get_addr: device: %2.2s\n",inbuf+inpos);
#endif
  for (rptr=rclad_base;rptr!=NULL;rptr=rptr->next)
    if(0==strncmp(inbuf+inpos,rptr->name,2)) {
#ifdef DEBUG
      printf(" found address %d\n",rptr->addr);
#endif
      *inpos_ptr+=2;
      return rptr->addr;
    }
#ifdef DEBUG
      printf(" not found\n");
#endif

  return -1;
}

/* ********************************************************************* */

int init(long ip[5])
{
  FILE *fp;   /* general purpose file pointer */
  char *errmsg; 
  int ierr;
  struct rclad *ptr;

#ifdef DEBUG
  printf("init,\n ip: %d %d %d %d %d\n",
	 ip[0],ip[1],ip[2],ip[3],ip[4]);
#endif
  ip[0]=ip[1]=ierr=0;

  if ( (fp = fopen(RCLAD_FILE,"r")) == NULL) {
    logit(NULL,errno,"un");    
    return -319;
  }
#ifdef DEBUG
  printf(" opened file, fp: %d\n",fp);
#endif
  while ( (ierr=get_rclad(fp)) == 0)
    ;
#ifdef DEBUG
  printf(" get_rclad loop ended, ierr: %d\n",ierr);
#endif

  if (ierr < 0)
    return -300+ierr;

  if( fclose(fp) == EOF) {
    return -310;
  }

  for (ptr=rclad_base;ptr!=NULL;ptr=ptr->next) {
    ierr=rcl_open(ptr->hostname,&ptr->addr, errmsg);
#ifdef DEBUG
  printf(" opened device %s addr: %d errmsg %s\n",
	 ptr->hostname,ptr->addr, errmsg);
#endif
    if(ierr!=RCL_ERR_NONE) {
      fprintf(stderr,"rclcn error opening '%.2s' as '%s': "
	      ,ptr->name,ptr->hostname);
      fprintf(stderr,"%s",errmsg);
      if(ierr>0) {
	ierr=-130-ierr;
      }
    
      return ierr;
    }
  }

  return 0;
}

/* ********************************************************************* */

int process(ip)    /* process the input class buffers */
long ip[5];
{

  char inbuf[RCLCN_REQ_BUF_MAX];
  char outbuf[RES_MAXLEN];
  int inpos, old_outpos, i, nchars;
  long start;

  int outpos = 0;
  int ierr = 0;

  long outclass = 0;
  long outrecs = 0;

  long iclass=ip[1];
  long nrecs=ip[2];

  int msgflg=0;
  int save=0;

  for (i=0; i<nrecs && ierr == 0;i++) {
    int rtn1, rtn2;

    nchars = cls_rcv(iclass,inbuf,RCLCN_REQ_BUF_MAX,&rtn1,&rtn2,msgflg,save);
    if(nchars <= 0) {
      ierr=-320;
      break;
    }

    inpos=0;
    while(inpos < nchars && ierr == 0) {
      int addr;

      memcpy(ip+4,inbuf+inpos,2);
#ifdef DEBUG
      printf("device:%2.2s\n",inbuf+inpos);
#endif

      addr=get_addr(inbuf,&inpos);
#ifdef DEBUG
      printf("device addr:%d\n",addr);
#endif

      if(addr>=0) {
	old_outpos=outpos;
	ierr=command(addr,inbuf,&inpos,outbuf,&outpos);
#ifdef DEBUG
      printf("command returned, ierr %d, outpos: %d\n",
	     ierr, outpos);
#endif
	if(outpos>RCLCN_RES_MAX_BUF) {
	  start=0;
	  while(start <= outpos-1) {
	    int len=outpos-start;
	    len= len < RCLCN_RES_MAX_BUF ? len: RCLCN_RES_MAX_BUF;
	    cls_snd(&outclass, outbuf+start, len, 0, 0);
	    outrecs++;
	    start+=RCLCN_RES_MAX_BUF;
	  }
	  outpos=0;
	}
      } else {
	ierr=-321;
	outbuf[outpos++]=ierr;
      }
    }

    start=0;
    while(start <= outpos-1) {
      int len=outpos-start;
      len= len <RCLCN_RES_MAX_BUF? len: RCLCN_RES_MAX_BUF;
      cls_snd(&outclass, outbuf+start, len, 0, 0);
      outrecs++;
      start+=RCLCN_RES_MAX_BUF;
    }
      
	
    outpos=0;
  }

  ip[0]=outclass;
  ip[1]=outrecs;
  ip[2]=ierr;

  return ierr;

}    
void echo_add_error(char *echobuf,int ierr)
{
  struct error_struct *ptr;

  if(ierr <0)
    for (ptr=error_base;ptr!=NULL;ptr=ptr->next)
      if(ptr->value==ierr) {
	sprintf(echobuf+strlen(echobuf),"<%s>",ptr->mnem);
	return;
      }

  switch (ierr) { 
    case RCL_ERR_NONE:
      strcat(echobuf,"<NONE>");
      break;
  case RCL_ERR_OPFAIL:
      strcat(echobuf,"<OPFAIL>");
      break;
  case RCL_ERR_IO:
      strcat(echobuf,"<IO>");
      break;
  case RCL_ERR_TIMEOUT:
      strcat(echobuf,"<TIMEOUT>");
      break;
  case RCL_ERR_BADVAL:
      strcat(echobuf,"<BADVAL>");
      break;
  case RCL_ERR_BADLEN:
      strcat(echobuf,"<BADLE>");
      break;
  case RCL_ERR_NETIO:
      strcat(echobuf,"<NETIO>");
      break;
  case RCL_ERR_NETBADHOST:
      strcat(echobuf,"<NETBADHOST>");
      break;
  case RCL_ERR_NETBADREF:
      strcat(echobuf,"<NETBADREF>");
      break;
  case RCL_ERR_NETMAXCON:
      strcat(echobuf,"<NETMAXCON>");
      break;
  case RCL_ERR_NETREMCLS:
      strcat(echobuf,"<NETREMCLS>");
      break;
  case RCL_ERR_PKTUNEX:
      strcat(echobuf,"<PKTUNEX>");
      break;
  case RCL_ERR_PKTLEN:
      strcat(echobuf,"<PKTLEN>");
      break;
  case RCL_ERR_PKTFORMAT:
      strcat(echobuf,"<PKTFORMAT>");
      break;
  default:
    sprintf(echobuf+strlen(echobuf),"<%d>",ierr);
  }
}
int command(int addr, char *inbuf, int *inpos_ptr, char *outbuf,
	    int *outpos_ptr)
{   
  int iparm;
  char echobuf[2*RCLCN_RES_MAX_BUF];
  int inpos =*inpos_ptr;
  int outpos=*outpos_ptr;
  int old_outpos=*outpos_ptr;
  int ierr=0;

  /*skip space for rclcn error code, assume 0 */

  ierr=0;
  memcpy(outbuf+outpos,&ierr,sizeof(ierr));
  outpos+=sizeof(ierr);

  if(iecho)
    echobuf[0]='\0';

  switch (inbuf[inpos++]) {
  case RCL_CMD_STOP:
    if(iecho)
      strcpy(echobuf,"[stop]");
    ierr=rcl_stop(addr);
    
    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_PLAY:
    if(iecho)
      strcpy(echobuf,"[play]");

    ierr=rcl_play(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_RECORD:
    if(iecho)
      strcpy(echobuf,"[record]");

    ierr=rcl_record(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_REWIND:
    if(iecho)
      strcpy(echobuf,"[rewind]");

    ierr=rcl_rewind(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_FF:
    if(iecho)
      strcpy(echobuf,"[ff]");

    ierr=rcl_ff(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_PAUSE:
    if(iecho)
      strcpy(echobuf,"[pause]");

    ierr=rcl_pause(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_UNPAUSE:
    if(iecho)
      strcpy(echobuf,"[unpause]");

    ierr=rcl_unpause(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_EJECT:
    if(iecho)
      strcpy(echobuf,"[eject]");

    ierr=rcl_eject(addr);

    if(iecho)
      echo_add_error(echobuf,ierr);
    break;
  case RCL_CMD_STATE_READ:
    {
      int rstate;
      
      if(iecho)
	strcpy(echobuf,"[state_read]");

      ierr=rcl_state_read(addr,&rstate);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	switch (rstate) {
	case RCL_RSTATE_PLAY:
	  strcat(echobuf,"<play>");
	  break;
	case RCL_RSTATE_RECORD:
	  strcat(echobuf,"<record>");
	  break;
	case RCL_RSTATE_REWIND:
	  strcat(echobuf,"<rewind>");
	  break;
	case RCL_RSTATE_FF:
	  strcat(echobuf,"<ff>");
	  break;
	case RCL_RSTATE_STOP:
	  strcat(echobuf,"<stop>");
	  break;
	case RCL_RSTATE_PPAUSE:
	  strcat(echobuf,"<ppause>");
	  break;
	case RCL_RSTATE_RPAUSE:
	  strcat(echobuf,"<rpause>");
	  break;
	case RCL_RSTATE_CUE:
	  strcat(echobuf,"<cue>");
	  break;
	case RCL_RSTATE_REVIEW:
	  strcat(echobuf,"<review>");
	  break;
	case RCL_RSTATE_NOTAPE:
	  strcat(echobuf,"<notape>");
	  break;
	case RCL_RSTATE_POSITION:
	  strcat(echobuf,"<position>");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"<0x%x>",rstate);
	}
      }

      memcpy(outbuf+outpos,&rstate,sizeof(rstate));
      outpos+=sizeof(rstate);
      
      break;
    }
  case RCL_CMD_SPEED_SET:
    {
      int speed;
      
      memcpy(&speed,inbuf+inpos,sizeof(speed)); inpos+=sizeof(speed);
      
      if(iecho) {
	strcpy(echobuf,"[speed_set]");
	switch (speed) {
	case RCL_SPEED_LP:
	  strcat(echobuf,"[lp]");
	  break;
	case RCL_SPEED_SLP:
	  strcat(echobuf,"[slp]");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"[0x%x]",speed);
	}
      }

      ierr=rcl_speed_set(addr,speed);

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_SPEED_READ:
    {
      int speed;
      
      if(iecho)
	strcpy(echobuf,"[speed_read]");

      ierr=rcl_speed_read(addr,&speed);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;      

      if(iecho) {
	switch (speed) {
	case RCL_SPEED_UNKNOWN:
	  strcat(echobuf,"[unknown]");
	  break;
	case RCL_SPEED_SP:
	  strcat(echobuf,"[sp]");
	  break;
	case RCL_SPEED_LP:
	  strcat(echobuf,"[lp]");
	  break;
	case RCL_SPEED_SLP:
	  strcat(echobuf,"[slp]");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"[0x%x]",speed);
	}
      }
      memcpy(outbuf+outpos,&speed,sizeof(speed));
      outpos+=sizeof(speed);
      break;
    }
  case RCL_CMD_SPEED_READ_PB:
    {
      int speed;
      
      if(iecho)
	strcpy(echobuf,"[state_read_pb]");

      ierr=rcl_speed_read_pb(addr,&speed);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	switch (speed) {
	case RCL_SPEED_UNKNOWN:
	  strcat(echobuf,"[unknown]");
	  break;
	case RCL_SPEED_SP:
	  strcat(echobuf,"[sp]");
	  break;
	case RCL_SPEED_LP:
	  strcat(echobuf,"[lp]");
	  break;
	case RCL_SPEED_SLP:
	  strcat(echobuf,"[slp]");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"[0x%x]",speed);
	}
      }

      memcpy(outbuf+outpos,&speed,sizeof(speed));
      outpos+=sizeof(speed);
      break;
    }
  case RCL_CMD_TIME_SET:
    {
      int year,day,hour,min,sec;
      
      memcpy(&year,inbuf+inpos,sizeof(year)); inpos+=sizeof(year);
      memcpy(&day ,inbuf+inpos,sizeof(day )); inpos+=sizeof(day );
      memcpy(&hour,inbuf+inpos,sizeof(hour)); inpos+=sizeof(hour);
      memcpy(&min ,inbuf+inpos,sizeof(min )); inpos+=sizeof(min );
      memcpy(&sec ,inbuf+inpos,sizeof(sec )); inpos+=sizeof(sec );
      
      if(iecho) {
	strcpy(echobuf,"[time_set]");
	sprintf(echobuf+strlen(echobuf),"[%d][%d][%d][%d][%d]",
		year,day,hour,min,sec);
      }

      ierr=rcl_time_set(addr,year,day,hour,min,sec);

      if(iecho)
	echo_add_error(echobuf,ierr);

      break;
    }
  case RCL_CMD_TIME_READ:
    {
      int year,day,hour,min,sec;
      ibool validated;
      long centisec[2];
      
      if(iecho)
	strcpy(echobuf,"[time_read]");

      rte_rawt(centisec);
      ierr=rcl_time_read(addr,&year,&day,&hour,&min,&sec,&validated);
      rte_rawt(centisec+1);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	sprintf(echobuf+strlen(echobuf),"<%d><%d><%d><%d><%d>",
		year,day,hour,min,sec);
	if(validated)
	  strcat(echobuf,"<valid>");
	else
	  strcat(echobuf,"<not-valid>");
	sprintf(echobuf+strlen(echobuf),"{%ld}{%ld}",
		centisec[0],centisec[1]);
      }
      
      memcpy(outbuf+outpos,&year,sizeof(year)); outpos+=sizeof(year);
      memcpy(outbuf+outpos,&day ,sizeof(day )); outpos+=sizeof(day );
      memcpy(outbuf+outpos,&hour,sizeof(hour)); outpos+=sizeof(hour);
      memcpy(outbuf+outpos,&min ,sizeof(min )); outpos+=sizeof(min );
      memcpy(outbuf+outpos,&sec ,sizeof(sec )); outpos+=sizeof(sec );
      memcpy(outbuf+outpos,&validated,sizeof(validated));
      outpos+=sizeof(validated);
      memcpy(outbuf+outpos,centisec ,sizeof(centisec));
      outpos+=sizeof(centisec );
      
      break;
    }
  case RCL_CMD_TIME_READ_PB:
    {
      int year,day,hour,min,sec;
      ibool validated;

      if(iecho)
	strcpy(echobuf,"[time_read_pb]");

      ierr=rcl_time_read_pb(addr,&year,&day,&hour,&min,&sec,&validated);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	sprintf(echobuf+strlen(echobuf),"<%d><%d><%d><%d><%d>",
		year,day,hour,min,sec);
	if(validated)
	  strcat(echobuf,"<valid>");
	else
	  strcat(echobuf,"<not-valid>");
      }

      memcpy(outbuf+outpos,&year,sizeof(year)); outpos+=sizeof(year);
      memcpy(outbuf+outpos,&day ,sizeof(day )); outpos+=sizeof(day );
      memcpy(outbuf+outpos,&hour,sizeof(hour)); outpos+=sizeof(hour);
      memcpy(outbuf+outpos,&min ,sizeof(min )); outpos+=sizeof(min );
      memcpy(outbuf+outpos,&sec ,sizeof(sec )); outpos+=sizeof(sec );
      memcpy(outbuf+outpos,&validated,sizeof(validated));
      outpos+=sizeof(validated);

      break;
    }
  case RCL_CMD_MODE_SET:
    if(iecho) {
      strcpy(echobuf,"[mode_set]");
      sprintf(echobuf+strlen(echobuf),"[%s]",inbuf+inpos);
    }

    ierr=rcl_mode_set(addr,inbuf+inpos);
    inpos+=strlen(inbuf+inpos)+1;

    if(iecho)
      echo_add_error(echobuf,ierr);

    break;
  case RCL_CMD_MODE_READ:
    {
      char mode[RCL_MAXSTRLEN_MODE];
      
      if(iecho)
	strcpy(echobuf,"[mode_read]");

      ierr=rcl_mode_read(addr,mode);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	sprintf(echobuf+strlen(echobuf),"<%s>",mode);
      }

      memcpy(outbuf+outpos,mode,strlen(mode)+1);
      outpos+=strlen(mode)+1;
      break;
    }
  case RCL_CMD_TAPEID_SET:
    if(iecho) {
      strcpy(echobuf,"[tapeid_set]");
      sprintf(echobuf+strlen(echobuf),"[%s]",inbuf+inpos);
    }
    ierr=rcl_tapeid_set(addr,inbuf+inpos);
    inpos+=strlen(inbuf+inpos)+1;

    if(iecho)
      echo_add_error(echobuf,ierr);

    break;
  case RCL_CMD_TAPEID_READ:
    {
      char tapeid[RCL_MAXSTRLEN_TAPEID];
      
      if(iecho)
	strcpy(echobuf,"[tapeid_read]");

      ierr=rcl_tapeid_read(addr,tapeid);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	sprintf(echobuf+strlen(echobuf),"<%s>",tapeid);
      }
      
      memcpy(outbuf+outpos,tapeid,strlen(tapeid)+1);
      outpos+=strlen(tapeid)+1;
      
      break;
    }
  case RCL_CMD_TAPEID_READ_PB:
    {
      char tapeid[RCL_MAXSTRLEN_TAPEID];
      
      if(iecho)
	strcpy(echobuf,"[tapeid_read_pb]");

      ierr=rcl_tapeid_read_pb(addr,tapeid);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	sprintf(echobuf+strlen(echobuf),"<%s>",tapeid);
      }
      
      memcpy(outbuf+outpos,tapeid,strlen(tapeid)+1);
      outpos+=strlen(tapeid)+1;
      
      break;
    }
  case RCL_CMD_USER_INFO_SET:
    {
      int fieldnum;
      ibool label;
      
      memcpy(&fieldnum,inbuf+inpos,sizeof(fieldnum));
      inpos+=sizeof(fieldnum);
      memcpy(&label   ,inbuf+inpos,sizeof(label   ));
      inpos+=sizeof(label   );
      
      if(iecho) {
	strcpy(echobuf,"[user_info_set]");
	sprintf(echobuf+strlen(echobuf),"[%d]",fieldnum);
	if (label)
	  strcat(echobuf,"[label]");
	else
	  strcat(echobuf,"[field]");
	sprintf(echobuf+strlen(echobuf),"[%s]",inbuf+inpos);
      }

      ierr=rcl_user_info_set(addr,fieldnum,label,inbuf+inpos);
      inpos+=strlen(inbuf+inpos)+1;

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_USER_INFO_READ:
    {
      int fieldnum;
      ibool label;
      char user_info[RCL_MAXSTRLEN_USER_INFO];
      
      memcpy(&fieldnum,inbuf+inpos,sizeof(fieldnum));
      inpos+=sizeof(fieldnum);
      memcpy(&label   ,inbuf+inpos,sizeof(label   ));
      inpos+=sizeof(label   );
      
      if(iecho) {
	strcpy(echobuf,"[user_info_read]");
	sprintf(echobuf+strlen(echobuf),"[%d]",fieldnum);
	if (label)
	  strcat(echobuf,"[label]");
	else
	  strcat(echobuf,"[field]");
      }

      ierr=rcl_user_info_read(addr,fieldnum,label,user_info);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if (iecho)
	sprintf(echobuf+strlen(echobuf),"<%s>",user_info);

      memcpy(outbuf+outpos,user_info,strlen(user_info)+1);
      outpos+=strlen(user_info)+1;
      
      break;
    }
  case RCL_CMD_USER_INFO_READ_PB:
    {
      int fieldnum;
      ibool label;
      char user_info[RCL_MAXSTRLEN_USER_INFO];
      
      memcpy(&fieldnum,inbuf+inpos,sizeof(fieldnum));
      inpos+=sizeof(fieldnum);
      memcpy(&label   ,inbuf+inpos,sizeof(label   ));
      inpos+=sizeof(label   );
      
      if(iecho) {
	strcpy(echobuf,"[user_info_read_pb]");
	sprintf(echobuf+strlen(echobuf),"[%d]",fieldnum);
	if (label)
	  strcat(echobuf,"[label]");
	else
	  strcat(echobuf,"[field]");
      }

      ierr=rcl_user_info_read_pb(addr,fieldnum,label,user_info);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if (iecho)
	sprintf(echobuf+strlen(echobuf),"<%s>",user_info);
      
      memcpy(outbuf+outpos,user_info,strlen(user_info)+1);
      outpos+=strlen(user_info)+1;
      
      break;
    }
  case RCL_CMD_USER_DV_SET:
    {
      ibool user_dv, pb_enable;
      
      memcpy(&user_dv  ,inbuf+inpos,sizeof(user_dv  ));
      inpos+=sizeof(user_dv  );
      memcpy(&pb_enable,inbuf+inpos,sizeof(pb_enable));
      inpos+=sizeof(pb_enable);
      
      if(iecho) {
	strcpy(echobuf,"[user_dv_set]");
	if (user_dv)
	  strcat(echobuf,"[true]");
	else
	  strcat(echobuf,"[false]");
	if (pb_enable)
	  strcat(echobuf,"[use]");
	else
	  strcat(echobuf,"[ignore]");
      }

      ierr=rcl_user_dv_set(addr,user_dv,pb_enable);

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_USER_DV_READ:
    {
      ibool user_dv, pb_enable;
      
      if(iecho)
	strcpy(echobuf,"[user_dv_read]");

      ierr=rcl_user_dv_read(addr,&user_dv,&pb_enable);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	if (user_dv)
	  strcat(echobuf,"<true>");
	else
	  strcat(echobuf,"<false>");
	if (pb_enable)
	  strcat(echobuf,"<use>");
	else
	  strcat(echobuf,"<ignore>");
      }
      
      memcpy(outbuf+outpos,&user_dv  ,sizeof(user_dv  ));
      outpos+=sizeof(user_dv  );
      memcpy(outbuf+outpos,&pb_enable,sizeof(pb_enable));
      outpos+=sizeof(pb_enable);
      
      break;
    }
  case RCL_CMD_USER_DV_READ_PB:
    {
      ibool user_dv;
      
      if(iecho)
	strcpy(echobuf,"[user_dv_read_pb]");

      ierr=rcl_user_dv_read_pb(addr,&user_dv);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	if (user_dv)
	  strcat(echobuf,"<true>");
	else
	  strcat(echobuf,"<false>");
      }
      
      memcpy(outbuf+outpos,&user_dv  ,sizeof(user_dv  ));
      outpos+=sizeof(user_dv  );
      
      break;
    }
  case RCL_CMD_GROUP_SET:
    {
      int newgroup;
      
      memcpy(&newgroup,inbuf+inpos,sizeof(newgroup));
      inpos+=sizeof(newgroup);
      
      if(iecho) {
	strcpy(echobuf,"[group_set]");
	sprintf(echobuf+strlen(echobuf),"[%i]",newgroup);
      }

      ierr=rcl_group_set(addr,newgroup);

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_GROUP_READ:
    {
      int group,num_groups;
      
      if(iecho)
	strcpy(echobuf,"[group_read]");

      ierr=rcl_group_read(addr,&group,&num_groups);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%i><%i>",group, num_groups);
      
      memcpy(outbuf+outpos,&group     ,sizeof(group     ));
      outpos+=sizeof(group);
      memcpy(outbuf+outpos,&num_groups,sizeof(num_groups));
      outpos+=sizeof(num_groups);
      
      break;
    }
  case RCL_CMD_TAPEINFO_READ_PB:
    {
      unsigned char table[1+RCL_TAPEINFO_LEN];

      if(iecho)
	strcpy(echobuf,"[tapeinfo_read_pb]");

      ierr=rcl_tapeinfo_read_pb(addr,table+1);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	int i;
	for (i=0;i<8;i++) {
	  unsigned char *tabler=table+i*52;
	  long int delay;

	  sprintf(echobuf+strlen(echobuf),
  "\\\n<%d><%d><%s><%s><%d><%d><%d><%d><%d><%d><%d><%d><%d><%u><%u>",
		  tabler[1],tabler[2],tabler+3,tabler+24,
		  tabler[34]<<8|tabler[35],tabler[36]<<8|tabler[37],
		  tabler[38],tabler[39],tabler[40],tabler[41],
		  tabler[42],tabler[43],tabler[44],
		  tabler[45]<<8|tabler[46],tabler[47]<<8|tabler[48]);
	  delay  = (long) tabler[49]<<24;
	  delay |= (long) tabler[50]<<16;
	  delay |= tabler[51]<<8;
	  delay |= tabler[52];
	  if(delay == 0x7FFFFFFF)
	    strcat(echobuf,"<unknown>");
	  else
	    sprintf(echobuf+strlen(echobuf),"<%d>",delay);
	}
      }	    

      memcpy(outbuf+outpos,table+1,RCL_TAPEINFO_LEN);
      outpos+=RCL_TAPEINFO_LEN;
      
      break;
    }
  case RCL_CMD_DELAY_SET:
    {
      ibool relative;
      long int nanosec;
      
      memcpy(&relative,inbuf+inpos,sizeof(relative));
      inpos+=sizeof(relative);
      memcpy(&nanosec,inbuf+inpos,sizeof(nanosec));
      inpos+=sizeof(nanosec);
      
      if(iecho) {
	strcpy(echobuf,"[delay_set]");
	if(relative)
	  strcat(echobuf,"[relative]");
	else
	  strcat(echobuf,"[absolute]");
	sprintf(echobuf+strlen(echobuf),"[%d]",nanosec);
      }

      ierr=rcl_delay_set(addr,relative,nanosec);

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_DELAY_READ:
    {
      long int nanosec;
      
      if(iecho)
	strcpy(echobuf,"[delay_read]");

      ierr=rcl_delay_read(addr, &nanosec);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%d>",nanosec);
      
      memcpy(outbuf+outpos,&nanosec,sizeof(nanosec));
      outpos+=sizeof(nanosec);
      
      break;
    }
  case RCL_CMD_DELAYM_READ:
    {
      long int nanosec;
      
      if(iecho)
	strcpy(echobuf,"[delaym_read]");

      ierr=rcl_delaym_read(addr, &nanosec);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%d>",nanosec);
      
      memcpy(outbuf+outpos,&nanosec,sizeof(nanosec));
      outpos+=sizeof(nanosec);
      
      break;
    }
  case RCL_CMD_ALIGN:
    {
      switch (inbuf[inpos++]) {
      case 0:
	{
	  int year, day, hour, min, sec;
	  long int nanosec;
	  
	  memcpy(&year,inbuf+inpos,sizeof(year)); inpos+=sizeof(year);
	  memcpy(&day ,inbuf+inpos,sizeof(day )); inpos+=sizeof(day );
	  memcpy(&hour,inbuf+inpos,sizeof(hour)); inpos+=sizeof(hour);
	  memcpy(&min ,inbuf+inpos,sizeof(min )); inpos+=sizeof(min );
	  memcpy(&sec ,inbuf+inpos,sizeof(sec )); inpos+=sizeof(sec );
	  memcpy(&nanosec,inbuf+inpos,sizeof(year));
	  inpos+=sizeof(nanosec);
	  
	  if(iecho) {
	    strcpy(echobuf,"[align][absolute]");
	    sprintf(echobuf+strlen(echobuf),"[%d][%d][%d][%d][%d][%ld]",
		    year,day,hour,min,sec,nanosec);
	  }

	  ierr=rcl_align_abs(addr,year,day,hour,min,sec,nanosec);
	  
	  if(iecho)
	    echo_add_error(echobuf,ierr);

	  break;
	}
      case 1:
	{
	  ibool negative;
	  int hour, min, sec;
	  long int nanosec;
	  
	  memcpy(&negative,inbuf+inpos,sizeof(negative));
	  inpos+=sizeof(negative);
	  memcpy(&hour,inbuf+inpos,sizeof(hour)); inpos+=sizeof(hour);
	  memcpy(&min ,inbuf+inpos,sizeof(min )); inpos+=sizeof(min );
	  memcpy(&sec ,inbuf+inpos,sizeof(sec )); inpos+=sizeof(sec );
	  memcpy(&nanosec,inbuf+inpos,sizeof(nanosec));
	  inpos+=sizeof(nanosec);
	  
	  if(iecho) {
	    strcpy(echobuf,"[align][relative]");
	    if(negative)
	      strcat(echobuf,"[-]");
	    else
	      strcat(echobuf,"[+]");
	    sprintf(echobuf+strlen(echobuf),"[%d][%d][%d][%ld]",
		    hour,min,sec,nanosec);
	  }
	  ierr=rcl_align_rel(addr,negative,hour,min,sec,nanosec);

	  if(iecho)
	    echo_add_error(echobuf,ierr);
	  
	  break;
	}
      case 2:
	if(iecho)
	  strcpy(echobuf,"[align][realign]");

	ierr=rcl_align_realign(addr);

	if(iecho)
	  echo_add_error(echobuf,ierr);

	break;
      case 3:
	if(iecho)
	  strcpy(echobuf,"[align][selfalign]");

	ierr=rcl_align_selfalign(addr);

	if(iecho)
	  echo_add_error(echobuf,ierr);

	break;
      default:
	ierr=-322;
      }
      
      break;
    }
  case RCL_CMD_POSITION_SET:
    {
      int code;
      
      memcpy(&code,inbuf+inpos,sizeof(code)); inpos+=sizeof(code);
      switch(code) {
      case 0:
      case 1:
      case 2:
	{
	  int num;
	  
	  memcpy(&num ,inbuf+inpos,sizeof(num )); inpos+=sizeof(num );
	  switch (num) {
	  case 1:
	    {
	      long int position;
	      
	      memcpy(&position,inbuf+inpos,sizeof(position));
	      inpos+=sizeof(position);
	      
	      if(iecho) {
		strcpy(echobuf,"[position_set]");
		if(code==0)
		  strcat(echobuf,"[absolute]");
		else if(code==1)
		  strcat(echobuf,"[relative]");
		else if(code==2)
		  strcat(echobuf,"[preset]");
		else
		  sprintf(echobuf+strlen(echobuf),"[%i]",code);

		strcat(echobuf,"[1]");
		  
		if(position == RCL_POS_UNSEL)
		  strcat(echobuf,"[unselected]");
		else if(position == RCL_POS_UNKNOWN && code==2)
		  strcat(echobuf,"[unknown]");
		else		    
		  sprintf(echobuf+strlen(echobuf),"[%li]",position);
	      }

	      ierr=rcl_position_set(addr,code,position);

	      if(iecho)
		echo_add_error(echobuf,ierr);
	      
	      break;
	    }
	  case 8:
	    {
	      long int position[8];
	      
	      memcpy(&position,inbuf+inpos,sizeof(position));
	      inpos+=sizeof(position);
	      
	      if(iecho) {
		int i;
		strcpy(echobuf,"[position_set]");
		if(code==0)
		  strcat(echobuf,"[absolute]");
		else if(code==1)
		  strcat(echobuf,"[relative]");
		else if(code==2)
		  strcat(echobuf,"[preset]");
		else
		  sprintf(echobuf+strlen(echobuf),"[%i]",code);

		strcat(echobuf,"[8]");
		  
		for(i=0;i<8;i++)
		  if(position[i] == RCL_POS_UNSEL)
		    strcat(echobuf,"[unselected]");
		  else if(position[i] == RCL_POS_UNKNOWN && code==2)
		    strcat(echobuf,"[unknown]");
		  else		    
		    sprintf(echobuf+strlen(echobuf),"[%li]",position[i]);
	      }

	      ierr=rcl_position_set_ind(addr,code,position);

	      if(iecho)
		echo_add_error(echobuf,ierr);
	      
	      break;
	    }
	  default:
	    ierr=-323;
	  }
	  break;
	}
      case 3:
	if(iecho)
	  strcpy(echobuf,"[position][reestablish]");

	ierr=rcl_position_reestablish(addr);

	if(iecho)
	  echo_add_error(echobuf,ierr);
	
	break;
      default:
	ierr=-324;
      }
      
      break;
    }
  case RCL_CMD_POSITION_READ:
    {
      int num;
      
      memcpy(&num ,inbuf+inpos,sizeof(num )); inpos+=sizeof(num );
      switch (num) {
      case 0:
	{
	  long int position, posvar;
	  
	  if(iecho)
	    strcpy(echobuf,"[position_read][0]");

	  ierr=rcl_position_read(addr,&position,&posvar);

	  if(iecho)
	    echo_add_error(echobuf,ierr);

	  if(ierr!=0)
	    break;

	  if(iecho) {
	    if(position == RCL_POS_UNKNOWN)
	      strcat(echobuf,"<unknown>");
	    else		    
	      sprintf(echobuf+strlen(echobuf),"<%li>",position);
	    if(posvar == RCL_POS_UNKNOWN)
	      strcat(echobuf,"<unknown>");
	    else		    
	      sprintf(echobuf+strlen(echobuf),"<%li>",posvar);
	  }
	  
	  {
	    int num=0;
	    memcpy(outbuf+outpos,&num,sizeof(num));
	    outpos+=sizeof(num);
	  }

	  memcpy(outbuf+outpos,&position,sizeof(position));
	  outpos+=sizeof(position);
	  
	  memcpy(outbuf+outpos,&posvar  ,sizeof(posvar  ));
	  outpos+=sizeof(posvar  );
	  
	  break;
	}
      case 1:
	{
	  int num_entries;
	  long int position[8];
	  
	  if(iecho)
	    strcpy(echobuf,"[position_read][1]");

	  ierr=rcl_position_read_ind(addr,&num_entries,position);

	  if(iecho)
	    echo_add_error(echobuf,ierr);

	  if(ierr!=0)
	    break;

	  if(iecho) {
	    int i;
	    sprintf(echobuf+strlen(echobuf),"<%d>",num_entries);
	    for (i=0;i<8;i++)
	      if(position[i] == RCL_POS_UNKNOWN)
		strcat(echobuf,"<unknown>");
	      else if(position[i] == RCL_POS_UNSEL)
		strcat(echobuf,"<unselected>");
	      else		    
		sprintf(echobuf+strlen(echobuf),"<%li>",position[i]);
	  }

	  {
	    int num=1;
	    memcpy(outbuf+outpos,&num,sizeof(num));
	    outpos+=sizeof(num);
	  }

	  memcpy(outbuf+outpos,&num_entries,sizeof(num_entries));
	  outpos+=sizeof(num_entries);
	  
	  memcpy(outbuf+outpos,position   ,num_entries*sizeof(int));
	  outpos+=num_entries*sizeof(int);
	  
	  break;
	}
      default:
	ierr=-325;
      }
      
      break;
    }
  case RCL_CMD_ERRMES:
    {
      long int error;
      
      memcpy(&error,inbuf+inpos,sizeof(error));
      inpos+=sizeof(error);
      
      if(iecho) {
	strcpy(echobuf,"[cmd_errmes]");
	sprintf(echobuf+strlen(echobuf),"[%li]",error);
      }

      ierr=rcl_errmes(addr, error);

      if(iecho)
	echo_add_error(echobuf,ierr);
      
      break;
    }
  case RCL_CMD_ESTERR_READ:
    {
      ibool order_chantran;
      int num_entries;
      char esterr_list[8*RCL_MAXSTRLEN_ESTERR];
      int i,j;
      
      memcpy(&order_chantran,inbuf+inpos,sizeof(order_chantran));
      inpos+=sizeof(order_chantran);
      
      if(iecho) {
	strcpy(echobuf,"[esterr_read]");
	if(order_chantran)
	  strcat(echobuf,"[channel]");
	else
	  strcat(echobuf,"[transport]");
      }

      ierr=rcl_esterr_read(addr, order_chantran, &num_entries,
			   esterr_list);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	int i,j;

	sprintf(echobuf+strlen(echobuf),"<%li>",num_entries);
	
	j=0;
	for (i=0;i<num_entries;i++) {
	  sprintf(echobuf+strlen(echobuf),"\\\n<%s>",esterr_list+j);
	  j+=strlen(esterr_list+j)+1;
	}
      }

      memcpy(outbuf+outpos,&num_entries,sizeof(num_entries));
      outpos+=sizeof(num_entries);

      j=0;
      for (i=0;i<num_entries;i++)
	j+=strlen(esterr_list+j)+1;
      
      memcpy(outbuf+outpos,esterr_list,j);
      outpos+=j;
      
      break;
    }
  case RCL_CMD_PDV_READ:
    {
      ibool order_chantran;
      int num_entries;
      char pdv_list[8*RCL_MAXSTRLEN_PDV];
      int i,j;
      
      memcpy(&order_chantran,inbuf+inpos,sizeof(order_chantran));
      inpos+=sizeof(order_chantran);
      
      if(iecho) {
	strcpy(echobuf,"[pdv_read]");
	if(order_chantran)
	  strcat(echobuf,"[channel]");
	else
	  strcat(echobuf,"[transport]");
      }


      ierr=rcl_pdv_read(addr, order_chantran, &num_entries,
			pdv_list);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;
      if(iecho) {
	int i,j;

	sprintf(echobuf+strlen(echobuf),"<%li>",num_entries);
	
	j=0;
	for (i=0;i<num_entries;i++) {
	  sprintf(echobuf+strlen(echobuf),"\\\n<%s>",pdv_list+j);
	  j+=strlen(pdv_list+j)+1;
	}
      }
      
      memcpy(outbuf+outpos,&num_entries,sizeof(num_entries));
      outpos+=sizeof(num_entries);
      
      j=0;
      for (i=0;i<num_entries;i++)
	j+=strlen(pdv_list+j)+1;
      
      memcpy(outbuf+outpos,pdv_list,j);
      outpos+=j;
      
      break;
    }
  case RCL_CMD_SCPLL_MODE_SET:
    {
      int scpll_mode;
      
      memcpy(&scpll_mode,inbuf+inpos,sizeof(scpll_mode));
      inpos+=sizeof(scpll_mode);
      
      if(iecho) {
	strcpy(echobuf,"[scpll_mode_set]");
	switch (scpll_mode) {
	case RCL_SCPLL_MODE_XTAL:
	  strcat(echobuf,"[xtal]");
	  break;
	case RCL_SCPLL_MODE_MANUAL:
	  strcat(echobuf,"[manual]");
	  break;
	case RCL_SCPLL_MODE_REFCLK:
	  strcat(echobuf,"[refclk]");
	  break;
	case RCL_SCPLL_MODE_1HZ:
	  strcat(echobuf,"[1hz]");
	  break;
	case RCL_SCPLL_MODE_ERRMES:
	  strcat(echobuf,"[errmes]");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"[%i]",scpll_mode);
	}
      }
	  
      ierr=rcl_scpll_mode_set(addr, scpll_mode);
      
      if(iecho)
	echo_add_error(echobuf,ierr);

      break;
      }
  case RCL_CMD_SCPLL_MODE_READ:
    {
      int scpll_mode;
      
      if(iecho)
	strcpy(echobuf,"[scpll_mode_read]");

      ierr=rcl_scpll_mode_read(addr, &scpll_mode);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	switch (scpll_mode) {
	case RCL_SCPLL_MODE_XTAL:
	  strcat(echobuf,"<xtal>");
	  break;
	case RCL_SCPLL_MODE_MANUAL:
	  strcat(echobuf,"<manual>");
	  break;
	case RCL_SCPLL_MODE_REFCLK:
	  strcat(echobuf,"<refclk>");
	  break;
	case RCL_SCPLL_MODE_1HZ:
	  strcat(echobuf,"<1hz>");
	  break;
	case RCL_SCPLL_MODE_ERRMES:
	  strcat(echobuf,"<errmes>");
	  break;
	default:
	  sprintf(echobuf+strlen(echobuf),"<%i>",scpll_mode);
	}
      
      memcpy(outbuf+outpos,&scpll_mode,sizeof(scpll_mode));
      outpos+=sizeof(scpll_mode);
      
      break;
    }
  case RCL_CMD_TAPETYPE_SET:
    {
      if(iecho) {
	strcpy(echobuf,"[tapetype_set]");
	sprintf(echobuf+strlen(echobuf),"[%s]",inbuf+inpos);
      }

      ierr=rcl_tapetype_set(addr, inbuf+inpos);
      inpos+=strlen(inbuf+inpos)+1;
      
      if(iecho)
	echo_add_error(echobuf,ierr);

      break;
    }
  case RCL_CMD_TAPETYPE_READ:
    {
      char tapetype[RCL_MAXSTRLEN_TAPETYPE];
      
      if(iecho)
	strcpy(echobuf,"[tapetype_read]");

      ierr=rcl_tapetype_read(addr, tapetype);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%s>",tapetype);
      
      memcpy(outbuf+outpos,tapetype,strlen(tapetype)+1);
      outpos+=strlen(tapetype)+1;
      
      break;
    }
  case RCL_CMD_MK3_FORM_SET:
    ierr=-326;
    break;
  case RCL_CMD_MK3_FORM_READ:
    ierr=-326;
    break;
  case RCL_CMD_TRANSPORT_TIMES:
    ierr=-326;
    break;
  case RCL_CMD_STATION_INFO_READ:
    {
      int station;
      long int serialnum;
      char nickname[RCL_MAXSTRLEN_NICKNAME];
      
      if(iecho)
	strcpy(echobuf,"[station_info_read]");

      ierr=rcl_station_info_read(addr, &station, &serialnum, nickname);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%d><%ld><%s>",
		station,serialnum,nickname);
      
      memcpy(outbuf+outpos,&station,sizeof(station));
      outpos+=sizeof(station);
      
      memcpy(outbuf+outpos,&serialnum,sizeof(serialnum));
      outpos+=sizeof(serialnum);
      
      memcpy(outbuf+outpos,nickname,strlen(nickname)+1);
      outpos+=strlen(nickname)+1;
      
      break;
    }
  case RCL_CMD_CONSOLECMD:
    {
      if(iecho) {
	strcpy(echobuf,"[consolecmd]");
	sprintf(echobuf+strlen(echobuf),"[%s]",inbuf+inpos);
      }

      ierr=rcl_consolecmd(addr,inbuf+inpos);

      if(iecho)
	echo_add_error(echobuf,ierr);

      inpos+=strlen(inbuf+inpos)+1;
      
      break;
    }
  case RCL_CMD_POSTIME_READ:
    {
      int tran, year, day, hour, min, sec, frame;
      long int position;
      
      memcpy(&tran,inbuf+inpos,sizeof(tran));
      inpos+=sizeof(tran);
      
      if(iecho) {
	strcpy(echobuf,"[postime_read]");
	sprintf(echobuf+strlen(echobuf),"[%d]",tran);
      }

      ierr=rcl_postime_read(addr, tran, &year, &day, &hour, &min,
			    &sec, &frame, &position);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%d><%d><%d><%d><%d><%d><%ld>",
		year,day,hour,min,sec,frame,position);

      memcpy(outbuf+outpos,&year    ,sizeof(year    ));
      outpos+=sizeof(year    );
      
      memcpy(outbuf+outpos,&day     ,sizeof(day     ));
      outpos+=sizeof(day     );
      
      memcpy(outbuf+outpos,&hour    ,sizeof(hour    ));
      outpos+=sizeof(hour    );
      
      memcpy(outbuf+outpos,&min     ,sizeof(min     ));
      outpos+=sizeof(min     );
      
      memcpy(outbuf+outpos,&sec     ,sizeof(sec     ));
      outpos+=sizeof(sec     );
      
      memcpy(outbuf+outpos,&frame   ,sizeof(frame   ));
      outpos+=sizeof(frame   );
      
      memcpy(outbuf+outpos,&position,sizeof(position));
      outpos+=sizeof(position);
      
      break;
    }
  case RCL_CMD_STATUS:
    {
      int summary, num_entries;
      unsigned char status_list[RCL_STATUS_MAX*2];
      
      if(iecho)
	strcpy(echobuf,"[status]");

      ierr=rcl_status(addr, &summary, &num_entries, status_list);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	int i;
	sprintf(echobuf+strlen(echobuf),"<0x%x><%d>",summary,num_entries);
	for (i=0;i<num_entries;i++) {
	  char st[11];
	  if(((~0x7)&status_list[i*2+1]) == 0) {
	    strcpy(st,"---");
	    if(0x1&status_list[i*2+1])
	      st[0]='E';
	    if(0x2&status_list[i*2+1])
	      st[1]='F';
	    if(0x4&status_list[i*2+1])
	      st[2]='C';
	  } else
	    sprintf(st,"0x%x",status_list[i*2+1]);

	  sprintf(echobuf+strlen(echobuf),"\\\n<%d><%s>",
		  status_list[i*2],st);
	}
      }
      
      memcpy(outbuf+outpos,&summary    ,sizeof(summary    ));
      outpos+=sizeof(summary    );
      
      memcpy(outbuf+outpos,&num_entries,sizeof(num_entries));
      outpos+=sizeof(num_entries);
      
      memcpy(outbuf+outpos,status_list ,num_entries*2);
      outpos+=num_entries*2;
      
      break;
    }
  case RCL_CMD_STATUS_DETAIL:
    {
      int stat_code, summary, num_entries, icount, i;
      ibool reread, shortt;
      unsigned char status_det_list[RCL_STATUS_DETAIL_MAXLEN];
      
      memcpy(&stat_code,inbuf+inpos,sizeof(stat_code));
      inpos+=sizeof(stat_code);
      
      memcpy(&reread   ,inbuf+inpos,sizeof(reread   ));
      inpos+=sizeof(reread   );
      
      memcpy(&shortt   ,inbuf+inpos,sizeof(shortt   ));
      inpos+=sizeof(shortt   );
      
      if(iecho) {
	strcpy(echobuf,"[status_detail]");
	sprintf(echobuf+strlen(echobuf),"[%d]",stat_code);
	if(reread)
	  strcat(echobuf,"[reread]");
	else
	  strcat(echobuf,"[not-reread]");
	if(shortt)
	  strcat(echobuf,"[short]");
	else
	  strcat(echobuf,"[not-short]");
      }

      ierr=rcl_status_detail(addr, stat_code, reread, shortt,
			     &summary, &num_entries, status_det_list);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	int i,j;
	sprintf(echobuf+strlen(echobuf),"<0x%x><%d>",summary,num_entries);
	j=0;
	for (i=0;i<num_entries;i++) {
	  char *newln, *start;
	  char st[11];

	  if(((~0x7)&status_det_list[j+1]) == 0) {
	    strcpy(st,"---");
	    if(0x1&status_det_list[j+1] == 0x1)
	      st[0]='E';
	    if(0x2&status_det_list[j+1] == 0x2)
	      st[1]='F';
	    if(0x4&status_det_list[j+1] == 0x4)
	      st[2]='C';
	  } else
	    sprintf(st,"0x%x",status_det_list[j+1]);

	  sprintf(echobuf+strlen(echobuf),"\\\n<%d><%s>\\\n",
		  status_det_list[j],st);
	  j+=2;
	  start=echobuf+strlen(echobuf);
	  strcat(start,"<");
	  while(status_det_list[j]!=0) {
	    newln=strchr(status_det_list+j,'\n');
	    if(newln!=NULL)
	      *newln=0;
	    strcat(start,status_det_list+j);
	    j+=strlen(status_det_list+j);
	    if(newln!=NULL) {
	      *newln='\n';
	      j++;
	      strcat(start,"\\n");
	    }
	    if(status_det_list[j]!=0)
	      strcat(start,"\n");
	  }
	  strcat(start,">");
	}
      }
      
      memcpy(outbuf+outpos,&summary    ,sizeof(summary    ));
      outpos+=sizeof(summary    );
      
      memcpy(outbuf+outpos,&num_entries,sizeof(num_entries));
      outpos+=sizeof(num_entries);
      
      icount=0;
      for(i=0;i<num_entries;i++) {
	icount+=2;
	icount+=strlen(status_det_list+icount)+1;
      }
      memcpy(outbuf+outpos,status_det_list ,icount);
      outpos+=icount;
      
      break;
    }
  case RCL_CMD_STATUS_DECODE:
    {
      int stat_code;
      ibool shortt;
      char stat_msg[RCL_MAXSTRLEN_STATUS_DECODE];
      
      memcpy(&stat_code,inbuf+inpos,sizeof(stat_code));
      inpos+=sizeof(stat_code);
      
      memcpy(&shortt   ,inbuf+inpos,sizeof(shortt   ));
      inpos+=sizeof(shortt   );
      
      if(iecho) {
	strcpy(echobuf,"[status_decode]");
	sprintf(echobuf+strlen(echobuf),"[%d]",stat_code);
	if(shortt)
	  strcat(echobuf,"[short]");
	else
	  strcat(echobuf,"[not-short]");
      }

      ierr=rcl_status_decode(addr, stat_code, shortt, stat_msg);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho) {
	char *newln, *start;
	int j;

	strcat(echobuf,"\\\n");
	j=0;
	start=echobuf+strlen(echobuf);
	strcat(start,"<");
	while(stat_msg[j]!=0) {
	    newln=strchr(stat_msg+j,'\n');
	    if(newln!=NULL)
	      *newln=0;
	    strcat(start,stat_msg+j);
	    j+=strlen(stat_msg+j)+1;
	    if(newln!=NULL)
	      strcat(start,"\\n");
	    if(stat_msg[j]!=0)
	      strcat(start,"\n");
	  }
	  strcat(start,">");
	}

      memcpy(outbuf+outpos,stat_msg ,strlen(stat_msg)+1);
      outpos+=strlen(stat_msg)+1;
      
      break;
    }
  case RCL_CMD_ERROR_DECODE:
    {
      int err_code;
      char err_msg[RCL_MAXSTRLEN_ERROR_DECODE];
      struct error_struct *new, *ptr, **clean_up;
      char *end;

      memcpy(&err_code,inbuf+inpos,sizeof(err_code));
      inpos+=sizeof(err_code);
      
      if(iecho) {
	strcpy(echobuf,"[error_decode]");
	sprintf(echobuf+strlen(echobuf),"[%d]",err_code);
      }

      ierr=rcl_error_decode(addr, err_code, err_msg);

      if(iecho) 
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%s>",err_msg);

      memcpy(outbuf+outpos,err_msg ,strlen(err_msg)+1);
      outpos+=strlen(err_msg)+1;

      new=NULL;
      if(error_base==NULL) {
	new=malloc( sizeof(struct error_struct));
	error_base=new;
        clean_up=&error_base;
      } else
	for (ptr=error_base;;ptr=ptr->next)
	  if(ptr->value==err_code)
	    break;
	  else if(ptr->next==NULL) {
	    new=malloc(sizeof(struct error_struct));
	    ptr->next=new;
	    clean_up=&ptr->next;
	    break;
	  }

      if (new!=NULL) {
	new->next=NULL;
	new->value=err_code;
	end=strchr(err_msg,':');
	if(end!=NULL)
	  *end=0;
	new->mnem=malloc(strlen(err_msg+4)+1);
	if(new->mnem==NULL) {
	  free(new);
	  *clean_up=NULL;
	} else
	  strcpy(new->mnem,err_msg+4);
      }

      break;
    }
  case RCL_CMD_DIAG:
    ierr=-326;
    break;
  case RCL_CMD_IDENT:
    ierr=-326;
    break;
  case RCL_CMD_PING:
    {
      int timeout;
      
      memcpy(&timeout,inbuf+inpos,sizeof(timeout));
      inpos+=sizeof(timeout);
      
      if(iecho){
	strcpy(echobuf,"[ping]");
	sprintf(echobuf+strlen(echobuf),"[%d]",timeout);
      }
      ierr=rcl_ping(addr, timeout);
      
      if(iecho)
	echo_add_error(echobuf,ierr);
	
      break;
    }
  case RCL_CMD_VERSION:
    {
      char version[RCL_MAXSTRLEN_VERSION];
      
      if(iecho)
	strcpy(echobuf,"[version]");

      ierr=rcl_version(addr, version);

      if(iecho)
	echo_add_error(echobuf,ierr);

      if(ierr!=0)
	break;

      if(iecho)
	sprintf(echobuf+strlen(echobuf),"<%s>",version);

      memcpy(outbuf+outpos,version ,strlen(version)+1);
      outpos+=strlen(version)+1;
      
      break;
    }
  default:
    ierr=-327;
    break;
  }

  if(iecho) {
    char *nl,*start;
    memcpy(&iparm,"to",2);
    start=echobuf;
    nl=strchr(start,'\n');
    while (nl!=NULL) {
      *nl=0;
      cls_snd(&shm_addr->iclbox,start,strlen(start),0,iparm);
      start=nl+1;
      nl=strchr(start,'\n');
    }
    cls_snd(&shm_addr->iclbox,start,strlen(start),0,iparm);
      
  }

  if(ierr!=0) {
    if(ierr>0)
      ierr=-130-ierr;
    outpos=old_outpos;
    memcpy(outbuf+outpos,&ierr,sizeof(ierr));
    outpos+=sizeof(ierr);
  }

  *inpos_ptr=inpos;
  *outpos_ptr=outpos;

  return ierr;
}

/* ********************************************************************* */

