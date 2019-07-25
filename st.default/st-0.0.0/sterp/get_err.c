/* get_err.c - hides details of error retrieval from main program
 *
 * Input:
 *
 *  maxlen - maximum number of bytes available in buffer
 *  ip[0]  - class number containing error message
 *
 * Output:
 *
 *  buffer - NULL terminated string containing error message
 *           the message is truncated if it won't fit
 */
 
void get_err(buffer,maxlen,ip)
char buffer[];
int maxlen;
long ip[5];
{

  int rtn1, rtn2,len;

  len=cls_rcv(ip[0], buffer, maxlen-1, &rtn1, &rtn2, 0, 0);
  buffer[len]='\0';

  return;
}
