      SUBROUTINE FRINP(IBUF,ILEN,LU,IERR)

C     This routine reads and decodes one line in the $CODES section.
C     Call in a loop to get all values in freqs.ftni filled in,
C     then call SETBA to figure out which frequency bands are there.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in WORDS
C     LU - unit for error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number
! function
      integer iwhere_in_string_list
      integer igetstatnum
      integer ias2b,igtfr


C  LOCAL:
      integer ix,n

      integer*4 itrk_map(max_headstack,max_trk)  !Has map of track mappings.

      integer*2 LNA(4)
      character*8 cna
      equivalence (lna,cna)
      integer ib,ic,iv,ivc,i,icode,istn,inum,is,ns,ibad,j
      integer icx,nvlist,ivlist(max_chan),ir
      integer*2 lc,lsg,lm(8),lid,lin,ls
      character*2 cs,cin
      equivalence (ls,cs), (lin,cin)
      character*16 cm
      equivalence (cm,lm)
      integer*2 lst(4,max_stn)
      character*8 cst(max_stn)
      equivalence (lst,cst)
      real*8 bitden
      logical kvlba,kmk3
      character*3 cswit
      real f2,vb,rbbc,srate
      double precision f1,f
      integer*2 lbar(2,max_stn),lfmt(2,max_stn)
      character*4 cbar(max_stn),cfmt(max_stn)
      equivalence (cbar,lbar),(cfmt,lfmt)
      logical kfound

      character*1 lchar
      integer*2   iDoNotUse
      equivalence (lchar,iDoNotUse)
      character*2 cifinptmp
      integer ilen2
      character*1 c1
      equivalence (c1,lid)


      save itrk_map
C
C  History
C     880310 NRV DE-COMPC'D
C     891116 NRV Cleaned up format, added fill-in of LBAND
C            nrv implicit none
C     930421 nrv Re-added: store track assignments
C 951019 nrv Add extension of LO lines to include per channel
C 951116 nrv Change to frequency sequencey per station
C 960124 nrv Missing argument in call to UNPLO
C 960212 nrv Missing argument in UNPLO
C 960213 nrv Uppercase the frequency code
C 960220 nrv Save LNAFRSUB even if no station names on the "F" line.
C 960221 nrv Read switching from "C" lines, also BBC index.
C 960223 nrv Fill in "L" line info on per channel basis
C 960228 nrv Change unplo call to include VC assignments from PC-SCHED
C            patching info.
C 960321 nrv Add "R" line for sample rate
C 960405 nrv Remove "subcode" from reading by UNPFSK
C 960405 nrv Check for valid station index from "F" line before filling
C            in frequency sequences etc.
C 960409 nrv Allow for headstack 2 in call to UNPCO and setting ITRAS,ITRA2
C 960516 nrv Crosscheck sub-groups on "L" lines and "C" lines using
C            channel numbers not BBC numbers
C 960709 nrv Add "B" line for barrel roll
C 960709 nrv Initialize fanout factor to 0, for Mark III modes.
C            It is reset to 1,2,4 if it's a VLBA mode.
C 961020 nrv Set the BBC sideband to "U" for non-Vex input.
C 970115 nrv Add UNPFMT for recording format by station line.
C 970117 nrv Add IF3O and IF3I to Mk3-4 allowed values.
C 970206 nrv Change itra2 to itras and add headstack index
C 971211 nrv Set sideband to "U" for all non-VEX (only done for .drg before).
C 991122 nrv LMODE can be 16 characters to accommodate S2 modes.
C            Store S2 mode into LMODE as well as LS2MODE.
C 011011 nrv If S2 mode was already set up from the equip line, don't
C            overwrite it.
C 020114 nrv Fill in roll defs.
C 2003Jul25 JMG  ITRAS changed to function
! 2005May2  JMG  Converted losb and lifinp to Characters
! 2008Sep25 JMG. Modified so won;'t set bitdens if recorder is Mark5 or K5
! 2011Aug11  JMG. Reformatted some warning messages
! 2013Sep19  JMGipson made sample rate station dependent
! 2015Jun05 JMG Modified to use new version of itras. 
! 2016Dec05 JMG. Fixed bug in reading in samplate rate. Previously  applied the sample rate to "1,ns". Now to "1,nstatn" 
C
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
      iDoNotUse=ibuf(1)   !this bit of code makes lchar=first character in ibuf

      ilen2=ilen-1
