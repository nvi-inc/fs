/* convert month, day of month to day of year */
int daymy(int year, int month, int day)
/* four digit year, Jan is month 1, first day of month is 1 */
{
  /*                    J  F  M  A  M  J  J  A  S  O  N  D */
  int month_days[ ] = {31,28,31,30,31,30,31,31,30,31,30,31};

  /* not Y2.1K compliant */
  if(year % 4 == 0)
    month_days[1] =  29;
  else
    month_days[1] =  28;

  if(month > 12)
    month = 13;  /* so month 13 and up is Jan next year */
  
  if(month > 1)  /* month 1 or less means day is already day of year */
    while(--month)
      day += month_days[month-1];

  return day;
}

