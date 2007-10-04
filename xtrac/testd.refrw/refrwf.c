double refrw_(), refrw2_();

double refrwf_(delin,tempc,humi,pres)
double *delin;
float *tempc,*humi, *pres;

{

  return refrw_(*delin,*tempc, *humi, *pres);
}

double refrw2f_(delin,tempc,humi,pres)
double *delin;
float *tempc,*humi, *pres;

{

  return refrw2_(*delin,*tempc, *humi, *pres);
}
