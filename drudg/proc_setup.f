      subroutine proc_setup(icode,codtmp,ktrkf,kpcal,kpcal_d,kk4vcab,
     >   itpicd_period_use,cname_ifd,cname_vc,lwhich8,cpmode,ierr)
! include
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'
! passed
      integer icode
      logical ktrkf
      logical kpcal
      logical kpcal_d  
      logical kk4vcab
! returned
      integer itpicd_period_use
      character*12 cname_vc
      character*12 cname_ifd
      character*1 lwhich8               ! which8 BBCs used: F=first, L=last
      character*4 cpmode
      integer ierr
! functions
   

! local
      character*12 cnamep
      character*4 contcal_out
      integer ipass              !No longer have tapes
      integer ichan, ic          !counters.
      integer ifan_fact
      integer irecbw
      character*5 lform          !Mark4 or VLBA
      
      character*2  codtmp 
      integer ir

      logical kroll              !barrel roll on
      logical kman_roll          !manual barrel roll on   
      logical ktpicd
    
      real samptest
      integer num_chans_obs         	!number of channels observed
      integer num_tracks_rec_mk5        !number we record=num obs * ifan
      integer NumTracks
     
      character*80 ldum          !temporary string
     
! Start of code
      ipass=1
      irec=1
      call setup_name(ccode(icode),cnamep)
      call proc_write_define(lu_outfile,luscn,cnamep)

      kroll = .false.  
      knopass=.true.           

      ktpicd= 
     >  Km3rack.or.km4rack.or.kvrack.or.kv4rack.or.klrack.or.kdbbc_rack
     > .or. 
     > ( (km5rack.or.kv5rack) .and. (km5b .or. km5c.or.knorec(1)) ) .or.
     > knorack 
    

      if((ks2rec(irec) .and. klrack) .or. .not. ks2rec(irec)) then
         call trkall(ipass,istn,icode,
     >          cmode(istn,icode), itrk,cpmode,ifan(istn,icode))
      else
            cmode(istn,icode)="S2"
      endif

      call lowercase(cpmode)
      km3mode=cpmode(1:1).ge."a".and. cpmode(1:1).le."e"
      km3be=  cpmode(1:1).eq."b".or.  cpmode(1:1).eq."e"
      km3ac=  cpmode(1:1).eq."a".or.  cpmode(1:1).eq."c"
c-----------make sure piggy for mk3 on mk4 terminal too--2hd---
      kpiggy_km3mode =km3mode               !2hd mk3 on mk5  !------2hd---

      if(km5p_piggy .or. km5A_piggy .or. km5disk) kpiggy_km3mode=.false.

      if(k8bbc.and.(cpmode(1:1).eq."a".or.cpmode(1:1).eq."c"))then
         write(luscn,"(/,a)")
     >        " This is a Mode A or C experiment at an 8-BBC station."
         lwhich8=" "
         do while (lwhich8 .ne. "F" .or. lwhich8 .ne. "L")
           write(luscn,'(a)')
     >          " Do you want the first or last 8 channels(F/L) ? "
           read(luusr,'(A)') lwhich8
           call capitalize(lwhich8)          
         end do
      endif


! Initialize contcal_out
      if(kdbbc_rack) then
        contcal_out=contcal_prompt
        call lowercase(contcal_out)
        write(*,*) "Contcal: ",contcal_out
        do while(.not. (contcal_out .eq. "on".or.
     >                  contcal_out .eq. "off".or.
     >                  contcal_out .eq. "no" .or. 
     >                  contcal_out .eq. " "))      
         write(*,*) "Enter in cont_cal action: (on/off)"
         read(*,*) contcal_out
         call lowercase(contcal_out)
       end do
      endif 


C Find out if any channel is LSB, to decide what procedures are needed.
      klsblo=.false.
      DO ichan=1,nchan(istn,icode) !loop on channels
        ic=invcx(ichan,istn,icode) ! channel number
        if (abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode))
     >       klsblo=.true.
      enddo
      ir=1
! Old logic 
!      ktrkf =
!     >    ((kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)      ! Valid recorders
!     >      .or. Km5Disk.or.kk41rec(ir).or.kk42rec(ir)))
!     >     .and.
!     >     ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack)
!     >     .and.        ! Valid rack types.
!     >       (.not.kpiggy_km3mode  .or.Km5A_piggy .or.klsblo         ! valid "modes"
!     >       .or.((km3be.or.km3ac).and.k8bbc)))
!     >      .or. (ks2rec(ir) .and. klrack)
      
      ktrkf=km4rack .or. kvrack .or. kv4rack .or. km4fmk4rack 
    
      if(km5disk .or. knorec(1) .and. km4form) then 
        ifan_fact=max(1,ifan(istn,icode))
        call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,num_chans_obs,num_tracks_rec_mk5)
        NumTracks=num_chans_obs*ifan_fact    
        call proc_mk5_init1(num_chans_obs,num_tracks_rec_mk5,luscn,ierr)
        if(ierr .ne. 0) return
      endif


C  PCALON or PCALOFF
      if (kpcal) then
        write(lu_outfile,'(a)') 'pcalon'
      else
        write(lu_outfile,'(a)') 'pcaloff'
      endif

