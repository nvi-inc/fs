#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define CTLFS "/usr2/fs/control/fserr.ctl"
#define CTLST "/usr2/control/sterr.ctl"
#define INDEXFS "/usr2/fs/control/fserr.ndx"
#define INDEXST "/usr2/control/sterr.ndx"
#define LOCLIM 1230
#define IBUFSZ 5136
#define JBUFSZ 1040
#define NULLPTR (char *) '\0'

extern struct fscom *shm_addr;

main(){
  int cls_rcv(), direc(), find();
  char tempbuf[80];
  long class, ip[5];
  int rtn1, rtn2;
  char inbuf[80];
  long off;
  int stfile, flag;
  int time1, time2, time3, time4;
  int err, ret;
  int i, len;

  struct{
    FILE dcb;
    int  index;
    long nents;
  } fs;

  struct{
    FILE dcb;
    int  index;
    long nents;
  } st;

  struct {
    char buf[8];
    long off;
  } entry;

  struct {
    char buf[8];
    long off;
  } entryfs;

  FILE *dcbfs, *dcbst;

  /* Section 1 */

  setup_ids();
  skd_wait("fserr", ip, 0);
  if(ip[0]==-1) exit(-1);

  /* call to retrieve parameter string */
  cls_rcv(ip[0], inbuf, 80, &rtn1, &rtn2, 0, 0);

  /* Section 2 */
  /* Read message files fserr.ctl and sterr.ctl and index file fserr.ndx */

  uptime(CTLST, &time1, &err);
  uptime(INDEXST, &time2, &err);
  uptime(CTLFS, &time3, &err);
  uptime(INDEXFS, &time4, &err);
  /* if index file is older than control file, purge index file */
  if ((time1>time2) && (time2!=0)){
    err = unlink(INDEXST);
    /* dblchk, unlink should be passed a pathname */
    if(err!=0){
      printf("can't purge sterr.ndx!\n");
      goto Suspend;
    }
  }
  if((time3>time4) && (time4 !=0)){
    err = unlink(INDEXFS);
    if(err!=0){
      printf("can't purge fserr.ndx!\n");
      goto Suspend;
    }
  }
  /* Open the control file */
  if((dcbfs=fopen(CTLFS, "r"))==NULL) goto Suspend;
  stfile = ((dcbst=fopen(CTLST, "r"))!=NULL);
  /* Open the index files */
  if((fs.index=open(INDEXFS, O_RDWR))<0){
    if((fs.index=open(INDEXFS, O_RDWR | O_CREAT, 0666))>=0)
      chmod(INDEXFS,0666);
    else goto Suspend;
    for(i=1;i<=(12*LOCLIM);++i) if(write(fs.index, "0", 1)<0) goto Suspend;
  }
  if(stfile)
    if((st.index=open(INDEXST, O_RDWR))<0){
      if((st.index=open(INDEXST, O_RDWR | O_CREAT, 0666))>=0)
        chmod(INDEXST,0666);
      else goto Suspend;
      for(i=1;i<=12*LOCLIM;++i) if(write(st.index, "0", 1)<0) {
        goto Suspend;}
    }
  /* a Direc call with 1st parm 1 is to set position in file to 1 */
  if(direc(1, &entryfs, &err, fs.index)<0){
    printf("can't access fserr.ndx!\n");
    goto Suspend;
  }
  fs.nents = entryfs.off;

  if(stfile){
    if(direc(1, &entry, &err, st.index)<0){
      printf("can't access sterr.ndx\n");
      goto Suspend;
    }
  }
  st.nents = entry.off;

/* If the index file is empty, recreate it */
  if(fs.nents==0){
    flag = FALSE;
    while((off=ftell(dcbfs))!=-1L){
      entryfs.off=off;
      if(fgets(tempbuf, 80, dcbfs)==NULL){
        err = -2;
      }
      strncpy(entryfs.buf, tempbuf, 8);
      entryfs.buf[7]='\0';
      len = strlen(entryfs.buf);
      if((err<0)||(len==0)) break;
      if(memcmp(entryfs.buf, "\"\"", 2)==0){
        if(flag) break;
        flag=TRUE;
        fs.nents+=1;
      }
      else if(flag){
        flag=FALSE;
        off=ftell(dcbfs);
/* a '3' direc call has direc call the find routine to hash */
        if(direc(3, &entryfs, &err, fs.index)<0) {
          goto Suspend;}
        fseek(dcbfs, off, SEEK_SET);
      }
    }
    flag=FALSE;
/* the '2' direc call has direc set position to 1 and post */
/* when setting up direc, see which vars should be passed as adresses */
    if(direc(2, &entryfs, &err, fs.index)<0){
      fprintf(stderr, "can't post fserr.ctl\n");
      goto Suspend;
    }
  }

/* Section 3.2 */
/* do the same thing for sterr.ctl - if exists */

  if(stfile){
    if(st.nents==0){
      flag=FALSE;
      while((off=ftell(dcbst))!=-1L){
        entry.off=off;
        if(fgets(tempbuf, 80, dcbst)==NULL){
          err=-2;
             }
        strncpy(entry.buf,tempbuf, 8);
        entry.buf[7]='\0';
        len=strlen(entry.buf);
        if((err<0) || (len==0)){
          break;
           }
        if(memcmp(entry.buf,"\"\"", 2)==0){
          if(flag){
            break;}
          flag=TRUE;
          st.nents+=1;
        }
        else if(flag){
          flag=FALSE;
          off = ftell(dcbst);
          if(direc(3,&entry,&err,st.index)<0){
            goto Suspend;}
          fseek(dcbst, off, SEEK_SET);
        }
      }
      flag = FALSE;
      if(st.nents!=0){
        if(direc(2,&entry,&err,st.index)<0){
          fprintf(stderr,"can't post sterr.ctl\n");
          goto Suspend;
        }
      }
    }
  }
stfile = (st.nents!=0);

/* Section 4 */
/* main rept-until loop done once for each err reported */
Repeat: 
  inbuf[48]='  ';
  if(memcmp(inbuf, "##", 2)==0){ 
    printf("number of entries = ");
    goto Suspend; 
  } 
  while((inbuf[0]<'a')||(inbuf[0]>'z'))
    for(i=0;i<79;++i)
      inbuf[i]=inbuf[i+1];
  for(i=0;i<80;++i)
      inbuf[i]=toupper(inbuf[i]);
  memcpy(entry.buf, inbuf, 7);
  entry.buf[7]= '\0';

  class = 0;

  memcpy(entryfs.buf, entry.buf, 8);
  if(stfile){
    ret=direc(4, &entry, &err, st.index);
    if((ret>=0)&&(entry.buf[0]!='\0')){ 
      if(fseek(dcbst, entry.off, SEEK_SET)==0){
        fgets(inbuf, 80, dcbst);
        fgets(inbuf, 80, dcbst);
        len = strlen(inbuf)-1;
        if((err>=0) && (memcmp(inbuf, "\"\"", 2)!=0) && (inbuf[0]!=' '))
          cls_snd(&class, inbuf, len, 0, 0);
        goto Suspend;
      }
    else
      entry.buf[0] = '\0';
    }
  }
  else
    entry.buf[0] = '\0';

  if(entry.buf[0]=='\0'){
/*    if(((ret=direc(4, &entryfs, &err, fs.index))>=0) && (entryfs.buf[0]!='\0')){
*/
    ret=direc(4, &entryfs, &err, fs.index);
/*if (entryfs.buf[0]=='\0')
*/
    if (ret > 0) {
      if(fseek(dcbfs, entryfs.off, SEEK_SET)==0){
        fgets(inbuf, 80, dcbfs);
        fgets(inbuf, 80, dcbfs);
        len = strlen(inbuf)-1;
        if((memcmp(inbuf,"\"\"",2)!=0) && (inbuf[0]!=' '))
          cls_snd(&class, inbuf, len, 0, 0); 
      }
    }
  }
  if((entry.buf[0]=='\0') && (entryfs.buf[0]=='\0')){
    cls_snd(&class, "nono", 4,0,0); }
 
Suspend:
  /* if(memcmp(&entry.buf[3], -1, 2)==0) goto Repeat; */

  ip[0] = class;
  skd_wait("fserr", ip, 0);
  if(ip[0]!=-1) {
    cls_rcv(ip[0], inbuf, 80, &rtn1, &rtn2, 0, 0);
    goto Repeat; }
  fclose(dcbst);
  fclose(dcbfs);
/* call direc & close index file */
  direc(9999, NULLPTR, NULLPTR, fs.index);
  direc(9999, NULLPTR, NULLPTR, st.index);
}