!      write(*,'("--->",10a2)') ibuf(2:11) 

      if(lchar .eq. "C") then
       CALL UNPCO(IBUF(2),ilen2,IERR,LC,LSG,F1,F2,Icx,LM,VB,itrk_map,
     >     cswit,ivc)
      else if(lchar .eq. "L") then
        CALL UNPLO(IBUF(2),ilen2,IERR,LID,LC,LSG,LIN,F,ivlist,ls,nvlist)
      else if(lchar .eq. "F") then
        CALL UNPFSK(IBUF(2),ilen2,IERR,LNA,LC,lst,ns)
      else if(lchar .eq. "R") then
        CALL UNPRAT(IBUF(2),ilen2,IERR,lc,srate)
      else if(lchar .eq. "B") then
        CALL UNPBAR(IBUF(2),ilen2,IERR,lc,lst,ns,lbar)
      else if(lchar .eq. "D") then
        CALL UNPFMT(IBUF(2),ilen2,IERR,lc,lst,ns,lfmt)
      endif
      call hol2upper(lc,2) ! uppercase frequency code

! Update the track mapping if neccessary.
      if(nstsav .eq. 0 .and. lchar .eq. "F") then
        call new_track_map()                  !indicate that we are starting a new track map. 
      endif

      if(lchar .ne. "C" .and. nstsav .ne. 0) then
        do j=1,nstsav ! apply to each station on the preceding "F" line
          is=istsav(j)
          call add_track_map(is,ncodes)       !Done with all of the tracks. Add the map. 
        end do
        nstsav=0
        call new_track_map()
      endif

C
C 1.5 If there are errors, handle them first.
C
      IF  (IERR.NE.0) THEN
        IERR = -(IERR+100)
        write(lu,9201) ierr,(ibuf(i),i=2,ilen)
9201    format('FRINP01 - Error in field ',I3,' of this line:'/40a2)
        RETURN
      END IF 
C  Lines need not be in order, so we may encounter a new code
C  on any line. But this is a bad practice.
      IF  (IGTFR(LC,ICODE).EQ.0) THEN !a new code
        if (lchar .eq. "F") then ! "F" line
          NCODES = NCODES + 1
          IF  (NCODES.GT.MAX_FRQ) THEN !too many codes
            IERR = MAX_FRQ
            ncodes=ncodes-1
            write(lu,9202) ierr
9202        format('FRINP02 - Too many frequency codes.  Max is ',I3,
     .      ' codes.')
            RETURN
          END IF  !too many codes
          ICODE = NCODES
        else ! not allowed
          write(lu,9203) (ibuf(i),i=2,ilen)
9203      format('FRINP03 - Warning! A new frequency code was found out',
     .    ' of order on the following line and was ignored:'/40a2)
          return
        endif
      END IF  !a new code
C
C     2. Now decide what to do with this information.
C     First, handle code type entries, "C" with frequencies.
C
      IF  (lchar .eq. "C") THEN  !code entry
        do j=1,nstsav ! apply to each station on the preceding "F" line
          is=istsav(j)
          if (is.gt.0) then ! valid station
          nchan(is,icode)=nchan(is,icode)+1 ! count them
          invcx(nchan(is,icode),is,icode)=icx ! channel index number 
          LSUBVC(icx,is,ICODE) = LSG ! sub-group, i.e. S or X
          FREQRF(icx,is,ICODE) = F1
          VCBAND(icx,is,ICODE) = VB
          if(vcband(1,is,icode) .eq. 0) then
             vcband(1,is,icode)=vb
          endif
          LCODE(ICODE) = LC ! 2-letter code for the sequence