C  TPICD=STOP
      if(ktpicd) then
        write(lu_outfile,'(a)') 'tpicd=stop'
      endif 

      if (kvrec(irec).or.kv4rec(irec)  .or. 
     >    km3rec(irec).or.km4rec(irec) .or. 
     >    Km5disk.or. knorec(irec).or.ktrkf) then
C  PCALD=STOP
         if (kpcal_d)  write(lu_outfile,'(a)') 'pcald=stop'


C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
c..2hd..if piggy make sure mk3 modes are written
        if(ktrkf .and. .not. klrack) then !For LBA, write trkf latter
          cnamep="trkf"//codtmp         
          write(lufile,'(a)') cnamep
        endif
C  PCALFff
        if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
           call snap_pcalf(codtmp)
        endif
      endif

      if (kvrec(irec)  .or.kv4rec(irec) .or.km3rec(irec).or.
     >    km4rec(irec) .or.Km5disk .or. knorec(irec)) then 
        call proc_tracks(icode,num_tracks_rec_mk5)   
      endif 

! Output S2 Mode stuff.
      if (ks2rec(irec)) then ! S2 mode
         call proc_s2_comments(icode,kroll)
      endif ! ks2rec

C REC_MODE=<mode> for K4
C !* to mark the time
          if (kk42rec(irec).or.kk41rec(irec)) then ! K4 recorder
            call snap_rec('=synch_on')
            if (kk42rec(irec)) then ! type 2 rec_mode
              irecbw = 16.0*samprate(istn,icode)
              if(krec_append) then
                 write(ldum,'("rec_mode",a1,"=",i3)') crec(irec), irecbw
              else
                 write(ldum,'("rec_mode=",i3)') irecbw
              endif
              call squeezewrite(lu_outfile,ldum)
              write(lu_outfile,'("!*")')
            endif ! type 2 rec_mode
C  RECPff
C           No RECP procedure if it's a Mk3 mode.
            if ((km4rack.or.kvracks.or.kk41rack.or.kk42rack)
     .       .and. (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
              call snap_recp(codtmp)
            endif
          endif ! K4 recorder
C  NONE rack gets comments
          if(cstrack(istn).eq."none" .or.cstrack(istn).eq."NONE") then
            call proc_norack(icode)
          endif ! none rack comments
C  PCALD=
          if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
            write(lu_outfile,'(a)') 'pcald='
          endif

C  FORM=m,r,fan,barrel,modu   (m=mode,r=rate=2*b)
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
! Note: Don't do Form or tracks command for Mark5 formatters
       
      if((km3form .or. km4form .or. kvform) .and. .not.
     >        (ks2rec(irec) .or. kk41rec(irec) .or. kk42rec(irec))) then
              call proc_form(icode,ipass,kroll,kman_roll,lform)
      endif ! kvracks or km3rac.or.km4rack but not S2 or K4

C  BBCffb, IFPffb  or VCffb
      if (kbbc .or. kifp .or. kvc.or. kdbbc_rack) then
         call proc_vcname(kk4vcab,                    !Make the VC procedure name.
     >        ccode(icode),vcband(1,istn,icode),cname_vc)

         write(lu_outfile,'(a)') cname_vc
         cname_ifd="ifd"//codtmp
         writE(lu_outfile,'(a)') cname_ifd
       endif ! kbbc kvc kfid

       if(kdbbc_rack) then   
          write(lu_outfile,'("cont_cal=", a)') contcal_out
          ldum="bbc_gain=all,agc"
          if(idbbc_bbc_target .gt. 0) then
             write(ldum(20:30),'(",",i5)') idbbc_bbc_target
          endif 
          call squeezewrite(lu_outfile,ldum)           
       endif        

C  FORM=RESET
        if (km3rack.and..not.(ks2rec(irec).or. km5Disk))then
          write(lu_outfile,'(a)') 'form=reset'
        endif
C  !*
        if (kvrack.and..not.
     >       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then
             write(lu_outfile,'(a)') '!*'
        endif

C  TPICD=no,period
         if(ktpicd) then 
           call snap_tpicd("no",itpicd_period_use)
         endif

C DECODE=a,crc
C replaced with CHECKCRC station-specific procedure
          if ((kv4rack.or.km3rack.or.km4rack).and..not.
     .       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then ! decode commands
            samptest = samprate(istn,icode)
            if (ifan(istn,icode).gt.0)
     .        samptest=samptest/ifan(istn,icode)
            if (samptest.lt.7.5) then ! no double speed decoding
              write(lu_outfile,'(a)') 'checkcrc'
            endif
          endif ! decode commands
C !*+8s for VLBA formatter
          if (kvrack.and..not.
     >      (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then ! formatter wait
            write(lu_outfile,"('!*+8s')")
          endif

         if(km5disk .or. km5A_piggy) then
           call proc_mk5_init2(lform,ifan(istn,icode),
     >             samprate(istn,icode),num_tracks_rec_mk5,luscn,ierr)
         endif

C !*+20s for K4 type 2 recorder
        if (kk42rec(irec)) then ! formatter wait
          write(lu_outfile,"('!*+20s')")
        endif
C  PCALD
        if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
          write(lu_outfile,'(a)') 'pcald'
        endif
C  TPICD always issued
        if(ktpicd) then
          write(lu_outfile,'(a)') "tpicd"
        endif 
  
        if(km5a .or. km5a_piggy) write(lu_outfile,'(a)') "mk5=mode?"
        write(lu_outfile,'(a)') "enddef"
        return
        end 

