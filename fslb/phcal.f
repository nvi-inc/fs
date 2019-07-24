      subroutine phcal(pcal,itrk,ivc)

C   calculates phase cal freq c#870115:05:14# 
C 
C     This routine determines the phase cal freq in a video converter 
C     given the track number. 
C 
C     MAH 19820222
C 
C     INPUT:
C         ITRK - track number 
C 
C     OUTPUT: 
C         IVC - video converter number for ITRK 
      double precision pcal,sum,flo,fvc 
C         PCAL - phase cal freq in IVC
C 
      include '../include/fscom.i'
C 
      lsb = 0 
      call fs_get_imodfm(imodfm)
      ivc = itr2vc(itrk,imodfm+1) 
      if (ivc.lt.0) lsb = 1 
      ivc = iabs(ivc) 
      i1dex = iabs(ifp2vc(ivc)) 
      call fs_get_inp1if(inp1if)
      if (i1dex.eq.1) i2dex = inp1if+1
      call fs_get_inp2if(inp2if)
      if (i1dex.eq.2) i2dex = inp2if+1
      flo = freqlo(i1dex,i2dex) 
      fvc = freqvc(ivc)+5.d-3 
      fvc = fvc*100.d0
      fvc = (aint(fvc))/100.d0 
      sum = flo+fvc 
      if (lsb.eq.0) pcal = aint(sum+1.d0)-sum
      if (lsb.eq.1) then
        pcal = dmod(sum,1.d0) 
      endif
      pcal = pcal*1.d6

      return
      end 
