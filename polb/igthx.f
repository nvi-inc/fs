      integer function igthx(jbuf,ifc,ilc,ifield,iferr)

      integer*2 jbuf(1)

      igthx=0

      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if(ic1.le.0.or.ic2-ic1+1.gt.8) then
         iferr=-ifield
         return
      endif

      do i=ic1,ic2
         iv=ia2hx(jbuf,i)
         if(iv.lt.0) then
            iferr=-ifield
            return
         endif
         igthx=iv+ishft(igthx,4)
      enddo

      return
      end