C         All listed Mk3 frequencies are for USB recording. 
C         Any LSB to be recorded is specified in track assignments,
C         i.e. for mode A and mode B&E.
!          idum = ichmv_ch(lnetsb(icx,is,icode),1,'U')
C         Initialize lmode to blanks.
!          call ifill(lmode(1,is,icode),1,16,oblank)
!          idum = ichmv(LMODE(1,is,ICODE),1,LM,1,16) ! recording mode
          cnetsb(icx,is,icode)="U"
          cmode(is,icode)=cm

C         This should be "VLBA" for NDR, otherwise it's DR. drudg will
C         modify this when it gets user input on the formatter type.
C         This is used by SPEED.
!          idum = ichmv(LMFMT(1,is,ICODE),1,LM,1,16) ! recording format
          cmfmt(is,icode)=cm
C         Initialize S2 mode to blank. It's probably safe to put 
C         LMODE into LS2MODE.
C         Not safe because the mode may be already there from the equip line.
          if(cs2mode(is,icode) .eq. " ") then
             cs2mode(is,icode) = cm
             cmode(is,icode) = " "
          endif
C         Determine fanout factor here. Fan-in code is commented for now.
          ifan(is,icode)=0
          ix=index(cmode(is,icode), "1:")
C         iy = iscn_ch(lmode(1,is,icode),1,16,':1') 
          if (ix.ne.0) then ! possible fan-out
            n=ias2b(lmode(1,is,icode),ix+2,1)
            if (n.gt.0) ifan(is,icode)=n
C         else if (iy.ne.0) then ! possible fan-in
C           n=ias2b(lmode(1,is,icode),iy+2,1)
C           if (n.gt.0) ifan(is,icode)=n
          endif
C         Set bit density depending on the mode
          if(cmode(is,icode)(1:1) .eq. 'V') then
            bitden=34020 ! VLBA non-data replacement
          else 
            bitden=33333 ! Mark3/4 data replacement
          endif
C         If "56000" was specified, use higher station bit density
          if (ibitden_save(is).eq.56000) then
            if(cmode(is,icode)(1:1) .eq. 'V') then
              bitden=56700 ! VLBA non-data replacement
            else 
              bitden=56250 ! Mark3/4 data replacement
            endif
          endif
C         Store the bit density by station
          if(cstrec(is,1) .eq. "Mark5A" .or. 
     >       cstrec(is,1) .eq. "K5") then
             continue
          else
            bitdens(is,icode)=bitden  
          endif
          cset(icx,is,icode) = cswit
          if (ivc.eq.0) then
            ibbcx(icx,is,icode) = icx
          else
            ibbcx(icx,is,icode) = ivc ! BBC number
          endif
          endif ! valid station
        enddo ! each station on "F" line
      END IF  !code entry
C
C
C     3. Next, LO type entries, from the "L" lines.
C
      IF  (lchar.eq. "L") THEN  !LO entry
        istn=igetstatnum(c1)
        IF  (istn.EQ.0) THEN  !error
          write(lu,'(a,a,a,/,40a2)')
     >     "FRINP03 - Station ",c1,
     >     " not selected.  LO entry on the following line ignored:",
     >    (ibuf(i),i=2,ilen)
          IERR = MAX_STN
          RETURN
        END IF  !error
C
        if (nvlist.ne.0) then ! physical BBC info present
          if (nvlist.eq.1) then ! one BBC on this line (new sked)
          kfound=.false.
          do iv=1,nchan(istn,icode) ! check all frequency channels
            ic=invcx(iv,istn,icode) ! channel index from "C" line
            ib=ibbcx(ic,istn,icode) ! BBC index from "C" line
            if (ib.gt.0.and.ib.eq.ivlist(1)) then 
