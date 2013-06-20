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
       int iversion=0;
       /*                   123456789012 */
       if (strncmp(inbuf+8,"July 14 2011",12)==0||
	   strncmp(inbuf+8,"Feb 21 2011",11)==0)
	 iversion=100;
       /*                       1234567890123 */
       else if(strncmp(inbuf+8,"March 08 2012",13)==0)
	 iversion =101;
       /*                       12345678901234567890123 */
       else if(strncmp(inbuf+8,"102 - September 07 2012",23)==0)
	 iversion =102;
       /*                       123456789012 */
       else if(strncmp(inbuf+8,"July 04 2012",12)==0)
	 iversion =-102;
       /*                       12345678901234567890123 */
       else if(strncmp(inbuf+8,"DDC,103,October 04 2012",23)==0)
	 iversion =103;
       /*                       123456789012345678901 */
       else if(strncmp(inbuf+8,"DDC,104,March 19 2013",21)==0)
	 iversion = -104;
       /*                       12345678901234567890 */
       else if(strncmp(inbuf+8,"DDC,104,June 20 2013",20)==0)
	 iversion =104;
       if(iversion!=shm_addr->dbbcddcv) {
	 switch(iversion) {
	 case 100:
	   ierr = -3;
	   break;
	 case 101:
	   ierr = -4;
	   break;
	 case 102:
	   ierr = -5;
	   break;
	 case 103:
	   ierr = -7;
	   break;
	 case 104:
	   ierr = -8;
	   break;
	 case -102:
	   ierr = -9;
	   break;
	 case -104:
	   ierr = -10;
	   break;
	 default:
	   ierr = -6;
	 }
	 if(ierr==-6) {	   
	   if(output[strlen(output)-1]!='/')
	     strcat(output,",");
	   strcat(output,inbuf);
	 }
	 break;
       }
     } else {
       if(output[strlen(output)-1]!='/')
	 strcat(output,",");
       strcat(output,"ack");
     }
   }

   if(i<ip[1]-1)
     cls_clr(ip[0]);
   ip[0]=ip[1]=0;
   if(ierr==-6 |ierr==0) {
     cls_snd(ip+0,output,strlen(output),0,0);
     ip[1]++;
   }
   return ierr;
   
}
