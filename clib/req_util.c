/* mcbcn communication request utilities */

#include <string.h>
#include <sys/types.h>
#include "../include/req_ds.h"

static int tbytes[ ]={7,5,3,1,3,5,5,5}; /* total bytes by message type */

void ini_req(buffer)               /* initialize buffer */
struct req_buf *buffer;
{
     buffer->count=0;
     buffer->class=0;
     buffer->nchars=0;

     return;
}

void add_req(buffer,request)       /* add a request to buffer */
                                   /* send if too full */
struct req_buf *buffer;
struct req_rec *request;
{
     unsigned char *ptr;
     int type;
                                /* defend against illegal types */
                                /* mcbcn will bounce out illegal types */
                                /* but we have to prevent things from  */
                                /* getting out of control here */

     type=request->type;
     if(type!=21 &&
	( type<0 || ( type> (sizeof(tbytes)/sizeof(int)) ) )) type=0;

     if(buffer->nchars+tbytes[ type%20]>REQ_BUF_MAX) {
       cls_snd(&buffer->class,buffer->buf,buffer->nchars,0,0);
       buffer->count++;
       buffer->nchars=0;
     }

     ptr=&buffer->buf[buffer->nchars];

     if((type%20)!=6) 
       switch (tbytes[ type%20]) {
         case 7:
            ptr[6]=0xff & request->data;      /* CDL */
            ptr[5]=0xff & (request->data>>8); /* CDH */
         case 5:
            ptr[4]=0xff & request->addr;      /* rel ADL */
            ptr[3]=0xff & (request->addr>>8); /* rel ADH */
         case 3:
            ptr[2]=request->device[1];        /* module mnemonic */
            ptr[1]=request->device[0];
       }
     else {
       ptr[4]=0xff & request->data;          /* CDL */
       ptr[3]=0xff & (request->data>>8);     /* CDH */
       ptr[2]=0xff & request->addr;          /* ADL */
       ptr[1]=0xff & (request->addr>>8);     /* ADH */
     }
     ptr[0]=0xff & request->type;            /* request type */
                                             /* (possibly bad type) */
     
     buffer->nchars+=tbytes[ type%20];

     return;
}

void end_req(ip,buffer)        /* end buffer, send if partial */
long ip[5];
struct req_buf *buffer;
{
     if(buffer->nchars>0) {
       cls_snd(&buffer->class,buffer->buf,buffer->nchars,0,0);
       buffer->count++;
       buffer->nchars=0;
     }
     ip[0]=1;
     ip[1]=buffer->class;
     ip[2]=buffer->count;

     return;
}
