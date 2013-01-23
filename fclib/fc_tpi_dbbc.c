void fc_tpi_dbbc__(ip,itpis_dbbc)
long ip[5];
int itpis_dbbc[34];
{
    void tpi_dbbc();

    tpi_dbbc(ip,itpis_dbbc);

    return;
}
    
void fc_tpput_dbbc__(ip,itpis_dbbc,isub,ibuf,nch,ilen)
long ip[5];
int itpis_dbbc[34];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_dbbc(ip,itpis_dbbc,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_dbbc__(ip,itpis_dbbc,ibuf,nch,itask)
long ip[5];
int itpis_dbbc[34];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_dbbc();

    tsys_dbbc(ip,itpis_dbbc,ibuf,nch,*itask);

    return;
}
