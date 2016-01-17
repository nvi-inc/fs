#include <ctype.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 513

int logmsg_dbbc(output,command,ip)
char *output;
struct cmd_ds *command;
long ip[5];
{
   void cls_snd();
   int i,ierr;
   int rtn1;    /* argument for cls_rcv - unused */
   int rtn2;    /* argument for cls_rcv - unused */
   int msgflg=0;  /* argument for cls_rcv - unused */
   int save=0;    /* argument for cls_rcv - unused */
   int nchars;
   char inbuf[BUFSIZE];

   strcpy(output,command->name);
   strcat(output,"/");

   ierr=0;
   for (i=0;i<ip[1];i++) {
     if ((nchars =
	  cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
       ierr = -1;
       break;
     }
     inbuf[nchars]=0;
       /*              12345678 */
     if(strncmp(inbuf,"version/",8)==0) {
       ierr=dbbc_version_check(inbuf,output);
       if(ierr!=0)
	 break;
     } else {
       if(output[strlen(output)-1]!='/')
	 strcat(output,",");
       strcat(output,"ack");
     }
   }

   if(i<ip[1]-1)
     cls_clr(ip[0]);
   ip[0]=ip[1]=0;
   if(ierr == -6 ||ierr == 0 || ierr == -11 || ierr == -12) {
     cls_snd(ip+0,output,strlen(output),0,0);
     ip[1]++;
   }
   return ierr;
   
}
