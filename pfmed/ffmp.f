      subroutine ffmp(lui,luo,ib,ichi,lproc,ldef,ibsrt,nprc)
     
C
C 1.  FFMP PROGRAM SPECIFICATION
C
C 1.1.   FFMP is a simplified FMGR for use with the Mark III field system.
C        There are two sets of commands available.  Commands without the
C        PF prefix (DL, LI, PU, RN, ST) apply to individual procedures
C        within a procedure file.  The command LL is also handled here.
C        The default prodedure file is the one currently used by BOSS.
C
C 1.2.   RESTRICTIONS - Only procedure files are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  FFMP INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL FFMP(LUI,LUO,IB,ICHI,LPROC,LDEF)
C
C     INPUT VARIABLES:
C
C        LUI,LUO - input, output LU's
C     IB changed to a character rather than holerith string
      character*(*) ib
C               - line and record buffer
C        ICHI   - number of characters from keyboard
      character*12 lproc
C               - procedure file currently active in PFMED
      character*34 ldef
C               - DEFINE line at top of each procedure
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
C     CALLED SUBROUTINES: FMP routines, ICHMV, IB2AS, IAS2B, ISCN_CH,
C                         ICHCM, IFILL, MIN0, PFBLK, PFCOP, TRIMLEN
  
C 3.  LOCAL VARIABLES
C
      character*12 lfr,lpf
      character lrn
      logical ldupl
c     logical lge,lle
      character*64 pathname,link
C               - file names
      character*74 lnam1,lnam2,ibc,ibc2
      character*80 ibcd
      integer trimlen, fnblnk
      character*40 cmessage
      logical kerr

      character*12 ibsrt(1)  ! 010816 pb 
      integer nprc,scanp,npx 
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES: none
C
C 6.  PROGRAMMER: C. Ma
C     LAST MODIFIED: <910320.0157>
C     010705 pb Add sorted directory list.
C     010819 pb Mods to pass sort array. 
c
C# LAST COMPC'ED  870115:05:41 #
C
C     PROGRAM STRUCTURE
C
C     Exit if no procedure file active.
  
      if(lproc.eq.' ') then
        write(lui,1101)
1101    format(1x,"no procedure file active")
        return
      end if
 
C     Initialize and parse names.
      lnam1= ' '
      lnam2= ' '
C     Search for commas.
      ic1 = index(ib(1:ichi),',')
C     No commas means no names.
      if(ic1.gt.0) then
        ic2 = index(ib(ic1+1:ichi),',')
        ic2 = ic2+ic1 ! add on distance to FIRST comma as well
        if(ic2.eq.ic1) ic2=ichi+1
C     previous line reveals if 2nd comma not found - in which case
C     the NEXT previous line would have been ic2 = 0 + ic1 and so
C     ic2 now would equal ic1.
C
C     Move first name to buffer.
        nch1 = ic2-ic1-1
        ipos=fnblnk(ib,ic1+1)
        lnam1=ib(ipos:ic2-1)
C     Move second name if present.
        if(ichi.gt.ic2) then
          nch2 = ichi-ic2
          if ((nch2.le.0).or.(nch2.gt.12)) then
            write(lui,1102)
1102        format(1x,"error, procedure names must be less than 12"
     .                   " characters")
            return
          end if
          ipos=fnblnk(ib,ic2+1)
          lnam2=ib(ipos:ichi)
        end if
      end if
  
C     DL - list procedures in active procedure file.
  
      if((ib(1:2).eq.'dl').or.(ib(1:2).eq.'ds')) then
        ix=1
        npx = nprc
        nprc = 1
        call f_rewind(idcb3,ierr)
        if (ierr.ne.0) goto 990
        ibcd = ' '
        len = 0

        do while (len.ge.0)
          call f_readstring(idcb3,ierr,ibc2,len)
          call char2low(ibc2)
          if(ierr.lt.0.or.len.lt.0) go to 130
C     Check for DEFINE.
          if (ibc2(1:6).eq.'define') then
C     Move name to print buffer.
            ibcd(ix:ix+11) = ibc2(9:20)
            ix=ix+13
            if(ix.lt.79) go to 120
C         Print buffer and reset pointer.
            nch = trimlen(ibcd)
            if ((nch.gt.0).and.(ib(1:2).eq.'dl')) then 
               write(luo,2101) ibcd(:nch)
