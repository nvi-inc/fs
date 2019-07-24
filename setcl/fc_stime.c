int stime();

int fc_stime_( tp)
long *tp;
{
  int error;
  long t;

  t=*tp;
  printf(" t %d \n",t);
  error = stime(&t);
  if (error < 0) perror("setting system time");
  return error;
}
