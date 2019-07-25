      Subroutine getstr(instring,ix,outstring)
C     Scans "instring" and returns the next blank-delimited field
C     as "outstring".  Similar to LNFCH's GTFLD.
C   Input:
      character*128 instring
      integer ix ! which character to start with in instring
C       NOTE: the value of ix is CHANGED by this routine
C   Output:
      character*128 outstring
C     ix  ! index of next character after the end of outstring
c                   (used for subsequent scans)
C
      outstring=''
      i=ix
      do while (index(instring(i:),' ').ne.1)
        i=i+1
      enddo
      i1=i
      ix=index(instring(i1:),' ')
      if (ix.eq.0) ix=len(instring)+1
      outstring=instring(i1:ix-1)
      return
      end
