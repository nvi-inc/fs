      subroutine proc_vc(cname_vc, cpmode,icode,
     >  kk4vcab, fvc,fvc_lo,fvc_hi,lwhich8)
! Write out VC commands.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! Passed parameters.
      character*12 cname_vc             !Name of procedure
      character*4 cpmode                !
      integer icode             	!what code
      logical kk4vcab                   !For K4 systems
      real fvc(max_bbc)		  	!VC frequencies
      real fvc_lo(max_bbc)              !lower edge
      real fvc_hi(max_bbc)              !upper edge
      character*1 lwhich8               ! which8 BBCs used: F=first, L=last

!functions
      integer itras            !track assignment function. Returns -99 if not set
      integer ib2as            !lnfch routines.
      integer ir2as
      integer mcoma
      integer ichmv_ch
      integer ichmv

! History:
! 2007Jul09. Split off from procs.
! 2008Feb26 JMG.  Write out comment if unused BBCs are present.

! local variables.
      character*80 cbuf2        !temporary text buffer
      real rfvc_max  		!maximum frequency
      real rfvc
      real DRF                  !RF frequency
      real DLO                  !LO frequency
      integer nch
      logical kok               !is everything OK?
      logical ku,kl             !is this channel upper or lower
      logical kux,klx           !is another channel hooked up to this BBC upper or lower
      logical kul               !Doublesided
      logical kinclude_chan     !Write out this channel?
      logical km4done           !Done Mark4?

      integer ichan,ichanx      !Channel Counters
      integer ib,ic,icx         !BBC#, Channel#, alternate channel#
      integer ic_hi             !channel # of hiband
      integer i
      integer igotbbc(max_bbc)  !flag indicating that we have this BBC
      logical kfirst
      character*2 cprfix


      character*1 cvc2k42(max_bbc)
      character*1 cvchan(max_bbc)
      integer Z4000,Z100

      data cvc2k42/'1','2','3','4','5','6','7','8',
     .             '1','2','3','4','5','6','7','8'/
      data cvchan /8*'A',8*'B'/
      data Z4000/Z'4000'/,Z100/Z'100'/

      cprfix='"'

      do irec=1,nrecst(istn) ! loop on recorders
C       If both recorders are in use then do the check to see if
C       we should do one or both procs
        if((kuse(1).ne.kuse(2).and.kuse(irec)).or.
     .     ((kuse(1).and.kuse(2)).and.(irec.eq.1.or.
     .                (irec.eq.2.and.kk4vcab)))) then ! do this

          call proc_write_define(lu_outfile,luscn,cname_vc)

C         Initialize the bbc array to "not written yet"
          do ib=1,max_bbc
            igotbbc(ib)=0
          enddo
          rfvc_max=-1.
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
            ib=ibbcx(ic,istn,icode) ! BBC number
C           If we already did this BBC, skip it.
            if (igotbbc(ib).eq.0) then ! do this BBC command
              igotbbc(ib)=1
              ic_hi=ic
              do i=ichan+1,nchan(istn,icode)
                if (ibbcx(invcx(i,istn,icode),istn,icode).eq.ib)
     .            ic_hi=invcx(i,istn,icode)
              enddo
              if (FREQRF(ic,istn,ICODE).gt.FREQRF(ic_hi,istn,ICODE))then
                i = ic
                ic = ic_hi
                ic_hi = i
              endif
C             For 8-BBC stations use the loop index number to get 1-7
              kinclude_chan=.true.
              if (k8bbc) then
                call proc_check8bbc(km3be,km3ac,lwhich8,ichan,
     >                   ib,kinclude_chan)
              endif
! Skip if the LO frequency is negative.
              if(freqrf(ic,istn,icode) .lt. 0) kinclude_chan=.false.
              if (kinclude_chan) then ! include this channel
                cbuf=" "
                DRF = FREQRF(ic,istn,ICODE)
                if (klrack) then
                  if (ic.eq.ic_hi) then
