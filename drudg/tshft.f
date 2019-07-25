C
      SUBROUTINE TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,ISSHFT,IMSHFT,
     .                 IHSHFT,IDSHFT)!DECODE AND SHIFT
C
C  SKSHF decodes date/time from schedule and adds sidereal shift.
C
C  CALLING PROGRAM: SKSHF
C
	integer*2 ITIM(6)
c        DIMENSION ITIM(6)
C ADDED 900720
	INTEGER Z4202,Z4203
	DATA Z4202/Z'4202'/, Z4203/Z'4203'/
C 910917 NRV Changed logic for going over new year, because the
C            new year starts with day 1, not day 0
C 931123 nrv Seemed to have gotten going over the new year wrong.
C            Remove the "+1" from the MOD calculation but leave
C            the ".gt.". (The +1 may have gone with a .ge.)
C
C  1.0  Decode date/time from buffer.
C
      IYR = IAS2B(ITIM,1,2) + 1900
      ISDAY = IAS2B(ITIM,3,3)
      ISHR = IAS2B(ITIM,6,2)
      ISMIN = IAS2B(ITIM,8,2)
      ISSEC = IAS2B(ITIM,10,2)
C
C  2.0  Shift each field of date/time.
C
C  Get new seconds.
C 
      INSEC = ISSEC+ISSHFT
      IF(INSEC.GE.0)GOTO 200
        INSEC = INSEC+60
        ICARRY = -1 
        GO TO 201 
200   ICARRY = INSEC/60 
      INSEC = MOD(INSEC,60) 
C 
C  Get new minutes. 
C 
201   INMIN = ISMIN+IMSHFT+ICARRY 
      IF(INMIN.GE.0)GOTO 202
        INMIN = INMIN+60
        ICARRY = -1 
        GOTO 203
202   ICARRY = INMIN/60 
      INMIN = MOD(INMIN,60) 
C 
C  Get new hours. 
C 
203   INHR = ISHR+IHSHFT+ICARRY 
      IF(INHR.GE.0)GOTO 204 
        INHR = INHR+24
        ICARRY = -1 
        GO TO 205 
204   ICARRY = INHR/24
      INHR = MOD(INHR,24) 
C 
C  Get new day. 
C 
205   INDAY = ISDAY+IDSHFT+ICARRY 
      ndays = iday0(iyr,0)
      icarry = 0
      if (inday.gt.ndays) then
        ICARRY = INDAY/ndays
        INDAY = MOD(INDAY,ndays)!+1
      endif
C 
C  Get new year 
C 
      IYR = IYR + ICARRY - 1900 
C 
	NC = IB2AS(IYR,ITIM,1,Z4202)
	NC = IB2AS(INDAY,ITIM,3,Z4203)
	NC = IB2AS(INHR,ITIM,6,Z4202)
	NC = IB2AS(INMIN,ITIM,8,Z4202)
	NC = IB2AS(INSEC,ITIM,10,Z4202)
206   RETURN
      END 
