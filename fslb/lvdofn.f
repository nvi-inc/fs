      subroutine lvdofn(lock,ip)

      character*(*) lock
      integer ip(5)
C
C  LVDOFN: turn LVDT off
C
C  INPUT:
C    LOCK: if 'LOCK' then lock the LVDT RN before accessing LVDT
C          if 'UNLOCK' then unlock the LVDT RN after accessing LVDT
C
C  OUTPUT:
C     IP - Field System return parameters
C     IP(3) - 0 if no error
C
      include '../include/fscom.i'
C
      integer*2 ibuf(6)
      integer iclass, nrec, rn_take
C
      if(lock.eq.'lock') then
        istat = rn_take('lvdt ',0)
        if (istat.eq.1) then
          ip(3)=-408
          call char2hol('q@',ip(4),1,2)
          return
        endif
      endif
C
      call fs_get_drive(drive)
      if(VLBA.eq.and(drive,VLBA)) then
        call fc_lvdofn_v(ip)
      else 
        nrec=0
        iclass=0
C
        ibuf(1)=0
        call char2hol('hd',ibuf(2),1,2)
        call ad2ma(ibuf(3),1,0,1)
        call add_class(ibuf,-12,iclass,nrec)
C
C   SEND STROBE
C
        ibuf(1)=5
        call char2hol('% ',ibuf(2),1,2)
        call add_class(ibuf,-3,iclass,nrec)
        klvdt_fs=.false.
        call fs_set_klvdt_fs(klvdt_fs)
C
C   Now schedule MATCN
C
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        call clrcl(ip(1))
        ip(2)=0
      endif
C
      if (lock.eq.'unlock'.or.ip(3).ne.0) then
        call rn_put('lvdt ')
      endif
C
      return
      end
