
main()
{
      float val;
      int ndigit,sign,decpt;
      char *ptr, *ecvt(), *fcvt();

      val=1000.5;
      ndigit=4;

      ptr=ecvt(val,ndigit,&decpt,&sign);
      printf(" ecvt %s decpt %d sign %d \n",ptr,decpt,sign);
      ptr=fcvt(val,ndigit,&decpt,&sign);
      printf(" fcvt %s decpt %d sign %d \n",ptr,decpt,sign);
      printf(" val %f\n",val);

      return;
}
