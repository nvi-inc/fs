*
* Copyright (c) 2020, 2023, 2025  NVI, Inc.
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
      subroutine ffm(lui,luo,ib,ichi,lproc,lprc,lstp,lnewsk,lnewpr)
C
C 1.  FFM PROGRAM SPECIFICATION
C
C 1.1.   FFM is a simplified FMGR for use with the Mark III field system.
C        There are two sets of commands available.  Commands with the
C        prefix PF (PF, PFCR, PFDL, PFPU, PFRN, PFST) apply to procedure
C        libraries as disk file units.
C
C 1.2.   RESTRICTIONS - Only procedure libraries are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  FFM INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL FFM(LUI,LUO,IB,ICHI,LPROC,LSTP,LNEWSK,LNEWPR)
C
C     INPUT VARIABLES:
C
C        LUI,LUO - input, output LU's
      character*(*) ib
C               - line and record buffer
C        ICHI   - number of characters from keyboard
      character*(*) lproc,lnewsk,lnewpr,lstp,lprc
C               - procedure library active in PFMED
C               - 2nd copy of schedule procedure library
C               - 2nd copy of station procedure library
C               - Field System station procedure library
C               - Field System schedule procedure library
C
C 2.2.   COMMON BLOCKS USED:
C
      include '../include/params.i'
      include 'pfmed.i'
C
C 2.3.   DATA BASE ACCESSES: none
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     INPUT VARIABLES: none
C
C     OUTPUT VARIABLES:
C
C     TERMINAL   - error message
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: PFMED
C
C     CALLED SUBROUTINES: FMP routines, ICHMV, IB2AS, ISCN_CH,
C                         IDTYP, IFILL, MIN0, PFBLK, PFCOP
C
C 3.  LOCAL VARIABLES
C
      character*(MAX_SKD) lnam1,lnam2
C               - procedure library names without extensions
      character*4 lfr
C               - procedure library extension with leading '.'
C        IR     - record count
C        IERR   - error flag
C        LEN    - record length
C        IDTK   - starting directory track of procedure LU
C        JT, JS, JO - track, sector, offset of procedure file entry
C        JX     - extent of procedure file
C
      integer ierr
      character*512 ibc
      character*80 dirstr
      character*64 pathname,pathname2,link
      integer trimlen
      integer iret
      character*(MAX_SKD) sl1,sl2,sl4
      character*40 cmessage
      logical kex,kest,kerr
      character*3 me
      logical kactive
C 4.  CONSTANTS USED
C
      data me/'ffm'/
      data dirstr/' '/
C 5.  INITIALIZED VARIABLES: none
C
C 6.  PROGRAMMER: C. Ma
C     LAST MODIFIED: <910323.2042>
c
C PB 010904 Mod. from J. Quick for .prc fix.   
C
C     PROGRAM STRUCTURE
C
C     Initialize and parse names.
      lnam1 = ' '
      lnam2 = ' '
C     Search for commas.
      ic1 = index(ib(1:ichi),',')
C     No commas means no names.
      if(ic1.ne.0) then
c  Index returns the location of the substring (,) within the string (ib)
        ic2=index(ib(ic1+1:ichi),',')
        ic2 = ic2 + ic1
        if(ic2.eq.ic1) ic2=ichi+1
c      if no comma was found, let ic2 be past the end of ib
C     Move first name to buffer with initialized prefix.
        nch1 = ic2-ic1-1
        if (nch1.le.0) then
          write(lui,1101)
1101      format(" no procedure library given")
          return
        else 
          if ((nch1.gt.4).and.(ib(ic1+nch1-3:ic1+nch1).eq.'.prc')) then
            nch1 = nch1-4
          end if
          ics=index(ib(ic1:ic1+nch1),' ')
          if(ics.ne.0) then
            write(lui,'(a)') 'Spaces are not allow in library names'
            return
          endif
          if (nch1.gt.len(lproc)) then
            write(lui,9100) len(lproc)
9100        format(" library names must be",i3," characters or less")
            return
          end if
         end if
        lnam1 = ib(ic1+1:ic1+nch1)
C     Move second name if present.
        if (ichi.gt.ic2) then
          nch2 = ichi-ic2
          if ((nch2.gt.4).and.(ib(ic2+nch2-3:ic2+nch2).eq.'.prc')) then
            nch2 = nch2-4
          end if
          ics=index(ib(ic2:ic2+nch2),' ')
          if(ics.ne.0) then
            write(lui,'(a)') 'Spaces are not allow in library names'
            return
          endif
          if (nch2.gt.len(lnam2)) then
            write(lui,9100) len(lnam2)
            return
           end if
          lnam2 = ib(ic2+1:ic2+nch2)
        end if
      endif
      if(ib(3:4).eq.'pu'.or.ib(3:4).eq.'rn') then
         pathname = '/usr2/proc/' // lnam1(1:nch1) // '.prc'
         call ftn_rw_perm(pathname,iperm,ierr)
         if(ierr.ne.0) then
            write(6,*) 'ffm: error checking file permissions: '//
     &           pathname(:max(1,trimlen(pathname)))
            goto 920
         else if(iperm.eq.0) then
            write(6,*) 'This command is not permitted because you ',
     &           'don''t have sufficent permission for'
            write(6,*) 'file ',pathname(:max(1,trimlen(pathname)))
            goto 920
         endif
      endif
  
