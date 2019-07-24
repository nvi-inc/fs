void fc_cls_snd_( iclass, buffer, nchars, parm3, parm4)
long *iclass;
char *buffer;
int *nchars, *parm3, *parm4;
{
   void cls_snd();

   cls_snd( iclass, buffer, *nchars, *parm3, *parm4);
}
