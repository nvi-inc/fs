void fc_tpi_norack__(ip,itpis_norack)
int ip[5];
int itpis_norack[2];
{
    void tpi_norack();

    tpi_norack(ip,itpis_norack);

    return;
}
    
void fc_tpput_norack__(ip,itpis_norack,isub,ibuf,nch,ilen)
int ip[5];
int itpis_norack[2];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_norack(ip,itpis_norack,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_norack__(ip,itpis_norack,ibuf,nch,itask)
int ip[5];
int itpis_norack[2];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_norack();

    tsys_norack(ip,itpis_norack,ibuf,nch,*itask);

    return;
}
