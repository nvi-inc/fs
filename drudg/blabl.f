      SUBROUTINE BLABL(LU,NOUT,LEXPER,LSTNNA,LSTCOD,IYR,ID1,IH1,IM1,
     .                 ID2,IH2,IM2,ILABROW,cprttyp,cprport)
C Print barcode Mark III field labels  ARW 830920
C Print barcode field labels for Mark III tapes on laser printer.
C
      include '../skdrincl/skparm.ftni'
      integer lu,nout,iyr,id1(*),ih1(*),im1(*),id2(*),ih2(*),im2(*),
     .        ilabrow
      integer*2 lexper(4),lstnna(4),lstcod
      character*128 cprttyp,cprport
C
C On entry:
C   LU,     printer lu
C   NOUT,   #labels across page (3 max for laser, 1 for Epson)
C   LEXPER, 8-character experiment name (4A2)
C   LSTNNA, 8-character station name (4A2)
C   LSTCOD, 1-character station code (A1)
C   IYR,    year of observation (i.e. 83 or 1983)
C   ID1,IH1,IM1,  day,hour,minute tape start times
C   ID2,IH2,IM2,  day,hour,minute tape stop times
C   ILABROW,     location of label on page
C   cprttyp,    printer type
C   cprport,    printer port
C
C NRV 881021 Created
C NRV 901026 Modified to include Epson
C NRV 910306 Modified laser control to spread out bar codes
C nrv 950829 PC-DRUDG version converted to linux
C
      integer*2 jbuf(80),lbuf(80),label(6),jch
      integer l,jyr,i,ichek,j,ic,idummy,ip,il,i1,idum
      character*43 cCHAR
      CHARACTER*1 CESC                     !<esc>
      CHARACTER*12 CLABEL
      CHARACTER*40 Cprint                  !holds commands for printer
      INTEGER trimlen,ichmv,ichmv_ch
      character*1 cx

C  Initialized
      DATA cCHAR /'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%'/

C 1. Send escape sequence to set up for printing headers.

      if (cprttyp.eq.'LASER'.or.cprttyp.eq.'FILE') then !laserjet
	  Cprint=CHAR(27)// '&l6D' // CHAR(27) // '(0U'
     .               // CHAR(27) // '(s0p16.66h9.5v0s0b6T'//char(13)
	  l=trimlen(cprint)
	  WRITE(lu,'(a)') Cprint(1:l)               !Gothic 9.5 pt. ASCII
C       Position cursor to upper left corner of label printing
	  CESC=CHAR(27)
	  WRITE(Cprint,9115) CESC,90+(ILABROW-1)*980,char(13)
9115    FORMAT(A1,'&a',I4.4,'v000H',a1)
c9115    FORMAT(A1,'&a',I4.4,'v360H')
	  WRITE(lu,9114) Cprint
9114    FORMAT(A13)
	endif
C
C     Re-open the file to change to LIST type control
COPEN(UNIT=LU,FILE=cprport,STATUS='UNKNOWN',IOSTAT=IERR,
C    .CARRIAGE CONTROL='LIST')

C     Now write the normal ASCII information
	JYR=MOD(IYR,100)
	if (cprttyp.eq.'LASER'.or.cprttyp.eq.'FILE') then !Laser jet
	  WRITE(lu,130) (LSTNNA,JYR,ID1(I),IH1(I),IM1(I),i=1,nout),
     .    char(13)
130       FORMAT(6X,3(4A2,5X,"Start ",I2.2,"/",I3.3,"-",I2.2,I2.2,15X)
     .    ,a1)
	  WRITE(lu,140) (LEXPER,JYR,ID2(I),IH2(I),IM2(I),I=1,NOUT),
     .    char(13)
140     FORMAT(6X,3(4A2,5X,"End   ",I2.2,"/",I3.3,"-",I2.2,I2.2,15X)
     .    ,a1)
	else if (cprttyp.eq.'EPSON'.or.cprttyp.eq.'EPSON24') then
	  JYR=MOD(IYR,100)
	  WRITE(lu,1301) LSTNNA,JYR,ID1(1),IH1(1),IM1(1),char(13)
1301    FORMAT(4A2,5X,"Start ",I2.2,"/",I3.3,"-",I2.2,I2.2,a1)
	  WRITE(lu,1401) LEXPER,JYR,ID2(1),IH2(1),IM2(1),char(13)
