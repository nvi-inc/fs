void fc_v2_head_vmov__(ihead,volt,ip,indxtp)
int *ihead;
float *volt;
long ip[5];
int *indxtp;
{
    void v2_head_vmov();

    v2_head_vmov(*ihead,*volt,ip,*indxtp);

    return;
}
