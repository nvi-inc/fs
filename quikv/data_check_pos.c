#include <stdio.h>
#include <string.h>

#define BUFSIZE 512

int data_check_pos(ip)
long ip[5];
{

  long out_class;
  int out_recs, ierr, icount;
  double pos;
  char outbuf[BUFSIZE];
  char inbuf[BUFSIZE];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char *ptr;

  out_recs=0;
  out_class=0;
  
  strcpy(outbuf,"position?\n");
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;
  
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("mk5cn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) return;

  if ((nchars =
       cls_rcv(ip[0],inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
    ip[3] = -401;
    goto error;
  }
  ptr=strchr(inbuf,'=');
  if(ptr == NULL) {
    ip[2]=-402;
  } else {
    if(1!=sscanf(ptr+1,"%d",&ierr)){
      ierr=-403;
      goto error;
    } else if(ierr != 0) {
      logita(NULL,-900-ierr,"m5","  ");
      ierr=-410;
      goto error;
    } else {
      ptr=strchr(inbuf,':');
      if(ptr==NULL) {
	ierr=-404;
	goto error;
      }
      ptr=strtok(ptr+1," ");
      icount=0;
      while (ptr!=NULL && strcmp(ptr,";")!=0 && icount <2) {
	if (strcmp(ptr,":")!=0 && icount==0) {
	  icount++;
	  if(icount==1)
	    if(1!=sscanf(ptr,"%lf",&pos)) {
	      ierr=-405;
	      goto error;
	    }
	}
	ptr=strtok(NULL," ");
      }
    }
    if(icount!=1)  {
      ierr=-406;
      goto error;
    }
  }

  pos-=1e6;

  out_recs=0;
  out_class=0;
    
  sprintf(outbuf,"play off %16.0lf\n",pos);
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;
  
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("mk5cn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) return;

  if ((nchars =
       cls_rcv(ip[0],inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
    ip[3] = -407;
    goto error;
  }
  ptr=strchr(inbuf,'=');
  if(ptr == NULL) {
    ip[2]=-408;
    goto error;
  } else {
    if(1!=sscanf(ptr+1,"%d",&ierr)){
      ierr=-409;
      goto error;
    } else if(ierr != 0) {
      logita(NULL,-900-ierr,"m5","  ");
      ierr=-411;
      goto error;
    }
  }
  ip[0]=ip[1]=ip[2]=0;
  return 0;

  error:
    cls_clr(ip[0]);
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"5d",2);
    return ierr;
}


