      subroutine equip_type(cr1)
C  equip_set displays the current equipment and prompts the user
C  to change if desired.
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/valid_hardware.ftni'
C History
C 990730 nrv New.
C 990910 nrv Add warning message. Change LMODE and LMFMT from 'v' to
C            'm' or vice versa when needed.
C 990914 nrv Force bit density to 33333 for V-->M.
C 990914 nrv Force bit density to 34020 for M-->V.
C 991028 nrv Second recorder. Fix index bugs.
C 991101 nrv Starting recorder.
C 991102 nrv Don't print CHANGE message if no change. Don't change to
C            a recorder that is set to 'none'.
C 991103 nrv Force first recorder to A or B if the other one is 'none'.
C 991110 nrv K4, S2, and Mk3 can only be A and B must be none.
C 991123 nrv Recorders 1 and 2.
C 991208 nrv Check for 'unused' type.
C 991210 nrv Remove restriction on K4,S2,Mk3 as first recorder, i.e.
C            second recorder can be whatever is legal.
C 991211 nrv Mk3A is legal rec 2. Use max_rec2_type instead of a number.
C 000321 nrv For non-K4 FS restrict types to be displayed.
C 000814 nrv For FS 9.5 display all types.
C 010820 nrv Don't switch mode M to V, ok to switch V to M.
C 020515 nrv Check length of rack/rec name as well as letters, so
C            that "VLBA" does not match "VLBA4" if only the first
C            four letters are checked.
C 17Apr2003  JMG.  Added Mark5 option.
! 2005Feb15  JMG. Got rid of most holleriths.
! 2006Jul20. JMG. Disabled switching to Mark3 rack if not Mark3 mode.
! 2007Jun13  JMG. Modified so that would all fit on one page.
! 2008Oct20  JMG. Better error messages.
! 2012Sep13  JMG. Tempoary fix so that don't show Mark5C.  (Search for 2012Sep13)

C Input:
      character*(*) cr1
! functions
      integer trimlen
      integer iwhere_in_string_list
C LOCAL:
      integer ich,ic1,ic2,i,nch,irack,irec1,irec2,ic
      integer irack_in,irec1_in,irec2_in,ifirst_rec
      integer ias2b
      integer max_equip_lines
      parameter (max_equip_lines=max(max_rack_type,max_rec_type))
      integer max_rack_local,max_rec_local,max_rec2_local
      character*12 crack_slot,crec1_slot,crec2_slot
      character*4  cfirst_slot

      character*1 cactive
      character*2 crec1
      character*1 lchar

C 0. Determine current types.

        max_rack_local = max_rack_type

! 2012Sep13 
        max_rec_local = max_rec_type-1
        if(Km5A_piggy .or.km5p_piggy) then
          max_rec_local=max_rec_local-3   !exclude Mark5A & Mark5P modes.
        endif

        max_rec2_local = max_rec2_type
!        max_equip_lines=max(max_rack_local,max_rec_local)

        irack_in=iwhere_in_string_list(crack_type,max_rack_local,
     >    cstrack(istn))

        irec1_in=iwhere_in_string_list(crec_type,max_rec_local,
     >    cstrec(istn,1))

        irec2_in=iwhere_in_string_list(crec_type,max_rec_local,
     >    cstrec(istn,2))

        if(cfirstrec(istn) .eq. "1") then
           ifirst_rec=1
        else
           ifirst_rec=2
        endif
        write(*,*) "RACK ",irack_in, irec1_in, irec2_in 
        write(*,*) cstrack(istn), cstrec(istn,1), cstrec(istn,2)
           
        

C 1. Batch input

      if (kbatch) then
        read(cr1,*,err=991) irack,irec1,irec2,crec1
991     if (irack.lt.1.or.irack.gt.max_rack_local) then
          write(luscn,9991) max_rack_local
9991      format("ERROR: Max rack types between 1 and ",i4)
          return
        endif
        if (irec1.lt.1.or.irec1.gt.max_rec_local-1) then
!2012Sep13
          write(luscn,9992) max_rec_local-1
9992      format("ERROR: Max rec types1 between 1 and ",i4)
          return
        endif
        if (irec2.lt.1.or.irec2.gt.max_rec_local.or.
     .    irec2.gt.max_rec2_local) then
          write(luscn,9993) max_rec2_local
9993      format("ERROR: Max rec types2 between 1 and ",i4)
          return
        endif
        if (crec1.ne.'1'.and.crec1.ne.'2') then
          write(luscn,9994)
9994      format('EQUIP06 - Invalid starting recorder')
          return
        else
          crec1=" "
        endif

