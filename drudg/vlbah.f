	SUBROUTINE vlbah(istin,icod,lu,ierr)
C
C   This subroutine writes the header lines and creates
C   the track and bbsynth commands for the scan blocks
C   when writing a VLBA schedule.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900720 CREATED
C     gag   901025  got rid of trailing blanks
C                   also got rid of trailing 0's in Synth line
C     gag   910513  Added parameter to nchanv and also changed parameters
C                   for the vlba common variables for multiple stations.
C     NRV   910524  Changed logic on writing BBSYN commands to create
C                   buffers and store in common.
C     NRv   921022  Add "program=" line
C     NRv   930412  implicit none
C     nrv   930708  Derive "nchan" as number of recorded tracks, for mode A
C                   and write out all 28 channels 
C     nrv   940114  Add "pcalxbit" and "pcalxfreq" commands per C. Walker
C     nrv   940707  Modify the above per Peggy for the POL version only
C     nrv   941122  Different pcalxbit and xfreq for 8-channel sequences,
C                   per Peggy
C     nrv   950628  For mode A, make nchanv=nchanv*2
C 951213 nrv Mods for new Mark IV/VLBA setup
C 960219 nrv Finish modes for new setups
C 960228 nrv Make i2bit 3-d as are other arrays passed to wrhead
C 960515 nrv Correct index for baseband, ifchan, wideband commands
C 960516 nrv Switching set for dummy is '0' not ' '
C 960709 nrv Fix "synth=" command so that only 2 synthesizers are used,
C            and 3 if we're switching.
C 961031 nrv Clean up the wordy "synth=" code.
C 961031 nrv Write out "nchanr" for the NCHAN command.
C 961101 nrv New set of pcalx commands from Craig.
C 980729 nrv Add "autoallocate" and "autoreverse" per Craig.
C 980924 nrv Remove "auto" for RDV11.
C 990106 nrv Add back in for RDVs.
C 020103 nrv Change 7010 to 5010 for phase cal freqs.
! 2008Aug19 JMG.  Rearranged and cleaned up in the process of debugging.
! 2009Sep15 JMG. Had error when computing how many bits.  Fixed.
! 2009Sep22 JMG. Got rid of unused variables
!

C
C
C  INPUT:
	integer istin ! 5=VLBA terminal, 6=VLBA antenna
      integer lu,icod
C
C  OUTPUT:
      integer ierr
C
C   SUBROUTINES
C     CALLED BY: POINT
C     CALLED: ifill,char2hol,writf_ascc,ib2as,wrhead,getqual,
C             bbsyn,ir2as
C
! functions
      integer ib2as,ichcm_ch,ir2as,ichmv_ch ! functions
      integer itras

C  LOCAL VARIABLES
!234567
      logical ksx      ! true for S/X frequencies
      logical k96      ! true if 9600 synth is in use
      logical ksw ! true if switching is being used
     
      integer immax  !maximum syn number
      integer nvc    !video converter number
      real mmaxv(max_chan)   !synth/1000
      real squal1(max_chan), squal2(max_chan) ! BBC freqs. grouped by sets
      real synthv(max_chan)  !BBC freqs

      integer isyn(max_chan) ! synthesizer numbers A=2,B=1,C=4,D=3
      integer i2bit(max_chan,max_stn,max_frq) ! 1 or 2-bit sampling per channel
      character*3 cs   !set character
 
      integer*2 ldum
      integer idum,ivcb,ix,iy,iz,ixy,i,imode,k,ileft,im,iysave
      double precision fr
      integer iset 

      character*1 lchar

C  NOTE: The header lines are written out for only the FIRST FREQUENCY
C        CODE encountered in the schedule.  If the code is changed
C        for some observations, this could be incorrect.
C You could write out a new set of header lines whenever the code
C changes within the schedule. Keep track as you go through the observations.
C       icod=1

C * comment with station name frequency code
        write(lu,'("!*",a," ",a)') cantna(istn), cnafrq(icod)
C program = experiment-name
        write(lu,'("program = ",a)') cexper

C nchanr is the number of channels to be recorded.
C For Mode A, there will be twice as many as for any mode C.
C Can't really derive nchan unambiguously by simply (?? why)
C counting the tracks assigned. Check i=1,2 for U,L and
C pass 1 only. 
C itras(ul,sm,head,chan,,pass,stn,code)

        nchanr = 0
        imode=1
        do i=1,2 ! upper,lower
          do k=1,max_chan
            if (itras(i,1,1,k,1,istn,icod).ne.-99) then
              nchanr=nchanr+1
              if (i.eq.2) imode=2 ! BOTH u/l in this mode
            endif
            if(i .eq. 1) then 
            i2bit(k,istn,icod)=1
            if (itras(i,2,1,k,1,istn,icod).ne.-99) i2bit(k,istn,icod)=2
            endif
          enddo
        enddo
