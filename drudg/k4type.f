	SUBROUTINE k4type(cr1,iktype)

C Get the type of K4 equipment from the user, for non-VEX.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
C INPUT
      character*(*) cr1
C OUTPUT
      integer iktype ! type selected
C
C LOCAL:
      integer ikin,i,nch
      integer ias2b

C LAST MODIFIED:
C 980929 nrv New. Copied prompts from point.f

      if (kbatch) then
        read(cr1,*,err=991) ikin
991     if (ikin.lt.1.or.ikin.gt.7) then
          write(luscn,9991)
9991      format(' Invalid K4 type.')
          return
        endif
      else
 1      WRITE(LUSCN,9019) (lantna(I,ISTN),I=1,4)
C From Koyama e-mail on 980325
C     Bandwidth       2MHz     4MHz     8MHz    16MHz
C     K4-1 +DFC1100    OK       NA       NA       NA
C     K4-1 +Mk-3/4     OK       OK       NA       NA
C     K4-2A+DFC1100    OK       NA       NA       NA
C     K4-2*+DFC2100    OK       OK       OK       NA
C     K4-2A+Mk-3/4     OK       NA       NA       NA
C     K4-2B+Mk-3/4     OK       NA       NA       OK
C     K4-2C+Mk-3/4     NA       NA       OK       OK

9019    FORMAT(' Select type of K4 equipment for ',4a2/
     .       ' 1 - K4-1 rack + DFC1100 recorder'/
     .       ' 2 - K4-1 rack + Mk3 recorder'/ 
     .       ' 3 - K4-1 rack + VLBA recorder'/ 
     .       ' 4 - K4-2 rack + DFC1100 recorder'/
     .       ' 5 - K4-2 rack + DFC2100 recorder'/ 
     .       ' 6 - K4-2 rack + Mk4 formatter + VLBA recorder'/ 
     .       ' 7 - K4-2 rack + Mk4 formatter + VLBA4 recorder'/ 
     .       ' 0 - QUIT '/' ? ',$)

	call gtrsp(ibuf,80,luusr,nch)
	ikin= ias2b(ibuf(1),1,1)
	IF (ikin.EQ.0) RETURN
        IF (ikin.LT.1.OR.ikin.GT.7) GOTO 1
      endif
      iktype = ikin
      return
      end
