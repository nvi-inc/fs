int fc_get_s2time__(dev,centisec,s2_tim,nanosec,ip,to,lendev)
char dev[];
long centisec[6];
int s2_tim[6];
long *nanosec;
long ip[5];
long *to;
int lendev;
{

  return get_s2time(dev,centisec,s2_tim,nanosec,ip,*to);

}