C     PFCR - create new procedure library.
  
      if(ib(3:4).eq.'cr') then
        if (lnam1.eq.' ') then
          write(lui,1102)
1102      format(" syntax error")
          goto 920
        end if
        pathname = '/usr2/proc/' // lnam1(1:nch1) // '.prc'
C  check to see if target exists already 
        inquire (FILE=pathname,EXIST=kest)
        if(kest) then
          inch=trimlen(pathname)
          write(lui,1113) pathname(:inch)
          goto 920
        end if
        call fopen(idcb1,pathname,ierr)
        if(ierr.lt.0) then
          goto 800
        else
          goto 900
        endif
      endif
 
C     PFDL - list directory of procedure libraries
  
      if(ib(3:4).eq.'dl') then
c  Have the OS issue directory command and send the results to file, FFMTMP
        call ftn_runprog('ls /usr2/proc > /usr2/proc/ffmtmp',ierr)
        if(kerr(ierr,me,'running',' ',0,0)) return
        open(unit=77,file='/usr2/proc/ffmtmp',
     .  status='old',iostat=ierr)
        if(ierr.ne.0) then
          write(lui,7000)ierr
7000      format(' error = ',i5,' when attempting to open ffmtmp.')
          return
        endif
        sl1 = lproc
        sl2 = lstp
        sl4 = lprc
        ix=3
        ibc = ' '
c  Top of "]PRC" filename get loop.
        do while (.true.)
          read(77,7700,end=208) dirstr
7700      format(a80)
          ipos = 1
            ipos=0
            do while (ipos.le.80)
              ipos = ipos + 1
              if (dirstr(ipos:ipos).eq.'.') then 
                goto 1201
              endif
            enddo
1201        continue
c  Are there any filenames left?
            if(dirstr(ipos+1:ipos+4).eq.'prc') then
            ibc(ix:ix+ipos-1) = dirstr(1:ipos-1)
C Add ">" for active in pfmed, "S" for station procedure library in FS
C  "A" for schedule procedure library in FS
              ix2=ix+len(lproc)-1
              if(kboss_pf) then
                if(ibc(ix:ix2).eq.sl2) ibc(ix-1:ix-1) = 'S'
                if(ibc(ix:ix2).eq.sl4) ibc(ix-1:ix-1) = 'A'
                if(ibc(ix:ix2).eq.sl1) then
                  if ((sl1.eq.sl2.or.sl1.eq.sl4)) then
                    ibc(ix-2:ix-2) = '>'
                  else
                    ibc(ix-1:ix-1) = '>'
                  endif
                endif
              else if(ibc(ix:ix2).eq.sl1) then
                ibc(ix-1:ix-1) = '>'
              endif
c space over past that name
              ix=ix+MAX_SKD+4
              if (ix.gt.80-MAX_SKD) then
                nch = trimlen(ibc)
                if (nch.gt.0) write(luo,7701) ibc(:nch)
                ix = 3
                ibc = ' '
              endif
              ipos = ipos+12
            endif
        enddo !while .true.
208     close(unit=77)
        call ftn_purge('/usr2/proc/ffmtmp',ierr)
        if(kerr(ierr,me,'purging',' ',0,0)) return
        if(ix.gt.2) then
          nch = trimlen(ibc)
          if (nch.gt.0) write(luo,7701) ibc(:nch)
7701      format(a)
        end if
        write(6,"(a)")
     .    "Key: '>' active in pfmed, 'A' schedule, 'S' station"
        return
      endif
  
C     PF - change procedure library active in PFMED.
  
      if(ib(3:3).eq.',') then
        if(lnam1.ne.' ') then
          call pfcop(lnam1,lui,iret)
          if (iret.ge.0) lproc = lnam1
          return
        else
          write(lui,1105)
1105      format(" syntax error")
          return
        end if
      end if
  
C     PFPU - purge procedure library.
  
      if(ib(3:4).eq.'pu') then
        if (lnam1.eq.' ') then
          write(lui,1106)
