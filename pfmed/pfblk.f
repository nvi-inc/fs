      subroutine pfblk(kblk,lp,lfr)
C
C 1.  PFBLK PROGRAM SPECIFICATION
C
C 1.1.   PFBLK interfaces PFMED with BOSS using a resource number.
C        When PFMED is ready to read or alter a file, PFMED is called to
C        lock the status of the procedure files.  If there is a second copy,
C        PFBLK returns the correct file name for reading.
C
C 1.2.   RESTRICTIONS - Only procedure files are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.  The resource number must be
C        allocated by OPRIN.
C
C 1.3.   REFERENCES - Field System Manual
C
C 2.  PFBLK INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL PFBLK(KBLK,LP,LFR)
C
C     INPUT VARIABLES:
C
C        KBLK    - control flag (1 - about to read, 2 - finished reading,
C                  3 - about to replace file, 4 - error after 1 or 2)
      character*(*) lp
C                - target procedure file
      character*(*) lfr
C                - correct extent name for reading
      character*64 fname,link
C
C 2.2.   COMMON BLOCKS USED:
C
      include 'pfmed.i'
C
      include '../include/fscom.i'
C
C        LPRC    - current schedule procedure file
C        LNEWSK  - flag for 2nd copy of schedule procedure file
C                  (<>0 if copy exists)
C        LNEWPR  - flag for 2nd copy of station procedure file
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     CALLING SUBROUTINES: KCOPY, FFM, FFMP
C
C     CALLED SUBROUTINES: FMP routines
C
C 3.  LOCAL VARIABLES:
C
      logical kerr
      integer trimlen
      character*5 me
      data me/'pfblk'/
C
C  WHO  WHEN    DESCRIPTION
C  GAG  901228  Changed IPGST calls to KBOSS calls to see if BOSS is running.
C
      goto (100,200,300),kblk
C     Before reading a procedure file.
100   continue
C     If file to be read is not second copy, release lock.
      call fs_get_lnewpr(ilnewpr)
      call hol2char(ilnewpr,1,8,lnewpr)
      call fs_get_lnewsk(ilnewsk)
      call hol2char(ilnewsk,1,8,lnewsk)
      if ((lp.ne.lnewsk.and.lp.ne.lnewpr).or.(.not.kboss_pf)) then
C     Set file name for reading.
        lfr(1:4)='.prc'
      else
C     Set name to second copy for reading.
        lfr(1:4)='.prx'
      endif
      return

200   continue
C     After reading - release lock and schedule BOSS if second copy used.
      if(lfr(1:4).ne.'.prx') return
      if (kboss_pf) knewpf = .true.
      return
C
C     Replacing procedure file.
300   continue
C     Set name.
C     If file to be replaced is not current to BOSS, purge old and rename.
      call fs_get_lnewpr(ilnewpr)
      call hol2char(ilnewpr,1,8,lnewpr)
      call fs_get_lnewsk(ilnewsk)
      call hol2char(ilnewsk,1,8,lnewsk)
      call fs_get_lprc(ilprc)
      call hol2char(ilprc,1,8,lprc)
      call fs_get_lstp(ilstp)
      call hol2char(ilstp,1,8,lstp)
      if((lp.ne.lstp.and.lp.ne.lprc).or.(.not.kboss_pf)) then
        lfr(1:4)='.prc'
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        call fclose(idcb2,ierr)
        if(kerr(ierr,me,'closing',lp,0,0)) return
        if (ierr.lt.0) then
          write(lui,9100)
9100      format('pfblk - error closing file.')
        end if
        nch = trimlen(lp)
        if(nch.le.0) then
           write(6,*) 'pfblk: 1 illegal filename length',nch
           return
        else
           call follow_link(lp(:nch),link,ierr)
           if(ierr.ne.0) return
           if(link.eq.' ') then
              fname = FS_ROOT //'/proc/' // lp(:nch) // lfr(1:4)
           else
              fname = FS_ROOT //'/proc/'//link(:trimlen(link))
           endif
        endif
        call ftn_purge(fname,ierr)
        if(kerr(ierr,me,'purging',fname,0,0)) return
        call ftn_rename(lsf2,ierr1,fname,ierr2)
        if (ierr1.ne.0.or.ierr2.ne.0) then
          if(kerr(ierr1,me,'renaming',lsf2,0,0)) continue
          if(kerr(ierr2,me,'renaming',fname,0,0)) return
        end if
C     If file is second copy, purge old, rename, and schedule BOSS.
      else if(lp.eq.lnewsk.or.lp.eq.lnewpr) then
        lfr(1:4)='.prx'
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        nch = trimlen(lp)
        if(nch.le.0) then
           write(6,*) 'pfblk: 2 illegal filename length',nch
           return
        else
           call follow_link(lp(:nch),link,ierr)
           if(ierr.ne.0) return
           if(link.eq.' ') then
              fname= FS_ROOT//'/proc/' // lp(:nch) // lfr(:4)
           else
              iprc=index(link,".prc")
              link(iprc+3:iprc+3)='x'
              fname= FS_ROOT//'/proc/' // link(:trimlen(link))
           endif
        endif
        call ftn_purge(fname,ierr)
        if(kerr(ierr,me,'purging',fname,0,0)) return
        call fclose(idcb2,ierr)
        if(kerr(ierr,me,'closing',lsf2,0,0)) return
        call ftn_rename(lsf2,ierr1,fname,ierr2)
        if (ierr1.ne.0.or.ierr2.ne.0) then
          if(kerr(ierr1,me,'renaming',lsf2,0,0)) continue
          if(kerr(ierr2,me,'renaming',fname,0,0)) return
        end if
        if (kboss_pf) knewpf = .true.
C     If file is current to BOSS, rename to second copy, set flag, and
C     schedule BOSS.
      else
        lfr(1:4)='.prx'
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        nch = trimlen(lp)
        if(nch.le.0) then
           write(6,*) 'pfblk: 3 illegal filename length',nch
           return
        else
           call follow_link(lp(:nch),link,ierr)
           if(ierr.ne.0) return
           if(link.eq.' ') then
              fname= FS_ROOT//'/proc/' // lp(:nch) // lfr(:4)
           else
              iprc=index(link,".prc")
              link(iprc+3:iprc+3)='x'
              fname= FS_ROOT//'/proc/' // link(:trimlen(link))
           endif
        endif
        call ftn_purge(fname,ierr)
c       if(kerr(ierr,me,'purging',fname,0,0)) return
        call fclose(idcb2,ierr)
        if(kerr(ierr,me,'closing',lsf2,0,0)) return
        call ftn_rename(lsf2,ierr1,fname,ierr2)
        if (ierr1.ne.0.or.ierr2.ne.0) then
          if(kerr(ierr1,me,'renaming',lsf2,0,0)) continue
          if(kerr(ierr2,me,'renaming',fname,0,0)) return
        end if
        call fs_get_lprc(ilprc)
        call hol2char(ilprc,1,8,lprc)
        if(lprc.eq.lp) lnewsk=lp
        call char2hol(lnewsk,ilnewsk,1,8)
        call fs_set_lnewsk(ilnewsk)
        call fs_get_lstp(ilstp)
        call hol2char(ilstp,1,8,lstp)
        if(lp.eq.lstp) lnewpr=lp
        call char2hol(lnewpr,ilnewpr,1,8)
        call fs_set_lnewpr(ilnewpr)
        if (kboss_pf) knewpf = .true.
      endif
      return
      end
