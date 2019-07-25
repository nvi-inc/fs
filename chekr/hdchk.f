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
      dimension ip(5)             ! - for RMPAR
      dimension poffx(2),pnow(2)
      real*4 scale,volt           ! - for Head Position Read-out
      integer inerr
      integer rn_take
C
C  INITIALIZED:
C
      ierr=rn_take('fsctl',0)
      call lvdonn('lock',ip)
      if (ip(3).ne.0) then
        call logit7ic(0,0,0,0,ip(3),lwho,'hd')
        goto 1091
      endif
      call fs_get_ipashd(ipashd)
      do ihd=1,2
        if(kposhd_fs(ihd)) then
          inerr = 0
          call vlt_head(ihd,volt,ip)
          if (ip(3).ne.0) then
            call logit7ic(0,0,0,0,ip(3),lwho,'hd')
            goto 1091
          endif
          call vlt2mic(ihd,ipashd(ihd),kautohd_fs,volt,pnow(ihd),ip)
          if (ip(3).ne.0) then
            call logit7ic(0,0,0,0,ip(3),lwho,'hd')
            goto 1091
          endif
          poffx(ihd) = pnow(ihd) - posnhd(ihd)
          if(volt.lt.-0.010) then
            scale=rslope(ihd)
          else if(volt.gt.0.010)then
            scale=pslope(ihd)
          else
            scale=max(pslope(ihd),rslope(ihd))
          endif
          if (abs(poffx(ihd)).gt.((ilvtl_fs+2)*0.0049+0.0026)*scale)
     &        inerr = inerr+1
          call fs_get_icheck(icheck(20),20)
          if(icheck(20).gt.0.and.ichecks(20).eq.icheck(20)) then
            if (inerr.ge.1) call logit7ic(0,0,0,0,-350-ihd,lwho,'hd')
          endif
        endif
      enddo
C
C  Turn off LVDT Oscillator
C
1091  continue
      call lvdofn('unlock',ip)
      call rn_put('fsctl')
      if (ip(3).lt.0) then
        call logit7ic(0,0,0,0,ip(3),lwho,'hd')
      endif
C
      return
      end
