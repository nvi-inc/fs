       integer function ichcm_ch(ar,ifc,string)
       implicit none
       integer ifc
! AEM 20050111 int->int*2
       integer*2 ar(*)
       character*(*) string
C
C ichcm_ch: compare to hollerith and string
C
C Input:
C       AR:     array holding hollerith string
C       IFC:    first character to use in AR
C       string: variable holding string
C
C Output:
C        ichcm_ch: zero if the two string match
C               +/- index of first character to not match
C                   1 <= ABS(ichcm_ch) <= NCHAR in this case
C               + value if character in AR < character in string
C               - value if character in AR > character in string
C
      integer nchar,i,i2
! AEM 20050111 char->char*1
      character*1 cjchar,ch1,ch2
C
      if (ifc.le.0) then
        write(6,*) ' ichcm_ch: Illegal arguments',IFC
        stop
      endif
C
      nchar = len(string)
      if (nchar.eq.0) then
        ichcm_ch = 0
        return
      endif
C
      ichcm_ch = 0
      do i=0,nchar-1
        ch1 = cjchar(ar,ifc+i)
        i2 = i+1
        ch2 = string(i2:i2)
        if (ch1.ne.ch2) then
          ichcm_ch = i+1
!          if (nchar.lt.i) ichcm_ch = -ichcm_ch
! AEM 20050111 incorrect: comparing other values than should be
          if (ch2.lt.ch1) ichcm_ch = -ichcm_ch
          return
        endif
      enddo
C
! AEM 20050111 commented return
!      return
      end