2101        format(1x,a)
            else if ((nch.gt.0).and.(ib(1:2).eq.'ds')) then
               nprc = scanp(ibcd,ibsrt,nprc)
            endif
            ibcd = ' '
            ix=1
          end if
120     end do

C       Write last line.
130     if(ix.gt.1) then
          nch = trimlen(ibcd)
          if ((nch.gt.0).and.(ib(1:2).eq.'dl')) then  
               write(luo,2102) ibcd(:nch)
2102           format(1x,a)
          else if ((nch.gt.0).and.(ib(1:2).eq.'ds')) then 
               nprc = scanp(ibcd,ibsrt,nprc)
          endif 
        end if

        if(ib(1:2).eq.'ds') then
         call sortp(ibsrt,nprc)
         write (luo,'("Pfmed: Displayed ",i3," procedures in ", 
     &        "file ",a12)') nprc,lproc 
        endif

        nprc = npx
        go to 900
      end if
 
C     LI - list procedure.
  
      if(ib(1:2).eq.'li') then
C     Check for name.
        if(lnam1.eq.' ') then
          write(lui,1104)
1104      format(1x,"no filename given")
          goto 900
        end if
C     Search file for DEFINE  procedurenam.
        call f_rewind(idcb3,ierr)
        if (ierr.ne.0) goto 990
        len = 0
        do while (len.ge.0)
          call f_readstring(idcb3,ierr,ibc,len)
c         turn to lower case for easy comparison
          call char2low(ibc)
          if(ierr.lt.0.or.len.lt.0) go to 226
          if(ibc(1:6).eq.'define'.and.ibc(9:20).eq.lnam1(1:12)) goto 221
        end do
C     Output body of procedure.
221     len = 0
        do while(len.ge.0)
          call f_readstring(idcb3,ierr,ibc,len)
          call char2low(ibc)
          if(ierr.lt.0.or.len.lt.0) goto 230
          if(ibc(1:6).eq.'enddef') goto 230
          nch = trimlen(ibc)
          if (nch.gt.0) write(luo,2103) ibc(:nch)
2103                    format(1x,a)
        end do
        goto 230
226     write(lui,1105) lnam1(1:12)
1105    format(1x,"Procedure ",a12," cannot be found")
C     Rewind scratch file.
230     call f_rewind(idcb3,ierr)
        if (ierr.ne.0) goto 990
        go to 900
      end if
  
C     PU - purge procedure from active procedure file.
  
      if (ib(1:2).eq.'pu') then
        if (lnam1.eq.' ') then
          write(lui,1106)
1106      format(1x,"no filename given")
          goto 900
        end if
C     Create scratch file 2.
        call fopen(idcb2,lsf2,ierr)
        if(ierr.lt.0) goto 381
        call f_rewind(idcb3,ierr)
        if(kerr(ierr,'ffmp','rewinding',' ',0,0)) return
C     Copy scratch file minus purged procedure.
        kpu=0
        ierr = 0
        len = 0
        call f_readstring(idcb3,ierr,ibc,len)
        do while (len.ge.0)
          call char2low(ibc)
          if (ierr.lt.0) then
            write(lui,11065)
11065       format(1x,"error reading procedure file")
            go to 389
          end if
          if(ibc(1:8).eq.'define  '.and.ibc(21:34).eq.' ') then
             ibc(21:)='  00000000000x'
          endif
          if ((ibc(1:6).eq.'define').and.
     .        (ibc(9:20).eq.lnam1(1:12))) then
            kpu = -1
          else if (kpu.ne.-1) then
            nch = trimlen(ibc)
            if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
            if(ierr.lt.0) goto 389
          end if
          if ((ibc(1:6).eq.'enddef').and.(kpu.eq.-1)) then
            kpu = 1
          end if
          call f_readstring(idcb3,ierr,ibc,len)
        end do
C     Check if procedure found.
        if(kpu.ne.1) then
          write(lui,1107) lnam1(:nch1)
1107      format(1x,"procedure ",a," not found")
          goto 389
        end if
C     Close old scratch copy.
        call fclose(idcb3,ierr)
        if(kerr(ierr,'ffmp','closing',' ',0,0)) return
C     Replace procedure file.
        call pfblk(3,lproc,lfr)
C     Copy new version.
        call pfcop(lproc,lui,id)
