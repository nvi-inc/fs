      subroutine hdchk(ichecks,lwho)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer ichecks(1)
      integer*2 lwho
C 
C  SUBROUTINES CALLED:
C 
C     LOGIT - to log and display the error
C 
C  LOCAL VARIABLES: 
C 
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
      dimension ip(5)             ! - for RMPAR
      dimension poffx(2),pnow(2)
      real*4 scale,volt           ! - for Head Position Read-out
      integer inerr
C
C  INITIALIZED:
C
      call lvdonn('lock',ip)
      if (ip(3).ne.0) then
        call logit7(0,0,0,0,ip(3),lwho,2Hhd)
        goto 1091
      endif
      call fs_get_ipashd(ipashd)
      do iloop=1,2
        if(kposhd_fs(iloop)) then
          inerr = 0
          call vlt_head(iloop,volt,ip)
          if (ip(3).ne.0) then
            call logit7(0,0,0,0,ip(3),lwho,2Hhd)
            goto 1091
          endif
          call vlt2mic(iloop,ipashd(iloop),volt,pnow(iloop),ip,koff4)
          if (ip(3).ne.0) then
            call logit7(0,0,0,0,ip(3),lwho,2Hhd)
            goto 1091
          endif
          poffx(iloop) = pnow(iloop) - posnhd(iloop)
          if(volt.lt.-0.010) then
            scale=rslope(iloop)
          else if(volt.gt.0.010)then
            scale=pslope(iloop)
          else
            scale=max(pslope(iloop),rslope(iloop))
          endif
          if (abs(poffx(iloop)).gt.((ilvtl_fs+2)*0.0049+0.0026)*scale)
     &        inerr = inerr+1
          call fs_get_icheck(icheck(20),20)
          if(icheck(20).gt.0.and.ichecks(20).eq.icheck(20)) then
            if (inerr.ge.1) call logit7(0,0,0,0,-350-iloop,lwho,2Hhd)
          endif
        endif
      enddo
C
C  Turn off LVDT Oscillator
C
1091  continue
      call lvdofn('unlock',ip)
      if (ip(3).lt.0) then
        call logit7(0,0,0,0,ip(3),lwho,2Hhd)
      endif
C
      return
      end
