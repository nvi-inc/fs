      subroutine fed(lui,luo,ib,ichx,lproc,ldef)
C
C 1.  FED PROGRAM SPECIFICATION
C
C 1.1.   FED is a simplified editor for use with the Mark III field system.
C        The following commands are available: P,O,L,>,/,-,^,R, ,E,A.
C        The syntax and usage are similar to the corresponding EDIT commands.
C        P and O allow only character for character replacement or a single
C        use of controlS, controlC, or controlT.
C
C        Procedure files lacking DEFINE as the first record are amended.
C
C 1.2.   RESTRICTIONS - Only procedure files are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.  Two scratch files tmppf1 and 
C        tmppf2 must exist on ICRPRC before editing can take place.  
C        They are created if needed.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  FED INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL FED(LUI,LUO,IB,ICHX,LPROC,LDEF)
C
C     INPUT VARIABLES:
C        LUI, LUO  - input, output LU's
      character*(*) ib
      character*74 ibc
C               - line and record buffer
C        ICHX   - number of characters from terminal
      character*103 editor
      character*12 lproc
C               - active procedure file
      character*34 ldef
C               - DEFINE line (name begins in col. 9)
C
C     OUTPUT VARIABLES: none
C
C 2.2.   COMMON BLOCKS USED
C
      include 'pfmed.i'
C
C 2.3.   DATA BASE ACCESSES: none
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     INPUT VARIABLES:
C
C     TERMINAL   - IB
C
C     OUTPUT VARIABLES:
C
C     TERMINAL   - various messages
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: PFMED
C
C     CALLED SUBROUTINES: EXEC, FMP routines, IB2AS, ICHMV, IAS2B,
C                         IFTL, LTOF, IFTOF, PLIN, ETO, ICHCM,
C                         IFILL, ISCN_CH, GTFLD, PFBLK, PFCOP
C
C 3.  LOCAL VARIABLES
C
      integer ichange,ierr
c               - flag for editor
      logical knew
C               - flag for newly created procedure
      character*12 lnam1,lnam2,cid
C               - procedure name
C        NN     - line number or count from command
C        ICHI   - character count of typed line
C        LCOM   - single character edit command
C        IERR   - FMP error flag
C        NPASS  - number of lines to pass over in positioning
C
C 4.  CONSTANTS USED
C
      character*28 ls1
      character*8 lm8
      integer trimlen
      integer nch,fnblnk
      logical kerr
      character*3 me
      data me/'fed'/
C
      data ls1    /'/usr2/proc/tmppf1'/
C               - scratch file names
C
C 5.  INITIALIZED VARIABLES: none
C
C 6.  PROGRAMMER: C. Ma
C     MODIFIED 840307 BY MWH To schedule EDIT/1000
C 
C HISTORY:
C WHO  WHEN    WHAT
C gag  920901  Added calls to char2low after a few readstring calls.
C
C     PROGRAM STRUCTURE
C
C     Exit if no procedure file active.
C
      if (lproc(1:1).eq.' ') then
        write(lui,1101)
1101    format("no procedure file active")
        goto 900
      endif
C     Initialize and parse names.
      lnam1 = ' '
      lnam2 = ' '
C     Search for commas.
      ic1 = index(ib(1:ichx),',')
C     No commas means no names.
C       Move name to buffer.
      if (ic1.ne.0) then
        nch = ichx - ic1
        lnam2 = ib(ic1+1:ichx)
        editor=ib(1:ic1-1)
      else
        editor=ib(1:ichx)
        write(lui,1102)
1102    format("enter procedure name(:: to cancel): ",$)
cxx        read(lui,'(a)') lnam2
        read(5,'(a)') lnam2
      end if
      if(editor(1:2).eq.'ed') editor='edit'
      ipos=trimlen(editor)+1
      editor(ipos:ipos)=char(0)
      ipos = fnblnk(lnam2,1)
      nch = trimlen(lnam2)
      if (nch.le.0) then
        write(lui,1103)
