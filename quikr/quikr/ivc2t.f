      function ivc2t(ivc,is)
C   finds track given vc#870115:04:51   # 
C 
C     Given a VC number as input, IVC2T finds the tracks
C     associated with that VC, and checks which one has 
C     phase cal., by calling PHCAL
C     INPUT:
C       IVC - VC number 
C 
C     OUTPUT: 
C       IVC2T - track number with phase cal 
C 
C     LOCAL:
      double precision pcal 
      include '../include/fscom.i'
C 
      ist = is
      if (ist.eq.0) ist = 1 
      call fs_get_imodfm(imodfm)
      do 100 i = ist,28 
          if (ivc.ne.iabs(itr2vc(i,imodfm+1))) goto 100 
          call phcal(pcal,i,iv) 
          if (pcal.le.50000.) goto 980
100       continue
      ivc2t = 0 
      return
980   ivc2t = i 
      end 
