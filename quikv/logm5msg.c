#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define BUFSIZE 2048

logm5msg(output,command,ip)
char *output;
struct cmd_ds *command;
long ip[5];
{
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  long out_class=0;
  int out_recs=0;
  char inbuf[BUFSIZE];
  int i;

 /* format output buffer */

  strcpy(output,command->name);
  strcat(output,"/");
      
  for (i=0;i<ip[1];i++) {
    char *ptr;
    if ((nchars =
	 cls_rcv(ip[0],inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
      goto error;
    }
        
    if(i!=0)
      strcat(output,",");
    strcat(output,"ack");
  }
    
  cls_snd(&out_class,output,strlen(output),0,0);
  out_recs++;
  
  ip[0]=out_class;
  ip[1]=out_recs;
  ip[2]=0;
  
  return 0;

error:
  cls_clr(ip[0]);
  return -1;
}
