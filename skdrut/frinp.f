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
C
C
C  LOCAL:
      integer ix,n,ITRK(4,max_pass),ITR2(4,max_pass)
      integer*2 LNA(4)
      integer idum,ib,ic,iv,ii,ivc,i,icode,istn,inum,itype,is,ns,ibad,j
      integer icx,nvlist,ivlist(max_chan)
      integer*2 lc,lsg,lm(4),lid,lin,ls
      integer*2 lst(4,max_stn)
      real*8 bitden
      logical kvlba,kmk3
      character*3 cs
      real*4 f1,f2,f,vb,rbbc,srate
      integer*2 lbar(2,max_stn)
      integer ias2b,iscn_ch,ichcm_ch,jchar,ichmv,igtfr,igtst ! functions
      logical knaeq
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
C
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
      ITYPE=0
      IF (JCHAR(IBUF,1).EQ.OCAPF) ITYPE=3 ! F frequency name, code and stations
      IF (JCHAR(IBUF,1).EQ.OCAPC) ITYPE=1 ! C frequency sequence lines
      IF (JCHAR(IBUF,1).EQ.OCAPL) ITYPE=2 ! L LO lines
      IF (JCHAR(IBUF,1).EQ.OCAPR) ITYPE=4 ! R sample rate lines
      IF (JCHAR(IBUF,1).EQ.OCAPB) ITYPE=5 ! B barrel roll lines 
      IF (ITYPE.EQ.1) CALL UNPCO(IBUF(2),ILEN-1,IERR,
     .                LC,LSG,F1,F2,Icx,LM,VB,ITRK,itr2,cs,ivc)
      IF (ITYPE.EQ.2) CALL UNPLO(IBUF(2),ILEN-1,IERR,
     .                LID,LC,LSG,LIN,F,ivlist,ls,nvlist)
      IF (ITYPE.EQ.3) CALL UNPFSK(IBUF(2),ILEN-1,IERR,LNA,LC,lst,
     .                ns)
      IF (ITYPE.EQ.4) CALL UNPRAT(IBUF(2),ILEN-1,IERR,lc,srate)
      IF (ITYPE.EQ.5) CALL UNPBAR(IBUF(2),ILEN-1,IERR,lc,lst,ns,lbar)
      call hol2upper(lc,2) ! uppercase frequency code
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
        if (itype.eq.3) then ! "F" line
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
      IF  (ITYPE.EQ.1) THEN  !code entry
        do j=1,nstsav ! apply to each station on the preceding "F" line
          is=istsav(j)
          if (is.gt.0) then ! valid station
          nchan(is,icode)=nchan(is,icode)+1 ! count them
          invcx(nchan(is,icode),is,icode)=icx ! channel index number 
          LSUBVC(icx,is,ICODE) = LSG ! sub-group, i.e. S or X
          FREQRF(icx,is,ICODE) = F1
          VCBAND(icx,is,ICODE) = VB
          LCODE(ICODE) = LC ! 2-letter code for the sequence
          idum = ichmv(LMODE(1,is,ICODE),1,LM,1,8) ! recording mode
C         Determine fanout factor here. Fan-in code is commented for now.
          ifan(is,icode)=0
          ix = iscn_ch(lmode(1,is,icode),1,8,'1:') 
C         iy = iscn_ch(lmode(1,is,icode),1,8,':1') 
          if (ix.ne.0) then ! possible fan-out
            n=ias2b(lmode(1,is,icode),ix+2,1)
            if (n.gt.0) ifan(is,icode)=n
C         else if (iy.ne.0) then ! possible fan-in
C           n=ias2b(lmode(1,is,icode),iy+2,1)
C           if (n.gt.0) ifan(is,icode)=n
          endif
C         Set bit density depending on the mode
          if (ichcm_ch(lmode(1,is,icode),1,'V').eq.0) then 
            bitden=34020 ! VLBA non-data replacement
          else 
            bitden=33333 ! Mark3/4 data replacement
          endif
C         If "56000" was specified, use higher station bit density
          if (ibitden_save(is).eq.56000) then 
            if (ichcm_ch(lmode(1,is,icode),1,'V').eq.0) then 
              bitden=56700 ! VLBA non-data replacement
            else 
              bitden=56250 ! Mark3/4 data replacement
            endif
          endif
C         Store the bit density by station
          bitdens(is,icode)=bitden
          DO  I=1,max_pass
            IF (ITRK(1,I).NE.-99) itras(1,1,icx,i,is,icode) = itrk(1,i)
            IF (ITRK(2,I).NE.-99) itras(2,1,icx,i,is,icode) = itrk(2,i)
            IF (ITRK(3,I).NE.-99) itras(1,2,icx,i,is,icode) = itrk(3,i)
            IF (ITRK(4,I).NE.-99) itras(2,2,icx,i,is,icode) = itrk(4,i)
            IF (ITR2(1,I).NE.-99) itra2(1,1,icx,i,is,icode) = itr2(1,i)
            IF (ITR2(2,I).NE.-99) itra2(2,1,icx,i,is,icode) = itr2(2,i)
            IF (ITR2(3,I).NE.-99) itra2(1,2,icx,i,is,icode) = itr2(3,i)
            IF (ITR2(4,I).NE.-99) itra2(2,2,icx,i,is,icode) = itr2(4,i)
          END DO 
          cset(icx,is,icode) = cs
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
      IF  (ITYPE.EQ.2) THEN  !LO entry
        IF  (IGTST(LID,ISTN).EQ.0) THEN  !error
          write(lu,'("FRINP03 - Station ",a2," not selected.",
     .    " LO entry on the following line ignored:"/40a2)') lid,
     .    (ibuf(i),i=2,ilen)
          IERR = MAX_STN
          RETURN
        END IF  !error
