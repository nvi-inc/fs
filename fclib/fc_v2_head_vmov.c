void fc_v2_head_vmov__(ihead,volt,ip)
int *ihead;
float *volt;
long ip[5];
{
    void v2_head_vmov();

    v2_head_vmov(*ihead,*volt,ip);

    return;
}
