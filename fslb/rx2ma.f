      subroutine rx2ma(ibuf,ical,iheat,idcal,ibox,ifamp,iad)

C  convert rx data to mat buffer c#870115:04:54#  
C 
C     RX2MA converts data for the receiver to an MAT buffer.
C 
C  INPUT: 
C 
C     IBUF - buffer to use
C     ICAL - the cal switch, on or off
C     IHEAT - transition bit
C     IDCAL, IBOX - dcal, box heat switches 
      dimension ifamp(3)  
C     - IF amp switches 
C     IAD - channel for A/D 
      integer*2 ibuf(1),iad,iado
C 
C     The buffer is set up as follows:
C                       00dc0ahn
C     where each letter represents a character (half word). 
C                   00 = these bits unused
C                   d = top bit of A/D and 2 bits noise control 
C                   c = lower 4 bits of A/D channel
C                   a = amplifier control
C                   h = heater control
C                   n = noise cal control
C
      call ifill_ch(ibuf,1,8,'0')
C                   Fill the whole thing with zeros first
C     First, set up noise source
      if (ical.eq.0) call ichmv(ibuf,8,2H02,2,1)
C                                          OFF
      if (ical.eq.2) call ichmv(ibuf,8,2H04,2,1)
C                                          EXT
      if (ical.eq.1) call ichmv(ibuf,8,2H01,2,1)
C                                        ON
C     Heater control
      ia = 0
      if (ibox.eq.-1) call sbit(ia,2,1)
C                                    BON
      if (ibox.eq. 0) call sbit(ia,1,1)
C                                    OFF
      if (idcal.eq. 0) call sbit(ia,3,1)
C                                    OFF
      if (iheat.eq.1) call sbit(ia,4,1)
      call ichmv(ibuf,7,ihx2a(ia),2,1)
C                    Convert to ASCII and put in buffer
C     IF amplifier switches
      ia = 0
      if (ifamp(1).eq.0) call sbit(ia,3,1)
      if (ifamp(2).eq.0) call sbit(ia,2,1)
      if (ifamp(3).eq.0) call sbit(ia,1,1)
      call ichmv(ibuf,6,ihx2a(ia),2,1)
C     A/D address AND NOISE CONTROL OVERRIDE
      idum=ichmv(iado,1,iad,1,2)
      if(iad.eq.0) call char2hol('00',iado,1,2)
      if(ical.eq.-1.or.ical.eq.-2) then
        inum=ia22h(iad)
        if(ical.eq.-1) call sbit(inum,7,1)
        call sbit(inum,6,1)
        idum=ichmv(iado,1,ih22a(inum),1,2)
      endif
      idum=ichmv(ibuf,3,iado,1,2)
C
      return
      end