C                                    ! this channel on this BBC
              if (lsg.ne.lsubvc(ic,istn,icode))
     .        write(lu,'(a,a2,a,a2,a,i3,a,a)')
     >        "FRINP04 - Subgroup ", lsg," inconsistent with ",
     >        lsubvc(ic,istn,icode), " for channel ",ic,
     >        " station",cstnna(istn)

              if (lc.ne.lcode(icode)) 
     .        write(lu,'(a,a2,a,a2,a,i3,a,a)')
     >        "FRINP05 - Code ",lc," inconsistent with ",
     >         lcode(icode), " for channel ",ic,
     >        " station",cstnna(istn)
              kfound=.true.
              FREQLO(ic,ISTN,ICODE) = F ! LO freq
              cIFINP(ic,istn,ICODE) = cIN ! IF input channel
              cosb(ic,istn,icode) = cs ! sideband
            endif
          enddo
          if(kfound) then
             ibbc_present(ivlist(1),istn,icode)=1
          else
             ibbc_present(ivlist(1),istn,icode)=-1
          endif

          else ! many BBCs on this line (from PC-SCHED)
            do iv=1,nvlist
              ic=ivlist(iv)

              if (lsg.ne.lsubvc(ic,istn,icode))
     .        write(lu,'(a,a2,a,a2,a,i3,a,a)')
     >        "FRINP04 - Subgroup ", lsg," inconsistent with ",
     >        lsubvc(ic,istn,icode), " for channel ",ic,
     >        "station",cstnna(istn)

              if (lc.ne.lcode(icode)) 
     .        write(lu,'(a,a2,a,a2,a,i3,a,a)')
     >        "FRINP05 - Code ",lc," inconsistent with ",
     >         lcode(icode), " for channel ",ic,
     >        "station",cstnna(istn)

              FREQLO(ic,ISTN,ICODE) = F ! LO freq
C             there's no sideband on this line
C             losb(ic,istn,icode) = ls ! sideband
!              LIFINP(ic,istn,ICODE) = LIN ! IF input channel
              cIFINP(ic,istn,ICODE) = cIN ! IF input channel
!              call char2hol('U ',losb(ic,istn,icode),1,2)
              cosb(ic,istn,icode)="U "
            enddo
          endif ! one/many 
        else ! fill physical info assuming all channels get same (old sked)
          do i=1,nchan(istn,icode)
            iv=invcx(i,istn,icode) ! channel index assumed same as BBC#
            if (lsg.eq.lsubvc(iv,istn,icode)) then ! match sub-group
              cifinptmp=cifinp(iv,istn,icode)
              if (cifinptmp .eq. " ") then
                cIFINP(iv,istn,ICODE) = cIN
                FREQLO(iv,ISTN,ICODE) = F
                cosb(iv,istn,icode)="U "
              else ! had a previous LO already
                rbbc=abs(freqlo(iv,istn,icode)-freqrf(i,istn,icode))
                kmk3 =cifinptmp .eq. "1N" .or. cifinptmp .eq. "2N" .or.
     >                cifinptmp .eq. "3N" .or.
     >                cifinptmp .eq. "1A" .or. cifinptmp .eq. "2A" .or.
     >                cifinptmp .eq. "3O" .or. cifinptmp .eq. "3I"

                kvlba=
     >               cifinptmp(1:1).eq."A" .or.cifinptmp(1:1).eq."B".or.
     >               cifinptmp(1:1).eq."C" .or.cifinptmp(1:1).eq."D"

                if ((rbbc.gt.1000.0.and.kvlba).or.
     .              (rbbc.gt.500.0.and.kmk3)) then
                  cIFINP(iv,istn,ICODE) = cIN
                  FREQLO(iv,ISTN,ICODE) = F
                  cosb(iv,istn,icode)="U "
                else ! what?
                endif
              endif ! previous LO/first time
            endif ! match sub-group
          enddo
        endif
      END IF  !LO entry
C
C
C     4. This is the name type entry section.
C        Index for icode has already been found above.
C
      IF (lchar.eq. "F") THEN  !name entry