1103    format("error entering procedure name")
        return
      end if
      lnam1 = lnam2(ipos:nch)
      call lower(lnam1,nch-ipos+1)
      if (lnam1.eq.'::') goto 390
C     Initialize flags and counters.
      knew = .false.
      call fopen(idcb1,ls1,ierr) !  open 1st scratch fi
      if (ierr.eq.-6) then        !  create scratch file if nonexistent
        call fopen(idcb1,ls1,ierr)
        if (ierr.lt.0) then
          write(lui,9100) ierr
9100      format(' error creating tmppf1 ',i4)
          goto 390
        endif
      else if (ierr.lt.0) then
        write(lui,9200) ierr
9200    format(' scratch error ',i4)
        goto 390
      endif
C     Write EOF to initialize.
      call f_rewind(idcb3,ierr)
      if(kerr(ierr,me,'rewinding',' ',0,0)) return
C     Search for procedure name given.
      call f_readstring(idcb3,ierr,ibc,len)
      call char2low(ibc)
      if(kerr(ierr,me,'reading',' ',0,0)) continue
      do while(ierr.ge.0.and.len.ge.0)
        if(ibc(1:6).eq.'define'.and.ibc(9:20).eq.lnam1) goto 130
        call f_readstring(idcb3,ierr,ibc,len)
        call char2low(ibc)
        if(kerr(ierr,me,'reading',' ',0,0)) continue
      enddo
      write(lui,1105)
1105  format("new procedure")
      knew = .true.
      goto 150
c
130   continue
      call f_readstring(idcb3,ierr,ibc,len)
      call char2low(ibc)
      if(kerr(ierr,me,'reading',' ',0,0)) continue
      do while(ibc(1:6).ne.'enddef'.and.ierr.ge.0.and.len.ge.0)
        nch = trimlen(ibc)
        if (nch.gt.0) then
          call f_writestring(idcb1,ierr,ibc(:nch),lenw)
          if(kerr(ierr,me,'writing',' ',0,0)) continue
        end if
        call f_readstring(idcb3,ierr,ibc,len)
        call char2low(ibc)
        if(kerr(ierr,me,'reading',' ',0,0)) continue
      enddo
150   continue
      call f_rewind(idcb3,ierr)
      if(kerr(ierr,me,'rewinding',' ',0,0)) return
      call fclose(idcb1,ierr)
      if(kerr(ierr,me,'closing',' ',0,0)) return
      ib = ' '
      nch=nch-1
C
C  SCHEDULE EDIT
C
C  EDIT
C     having ported the field system, the editor now used will be
C     'vi' since EDIT 1000 is no longer available
c     call ftn_runprog('vi ' // ls1,ierr)
cxx      call ftn_editor(ls1,ierr,ichange)
      ierr = 0
      call ftn_edit(ls1,ierr,ichange,editor)
      if (ierr.ne.0) write(6,*) 'error editing procedure',ierr
C
      if (ichange.eq.0) then
        write(6,9000) lnam1
9000    format("NO changes were made to the procedure: ",a)
      else if (ichange.eq.1) then
        call fopen(idcb1,ls1,ierr)
        if (ierr.lt.0) then
          write(lui,9090) ierr
9090      format(' error ',i4,' opening tmppf1')
          goto 390
        endif
C
C  Open/Create scratch file 2
C
        call fopen(idcb2,lsf2,ierr)
        if (ierr.eq.-6) then
          call fopen(idcb2,lsf2,ierr)
          if (ierr.lt.0) then
            write(lui,9500) ierr
9500        format(' error ',i4,' creating output file')
            goto 390
          endif
        else if (ierr.lt.0) then
          write(lui,9200) ierr
          goto 390
        endif
      
C  Replace/insert edited procedure
C
C   copy down to the old procedure if it existed, to the end otherwise
C
        call f_readstring(idcb3,ierr,ibc,len)
        call char2low(ibc)
        if(kerr(ierr,me,'reading',' ',0,0)) continue
        do while(ierr.ge.0.and.len.ge.0)
          if(ibc(1:8).eq.'define  '.and.ibc(21:34).eq.' ') then
             ibc(21:)='  00000000000x'
          endif
          if(ibc(1:6).eq.'define'.and.ibc(9:20).eq.lnam1) goto 160
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),lenw)
          if(kerr(ierr,me,'writing',' ',0,0)) continue
          call f_readstring(idcb3,ierr,ibc,len)
          call char2low(ibc)
          if(kerr(ierr,me,'reading',' ',0,0)) continue
        enddo
