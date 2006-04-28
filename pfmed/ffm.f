      subroutine ffm(lui,luo,ib,ichi,lproc,lprc,lstp,lnewsk,lnewpr)
C
C 1.  FFM PROGRAM SPECIFICATION
C
C 1.1.   FFM is a simplified FMGR for use with the Mark III field system.
C        There are two sets of commands available.  Commands with the
C        prefix PF (PF, PFCR, PFDL, PFPU, PFRN, PFST) apply to procedure
C        files as disk file units.
C
C 1.2.   RESTRICTIONS - Only procedure files are accessible.  These have
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
      character*12 lproc,lnewsk,lnewpr,lstp,lprc
C               - procedure file currently active in PFMED
C               - 2nd copy of schedule procedure file
C               - 2nd copy of station procedure file
C               - station procedure library
C               - Field System procedure library
C
C 2.2.   COMMON BLOCKS USED:
C
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
      character*12 lnam1,lnam2
C               - file names
      character*12 lfr
C               - corrected procedure file name for reading
C        IR     - record count
C        IERR   - error flag
C        LEN    - record length
C        IDTK   - starting directory track of procedure LU
C        JT, JS, JO - track, sector, offset of procedure file entry
C        JX     - extent of procedure file
C
      integer ierr
      character*29 dlstr
      character*12 dlfilenm
      character*512 ibc
      character*80 dirstr
      character*12 twochr
      character*64 pathname,pathname2,link
      integer trimlen
      integer i2byte(6)
      integer iret
      character*12 sl1,sl2,sl4
      character*40 cmessage
      logical kex,kest,kerr
      character*3 me
      equivalence (twochr,i2byte)
      equivalence (dlfilenm,dlstr(18:29))
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
1101      format(" no filename given")
          return
        else 
          if ((nch1.gt.4).and.(ib(ic1+nch1-3:ic1+nch1).eq.'.prc')) then
            nch1 = nch1-4
          end if
          if (nch1.gt.8) then
            write(lui,9100)
9100        format(" file names must be 8 characters or less")
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
          if (nch2.gt.8) then
            write(lui,9100)
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
            write(6,*) 'library ',lnam1(:nch1)
            goto 920
         endif
      endif
  
C     PFCR - create new procedure file.
  
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
 
C     PFDL - list directory of procedure files
  
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
c space over past that name
C Add ">" for active, "s" for schedule 2nd copy.
C  "a" for active F.S. proc file
              if(ibc(ix:ix+11).eq.sl2(1:12)) ibc(ix-1:ix-1) = 'S'
              if(ibc(ix:ix+11).eq.sl4(1:12)) ibc(ix-1:ix-1) = 'A'
              if(ibc(ix:ix+11).eq.sl1(1:12)) then
                if ((sl4.eq.sl1).or.(sl1.eq.sl2)) then
                  ibc(ix-2:ix-2) = '>'
                else
                  ibc(ix-1:ix-1) = '>'
                endif
              endif
              ix=ix+14
              if (ix.gt.60) then
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
        return
      endif
  
C     PF - change procedure file active in PFMED.
  
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
  
C     PFPU - purge procedure file.
  
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
 
C     PFRN - rename procedure file.
  
      if(ib(3:4).eq.'rn') then
        if ((lnam1.eq.' ').or.(lnam2.eq.' ')) then
          write(lui,1107)
1107      format(" syntax error")
          return
        end if
  
        if (lnam1.eq.lstp) then
          write(lui,9200)
9200      format(" cannot perform operation on current station library")
          return
        endif
        if (lnam1.eq.lprc) then
          write(lui,9300)
9300      format(" cannot perform operation on current active "
     .           "field system proc library")
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
  
C     PFST - transfer from existing file to file created by this command.
  
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
        call fopen(idcb1,pathname,ierr)
        if(ierr.lt.0) then
          write(lui,1112) pathname
1112      format(" error opening file ",a)
          kest = .true.
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
        do 710 ir=1,32767
          call f_readstring(idcb1,ierr,ibc,len)
          if(ierr.lt.0.or.len.lt.0) goto 720
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
          if(ierr.lt.0) goto 800
710     continue
720     call pfblk(2,lnam1,lfr)
        call fclose(idcb2,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
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
