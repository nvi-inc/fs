void fc_v2_vlt_head__(ihead,volt,ip,indxtp)
int *ihead;
float *volt;
int ip[5];
int *indxtp;
{
    void v2_vlt_head();

    v2_vlt_head(*ihead,volt,ip,*indxtp);

    return;
}