1106      format(" syntax error")
          return
        end if
        call fclose(idcb1,ierr)
        if (ierr.lt.0) goto 800
        call follow_link(lnam1(:nch1),link,ierr)
        if(ierr.ne.0) return
        if(link.ne.' ') then
           write(6,*) "can't purge a link ",lnam1(:nch1)
           return
        endif
        pathname = '/usr2/proc/' // lnam1(1:nch1) // '.prc'
        call purn(lui,lnam1,lproc,lstp,lprc,pathname,ierr)
        if (ierr.ne.0) return
        call ftn_purge(pathname,ierr)
        if(ierr.ne.0) goto 800
        return
      end if
 
C     PFRN - rename procedure library.
  
      if(ib(3:4).eq.'rn') then
        if ((lnam1.eq.' ').or.(lnam2.eq.' ')) then
          write(lui,1107)
1107      format(" syntax error")
          return
        end if
  
        if (lnam1.eq.lstp) then
          write(lui,9200)
9200      format(" cannot perform operation on current FS station "
     .           "procedure library")
          return
        endif
        if (lnam1.eq.lprc) then
          write(lui,9300)
9300      format(" cannot perform operation on current FS schedule "
     .           "procedure library")
          return
        endif
 
        pathname = '/usr2/proc/' // lnam1(1:nch1) // '.prc'
        call follow_link(lnam1(:nch1),link,ierr)
        if(ierr.ne.0) return
        if(link.ne.' ') then
           write(6,*) "can't rename a link ",lnam1(:nch1)
           return
        endif
        inquire(file=pathname,exist=kex)
        if (.not.kex) then
          nch=trimlen(pathname)
          write(lui,1108) pathname(:nch)
1108      format(" ffm file ",a," does not exist")
          return
        end if
        pathname2 = '/usr2/proc/' // lnam2(1:nch2) // '.prc'
        inquire(file=pathname2,exist=kex)
        if (kex) then
          nch = nch2 + 12
          write(lui,1109) pathname2(:nch)
1109      format(" file ",a," already exists")
          return
        end if
        call fclose(idcb3,ierr)
        call ftn_rename(pathname,ierr1,pathname2,ierr2)
        if ((id.ne.0).or.((ierr1.ne.0).or.(ierr2.ne.0))) then
          write(lui,1110)
1110      format(" error renaming files")
          return
        end if
        if (lnam1.eq.lproc) lproc=lnam2
        call pfcop(lproc,lui,id)
        goto 920
      end if
  
C     PFST - transfer from existing library to library created by this command.
  
      if(ib(3:4).eq.'st') then
        kest = .false.
        if ((lnam1.eq.' ').or.(lnam2.eq.' ')) then
          write(lui,1111)
1111      format(" syntax error")
          return
        end if
C     Open file.
        call pfblk(1,lnam1,lfr)
        pathname ='/usr2/proc/' // lnam1(1:nch1) // lfr(1:4)
        inquire (FILE=pathname,EXIST=kest)
        if(.not.kest) then
          inch=trimlen(pathname)
          write(lui,1112) pathname(:inch)
1112      format(" error, file ",a," doesn't exist")
          goto 920
        end if
        kactive=lnam1.eq.lproc
        if(kactive) then
C
C close the active library if it is the one being copied from because
C gfortran doesn't allow a file to be opened on more than one unit
C
            call fclose(idcb3,ierr)
            if(kerr(ierr,'ffmp','closing',pathname,0,0)) return
        endif
        call fopen(idcb1,pathname,ierr)
        if(ierr.lt.0) then
          write(lui,1114) pathname
          goto 920
        end if
C     Create new file.
        pathname2 = '/usr2/proc/' // lnam2(1:nch2) // '.prc'
C  check to see if target exists already to avoid overwriting it
C   by mistake
        inquire (FILE=pathname2,EXIST=kest)
        if(kest) then
          inch=trimlen(pathname2)
          write(lui,1113) pathname2(:inch)
1113      format(" error, file ",a," already exists")
          goto 900
        end if
        call fopen(idcb2,pathname2,ierr)
        if(ierr.lt.0) then
          write(lui,1114) pathname2
1114      format(" error opening file ",a)
          goto 920
        end if
        do 710 ir=1,32767
          call f_readstring(idcb1,ierr,ibc,llen)
          if(ierr.lt.0.or.llen.lt.0) goto 720
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
          if(ierr.lt.0) goto 800
710     continue
720     call pfblk(2,lnam1,lfr)
        call fclose(idcb2,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        if(kactive) then
C has to be reopened if it was closed above
            call fopen(idcb3,pathname,ierr)
            if(kerr(ierr,'ffmp','opening',pathname,0,0)) return
        endif
        goto 920
      end if
  
C     Bad command
      write(lui,1115)
1115  format(" bad command")
      return
C     FMP error condition.
c800   call fmperror(ierr,cmessage)
800   write(lui,2101) cmessage
2101  format(a)
  
900   call fclose(idcb1,ierr)
  
920   return
      end