C 2. Interactive input

      else ! interactive
 1      WRITE(LUSCN,9019) cantna(ISTN),
     >  cstrack(istn),cstrec(istn,1),cstrec(istn,2)

9019    FORMAT(a8,' equipment: Rack=',a8,' Recorder1=',a8
     >       ' Recorder2=',a8)

        write(luscn,'(a)')
     .       '| Select rack  | Select Rec 1 | Select Rec 2 | Start|'
! We subtract 1 from max_equip_lines, max_rack_type and max_rec_type
!  so we don't display the "unknwon" option.
          do i=1,max_equip_lines-1 ! write each line
            if(i .le. max_rack_type-1) then
              if(irack_in .eq. i) then
                cactive="*"
              else
                cactive=" "
              endif
              write(crack_slot,'(a1,i2,"=",a8)') cactive,i,crack_type(i)
            else
              crack_slot=" "
            endif
! JMG 2012Sep13  Temporary fix!!!
            if(i .le. max_rec_type-2) then
              if(irec1_in .eq. i) then
                cactive="*"
              else
                cactive=" "
              endif
              write(crec1_slot,'(a1,i2,"=",a8)') cactive,i,crec_type(i)
            else
              crec1_slot=" "
            endif
            if(i .le. max_rec2_type) then
              if(irec2_in .eq. i) then
                cactive="*"
              else
                cactive=" "
              endif
              write(crec2_slot,'(a1,i2,"=",a8)') cactive,i,crec_type(i)
            else
              crec2_slot=" "
            endif
            if(i .le. 2) then
              if(ifirst_rec .eq. i) then
                 cactive="*"
              else
                 cactive=" "
              endif
              write(cfirst_slot,'(a,i2)') cactive,i
            else
              cfirst_slot=" "
            endif
            write(luscn,'("| ",4(a,1x,"|",1x))') crack_slot,crec1_slot,
     >         crec2_slot,cfirst_slot
          enddo
!          write(luscn,'(a)')
!     >     '|  0=no change |  0=no change |  0=no change | 0=no change'
          write(luscn,'(a)')
     >   ' Press <ret> or type 0 for no change. '//
     >   ' Else <rack><rec1><rec2><start> '
          write(luscn,'(a)')
     >      "CAUTION! Be sure the schedule works with your choices!"

        irack=0
        irec1=0
        irec2=0
        crec1="0 "
        read(luusr,'(a)') cbuf
        nch=trimlen(cbuf)
        ich=1
        call gtfld(ibuf,ich,nch,ic1,ic2) ! rack field
        if (ic1.eq.0) return
        irack= ias2b(ibuf(1),ic1,ic2-ic1+1)
        IF (irack.LT.0.OR.(irack.GT.max_rack_local)) then
          write(luscn,9991) max_rack_local
          GOTO 1
        endif
        call gtfld(ibuf,ich,nch,ic1,ic2) ! rec1 field
        if (ic1.ne.0) then ! rec1 specified
          irec1= ias2b(ibuf(1),ic1,ic2-ic1+1)
!2012Sep13
          IF (irec1.LT.0.OR.(irec1.GT.max_rec_local-1)) then
            write(luscn,9992) max_rec_local
            GOTO 1
          endif
          call gtfld(ibuf,ich,nch,ic1,ic2) ! rec2 field
          if (ic1.ne.0) then ! rec2 specified
            irec2= ias2b(ibuf(1),ic1,ic2-ic1+1)
            IF (irec2.LT.0.OR.(irec2.GT.max_rec_local).or.
     .        irec2.gt.max_rec2_local) then
              write(luscn,9993) max_rec2_local
              GOTO 1
            endif
            call gtfld(ibuf,ich,nch,ic1,ic2) ! starting rec field
            if (ic1.ne.0) then ! rec1 specified
!              idum = ichmv(lrec1,1,ibuf,ic1,1)
              crec1=cbuf(ic1:ic1)
              if (crec1 .ne. "0" .and. crec1 .ne. "1" .and.
     >            crec1 .ne. "2") then
                write(luscn,9994)
                GOTO 1
              endif
            endif ! rec1 specified
          endif ! rec2 specified
        endif ! rec1 specified
      endif ! batch/interactive

C 3. Modify rack type