C       Check the list of station names.  
        ibad=0
        if (ns.gt.0) then ! station names on "F" line
          do is=1,ns ! for each station name found on the line
            i=iwhere_in_string_list(cstnna,nstatn,cst(is))
            if (i.eq.0) then ! no match
              write(lu,9400) cst(is)
9400          format('FRINP04 - Station ',a,' not selected. ',
     .        'Frequency sequence for this station ignored.')
              istsav(is)=-1
            else
             istsav(is)=i ! save the station index 
C            idum= ICHMV(LNAFRsub(1,i,ICODE),1,lsub,1,8)
            endif
          enddo
          nstsav=ns !           
        else ! no stations listed, assume all
          nstsav=nstatn
          do i=1,nstatn
            istsav(i)=i ! save the station index 
C           idum= ICHMV(LNAFRsub(1,i,ICODE),1,lsub,1,8)
          enddo
        endif
        cnafrq(icode)=cna
        LCODE(ICODE) = LC
      END IF  !name entry
C
C 5. This is the sample rate line.

      if (lchar.eq. "R") then ! sample rate  
        do is=1,nstatn 
          samprate(is,icode)=srate
        end do 
      endif ! sample rate

C 6. This section for the barrel roll line.

      if (lchar .eq. "B") then ! barrel
        if (ns.gt.0) then ! station names on "B" line
          do is=1,ns ! for each station name found on the line
            i=iwhere_in_string_list(cstnna,nstatn,cst(is))
            if (i.eq.0) then ! no match
              write(lu,9401) cst(is)
9401          format('FRINP06 - Station ',a,' not selected. ',
     .        'Barrel roll for this station ignored.')
            else ! save it
              cbarrel(i,icode)=cbar(is)
              if(cbarrel(i,icode)(1:1) .eq. "8") ir=1
              if(cbarrel(i,icode)(1:2) .eq. "16") ir=2
              if (ir.eq.1.or.ir.eq.2) then ! fill roll table
                iroll_inc_period(i,icode) = ircan_inc(ir)
                iroll_reinit_period(i,icode) = ircan_reinit(ir)
                nrolldefs(i,icode)  = nrcan_defs(ir)
                nrollsteps(i,icode) = nrcan_steps(ir)
                call init_roll_type(is,icode,nrcan_defs(ir),
     >              nrcan_steps(ir),icantrk(1,1,ir))
              endif ! fill roll table
            endif ! save it
          enddo ! each station name found on the line
        endif ! station names on "B" line
      endif ! barrel

C 7. This section for the recording format line.

      if (lchar .eq."D" ) then ! format
        if (ns.gt.0) then ! station names on the line
          do is=1,ns ! for each station name found on the line
            i=iwhere_in_string_list(cstnna,nstatn,cst(is))
            if (i.eq.0) then ! no match
              write(lu,9402) cst(is)
9402          format('FRINP07 - Station ',a,' not selected. ',
     .        'Recording format for this station ignored.')
            else ! save it
              if (cfmt(is)(1:1) .eq. "N") then
                cmfmt(i,icode)(1:1)="M"
              endif
            endif
C       RESet bit density depending on the recording format.
C       Check once more on the bit density but this time use LMFMT.
            if (cmfmt(i,icode)(1:1) .eq. "V") then
              bitden=34020 ! VLBA non-data replacement
            else
              bitden=33333 ! Mark3/4 data replacement
            endif
C           If "56000" was specified, use higher station bit density
            if (ibitden_save(i).eq.56000) then 
              if (cmfmt(i,icode)(1:1) .eq. "V") then
                bitden=56700 ! VLBA non-data replacement
              else 
                bitden=56250 ! Mark3/4 data replacement
              endif
            endif
C           Store the bit density by station
            bitdens(i,icode)=bitden
          enddo ! each station name on the line
        endif
      endif ! recording format line

      IERR = 0
      INUM = 0
C
      RETURN
      END
