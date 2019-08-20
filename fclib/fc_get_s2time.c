int fc_get_s2time__(dev,centisec,s2_tim,nanosec,ip,to,lendev)
char dev[];
int centisec[6];
int s2_tim[6];
int *nanosec;
int ip[5];
int *to;
int lendev;
{

  return get_s2time(dev,centisec,s2_tim,nanosec,ip,*to);

}
