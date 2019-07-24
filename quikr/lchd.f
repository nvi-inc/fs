      subroutine lchd(hd,step,nsamp,rng,odev,vltpos,peakv,mper,ip,echo,
     &                lu)
      implicit none
      integer hd,odev,ip(5),lu,nsamp
      real*4 vltpos,peakv,mper,step,pmax,vmax,rng
      logical echo
C
C  PKHD: Peak High Density Head
C
C  INPUT:
C     HD: Head to move for peaking, 1 or 2
C     ICOUNT: NUMBER OF TIMES TO PEAK
C     NSAMP: Samples to make for each power measurement, positive
C     ODEV: Channel to monitor power of, odd or even
C
C  OUTPUT:
C     VLTPOS: Voltage of peak response poistion
C     PEAKV: Peak power voltage
C     MPER: lowest sample at peak as a percentage of peak
C     IP: Field System return parameters
C
C  The model of power response is two lines with slopes of the
C  same absolute value, but oppisite sign.  The peak response is at
C  the intersection of the two lines.
C
      integer ipass(2),ichcm_ch
      real*4 micnow(2),micold,volts,minper,pnow,ru,rl,rmper
      data ipass/2*0/
C
C  get power and current location
C
      call mic_read(hd,ipass,micnow,ip)
      if(ip(3).ne.0) return
C
      rl=micnow(hd)-rng
      ru=micnow(hd)+rng
C
91    format(3f10.3)
C
C  now GO IN STEPS UNTIL WE STOP ADVANCING
C
      vmax=-20.0
      pmax=micnow(hd)
      rmper=0.0
C
      do pnow=rl,ru,step
        micnow(hd)=pnow
c
c set the position, if we get stuck go to the highest peak
c
        call set_mic(hd,ipass,micnow,ip,5.0)
        if(ip(3).eq.-407.and.ichcm_ch(ip(4),1,'q@').eq.0) goto 100
        if(ip(3).ne.0) return
C
        call mic_read(hd,ipass,micnow,ip)
        if(ip(3).ne.0) return
C
        call get_power(odev,nsamp,volts,minper,ip)
        if(ip(3).ne.0) return
C
        if(volts.gt.vmax) then
          pmax=micnow(hd)
          vmax=volts
          rmper=minper
        endif
        if(echo) then
          write(lu,91) micnow(hd),volts,minper
        endif
      enddo
C
100   continue
      ip(3)=0
      micnow(hd)=pmax
      call set_mic(hd,ipass,micnow,ip,0.40)
      if(ip(3).ne.0) return
C
      call get_atod(hd,vltpos,ip)
      if(ip(3).ne.0) return
C
      peakv=vmax
      mper=rmper
C
      end