C       if (nchanr.eq.28) imode=2 ! for mode A
        write(lu,'("nchan = ",i3)') nchanr

C format = <mode>
        lchar=cmode(istn,icod)(1:1)
        call capitalize(lchar)
        if(lchar .ge. "A" .and. lchar .le. "E") then
          write(lu,'(a)') "format = MARKIII"
        else ! other
          write(lu,'("format = ",a)') cmode(istn,icod)
        endif

C bits = (n,1 or 2) ... where n=1,nchan and 1 or 2 bits sampling
        call wrhead(lu,ierr,'bits = ',idum,i2bit,ldum,3,imode,icod)

C samplerate = 2*vcbandwidthM, use channel 1 only
C ******** should write out per channel, not juse channel 1   
        ivcb=2*vcband(1,istn,icod)       
        write(lu,'("samplerate = ",i2,"M")') ivcb
           
C period = (n,1), ...  where n=1 to nchan
        call wrhead(lu,ierr,'period = ',1,idum,ldum,1,imode,icod)
        if (ierr.ne.0) then
          write(luscn,9100)
9100    format(' VLBAH01 - Error writing period section of header.')
          ierr = 0
        end if

C bbfilter = (n,vcbandwidth M), ...  where n=1 to nchan
C ******** should write out per channel, not juse channel 1
        ivcb=vcband(1,istn,icod)
        call wrhead(lu,ierr,'bbfilter = ',ivcb,idum,ldum,2,imode,icod)
        if (ierr.ne.0) then
          write(luscn,'(a)')
     >     ' VLBAH02 - Error writing bbfilter section of header.'
          ierr = 0
        end if

C level = (n,-1), ...  where n=1 to nchan
        call wrhead(lu,ierr,'level = ',-1,idum,ldum,1,imode,icod)
        if (ierr.ne.0) then
          write(luscn,9300)
9300    format(' VLBAH03 - Error writing level section of header.')
          ierr = 0
	end if

