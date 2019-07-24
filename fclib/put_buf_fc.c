void put_buf_fc_( iclass, buffer, nchars, parm3, parm4)
long *iclass;
char *buffer;
int *nchars, *parm3, *parm4;
{
   int cls_snd(),idum;

   idum=cls_snd( iclass, buffer, *nchars, *parm3, *parm4);
   return;
}
