      subroutine lv_open

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

  char inbuf[100];
  char ans[3];
  char outname[100];
  char append[3];

  fp_out = NULL;
  while (fp_out == NULL) {
    write(luscn,'("Enter name of output file, :: to quit  ",$)')
    gets(inbuf);
    if (strncmp(inbuf,"::",2) == 0) 
      return;
    *fp_out = fopen(inbuf,"r");
    if (*fp_out != NULL) { /* file already exists */
      printf("Output file already exists, (o)verwrite or (a)ppend, :: to quit  ");
      gets(ans);
      if (strncmp(ans,"::",2) == 0)
        exit(1);
      while (ans[0] != 'a' && ans[0] != 'o') {
        printf("Enter either o for overwrite or a for append  ");
        gets(ans);
      }
      if (ans[0] == 'a')
        *fp_out = fopen(inbuf,ans);
      else
        *fp_out = fopen(inbuf,"w");
    }
    else {
      *fp_out = fopen(inbuf,"w");
    }
    if (*fp_out == NULL) printf("Can't open output file %s\n",inbuf);
      return
      end