160     continue
C
C   write the new DEFINE line
C
        ldef(9:20) = lnam1(1:12)
        call f_writestring(idcb2,ierr,ldef(:34),lenw)
        if(kerr(ierr,me,'writing',' ',0,0)) continue
C
C  copy the new procedure in
C
        call f_readstring(idcb1,ierr,ibc,len)
        call char2low(ibc)
        if(kerr(ierr,me,'reading',' ',0,0)) continue
        do while(ierr.ge.0.and.len.ge.0)
          nch = trimlen(ibc)
          if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),lenw)
          if(kerr(ierr,me,'writing',' ',0,0)) continue
          call f_readstring(idcb1,ierr,ibc,len)
          call char2low(ibc)
          if(kerr(ierr,me,'reading',' ',0,0)) continue
        enddo
C
C  Write the ENDDEF line
C
        call f_writestring(idcb2,ierr,'enddef',lenw)
        if(kerr(ierr,me,'writing',' ',0,0)) continue
C
C  copy through the old routine if it existed, otherwise we are at EOF
C
        if (.not.knew) then
          call f_readstring(idcb3,ierr,ibc,len)
          call char2low(ibc)
          if(kerr(ierr,me,'reading',' ',0,0)) continue
          do while(ibc(1:6).ne.'enddef')
            if(ierr.lt.0.or.len.le.0) goto 180
            call f_readstring(idcb3,ierr,ibc,len)
            call char2low(ibc)
            if(kerr(ierr,me,'reading',' ',0,0)) continue
          enddo
C
C  okay, now copy the remaining procedures
C
          call f_readstring(idcb3,ierr,ibc,len)
          call char2low(ibc)
          if(kerr(ierr,me,'reading',' ',0,0)) continue
          do while(ierr.ge.0.and.len.ge.0)
            if(ibc(1:8).eq.'define  '.and.ibc(21:34).eq.' ') then
               ibc(21:)='  00000000000x'
            endif
            nch = trimlen(ibc)
            if (nch.gt.0) call f_writestring(idcb2,ierr,ibc(:nch),lenw)
            if(kerr(ierr,me,'writing',' ',0,0)) continue
            call f_readstring(idcb3,ierr,ibc,len)
            call char2low(ibc)
            if(kerr(ierr,me,'reading',' ',0,0)) continue
          enddo
        end if
C
180     continue
        call fclose(idcb3,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        call fclose(idcb1,ierr)
        if(kerr(ierr,me,'closing',' ',0,0)) return
        if (knew) then
          lm8(1:8) = 'inserted'
        else
          lm8(1:8) = 'replaced'
        end if
        nch = trimlen(lnam1)
        if (nch.gt.0) write(lui,9800) lnam1(1:nch),lm8,lproc(1:12)
9800    format(' procedure ',a,' ',a8,' in ',a)
C  Replace procedure file
        call pfblk(3,lproc,cid)
C  Copy to scratch 3
        call pfcop(lproc,lui,id)
      endif
C
390   call fclose(idcb1,ierr)
      if(kerr(ierr,me,'closing',' ',0,0)) return
      call ftn_purge(ls1,ierr)    !idcb1
      if(kerr(ierr,me,'purging',' ',0,0)) return
      call fclose(idcb2,ierr)
      if(kerr(ierr,me,'closing',' ',0,0)) return
      call f_rewind(idcb3,ierr)
      if(kerr(ierr,me,'rewinding',' ',0,0)) return
900   continue

      return
      end
