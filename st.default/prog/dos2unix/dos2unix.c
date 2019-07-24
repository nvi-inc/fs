#include <stdio.h>

main()
{
	int c;

	while(EOF != (c=getchar()) )
		if (c != '\r')
			putchar(c);
}
