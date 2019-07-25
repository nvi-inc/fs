      integer function fblnk(ibuf,ifc,ilc)
c
      implicit none
cxx      integer ibuf(1)
      integer*2 ibuf(1)
      integer ifc,ilc
      integer i,inext,ilen,ichmv,ichcm_ch,ichmv_ch
      logical kfirst
c
      fblnk=0
      ilen = ilc-ifc+1
      if (ilen.le.0) then
        return
      endif
c
c delete leading blanks
c
      inext=ifc
      kfirst=.false.
      do i = ifc,ilc
        if(ichcm_ch(ibuf,i,' ').ne.0.or.kfirst) then
          kfirst=.true.
          inext=ichmv(ibuf,inext,ibuf,i,1)
        endif
      end do
c
C   return the length of array minus what was taken off.
c
      fblnk = inext-ifc
C
C  BLANK PAD TO THE END
c
      do while(inext.le.ilc)
        inext=ichmv_ch(ibuf,inext,'  ')
      enddo
      return
      end
