void fc_tpi_vlba__(ip,itpis_vlba,isub)
int ip[5];
int itpis_vlba[34];
int *isub;
{
    void tpi_vlba();

    tpi_vlba(ip,itpis_vlba,*isub);

    return;
}
    
void fc_tpput_vlba__(ip,itpis_vlba,isub,ibuf,nch,ilen)
int ip[5];
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

void fc_tsys_vlba__(ip,itpis_vlba,ibuf,nch,itask)
int ip[5];
int itpis_vlba[34];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_vlba();

    tsys_vlba(ip,itpis_vlba,ibuf,nch,*itask);

    return;
}
