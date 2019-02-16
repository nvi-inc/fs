void fc_cls_sndc__( iclass, buffer, nchars, parm3, parm4, blen)
int *iclass;
char *buffer;
int *nchars, *parm3, *parm4, blen;
{
   void cls_snd();

   cls_snd( iclass, buffer, *nchars, *parm3, *parm4);
}
