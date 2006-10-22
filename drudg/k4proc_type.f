	SUBROUTINE k4proc_type(cr1,iktype)

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
      integer ikin,i

C LAST MODIFIED:
C 980929 nrv New. Copied prompts from point.f
C 990523 nrv Changed options 2 and 3 to be VLBA and VLBA4 rec.
C            Add K4-1, DFC2100 option, now there are 12.
! 2006JMGipson.  Did direct read instead of using Hollerith gtrsp.

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
     .       ' 1 - K4-1  rack + DFC1100 recorder'/
     .       ' 2 - K4-1  rack + DFC2100 recorder'/
     .       ' 3 - K4-1  rack + K3 formatter + VLBA recorder'/ 
     .       ' 4 - K4-1  rack + K3 formatter + VLBA4 recorder'/ 
     .       ' 5 - K4-2  rack + DFC1100 recorder'/
     .       ' 6 - K4-2  rack + DFC2100 recorder'/ 
     .       ' 7 - K4-2  rack + Mk4 formatter + VLBA recorder'/ 
     .       ' 8 - K4-2  rack + Mk4 formatter + VLBA4 recorder'/ 
     .       ' 9 - VLBA  rack + DFC1100 recorder'/ 
     .       '10 - VLBA  rack + DFC2100 recorder'/ 
     .       '11 - Mk3/4 rack + DFC1100 recorder'/ 
     .       '12 - Mk3/4 rack + DFC2100 recorder'/ 
     .       ' 0 - QUIT '/' ? ',$)

        read(luusr,*) ikin
	IF (ikin.EQ.0) RETURN
        IF (ikin.LT.1.OR.ikin.GT.12) GOTO 1
      endif
      iktype = ikin
      return
      end