C                     use centreband filters where possible
                    if (cnetsb(ic,istn,ICODE).eq."L") then
                      DRF = FREQRF(ic,istn,ICODE)
     .                      - VCBAND(ic,istn,ICODE) / 2.0
                    else
                      DRF = FREQRF(ic,istn,ICODE)
     .                      + VCBAND(ic,istn,ICODE) / 2.0
                    endif
                  else if (FREQRF(ic,istn,ICODE).eq.
     .                           FREQRF(ic_hi,istn,ICODE)) then
C                     must be simple double sideband ie. L+U
                    if (cnetsb(ic,istn,ICODE).ne.
     >                  cnetsb(ic_hi,istn,ICODE))
     .                write(luscn,9900) ic,ic_hi
9900                  format(/'PROCS00 - WARNING! Sideband',
     .                ' definitions for channels ',i2,' and ',
     .                i2,' conflict!')
                  else
C                     different frequencies must differ by bandwidth
                    if ((FREQRF(ic_hi,istn,ICODE)-FREQRF(ic,istn,ICODE))
     .              .ne.VCBAND(ic,istn,ICODE))
     .                write(luscn,9901) ic,ic_hi,ib
9901                  format (/'PROCS01 - WARNING! Channels ',i2,' and ',
     .                i2,' define IFP ',i2,' differently!')
C                     and one or other sideband must be flipped ie L+L or U+U
                    if (cnetsb(ic,istn,ICODE).ne.
     >                   cnetsb(ic_hi,istn,ICODE))
     .                     write(luscn,9900) ic,ic_hi
                    if (cnetsb(ic,istn,icode) .eq. 'L') then
C                     L+L is produced via L + flipped U
                      DRF = FREQRF(ic,istn,ICODE)
                    else
C                     U+U is produced via flipped L + U
                      DRF = FREQRF(ic_hi,istn,ICODE)
                    endif
                  endif
                endif ! klrack
                DLO = FREQLO(ic,ISTN,ICODE)
                if (DLO.lt.0.d0) then ! missing LO
                  write(luscn,9910) ic
9910              format(/'PROCS02 - WARNING! LO frequency for',
     .            ' channel ',i2,' is missing!'/
     .            '   BBC or VC frequency procedure will ',
     .            'not be correct, nor will IFD procedure.')
                  RFVC=-1.0     !set to invalid number.
                else
                  rFVC = abs(DRF-DLO)   ! BBCfreq = RFfreq - LOfreq
                endif

                fvc(ib) = rfvc
                fvc_lo(ib)=0.
                fvc_hi(ib)=0.
                if (kbbc .or.kifp.or.kvc) then
                    nch=4
                  if (kbbc) then
                    cbuf="BBC"
                  elseif(kifp) then
                    cbuf="IFP"
                  else if (kvc) then
                    cbuf="VC"
                    nch=3
                  endif
                  nch = nch + ib2as(ib,ibuf,nch,Z4000+2*Z100+2)
                  nch = ichmv_ch(IBUF,nch,'=')
                endif
                if (kk41rack.or.kk42rack) then ! k4-2
                  if (kk41rack) then ! k4-1
                    write(cbuf,'("vclo=",i2.2,",")') ib
                    nch=9
                  else ! k4-2
                    write(cbuf,'("v",a1,"lo=",a1,",")')
     >                  cvchan(ib),cvc2k42(ib)
                    nch=8
                  endif ! k4-1/2
                endif ! k4-2
