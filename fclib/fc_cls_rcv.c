int fc_cls_rcv__( iclass, buffer, nchars, rtn1, rtn2)
int *iclass;
char *buffer;
int *nchars, *rtn1, *rtn2;
{
   int cls_rcv();

   return(cls_rcv( *iclass, buffer, *nchars, rtn1, rtn2, 0, 0));
}