C baseband = (n,BBC#(n)), ... where n=1 to nchan
C should perhaps be an indirect array instead of invcx, like ivix??
C invcx IS an indirect array -- should not use one
        call wrhead(lu,ierr,'baseband = ',idum,ibbcx,ldum,3,imode,icod)
        if (ierr.ne.0) then
          write(luscn,9400)
9400    format(' VLBAH04 - Error writing baseband section of header.')
          ierr = 0
        end if

C ifchan = (n,IFchan(n)), ... where n=1 to nchan
        call wrhead(lu,ierr,'ifchan = ',idum,idum,lifinp,4,imode,icod)
        if (ierr.ne.0) then
          write(luscn,9500)
9500    format(' VLBAH05 - Error writing ifchan section of header.')
          ierr = 0
        end if

C sideband = (n,SB(n)), ... where n=1 to nchan
        call wrhead(lu,ierr,'sideband = ',idum,idum,losb,4,imode,icod)
        if (ierr.ne.0) then
          write(luscn,9600)
9600    format(' VLBAH06 - Error writing sideband section of header.')
          ierr = 0
        end if

C bbsynth = (n,abs[VCfreq(vc(n))-Synth(n))], ...
C       where n=1 to nchan for unswitched sequences
C (For switched sequences, include only channels that have Set=1,2.)
C bbsynth = (1,610.99),(2,650.99),(3,730.99),(4,970.99)
C bbsynth = (5,677.01),(6,662.01),(7,607.01),(8,597.01)
C For the switched R&D sequence:
C bbsynth = (1,612.99),(8,667.01),(9,679.01),(10,669.01),(14,554.01)

        do ix=1,nchan(istn,icod) !calculate BBC frequencies
          nvc = invcx(ix,istn,icod)
          synthv(ix) = abs(freqrf(nvc,istn,icod)-freqlo(nvc,istn,icod))
          ksw=cset(nvc,istn,icod).ne.'   '
        end do

        if (ksw) then ! set up arrays with freqs by mode
          do ix=1,nchan(istn,icod)
            nvc = invcx(ix,istn,icod)
            cs = cset(nvc,istn,icod)
            if (cs.eq.'1,2') then
        	squal1(ix) = 0.0
        	squal2(ix) = 0.0
            else
        	if (cs(1:1).eq.'0') then
        	   call getqual('1',ix,icod,squal1)
        	   call getqual('2',ix,icod,squal2)
        	else if (cs(1:1).eq.'1') then
        	  squal1(ix) = synthv(ix)
        	  call getqual('2',ix,icod,squal2)
        	else if (cs(1:1).eq.'2') then
        	  squal2(ix) = synthv(ix)
        	  call getqual('1',ix,icod,squal1)
        	end if
            end if
          end do
C       Create buffers with switched frequencies
          call bbbuf(1,icod,squal1)
          call bbbuf(2,icod,squal2)
        end if

C  Now write out the unswitched frequencies in the header
        ileft = o'100002'
        iz = 0 ! channel counter

        do ix=1,nchan(istn,icod)
          if(mod(iz,5) .eq. 0) then    !start a new line. 
            cbuf="bbsynth ="
            iy=11 ! character counter within buffer
          endif
          nvc=invcx(ix,istn,icod)
          cs = cset(nvc,istn,icod)
          if (((ksw).and.(cs(1:3).eq.'1,2')).or. (.not.ksw)) then
           do im=1,imode
              iy = ichmv_ch(ibuf,iy,'(')
	      iz = iz + 1
C             Use iz counter for mode A, imode=2
              if (imode.eq.1) iy = iy + ib2as(ix,ibuf,iy,ileft)
C             Use actual ix counter for "normal" modes
              if (imode.eq.2) iy = iy + ib2as(iz,ibuf,iy,ileft)
              iy = ichmv_ch(ibuf,iy,',')
              iy = iy + ir2as(synthv(ix),ibuf,iy,6,2)
              iy = ichmv_ch(ibuf,iy,')')
              if (mod(iz,5).eq.0) then ! have 5 frequencies on the line
                write(lu,'(a)') cbuf(1:iy)        	                       
              else
                cbuf(iy:iy)=","
                iy=iy+1       
              endif
            enddo
          end if
        end do
        if (mod(iz,5).ne.0) then ! write out what's left on the line
          write(lu,'(a)') cbuf(1:iy-2)     ! iy-2 because we don't want last comma.
        end if

C Write out BBCs
        do iset=1,2
          do i=1,nbbcbuf(iset)
            if(iset .eq. 2) write(lu,'("!* ",$)') 
            write(lu,'(a)') cbbcbuf(iset,i)(1:ibbclen(iset,i))      
          enddo
        end do

C logging = special
        if (istin.eq.5) then
          write(lu,'(a)')    'logging = special '
        endif

C autoallocate=on
C autoreverse=on
        if(tape_allocation(istn).eq.'AUTO') then 
          write(lu,'(a)') 'autoallocate=on '
          write(lu,'(a)') 'autoreverse=on '
        endif
C  Following lines are written out only for VLBA antennas

        if (istin.eq.6) then !VLBA antennas
C
C fe = (1,13cm),(2,4cm),(3,13cm),(4,4cm) if any RF freqs are
C     between 8-9 or 2-3 GHz
C !* Don't know what the front end is ... for others

        ksx = .false.
        do ix=1,nchan(istn,icod)
          nvc=invcx(ix,istn,icod)
          fr = freqrf(nvc,istn,icod)
          if ((fr.lt.9000.0.and.fr.gt.8000.0).or.
     .      (fr.lt.3000.0.and.fr.gt.2000.0)) ksx=.true.
        enddo
        if (ksx) then
          write(lu,'(a)') 'fe = (1,13cm),(2,4cm),(3,13cm),(4,4cm)'
        else
          write(lu,'(a)') '!* fe = unknown front end '
        end if

C noise = (1,low-s),(2,low-s),(3,low-s),(4,low-s)   for all codes
        write(lu,'(a)')'noise = (1,low-s),(2,low-s),(3,low-s),(4,low-s)'
        
C PCAL = 1MHz
        write(lu,'(a)') 'pcal = 1MHZ '
C   These lines allow the use of the pcal extractors on the DS board.
        if (nchanr.eq.16) then ! probably u/l mode
          write(lu,'(a)')  'pcalxbit1='//
     >     '(1,S1),(2,S3),(3,S5),(4,S7),(5,S9),(6,S11),(7,S13),(8,15)'
          write(lu,'(a)') 'pcalxbit2='//
     >     '(1,S2),(2,S4),(3,S6),(4,S8),(5,S10),(6,S12),(7,S14),(8,16)'
          write(lu,'(a)') 'pcalxfreq1='//
     >     '(1,10),(2,10),(3,10),(4,10),(5,10),(6,10),(7,10),(8,10)'
          write(lu,'(A)') 'pcalxfreq2= (1,990),(2,990),'//
     >     '(3,990),(4,990),(5,990),(6,990),(7,990),(8,990)'
C   If nchan=14 use these lines.
        else if (nchan(istn,icod).eq.14) then
          write(lu,'(a)') 'pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),'//
     >      '(5,S9),(6,S11),(7,S13),(8,S1)'
          write(lu,'(a)') 'pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),'//
     >       '(5,S10),(6,S12),(7,S14),(8,S9)'
          write(lu,'(a)') 'pcalxfreq1=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,10),(6,10),(7,10),(8,0)'
          write(lu,'(a)') 'pcalxfreq2=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,10),(6,10),(7,10),(8,0)'
C   If nchan=8 use these lines.
        else if (nchan(istn,icod).eq.8) then
          write(lu,'(a)') 'pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),'//
     >       '(5,S1),(6,S3),(7,S5),(8,S7)'
          write(lu,'(a)') 'pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),'//
     >       '(5,S2),(6,S4),(7,S6),(8,S8)'
          if (ivcb.eq.8) then ! 8 MHz bandwidth use 5010
            write(lu,'(a)')  'pcalxfreq1=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,5010),(6,5010),(7,5010),(8,5010)'
            write(lu,'(a)') 'pcalxfreq2=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,5010),(6,5010),(7,5010),(8,5010)'
          else if (ivcb.eq.4) then ! 4 MHz bandwidth
            write(lu,'(A)') 'pcalxfreq1=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,3010),(6,3010),(7,3010),(8,3010) '
            write(lu,'(a)') 'pcalxfreq2=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,3010),(6,3010),(7,3010),(8,3010) '
          else if (ivcb.eq.2) then ! 2 MHz bandwidth
            write(lu,'(a)') 'pcalxfreq1=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,1010),(6,1010),(7,1010),(8,1010) '
            write(lu,'(A)') 'pcalxfreq2=(1,10),(2,10),(3,10),(4,10),'//
     >       '(5,1010),(6,1010),(7,1010),(8,1010) '
          endif ! multiple bandwidth choices
        endif

C synth = (m,Synth(m)/1000), ... where m=1 to nsynth and nsynth=
C         either 1 or 2 or 3. 3 is used only for switched.

        do ix=1,nchan(istn,icod)
          nvc=invcx(ix,istn,icod)
          lchar=cifinp(nvc,istn,icod)(1:1)
          if(lchar.eq."A")  isyn(nvc)=2 ! S
          if(lchar.eq."B")  isyn(nvc)=1 ! X
          if(lchar.eq."D")  isyn(nvc)=3 ! Xu
        enddo
        immax = -1
C       Find highest value of isyn (1, 2, or 3)
        do ix=1,nchan(istn,icod)
          nvc=invcx(ix,istn,icod)
          if (immax.lt.isyn(nvc)) then
            immax = isyn(nvc)
          end if
        end do
        do ix=1,immax
          iy = 1
          do while (iy.le.nchan(istn,icod))
            nvc=invcx(iy,istn,icod)
            if (ix.eq.isyn(nvc)) then
        	mmaxv(ix) = freqlo(nvc,istn,icod)/1000.0
        	iy = nchan(istn,icod)
            end if
            iy = iy + 1
          end do
        end do

        cbuf='synth = '
        iy=9
        k96=.false.
        do ix=1,immax
          iy = ichmv_ch(ibuf,iy,'(')
          iy = iy + ib2as(ix,ibuf,iy,ileft)
          iy = ichmv_ch(ibuf,iy,',')
          iysave=iy
          iy = iy + ir2as(mmaxv(ix),ibuf,iy,6,4)
          if (ichcm_ch(ibuf,iysave,'9.6').eq.0) k96=.true.
          ixy = 1
          do while (ixy.eq.1) ! strip trailing zeros
            if (ichcm_ch(ibuf,iy-1,'0').eq.0) then
        	iy = iy - 1
            else
        	ixy = 2
            end if
          end do
          iy = ichmv_ch(ibuf,iy,')')
        end do
        write(lu,'(a)') cbuf(1:iy-1)     

C ifdistr = (1,0),(2,0),(3,0),(4,0)   for all codes
        write(lu,'(a)') 'ifdistr = (1,0),(2,0),(3,0),(4,0) '
C fexfer = (2,split)  for switched sequences only
C Change to check for the use of 9600 synthesizer to determine 
C if transfer switch is on.

        if (k96) then
          write(lu,'(a)') 'fexfer = (2,split)'
        end if

C logging = standard
        write(lu,'(a)') 'logging = standard '
      endif !VLBA antennas

      RETURN
      END
