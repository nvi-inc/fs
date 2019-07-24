#include <stdio.h>

main()
{
	int c;

	while(EOF != (c=getchar()) ) {
		if (c == '\n')
			putchar('\r');
		putchar(c);
	}
}