! Check for valid IF input.
                kok=.false.
                if (kk41rack.or.kk42rack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "1" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "3"
                else if (kmracks) then
                  kok=cifinp(ic,istn,icode) .eq. "1N" .or.
     >                cifinp(ic,istn,icode) .eq. "2N" .or.
     >                cifinp(ic,istn,icode) .eq. "3N" .or.
     >                cifinp(ic,istn,icode) .eq. "3I" .or.
     >                cifinp(ic,istn,icode) .eq. "3O" .or.
     >                cifinp(ic,istn,icode) .eq. "1A" .or.
     >                cifinp(ic,istn,icode) .eq. "2A" .or.
     >                cifinp(ic,istn,icode) .eq. "3A"
                else if(kbbc) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "A" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "D"
                elseif (klrack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "1" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "4"
                endif
! Write IF input warking message.
                if(.not.kok) writE(luscn,9919)
     >                cifinp(ic,istn,icode), cstrack(istn)
9919               format(/'PROCS04 - WARNING! IF input ',a,' not',
     .            ' consistent with ',a)

! check RFVC values
                Kok=.true.
                if (kbbc) then
                  kok = (rfvc.ge.450.0 .and.rfvc.le.1050.0)
                else if(kmracks) then
                  kok=  (rfvc.ge.0.0   .and.rfvc.le.500.0)
                else if(kk41rack) then
                  kok = (rfvc.ge.99.99 .and.rfvc.le.511.99)
                else if(kk42rack) then
                  kok = (rfvc.ge.499.99.and.rfvc.le.999.99)
                else if(klrack)  then
                  kok = (rfvc.ge.  0.0 .and.rfvc.le.192.0)
                endif
                if(.not.kok) then
                  write(luscn,9911) ib,rfvc
9911              format(/'PROC_VC - WARNING! IF/VC/BBC ',i2,
     >            ' frequency ', f7.2,' is out of range.'/
     >            '              Check LO and IF in schedule.')
                endif

                if((km3rack .or. kk41rack) .and.
     >              vcband(ic,istn,icode).gt.7.9) then
                  write(luscn,9192) cstrack(istn)
9192              format(/'PROCS07 - WARNING! Video bandwidths ',
     .              'greater than 4 '/'  are not supported for ',a)
                endif

                NCH = nch + IR2AS(rFVC,IBUF,nch,7,2) ! converter freq

                if (kbbc) then
                  NCH = MCOMA(IBUF,NCH)
C                 Write out actual IF input from schedule file.
C                 This effectively disables the translation to VLBA IFs.
                  nch = ichmv(ibuf,nch,lifinp(ic,istn,icode),1,1)
                endif
C               Converter bandwidth
                km4done = .false.
                if (km4rack.and.(vcband(ic,istn,icode).eq.1.0.or.
     .                           vcband(ic,istn,icode).eq.0.25)) then ! external
                  NCH = ichmv_ch(ibuf,nch,',0.0(')
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                  NCH = ichmv_ch(ibuf,nch,')')
                  km4done = .true.
                else if (kmracks.or.kbbc)  then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec)) then
                     if(km3rack) then
                       nch = ichmv_ch(ibuf,nch,'4.0') ! max for K42 rec
                     else
                       nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
                     endif
                  else
                    NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,
     .                  NCH,6,3)
                  endif
                endif
C               TPI selection
                if (kmracks) then
                  NCH = MCOMA(IBUF,NCH)
C                 itras(sideband,bit,head,channel,subpass,station,code)
                  ku = itras(1,1,1,ic,1,istn,icode).ne.-99  
     .            .or.  itras(1,1,2,ic,1,istn,icode).ne.-99  ! head 2
                  kl = itras(2,1,1,ic,1,istn,icode).ne.-99
     .            .or.  itras(2,1,2,ic,1,istn,icode).ne.-99  ! head 2
C                 Find other channels that this BBC goes to.
                  DO ichanx=ic,nchan(istn,icode) !remaining channels
                    icx=invcx(ichanx,istn,icode) ! channel number