C     Reload the name buffer 
        go to 900
      end if
  
C     LL - change list device.
  
      if(ib(1:2).eq.'ll') then
        ib = ' '
C        call ifill(ib,1,3,2h  )
C       luo=ias2b(ib,4,ichi-3)
C       if (luo.lt.1.or.luo.gt.63) then
C         write(lui,1108)
C1108      format(1x,"ll must be between 1 and 63")
C         luo=lui
C       end if
        write(6,*) ' this area not implemented yet'
        goto 900
      end if
  
C     RN - rename procedure.
  
      if(ib(1:2).eq.'rn') then
        if (lnam1.eq.' ') then
          write(lui,1109)
1109      format(1x,"no filename given")
          goto 900
        end if
        if (lnam2.eq.' ') then
          write(lui,1110)
1110      format(1x,"no destination filename given")
          goto 900
        end if
C     Check for illegal name.
        lrn=lnam2(1:1)
c        if ((lge(lrn,'0')).and.(lle(lrn,'9'))) then
c          write(lui,1111) lnam2(:nch2)
c1111      format(1x,a,"illegal procedure name")
c          go to 900
c        end if
C     Create scratch file 2.
        call fopen(idcb2,lsf2,ierr)
        if(ierr.lt.0) call fopen(idcb2,lsf2,ierr)
        if(ierr.lt.0) go to 381
        call f_rewind(idcb3,ierr)
        if(kerr(ierr,'ffmp','rewinding',' ',0,0)) return
C     Copy to scratch file.
        krn=0
        ldupl = .false.
        len = 0
        call f_readstring(idcb3,ierr,ibc,len)
        do while (len.ge.0)
          call char2low(ibc)
          if(ierr.lt.0) then
            write(lui,1112)
1112        format(1x,"error reading procedure file")
            goto 389
          end if
C     Check for DEFINE.
          if(ibc(1:6).eq.'define') then
C     Check for possible duplicate DEFINE.
            if(ibc(9:20).eq.lnam2(1:12)) then
              write(lui,1113)
1113          format(1x,"error - duplicate name")
              ldupl = .true.
              GO TO 389
C     Rewrite name if target.
            else if(ibc(9:20).eq.lnam1(1:12)) then
              if (.not.ldupl) then
                ibc(9:20) = lnam2(1:12)
                ibc(23:34) = '000000000000'
              end if
              krn=1
            end if
          end if
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
          if(ierr.lt.0) then
            write(lui,1114)
1114        format(1x,"error writing to scratch file")
            go to 389
          end if
          call f_readstring(idcb3,ierr,ibc,len)
        end do
C     Check if procedure found.
        if(krn.eq.0) then
          write(lui,1115) lnam1(:nch1)
1115      format(1x,"procedure ",a," not found")
          goto 389
        end if
C     Close old scratch copy.
        if (.not.ldupl) then
          call fclose(idcb3,ierr)
          if(kerr(ierr,'ffmp','closing',' ',0,0)) return
C     Replace procedure file.
          call pfblk(3,lproc,lfr)
C     Copy new version.
          call pfcop(lproc,lui,id)
C     Reload name buffer
          go to 900
        else
          goto 389
        end if
      end if
  
C     ST - copy procedure to active procedure file.
  
      if(ib(1:2).eq.'st') then
        if (lnam1.eq.' ') then
          write(lui,1116)
1116      format(1x,"syntax error")
          return
        end if
C     Parse first name for procedure file.
        ix = 1
        do while ((lnam1(ix:ix+1).ne.'::').and.(ix.le.nch1))
          ix = ix + 1
        end do
        if (ix.lt.nch1) then
          lpf= ' '
          lpf = lnam1(ix+2:nch1)
        else
          lpf = lproc
        end if
C     Blank ::FF.
        lnam1(ix:74) = ' '
C     Copy procedure name if output name blank.
        if(lnam2.eq.' ') lnam2(1:12) = lnam1(1:12)
C     Get full name for reading.
        call pfblk(1,lpf,lfr)
