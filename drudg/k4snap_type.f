	SUBROUTINE k4snap_type(cr1,iktype)

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

C LAST MODIFIED:
C 990113 nrv New. Copied from k4proc_type

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

9019    FORMAT(' Select type of K4 recorder for ',4a2/
     .       ' 1 - DFC2100 recorder'/ 
     .       ' 2 - other K3 or K4 recorder'/ 
     .       ' 0 - QUIT '/' ? ',$)

        read(luusr,*) ikin
	IF (ikin.EQ.0) RETURN
        IF (ikin.LT.1.OR.ikin.GT.2) GOTO 1
      endif
      iktype = ikin
      return
      end
