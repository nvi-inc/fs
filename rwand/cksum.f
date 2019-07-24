      logical function cksum(bufr,nchar)
C  Check the sum of characters received from the TimeWand. 
C                                                Lloyd Rawley   March 1988
C  Input parameters:
      integer*2 bufr(1)           !  buffer received from the wand
      integer nchar             !  number of characters in buffer
      integer*2 lcrcr
      integer icompare, ichcm, ia2hx 
      integer*2 icheck, isum
      integer*2 lbyte, mbyte
C
C  Output value:  TRUE if check works, FALSE if it fails
C
C  Method:  The last five bytes of the buffer sent by the wand contain three
C           carriage returns and a two-digit hexadecimal value which should
C           be the sum of the binary values of the characters sent before
C           (other than carriage returns).
C
C  Subroutines called:  Lee Foster's character routines,
C                       HP bit manipulation routines
C
C 1. Check that last five bytes are in the form expected.
C
      lcrcr = z'0D0D'     !  (two carriage returns.)
      icompare = ichcm(lcrcr,1,bufr,nchar-4,2)
      i16 = ia2hx(bufr,nchar-2)             !  convert ascii hex to binary;
      i1  = ia2hx(bufr,nchar-1)             !  -1 returned if out of range. 
      if (i16.eq.-1 .or. i1.eq.-1 .or. icompare.ne.0) then
        cksum = .false.
        return                              !  string was probably truncated.
      endif
C
      icheck = iand((16*i16)+i1,z'FF')
C
C 2. Add up all previous bytes and compare to value obtained above.
C
      isum = 0
      nwords = (nchar-4)/2
      do i=1,nwords
        lbyte = iand(bufr(i),z'FF')
        if (lbyte.eq.z'0D') lbyte=0
        mbyte = ishft(bufr(i),-8)
        if (mbyte.eq.z'0D') mbyte=0
        isum = iand(lbyte+mbyte+isum,z'FF')
      end do

      cksum = (isum.eq.icheck)
C
      return
      end
