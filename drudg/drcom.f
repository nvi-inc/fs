      BLOCK DATA DRCOM_DATA !,DRUDG BLOCK DATA C#880412:21:51#
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
C
C Permissions on output files
      data iperm/o'0666'/
C Initialize LU's
      DATA LU_INFILE  /20/
      DATA LU_OUTFILE /21/
      DATA LUPRT      /22/
C The length of a schedule file record
      DATA ISKLEN/128/
C Initialize the number of labels and lines/label
      DATA NLAB/1/, NLLAB/9/
C Initialize printer width
      DATA IWIDTH/137/
C      DATA IWIDTH/80/
C Initialize the $PROC section location
      DATA IRECPR/0/, IRBPR/0/, IOFFPR/0/
C Codes for passes and bandwidths
      DATA LBNAME/2hD8,2H42,2H1H,2HQE/
c Initialize no. entries in lband (freqs.ftni)
      DATA NBAND /2/
      END

