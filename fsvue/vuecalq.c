#include <stdio.h>

/* A few definitions */
#define maxops 50             /* maximum number of operators */
#define s_add 0               /* + */
#define s_sub 1               /* - */
#define s_mul 2               /* * */
#define s_div 3               /* / */
#define s_mod 4               /* modulus */

#define s_rsf 5               /* shift register right */
#define s_lsf 6               /* shift register left */
#define s_and 7               /* AND registers */
#define s_ior 8               /* INCLUSIVE OR */
#define s_xor 9               /* EXCLUSIVE OR */

#define err_comp 1            /* Expression too complicated */
#define err_numb 2            /* Bad number */
#define err_oper 3            /* Unbalanced operator */
#define err_unkn 4            /* Unknown operator */
#define err_div0 5            /* Division by 0 not allowed */

int bracket, pos, exprerr;

vuecalq(str)
     char str[];
{
  char c;
  char expr[100];
  int value;

  if (str[0]=='\0') {
    printf("Give me value\n");
    printf("or a something\n");
    printf("to compute.\n");
    strcpy(expr,"0");
  } else {
    strcpy(expr,str);
  }

  bracket = exprerr = 0;
  value = evaluate(expr);
  if (exprerr || bracket) {
    printf("\nERROR - ");
    switch(exprerr) 
      {
      case err_comp: 
	puts("Expression too complicated.");
	break;
      case err_numb:
	puts("Bad number");
	break;
      case err_oper:
	 puts("Unbalanced expression");
	break;
      case err_unkn:
	puts("Unknown operator:\n");
	puts("Must start with hex #, o ', bit % symbol or value");
	break;
      case err_div0:
	puts("Division by zero not allowed");
	break;
      default: 
	puts("Unbalanced brackets");
      }
  } else {
    printf("%d\n#%x\n'%o\n%%", value, value, value);
    bitprt(value);
    printf("\n");
  }
  exit(0);
}

/* Here we are that the place where the work of evaluating expr takes 
   place. */
evaluate(s)
char *s;
{
  int op, term, done, bflag, opvec[maxops], termvec[maxops];
  op = term = pos = 0;

  while (s[pos]) {
    done = 1;
    bflag = 0;
    if (op == maxops || term == maxops) {
      exprerr = err_comp;
      return;
    }
    switch(toupper(s[pos]))
      {
      case ' ': 
	pos++;
	continue;
      case '%': 
	termvec[term++] = atobase(s,2);
	break;
      case '\'': 
	termvec[term++] = atobase(s,8);
	break;
      case '#': 
	termvec[term++] = atobase(s,16);
	break;
      case '0': case '1': case '2': case '3': case '4':
      case '5': case '6': case '7': case '8': case '9':
	termvec[term++] = atobase(s,10);
	break;
      case '(':
	++bracket;
	++pos;
	strcpy(s,s+pos);
	termvec[term++] = evaluate(s);
	break;
      case '+': 
	opvec[op++] = s_add;
	++pos;
	break;
      case '-': 
	opvec[op++] = s_sub;
	++pos;
	break;
      case '*': 
	opvec[op++] = s_mul;
	++pos;
	break;
      case '/': 
	opvec[op++] = s_div;
	++pos;
	break;
      case '&':
	opvec[op++] = s_and;
	++pos;
	break;
      case '|': 
	opvec[op++] = s_ior;
	++pos;
	break;
      case '<': 
	if (s[pos+1] == '<') {
	  opvec[op++] = s_lsf;
	  pos += 2;
	} else {
	  done = 1;
	  exprerr = err_oper;
	  return;
	}
	break;
      case '>': 
	if (s[pos+1] == '>') {
	  opvec[op++] = s_rsf;
	  pos += 2;
	} else { 
	  done = 1;
	  exprerr = err_oper;
	  return;
	}
	break;
      case 'M': 
	if (toupper(s[pos+1]) == 'O' && toupper(s[pos+2]) == 'D') {
	  opvec[op++] = s_mod;
	  pos += 3;
	} else {
	  exprerr = err_oper;
	  return; done = 1;
	}
	break;
      case 'X': 
	if (toupper(s[pos+1]) == 'O' && toupper(s[pos+2]) == 'R') {
	  opvec[op++] = s_xor;
	  pos += 3;
	} else {
	  exprerr = err_oper;
	  return; done = 1;
	}
	break;
      case ')': 
	--bracket;
	++pos;
	bflag = 1;
	break;
      default: 
	done = 0;
      }
    if (!done) {
      exprerr = err_unkn;
      return;
    }
    if (bflag) break;
  }
  if (exprerr) return;
  return (get_val(opvec, op, termvec, term));
}
/* ************** */
/* get the values */ 
/* ************** */
get_val(ops, op, terms, term)
int *ops, op, *terms, term;
{
  int curterm, curop, thisop, total, term1;
  total = curterm = curop = 0;
  while (curterm<term) {
    term1 = terms[curterm++];
    if (curop>op) {
      exprerr = err_numb;
      return;
    }
    thisop = (curop == 0) ? s_add : ops[curop-1];
    ++curop;
    total = docalc(total, term1, thisop);
    if (exprerr) return;
  }
  if (curop>op) return(total);
  exprerr = err_oper;
}

/* ******************** */
/* calculate the values */
/* ******************** */
docalc( term1, term2, op)
int term1, term2, op;
{
  switch (op)
    {
    case s_add: 
      return(term1+term2);
    case s_sub: 
      return(term1-term2);
    case s_mul: 
      return(term1*term2);
    case s_div: 
      if ( term2 == 0) {
	exprerr = err_div0;
	return;
      }
      return(term1/term2);
    case s_mod: 
      if (term2 == 0) {
	exprerr = err_div0;
	return;
      }
      return(term1%term2);
    case s_rsf: 
      return(term1>>term2);
    case s_lsf: 
      return(term1<<term2);
    case s_and: 
      return(term1&term2);
    case s_ior: 
      return(term1|term2);
    case s_xor: 
      return(term1^term2);
    }
}

/* ************************ */
/* Bits, bits and more bits */
/* ************************ */
bitprt(num)
int num;
{
  char s[17], *ptr;
  int i;
  ptr = s;

  for ( i=15; i>=0; i--)
    if (num & 1 << i)
      *ptr++ = '1';
    else
      *ptr++ = '0';
  *ptr = '\0';
  ptr = s;
  while (*ptr == '0') ++ptr;
  if (!*ptr) --ptr;
  printf("%s",ptr);
}

/* *********************************************************** */
/* hex, octal, hex, octal, hex what the heck is all this about */
/* *********************************************************** */
atobase( s, radix)
char *s;
int radix;
{
  int sum, c;
  
  if (radix!=10) ++pos;
  if ((sum=digit(s[pos++]))>=radix)
    {
     exprerr = err_numb;
     return;
   }
   while (c=s[pos]) 
     {
      if ((c=digit(c))>=radix) break;
      sum = sum * radix + c;
      ++pos;
    }
    return(sum);
}
/* *********** */
/* digitize it */
/* *********** */
digit(c)
char c;
{
  if (c>='a') c = toupper(c);
  return ((c>='0' && c<='9') ? c - '0':
          (c>='A' && c<='F') ? c - 'A' + 10:100);
}

/* ********** */
/* uppercase  */
/* ********** */
int toupper(c)
int c;
{
 return ((c>='a' && c<='z') ? c - 0x20 : c);
}
