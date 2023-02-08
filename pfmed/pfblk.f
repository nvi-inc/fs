*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine pfblk(kblk,lp,lfr)
C
C 1.  PFBLK PROGRAM SPECIFICATION
C
C 1.1.   PFBLK interfaces PFMED with BOSS using a resource number.
C        When PFMED is ready to read or alter a file, PFMED is called to
C        lock the status of the procedure files.  If there is a second copy,
C        PFBLK returns the correct file name for reading.
C
C 1.2.   RESTRICTIONS - Only procedure libraries are accessible.  These have
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
C                - target procedure library (without extension)
      character*(*) lfr
C                - correct extension with leading dot for reading
      character*64 fname,link
C
C 2.2.   COMMON BLOCKS USED:
C
C
      include '../include/fscom.i'
      include 'pfmed.i'
C
C        LPRC2   - current schedule procedure library
C        LNEWSK2 - flag for 2nd copy of schedule procedure library
C                  (<>0 if copy exists)
C        LNEWPR2 - flag for 2nd copy of station procedure library
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
      call fs_get_lnewpr2(ilnewpr2)
      call hol2char(ilnewpr2,1,MAX_SKD,lnewpr2)
      call fs_get_lnewsk2(ilnewsk2)
      call hol2char(ilnewsk2,1,MAX_SKD,lnewsk2)
      if ((lp.ne.lnewsk2.and.lp.ne.lnewpr2).or.(.not.kboss_pf)) then
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
C     Replacing procedure library.
300   continue
C     Set name.
C     If library to be replaced is not current to BOSS, purge old and rename.
      call fs_get_lnewpr2(ilnewpr2)
      call hol2char(ilnewpr2,1,MAX_SKD,lnewpr2)
      call fs_get_lnewsk2(ilnewsk2)
      call hol2char(ilnewsk2,1,MAX_SKD,lnewsk2)
      call fs_get_lprc2(ilprc2)
      call hol2char(ilprc2,1,MAX_SKD,lprc2)
      call fs_get_lstp2(ilstp2)
      call hol2char(ilstp2,1,MAX_SKD,lstp2)
      if((lp.ne.lstp2.and.lp.ne.lprc2).or.(.not.kboss_pf)) then
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
C     If library is second copy, purge old, rename, and schedule BOSS.
      else if(lp.eq.lnewsk2.or.lp.eq.lnewpr2) then
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
C     If library is current to BOSS, rename to second copy, set flag, and
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
        call fs_get_lprc2(ilprc2)
        call hol2char(ilprc2,1,MAX_SKD,lprc2)
        if(lprc2.eq.lp) lnewsk2=lp
        call char2hol(lnewsk2,ilnewsk2,1,MAX_SKD)
        call fs_set_lnewsk2(ilnewsk2)
        call char2hol(lnewsk2,ilnewsk,1,8)
        call fs_set_lnewsk(ilnewsk)
        call fs_get_lstp2(ilstp2)
        call hol2char(ilstp2,1,MAX_SKD,lstp2)
        if(lp.eq.lstp2) lnewpr2=lp
        call char2hol(lnewpr2,ilnewpr2,1,MAX_SKD)
        call fs_set_lnewpr2(ilnewpr2)
        call char2hol(lnewpr2,ilnewpr,1,8)
        call fs_set_lnewpr(ilnewpr)
        if (kboss_pf) knewpf = .true.
      endif
      return
      end
