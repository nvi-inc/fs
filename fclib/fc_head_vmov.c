void fc_head_vmov_(ihead,idir,ispdhd,jm,ip)
int *ihead;
int *idir;
int *ispdhd;
long *jm;
long ip[5];
{
    void head_vmov();

    head_vmov(*ihead,*idir,*ispdhd,*jm,ip);

    return;
}
