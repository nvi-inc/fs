void fc_tpi_norack__(ip,itpis_norack)
long ip[5];
int itpis_norack[2];
{
    void tpi_norack();

    tpi_norack(ip,itpis_norack);

    return;
}
    
void fc_tpput_norack__(ip,itpis_norack,isub,ibuf,nch,ilen)
long ip[5];
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

void fc_tsys_norack__(itpis_norack,ibuf,nch,caltmp)
int itpis_norack[2];
char *ibuf;
int *nch;
float *caltmp;
{
    void tsys_norack();

    tsys_norack(itpis_norack,ibuf,nch,*caltmp);

    return;
}
