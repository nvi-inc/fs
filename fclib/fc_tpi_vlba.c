void fc_tpi_vlba__(ip,itpis_vlba)
long ip[5];
int itpis_vlba[34];
{
    void tpi_vlba();

    tpi_vlba(ip,itpis_vlba);

    return;
}
    
void fc_tpput_vlba__(ip,itpis_vlba,isub,ibuf,nch,ilen)
long ip[5];
int itpis_vlba[34];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_vlba(ip,itpis_vlba,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_vlba__(itpis_vlba,ibuf,nch,caltmp)
int itpis_vlba[34];
char *ibuf;
int *nch;
float *caltmp;
{
    void tsys_vlba();

    tsys_vlba(itpis_vlba,ibuf,nch,*caltmp);

    return;
}