!                    ibx=ibbcx(icx,istn,icode) ! BBC number
                    if (ib.eq.ibbcx(icx,istn,icode)) then ! Same BBC?
                      kux = itras(1,1,1,icx,1,istn,icode).ne.-99
     .                 .or.  itras(1,1,2,icx,1,istn,icode).ne.-99
                      klx = itras(2,1,1,icx,1,istn,icode).ne.-99
     .                 .or.  itras(2,1,2,icx,1,istn,icode).ne.-99
                      kul = ku.and.klx .or. kux.and.kl 
                    endif
                  enddo
                  if(kul) then
                     fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)
                     fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
                     nch=ichmv_ch(ibuf,nch,'ul')
                  else if(ku) then
                     nch=ichmv_ch(ibuf,nch,'u')
                     fvc_lo(ib)=fvc(ib)
                     fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
                  else if(kl) then
                     fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)
                     fvc_hi(ib)=fvc(ib)
                     nch=ichmv_ch(ibuf,nch,'l')
                  endif
                endif
                if (kbbc.or.klrack) then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec)) then
                    nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
                  else
                    NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,
     .                     NCH,6,3)
                  endif
                endif
                if (klrack) then
                  if (ic.eq.ic_hi) then
                    nch = ichmv_ch(ibuf,nch,',SCB,') ! for single centreband filter
                  else
                    nch = ichmv_ch(ibuf,nch,',DSB,') ! for double sideband filter
                  endif
                  if(cnetsb(ic_hi,istn,ICODE).ne.'L'.and..not.klsblo.or.
     >               cnetsb(ic_hi,istn,ICODE).eq.'L'.and.klsblo) then
                    nch = ichmv_ch(ibuf,nch,'NAT,')
                  else
                    nch = ichmv_ch(ibuf,nch,'FLIP,')
                  endif
                  if (ic.ne.ic_hi) then
C                     Normally LSB so login inverts
                    if(cnetsb(ic,istn,ICODE).eq.'L'.and..not.klsblo .or.
     >                  cnetsb(ic,istn,ICODE).eq.'L'.and.klsblo) then
                      nch = ichmv_ch(ibuf,nch,'NAT')
                    else
                      nch = ichmv_ch(ibuf,nch,'FLIP')
                    endif
                  endif
                  NCH = MCOMA(IBUF,NCH)
                  cbuf(nch:nch+7)=cs2data(istn,icode)
                endif
                call lowercase_and_write(lu_outfile,cbuf)

                if (kk41rack.or.kk42rack) then ! k4
                  if (kk41rack) then ! k4-1
                    write(cbuf,'("vc=",i2.2)') ib
                  else ! k4-2
                    write(cbuf,'("v", a1,"=",a1)')
     >                  cvchan(ib),cvc2k42(ib)
                  endif ! k4-1/2
                  call lowercase_and_write(lu_outfile,cbuf)
                endif ! k4
              endif ! include this channel
            endif ! do this BBC command
            if(rfvc_max .lt. rfvc) then
               cbuf2=cbuf
               rfvc_max=rfvc
            endif
          ENDDO !loop on channels
! Here we pick up the BBCs that are present, but not used.
! This is for the RDVs.

          nch=4
          if (kvc) nch=3
          kfirst=.true.
          do ib=1,max_bbc
            if(ibbc_present(ib,istn,icode) .eq. -1) then  !present but not used.
              if(kfirst) then
                 kfirst=.false.
                 write(lu_outfile,'(a,a)') cprfix,
     >             "NOTE: following BBCs/VCs are present but not used"
              endif
              write(cbuf2(nch:nch+1),'(i2.2)') ib
              call squeezewrite(lu_outfile,cbuf2)
            endif
          end do

          if (kmracks) then
            write(lu_outfile,"('!+1s')")
            write(lu_outfile,'(a)') 'valarm'
          endif

C         For K4, use bandwidth of channel 1
          if (kk41rack) then ! k4-1
            cbuf="vcbw="
            nch=6
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'4.0')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)
          endif ! k4-1
          if (kk42rack) then ! k4-2
            cbuf="vabw="
            nch=6

            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)

            cbuf="vbbw="
            nch=6
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)

          endif ! k4-2
          write(lu_outfile,"(a)") 'enddef'
        endif ! do this
      enddo ! loop on recorders
      end