C
        if (nvlist.ne.0) then ! physical BBC info present
          if (nvlist.eq.1) then ! one BBC on this line
          do iv=1,nchan(istn,icode) ! check all frequency channels
            ic=invcx(iv,istn,icode) ! channel index from "C" line
            ib=ibbcx(ic,istn,icode) ! BBC index from "C" line
            if (ib.gt.0.and.ib.eq.ivlist(1)) then 
C                                    ! this channel on this BBC
              if (lsg.ne.lsubvc(ic,istn,icode)) 
     .        write(lu,'("FRINP04 - Subgroup ",a2," inconsistent with "
     .        ,a2," for channel ",i3,", station ",4a2)') lsg,
     .        lsubvc(ic,istn,icode),ic,(lstnna(i,istn),i=1,4)
              if (lc.ne.lcode(icode)) 
     .        write(lu,'("FRINP05 - Code ",a2," inconsistent with ",
     .        a2," for channel ",i3,", station ",4a2)') lc,lcode(icode)
     .        ,ic,(lstnna(i,istn),i=1,4)
              LIFINP(ic,istn,ICODE) = LIN ! IF input channel
              FREQLO(ic,ISTN,ICODE) = F ! LO freq
              losb(ic,istn,icode) = ls ! sideband
            endif
          enddo
          else ! many BBCs on this line (from PC-SCHED)
            do iv=1,nvlist
              ic=ivlist(iv)
              if (lsg.ne.lsubvc(ic,istn,icode)) 
     .        write(lu,'("FRINP04 - Subgroup ",a2," inconsistent with "
     .        ,a2," for channel ",i3,", station ",4a2)') lsg,
     .        lsubvc(ic,istn,icode),ic,(lstnna(i,istn),i=1,4)
              if (lc.ne.lcode(icode)) 
     .        write(lu,'("FRINP05 - Code ",a2," inconsistent with ",
     .        a2," for channel ",i3,", station ",4a2)') lc,lcode(icode)
     .        ,ic,(lstnna(i,istn),i=1,4)
              LIFINP(ic,istn,ICODE) = LIN ! IF input channel
              FREQLO(ic,ISTN,ICODE) = F ! LO freq
              losb(ic,istn,icode) = ls ! sideband
            enddo
          endif ! one/many 
        else ! fill physical BBC/IF/LO info assuming all channels get same
          do i=1,nchan(istn,icode)
            iv=invcx(i,istn,icode) ! channel index assumed same as BBC#
            if (lsg.eq.lsubvc(iv,istn,icode)) then ! match sub-group
              if (ichcm_ch(lifinp(iv,istn,icode),1,'  ').eq.0) then ! first time
                LIFINP(iv,istn,ICODE) = LIN 
                FREQLO(iv,ISTN,ICODE) = F
                call char2hol('U ',losb(iv,istn,icode),1,2)
              else ! had a previous LO already
                rbbc=abs(freqlo(iv,istn,icode)-freqrf(i,istn,icode))
                kmk3 =ichcm_ch(lifinp(iv,istn,icode),1,'1N').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'2N').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'3N').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'1A').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'2A').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'3A').eq.0
                kvlba=ichcm_ch(lifinp(iv,istn,icode),1,'A').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'B').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'C').eq.0.or.
     .                ichcm_ch(lifinp(iv,istn,icode),1,'D').eq.0
                if ((rbbc.gt.1000.0.and.kvlba).or.
     .              (rbbc.gt.500.0.and.kmk3)) then
                  LIFINP(iv,istn,ICODE) = LIN 
                  FREQLO(iv,ISTN,ICODE) = F
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
      IF (ITYPE.EQ.3) THEN  !name entry
C       Check the list of station names.
        ibad=0
        if (ns.gt.0) then ! station names on "F" line
          do is=1,ns ! for each station name found on the line
            i=1
            do while (i.le.nstatn.and..not.knaeq(lst(1,is),
     .               lstnna(1,i),4))
              i=i+1
            enddo
            if (i.gt.nstatn) then ! no match
              write(lu,9400) (lst(ii,is),ii=1,4)
9400          format('FRINP04 - Station ',4a2,' not selected. ',
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
        idum= ICHMV(LNAFRQ(1,ICODE),1,LNA,1,8)
        LCODE(ICODE) = LC
      END IF  !name entry
C
C 5. This is the sample rate line.

      if (itype.eq.4) then ! sample rate
        samprate(icode)=srate
      endif ! sample rate

C 6. This section for the barrel roll line.

      if (itype.eq.5) then ! barrel
        if (ns.gt.0) then ! station names on "B" line
          do is=1,ns ! for each station name found on the line
            i=1
            do while (i.le.nstatn.and..not.knaeq(lst(1,is),
     .               lstnna(1,i),4))
              i=i+1
            enddo
            if (i.gt.nstatn) then ! no match
              write(lu,9401) (lst(ii,is),ii=1,4)
9401          format('FRINP06 - Station ',4a2,' not selected. ',
     .        'Barrel roll for this station ignored.')
            else ! save it
             idum = ichmv(lbarrel(1,i,icode),1,lbar(1,is),1,4)
            endif
          enddo
        endif
      endif

      IERR = 0
      INUM = 0
C
      RETURN
      END
