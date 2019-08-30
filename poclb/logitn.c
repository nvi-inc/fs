/* logitn

   logitn formats message and errors for logging and sends the
   buffer to ddout. It is just like logit.c, but it handles numeric what
*/

#include <string.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/fscom.h"

void cls_snd();
void pname();
void rte_time();

logitn(msg,ierr,who, what)
char *msg;           /* a message to be logged, NULL if none */
int ierr;            /* error number, 0 if no error          */
char *who;           /* 2-char string identifying the error  */
int  what;          /* int with more info                   */

{
  char buf[2049];    /* Holds the complete log entry */
  char name[5];     /* The name of our main program */
  int it[6],ip1,ip2,l;
 
/* First get the time and put dddhhmmss into the log entry.
*/
  rte_time(it,&it[5]);
  buf[0]='\0';
  int2str(buf,it[5],-4,1);
  strcat(buf,".");
  int2str(buf,it[4],-3,1);
  strcat(buf,".");
  int2str(buf,it[3],-2,1);
  strcat(buf,":");
  int2str(buf,it[2],-2,1);
  strcat(buf,":");
  int2str(buf,it[1],-2,1);
  strcat(buf,".");
  int2str(buf,it[0],-2,1);

/* For error messages, put ?ERROR xx (nn) into the log entry.
*/
  if (ierr != 0) {
    strcat(buf,"?ERROR ");
    strncat(buf,who,2);
    int2str(buf,ierr,-5,0);
    strcat(buf,"(");
    int2str(buf,what,-4,0);
    strcat(buf,")");
  }
/* Get the name of our main program and append #pname# to the
   log entry. Then append the message.
*/
  else {
    pname(name);
    strcat(buf,"#");
    l=strlen(buf);
    memcpy(buf+l,name,5);
    buf[l+5]='\0';
    strcat(buf,"#");
    if(msg!=NULL)
      strncat(buf,msg,sizeof(buf)-strlen(buf)-1);
  }
/* Send the complete log entry to ddout via class.
*/
  memcpy(&ip1,"fs",2);
  memcpy(&ip2,"  ",2);
  if (ierr != 0) memcpy(&ip2,"b1",2);
/* for testing, send to output PLUS class */
/*  fprintf(stdout,"%s\n",buf); */
  cls_snd(&shm_addr->iclbox,buf,strlen(buf),ip1,ip2);
}
