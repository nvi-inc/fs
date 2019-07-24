      subroutine set_vlt(ihead,volt,ip,tol)
      implicit none
      integer ihead,ip(5)
      real*4 volt(2),tol
C
C  SET_VLT: set head(s) to (a) particular voltage(s)
C
C  INPUT:
C     IHEAD: head number to move: 1, 2, or 3 (both)
C     VOLT: voltage to set the head(s) to
C
C  OUTPUT:
C     IP: Field System return parameters
C       IP(3) = 0 if no error
C
      if(ihead.eq.3) then
        call head_vlt(2,0.0,ip,1498.5) !1498.5 ~= 9.9902*150
        if(ip(3).ne.0) return
        call head_vlt(1,0.0,ip,1498.5) !1498.5 ~= 9.9902*150
        if(ip(3).ne.0) return
      endif
C
      if(ihead.ne.1) then
        call head_vlt(2,volt(2),ip,tol)
        if(ip(3).ne.0) return
      endif
C
      if(ihead.ne.2) then
        call head_vlt(1,volt(1),ip,tol)
        if(ip(3).ne.0) return
      endif
C
      return
      end
