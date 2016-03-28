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

  skd_arg_buff(buffer,maxlen);

  return;
}
