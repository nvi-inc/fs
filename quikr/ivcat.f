      function ivcat(ivc,it,itn,irep) 
C 
C  INPUT: 
C     IVC - VC #
C     ITN - track counter (not used if IREP=-1) 
C 
C  OUTPUT:
C     IT - array with tracks
C     ITN - updated for next track
C 
      include '../include/fscom.i'
C 
      dimension it(1),inum(5) 
      data inum/1,2,2,28,4/ 
C 
      ivcat = 1 
      call fs_get_imodfm(imodfm)
      nmod = inum(imodfm+1) 
      if (irep.eq.3) nmod = 1 
      is = 0
      itrem = itn 
      do 110 i = 1,nmod 
          ichk = ivc2t(ivc,is)
          if (ichk.eq.0) goto 120 
          if (irep.eq.-1) then
            it(ichk) = 100
          else
            it (itn) = ichk 
            if (i.ne.nmod) itn = itn+1
          end if
          is = ichk+1 
110       continue
      return
120   if (is.eq.0) ivcat = 0
      if (is.ne.0.and.irep.ne.-1) itn = itn-1 
      return
      end 