C     Read until procedure found.
        nch = trimlen(lpf)
        if (nch.le.0) then
           write(6,*) 'ffmp: illegal filename length'
           goto 900
        else
           call follow_link(lpf(:nch),link,ierr)
           if(ierr.ne.0) return
           if(link.ne.' ') then                 
              if(lfr(:4).eq.'.prx') then
                 iprc=index(link,".prc")
                 link(iprc+3:iprc+3)='x'
              endif
              pathname = FS_ROOT//'/proc/' // link(:trimlen(link))
           else
              pathname = FS_ROOT//'/proc/'//lpf(:nch)//lfr(1:4)
           endif
        endif
        call fopen(idcb1,pathname,ierr)
        if(ierr.lt.0) then
          write(lui,1117) lpf(:nch)
1117      format(1x,"file ",a," not found")
          go to 900
        end if
        len = 0
        do while(len.ge.0)
          call f_readstring(idcb1,ierr,ibc,len)
          call char2low(ibc)
          if(ierr.lt.0.or.len.lt.0) then
            write(lui,1118) lnam1(:nch1)
1118        format(1x,"procedure ",a," not found")
            go to 690
          end if
C     Check for DEFINE of procedure.
          if(ibc(1:6).eq.'define'.and.ibc(9:20).eq.lnam1(1:12)) goto 615
        end do
C     Create scratch file 2.
615     call fopen(idcb2,lsf2,ierr)
        if(ierr.lt.0) call fopen(idcb2,lsf2,ierr)
        if(ierr.lt.0) then
          write(lui,1119)
1119      format(1x,"error creating scratch file")
          go to 690
        end if
C     Change procedure name.
        ibc(9:20) = lnam2(1:12)
        ibc(23:34) = '000000000000'
C     Copy procedure to scratch.
        len = 0
        do while(len.ge.0)
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
          if(ierr.lt.0) go to 687
          call f_readstring(idcb1,ierr,ibc,len)
          call char2low(ibc)
          if(ierr.lt.0.or.len.lt.0) go to 685
C     Check for ENDDEF.
          if(ibc(1:6).eq.'enddef') go to 625
        end do
C     Write ENDDEF.
625     nch = trimlen(ibc)
        if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
        if(ierr.lt.0) go to 687
        call fclose(idcb1,ierr)
        if(kerr(ierr,'ffmp','closing',' ',0,0)) return
C     Release lock.
        call pfblk(2,lpf,lfr)
C     Copy active file.
        call f_rewind(idcb3,ierr)
        if(kerr(ierr,'ffmp','rewinding',' ',0,0)) return
        len = 0
        do while(len.ge.0)
          call f_readstring(idcb3,ierr,ibc,len)
          call char2low(ibc)
          if(ibc(1:8).eq.'define  '.and.ibc(21:34).eq.' ') then
             ibc(21:)='  00000000000x'
          endif
          if(ierr.eq.-12.or.len.lt.0) go to 635
          if(ierr.lt.0) go to 685
C     Check for duplicate procedure.
          if(ibc(1:6).eq.'define'.and.ibc(9:20).eq.lnam2(1:12)) then
            write(lui,1120)
1120        format(1x,"duplicate procedure")
            go to 690
          end if
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),id)
          if(ierr.lt.0) go to 687
        end do
635     call fclose(idcb3,ierr)
        if(kerr(ierr,'ffmp','closing',' ',0,0)) return
C     Replace file.
        call pfblk(3,lproc,lfr)
C     Copy new version.
        call pfcop(lproc,lui,id)
C     Reload name buffer 
        go to 900
C     Various errors and messages.
685     write(lui,1121)
1121    format(1x,"error reading procedure file")
        go to 690
687     write(lui,1122)
1122    format(1x"error writing to scratch file")
690     call fclose(idcb1,ierr)
        if(kerr(ierr,'ffmp','closing',' ',0,0)) return
        goto 389
      end if
  
C     Bad command
  
cc      write(lui,1123)
cc1123  format(1x,"error, bad command")
      go to 900
  
C     FMP error condition.
  
381   write(lui,1124)
1124  format(1x,"error opening scratch file")
389   call fclose(idcb2,ierr1)
      if(kerr(ierr,'ffmp','closing',' ',0,0)) return
      call ftn_purge(lsf2,ierr1)
      if(kerr(ierr,'ffmp','purging',' ',0,0)) return
      call f_rewind(idcb3,ierr1)
      if(kerr(ierr,'ffmp','rewinding',' ',0,0)) return
      goto 900
  
c990   call fmperror(ierr,cmessage)
990   write(lui,2221) cmessage
2221  format(1x,"This an error message from ffmp",a,/)
  
900   return
      end