C Now modify the common variables and send warnings.
        if (irack.ne.0) then ! modify
          if (crack_type(irack) .eq. "unknown") then
            call write_error_and_pause(luscn,
     >       "EQUIP_TYPE: Warning! Can't change to unknown rack type!")
          else if (irack.ge.1.and.irack.le.max_rack_local) then
            lchar=cmode(istn,1)
            call capitalize(lchar)
            if(irack .eq. 2) then
              if(cstrack(istn) .ne. "Mark4" .and.
     >           cstrack(istn) .ne. "Mark3A") then
                nch=trimlen(cstrack(istn))
                call write_error_and_pause(luscn,
     >             "WARNING: Can not change "//cstrack(istn)(1:nch)//
     >             " rack to Mark3A!")
                return
              else if(.not. (lchar.ge."A".and.lchar.le."E") ) then
                call write_error_and_pause(luscn,
     >          "Can't change to Mark3A rack with non-Mark3A Mode: "//
     >           cmode(istn,1))
               return
              endif
            endif
            if (cstrack(istn) .ne. crack_type(irack)) then
              write(luscn,901) cantna(istn),
     >          cstrack(istn),crack_type(irack)
901           format('EQUIP05 - CHANGED ',a,' rack from ',
     >        a8,' to ',a)
              cstrack(istn)=crack_type(irack)
            endif ! change
C Retain switching from V mode to M if it's a Mk4 or VLBA4 
C formatter because they can't record V modes.
            if( cmode(istn,1) .eq. "VLBA" .and.
     >          (cstrack(istn)(1:5) .eq. "Mark4" .or.
     >           cstrack(istn)(1:5) .eq. "Mark3" .or.
     >           cstrack(istn)(1:5) .eq. "VLBA4")) then
              do ic=1,ncodes
                write(luscn,903) cnafrq(ic)
903             format('EQUIP01 - WARNING: changed recording ',
     .           'format for mode ',a,' from VLBA to Mk4.')
!                idum = ichmv_ch(lmfmt(1,istn,ic),1,'M       ')
                cmfmt(istn,ic)='M'
                if (bitdens(istn,ic).lt.40000.d0) then
                  bitdens(istn,ic) = 33333.0
                else
                  bitdens(istn,ic) = 56250.0
                endif
                write(luscn,907) bitdens(istn,ic)
907             format('EQUIP06 - WARNING: changed recording ',
     .           'bit density to ',f8.0)
                write(luscn,905)
905             format('NOTE: The schedule may not be consistent ',
     .           ' with this change.')
              enddo
            endif ! v--> M
          endif
        endif

C 4. Modify rec 1

      if((irec1.ge.1.and.irec1.le.max_rec_local) .and.
     >     (cstrec(istn,1) .ne. crec_type(irec1))) then
         if(crec_type(irec1) .eq. "unknown") then
            call write_error_and_pause(luscn,
     >    "EQUIP_TYPE: Warning! Can't change to recorder type unknown!")
         else
           write(luscn,902) cantna(istn),cstrec(istn,1),crec_type(irec1)
902        format('EQUIP03 - CHANGED ',a,' rec1 from ',a,' to ',a)
           cstrec(istn,1)=crec_type(irec1)
         endif
      endif

C 5. Modify rec 2
C    If rec 1 is K4, S2 or Mk3 then can't have rec 2
      if((irec2.ge.1.and.irec2.le.max_rec2_local) .and.
     >    (cstrec(istn,2) .ne. crec_type(irec2))) then
        write(luscn,909) cantna(istn),cstrec(istn,2),crec_type(irec2)
909     format('EQUIP09 - CHANGED ',a,' recor2 from ',a,' to ',a)
        cstrec(istn,2)=crec_type(irec2)
        if (nrecst(istn).eq.1.and.irec2.gt.1) then
          write(luscn,910) cantna(istn)
910       format('EQUIP10 - WARNING: Second recorder was added to ',
     .        'the equipment for ',a,'.')
          nrecst(istn)=2
        else if (nrecst(istn).eq.2.and.irec2.eq.1) then
          write(luscn,911) cantna(istn)
911       format('EQUIP11 - WARNING: Second recorder was removed ',
     .        'from equipment for ',a8,'.')
          nrecst(istn)=1
        endif
      endif ! modify rec2

C 6. Modify first recorder

      if(crec1 .eq.'0' .or. cfirstrec(istn) .eq. crec1) then
         continue       ! no change.
      else if((crec1 .eq. '1' .and.
     >   (cstrec(istn,1).eq.'unused'.or.cstrec(istn,1).eq.'none'))
     >    .or. (crec1 .eq. '2' .and.
     >   (cstrec(istn,2).eq.'unused'.or.cstrec(istn,2).eq.'none'))) then
            write(luscn,'(a,a,/,a)')
     >   "EQUIP12 - Can't start the schedule with Recorder ",crec1,
     >   " because it is set to 'none' or 'unused'."
      else
        write(luscn,912) cantna(istn), cfirstrec(istn),crec1
912     format('EQUIP13: CHANGED ',a,' first recorder from ',a,' to ',a)
        cfirstrec(istn)=crec1
      endif !modify firstrec
      return
      end
