#include <stdio.h>

main()
{
int class, rtn1, rtn2, nchars,i;
char buffer[100];

    setup_ids();

    class=2;
    nchars=cls_rcv(class,buffer,100,&rtn1,&rtn2,0,0);

    printf(" '%.*s'\n",nchars,buffer);
    for (i=0;i<nchars;i++)
       printf("%o ",buffer[i]);

}
