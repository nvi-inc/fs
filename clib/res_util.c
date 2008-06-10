/* response buffer utilities */

#include <string.h>
#include "../include/res_ds.h"

void opn_res(buffer,ip)      /* initialize (open) response structs */
struct res_buf *buffer;        /* work struct */
long ip[5];                    /* ip information from mcbcn */
{
    buffer->class = ip[0];
    buffer->count = ip[1];
    buffer->ifc   = 0;
    buffer->nchars= 0;

    ip[0]=0;
    ip[1]=0;
    return;
}

void get_res(response, buffer)  /* fetch next response */
struct res_rec *response;      /* this respone, */
struct res_buf *buffer;        /* response buffer */
                               /* response->state==0 okay */
                               /* response->state==-1, no more */
{
    int idum, cls_rcv(), adv;
    unsigned char *ptr;

    if(buffer->ifc>=buffer->nchars && buffer->count > 0) {
      buffer->nchars=
        cls_rcv(buffer->class,buffer->buf,RES_MAX_BUF,&idum,&idum,0,0);
      buffer->count--;
      buffer->ifc=0;
    } else if (buffer->ifc>=buffer->nchars && buffer->count <= 0) {
      response->state=-1;
      return;
    }
      
    ptr=&buffer->buf[buffer->ifc];
    response->code=*ptr;
    adv=1;

    switch (response->code) {
      case 4:
        memcpy(response->array,ptr+3,24);
        adv+=24;
      case 1:
        response->data=(0xff00 & (*++ptr<<8)) | (0xff & (*++ptr) );
        adv+=2;
        break;
      default:
	if(response->code >=10) {
	  response->data=(0xff00 & (*++ptr<<8)) | (0xff & (*++ptr) );
	  adv+=2;
	  response->code-=50;	
	}
        break;
    }
    buffer->ifc+=adv;
    response->state=0;
    return;

}
    
void clr_res(buffer)         /* close buffer and clear class number */
struct res_buf *buffer;
{
    void cls_clr();

    if(buffer->count >0) cls_clr(buffer->class);

    buffer->class=0;
    buffer->count=0;

    return;
}
