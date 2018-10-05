void fc_tpi_dbbc3__(ip,itpis_dbbc3)
long ip[5];
int *itpis_dbbc3;
{
    void tpi_dbbc3();

    tpi_dbbc3(ip,itpis_dbbc3);

    return;
}
    
void fc_tpput_dbbc3__(ip,itpis_dbbc3,isub,ibuf,nch,ilen)
long ip[5];
int *itpis_dbbc3;
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_dbbc3(ip,itpis_dbbc3,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_dbbc3__(ip,itpis_dbbc3,ibuf,nch,itask)
long ip[5];
int *itpis_dbbc3;
char *ibuf;
int *nch;
int *itask;
{
    void tsys_dbbc3();

    tsys_dbbc3(ip,itpis_dbbc3,ibuf,nch,*itask);

    return;
}
