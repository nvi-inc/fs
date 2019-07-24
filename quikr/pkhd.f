      subroutine pkhd(hd,icount,nsamp,odev,vltpos,peakv,mper,ip,echo,lu,
     &                kpeak,pmin)
      integer hd,icount,nsamp,odev,ip(5),lu
      real*4 vltpos,peakv,mper,pmin
      logical echo,kpeak
C
C  PKHD: Peak High Density Head
C
C  INPUT:
C     HD: Head to move for peaking, 1 or 2
C     ICOUNT: NUMBER OF TIMES TO PEAK
C     NSAMP: Samples to make for each power measurement, positive
C     ODEV: Channel to monitor power of, odd or even
C     PMIN: minimum power to accepted as a good peak
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
      integer ipass(2),ioff(2),i,imax,imin,j,step
      real*4 micnow(2),micold,volts,minper,pos(3),pwr(3),m1,m2,b1,b2
      real*4 micpk,temp,lvsig,lvavg,lvsum,lvsum2,wide,pwrpk
      logical kwide
      data ipass/2*0/,ioff/8,-8/
C
      do j=1,icount
C
C  get power and current location
C
      call mic_read(hd,ipass,micnow,ip)
      if(ip(3).ne.0) return
C
      call get_power(odev,nsamp,volts,minper,ip)
      if(ip(3).ne.0) return
C
      pos(2)=0.0
      micold=micnow(hd)
      pwr(2)=volts
      if(echo) then
        write(lu,91) micnow(hd),volts,minper
91      format(3f10.3)
      endif
C
C  now try to bracket peak, take two more samples
C  go off IOFF(1), if power is lower there,
C                     then next point is in the oppisite direction
C                  if power is higher there,
C                     then next point is in the same direction
C                     and rearrange the values in memory
C
      do i=1,2
        step=ioff(i)
        micnow(hd)=micold+step
        if(i.eq.2.and.pwr(1).gt.pwr(2)) then
          step=ioff(1)
          micnow(hd)=micold+2*step
          temp=pwr(1)
          pwr(1)=pwr(2)
          pwr(2)=temp
          temp=pos(1)
          pos(1)=pos(2)
          pos(2)=temp
        endif
C
        call set_mic(hd,ipass,micnow,ip,2.7)
        if(ip(3).ne.0) return
C
        call mic_read(hd,ipass,micnow,ip)
        if(ip(3).ne.0) return
C
        call get_power(odev,nsamp,volts,minper,ip)
        if(ip(3).ne.0) return
C
        pos(2*(i-1)+1)=micnow(hd)-micold
        pwr(2*(i-1)+1)=volts
        if(echo) then
          write(lu,91) micnow(hd),volts,minper
        endif
      enddo
C
C HAVE WE should have braketted the peak, but if not search on:
C
      i=0
      do while(pwr(3).gt.pwr(2).and.i.le.abs(40/step))
        i=i+1
        pwr(1)=pwr(2)
        pos(1)=pos(2)
        pwr(2)=pwr(3)
        pos(2)=pos(3)
        micnow(hd)=micold+(2+i)*step
C
        call set_mic(hd,ipass,micnow,ip,2.7)
        if(ip(3).ne.0) return
C
        call mic_read(hd,ipass,micnow,ip)
        if(ip(3).ne.0) return
C
        call get_power(odev,nsamp,volts,minper,ip)
        if(ip(3).ne.0) return
C
        pos(3)=micnow(hd)-micold
        pwr(3)=volts
        if(echo) then
          write(lu,91) micnow(hd),volts,minper
        endif
      enddo
C
C Now we estimate the peak location, assuming noiseless (ha, ha) data.
C Using the response model mentioned above, the lower of the two
C outside points and the center point should be on the same line.
C We get that line's slope and intercept. Then assume the other outside
C point is on the other line (it might not be, but we'll worry about it
C latter) and gets its slope, negative of the first by assumption, and
C intercept. Then find the peak posiiton as the intersection of the two
C lines.
C
      m1=(pwr(1)-pwr(2))/(pos(1)-pos(2))
      m2=(pwr(3)-pwr(2))/(pos(3)-pos(2))
      imax=3
      if(abs(m2).gt.abs(m1)) imax=1
      imin=4-imax
      m1=(pwr(imin)-pwr(2))/(pos(imin)-pos(2))
      b1=pwr(imin)-m1*pos(imin)
      m2=-m1
      b2=pwr(imax)-m2*pos(imax)
      micpk=(b1-b2)/(m2-m1)
      pwrpk=(m2*b1-m1*b2)/(m2-m1)
C
C Now, what can go wrong: (I) The power (measured) at point 1 is garunteed
C to have less power than point (2). Suppose point (1) and point (2)
C actually should be reversed, this would imply that the two points
C are actually at about the same response on opposite sides of the peak .
C (at least to the level of measurement noise). Then the third point
C will be down a long way, assuming the step size times the response
C slope is large compared to the noise. Which will give a reasonable
C estimate of the slope and the larger outside point WILL lie on the second
C line.
C (II) Suppose the larger outside point is not on the second line, actually
C all three points are on the same line. The intersection will occur at the
C third point. Suppose the third point lies above or below the first
C line, i.e. the lines should be collinear, but the third point is
C noisy, then this algorithm would treat it as two distinct lines.
C If the larger outside point is below the line, the algorihtm
C will estimate a peak near the larger outside points, but interior
C to the endpoints. If it's above the line the intersction will lie
C somewhere outside the intersection, in fact maybe a long way, so we
C will simple require that the "peak" must be on the interval defined by
C the endpoints.  This at least puts us closer to the peak than we were
C before.
C (III) Suppose the response curve is flat in this area. Then there is
C no information to look for a peak with.  Since we can't predict a prior
C what a responable slope should be, limiting the peak position to within
C the endpoints saves us from shooting off aimlessly.
C
      micpk=max(micpk,min(pos(1),pos(2),pos(3)))
      micpk=min(micpk,max(pos(1),pos(2),pos(3)))
      micpk=micpk+micold
C
      micnow(hd)=micpk
C
C Get the voltage position and power at the estimated peak slope
C
      call set_mic(hd,ipass,micnow,ip,0.40)
      if(ip(3).ne.0) return
      if(echo.or.j.eq.icount) then
        call get_atod(hd,vltpos,ip)
        if(ip(3).ne.0) return
C
        call get_power(odev,nsamp,peakv,mper,ip)
        if(ip(3).ne.0) return
C
        kpeak=abs(micpk-(pos(2)+micold)).lt.5.4.and.peakv.ge.pmin
        if(echo) write(lu,99) micnow(hd),vltpos,peakv,mper,kpeak,pwrpk
99      format(" ",4f10.3,l7,f10.3)
      endif
      enddo
C
      end