1401    FORMAT(4A2,5X,"End   ",I2.2,"/",I3.3,"-",I2.2,I2.2,a1)
	endif

C
C  2. Fill up JBUF with characters to be printed as the bar code.
C     Fill up LBUF with characters to be printed as ASCII above the bar.

	CALL IFILL(LBUF,1,160,32)
	CALL IFILL(JBUF,1,80,32)
	DO I=1,NOUT !for each label across the row
	  WRITE(CLABEL,160) LSTCOD,ID1(I),IH1(I),IM1(I)
160     FORMAT(A1,I3.3,"-",2I2.2,1X)
	  CALL CHAR2HOL(CLABEL,LABEL,1,12)
C
C Compute modulo-43 check character
	  ICHEK=0
	  DO J=1,10 !for each character in LABEL
	    ic=0
	    idummy = ICHMV(IC,1,LABEL,J,1)
	    call hol2char(ic,1,1,cx)
	    IP=index(cchar,cx)
	    IF (IP.EQ.0) THEN !REPLACE ANY ILLEGAL CHARACTER WITH <SPACE>
		idummy = ICHMV_ch(LABEL,J,' ')
		IP=39
	    ENDIF
	    ICHEK=ICHEK+(IP-1)
	  enddo
	  ICHEK=MOD(ICHEK,43)
	  cx=cchar(ichek+1:ichek+1)
	  call char2hol(cx,jch,1,1)
	  idummy = ICHMV(LABEL,11,JCH,1,1)
	  IF (cx.EQ.' ') idummy = ICHMV_ch(LABEL,11,',') !USE ,  FOR <SPACE>
	  i1=4
	  il=22
	  idummy = ICHMV_ch(JBUF,i1+(I-1)*il,'*')
	  idummy = ICHMV(JBUF,i1+1+(I-1)*il,LABEL,1,11)
	  idummy = ICHMV_ch(JBUF,i1+10+(I-1)*il,',')  !Use , for <space>
	  idummy = ICHMV_ch(JBUF,i1+12+(I-1)*il,'*')
	  idummy = ICHMV(LBUF,i1+3+(I-1)*45,LABEL,1,10)
C       For laser:     JBUF looks like    *nddd-hhmm x*
C                                         1234567890123
C       For Epson:     LBUF looks like    nddd-hhmm
C                     LABEL looks like    nddd-hhmm x
	enddo !for each label across the row

C  3. For Epson, generate graphics buffer and print labels.
C     For laser, write ASCII version, then print label in bar code font.

	if (cprttyp.eq.'EPSON'.or.cprttyp.eq.'EPSON24') then
	  idum = ichmv_ch(lbuf,1,'<')

	  idum = ichmv(lbuf,2,label,1,11)
	  idum = ichmv_ch(lbuf,13,'>')
	  call bcode(lu,lbuf,label,cprttyp)

	else if (cprttyp.eq.'LASER'.or.cprttyp.eq.'FILE') then
C       Send ASCII version of labels to laser printer.
      write(6,9210) (lbuf(j),i=1,60)
	  WRITE(lu,9210)(LBUF(J),J=1,60),char(13)
9210    FORMAT(60A2,a1)
C       Switch to bar code font
	  Cprint=CHAR(27)//'(0Y'//CHAR(27)//'(s0p8.1h12v0s0b0T'
     .     //char(13)
	  WRITE(lu,9105) Cprint                  !bar code 3 of 9 pitch
9105    FORMAT(A23)
C        cprint=char(27)//'&k19H'               !spacing in 120ths of an inch
C        write(lu,9106) cprint
C9106    format(1x,a6)
C       Position cursor up a bit, right under printed code
	  WRITE(Cprint,9115) CESC,450+(ILABROW-1)*980,char(13)
	  WRITE(lu,9114) Cprint
C       Write bar code labels
	  DO I=1,3
	    WRITE(lu,9220)(JBUF(J),J=1,32),char(13)
	  ENDDO
9220    FORMAT(32A2,a1)
C
	endif

C  Re-open the output to change back to Fortran type control
COPEN(UNIT=LU,FILE=cprport,STATUS='UNKNOWN',IOSTAT=IERR,
C    .CARRIAGE CONTROL='FORTRAN')

900   RETURN
	END

