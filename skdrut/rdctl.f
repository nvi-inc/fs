      SUBROUTINE rdctl(                                             ! Start with sked params
     >   source_cat,station_cat,antenna_cat,position_cat,           ! 4 on each line
     >   equip_cat, mask_cat,   freq_cat,   rx_cat,                 ! 4 on each line
     >   loif_cat,  modes_cat,  modes_description_cat,  rec_cat,
     >   hdpos_cat, tracks_cat,flux_cat,flux_comments,
     >   cmaster_dir, cat_program_path, par_program_path,          ! 3
     .   csked,csnap,cproc,
     .   ctmpnam,cprtlan,cprtpor,cprttyp,cprport,
     .   cprtlab,clabtyp,rlabsize,cepoch,coption,luscn,
     .   dr_rack_type,crec_default,
     >   kequip_over,
     >   tpid_prompt,itpid_period,contcal_prompt)
C
C  This routine will open the default control file for 
C  directories and devices to use with SKED. Then it will
C  open a user's local control file. Any information in 
C  this file will overwrite same-named information found
C  in system control file.
C
C   HISTORY:
C     gag   900212 created
C     NRV   901018 Added "printer" line in $PRINT section
C     nrv   950329 Added flux_comments
C     nrv   950925 Add full code for printer line in $PRINT
c 951124 nrv Change calling sequence for new catalog names
C 960226 nrv Add "cprtlab" for script to print labels
C 960403 nrv Add "rec_cat" to call
C 970207 nrv Add cepoch to call. Add to $MISC section.
C            Allow null script names.
C 970228 nrv Add "label_printer" key word and "clabtyp" to call. 
C 970228 nrv Add "label_size" key word and "rlabsize" to call.
C 970304 nrv Add "cproc" to call, change "cdrudg" to "csnap".
C 970304 nrv Add "option1", "option4", "option5" key words and options,
C                and add "coption" to call.
C 970328 nrv Add "station_cat"
C 991101 nrv Add EQUIPMENT line 
C 991117 nrv Add cat_program_path
C 991211 nrv Add check against max_rec2_type.
C 000326 nrv Add par_program_path.
C 020508 nrv Add TPI daemon controls for drudg.
C 020524 nrv Set TPICD defaults.
C 021010 nrv Remove check for rack and recorder names because these
C            names are not known until skdrini is called later. Just
C            send the names back.
! 2004    JMGipson
!            modified to use extract_token etc.
! 2004Oct14-17.  Fixed two problems in above conversion
!          1. In printer commands, some stations assumed that drudg read
!             rest of line after keyword. (As was done in earlier versions.)
!             This version used to read just the value. Now made backward compatible.
!          2. Previous versions of drudg assigned keyword of line "optionX  YY" to
!             coption(1,2,3) where X =1,4,5.  Made an error in trying to assign to coption(X),
!             e.g., if X=4, would assign to coption(4).  Fixed to agree with previous usage.
! 2005Jul26 JMGipson.  Added disk2file_dir,_node,_userid.
! 2006Jun13 JMGipson.  Added disk2file_script. Removed all disk2file stuff from argument
!                      list and put in common.
! 2006Jun29 JMGipson. Modified to get rid of old disk2file stuff. Now just processes lines:
!              Autoftp on diskf2file_string
!              disk2file_Dir disk2fiel
! 2006Jul19 JMGipson. Changed ldisk2file_string ->lautoftp_string.
!           For ldisk2file_dir, csnap, and cproc, add an ending "/" if neded.
! 2006Oct18 JMGipson. Initilaized rlabsize which is used in drudg.
! 2006Nov30 JMGipson. Combined dr_reca_type, dr_recb_type into crec_default
! 2007Jul24 JMGipson. Check on valid rack and recorder types in equip.
!           Also check if equip_override is on that we have actually chosen recorders!
! 2008Oct08 JMGipson.  Add "/" if needed for scracth directory and sked directory
! 2008Oct20 JMGipson.  Changed readline_skdrut call to readline_skdrut_skdrut
! 2009Sep09 JMGipson.  Added cat_dir = default catalog directory.
! 2012Sep20 JMGipson.  If default 'global' skedf.ctl does not exist, try alternatives.
!                     Added Cont_Cal option.
C
C   parameter file
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/data_xfer.ftni'   !This includes info about data transfer
      include '../skdrincl/mysql_common.i'
      include '../skdrincl/valid_hardware.ftni'

! Passed
      character*128  source_cat,station_cat,antenna_cat,position_cat,
     .equip_cat,modes_description_cat,cat_program_path,
     .               par_program_path,
     .               mask_cat,freq_cat,rx_cat,loif_cat,modes_cat,
     .               hdpos_cat,tracks_cat,flux_cat,flux_comments,
     .               rec_cat,cmaster_dir,
     >               csked,csnap,cproc,ctmpnam,cprtlab,
     .               cprtlan,cprtpor,cprttyp,cprport,clabtyp

      character*4  tpid_prompt
      character*4  contcal_prompt
      character*4 cepoch
      character*8 dr_rack_type,crec_default(2)
      logical kequip_over
      real rlabsize(6)
      character*2 coption(3)
      integer luscn,itpid_period
! functions
      integer iwhere_in_string_list
      integer  trimlen     !function call
C
C  LOCAL VARIABLES
      integer ind,nch
      integer itmplen          !variable for filename length
      logical*4 kexist         !control file existence
      character*128 ctemp      !temporary control file variable
      character*10 lsecname
      character*3 lprompt
      integer itemp
      character*20 lkeyword     !keyword
      character*128 lvalue      !value
      character*128 cat_dir     !default catalog directory
      integer nch_cat_dir       !length

      integer MaxToken
      integer NumToken
      parameter(MaxToken=6)
      character*128 ltoken(MaxToken)
      equivalence (lkeyword,ltoken(1))
      equivalence (lvalue,ltoken(2))

      integer lu          !open lu
      integer ic,i,j,ilen,ierr
      character*256 cbuf
      logical ktoken
      logical keof      !EOF reached in reading in file
      logical kfound_global_file

      character*32 cskedf(3)   
      data cskedf/
     > "/usr/local/bin/skedf.ctl", "/usr2/control/skedf.ctl",
     > "skedf.ctl"/ 

C  1. Open the default control file if it exists.   

! Initialization

      kfound_global_file=.false. 
! Avery 5160. ht,wid,rows,cols,top,left
      rlabsize(1)=1.0
      rlabsize(2)=2.625
      rlabsize(3)=10
      rlabsize(4)=3
      rlabsize(5)=0.5
      rlabsize(6)=0.3125

      ilen = 0
      ierr = 0
      lu = 11
      kequip_over=.false.         !initialize
      dr_rack_type    = "UNKNOWN"
      crec_default(1) = "UNKNOWN"
      crec_default(2) = "NONE"
      cmaster_dir="NONE"
      cat_dir=" "
      nch_cat_dir=0

      kautoftp0=.false.
      ldisk2file_dir0 =" "
      lautoftp_string0=" "

C  2. Process the control file if it exists. Loop throug 3 times.
!     The first two times check for the global skedf.ctl
!     The last time for the local file. 

      do j=1,3      
! If already found the global file, don't need to check the alternative.
        if(j .eq. 2 .and. kfound_global_file) goto 500    !quick exit. 
! If we are the start of the third round and haven't found the global file, 
! write a warning message but try to read the local file. 
        if(j .eq. 3 .and. .not.kfound_global_file) then
         write(luscn,
     >   '("WARNING! Rdctl: Did not find global skedf.ctl file:",a)')
     >       cskedf(1)(1:trimlen(cskedf(1)))
         write(luscn,
     >    '("                or alternate global skedf.ctl file:",a)') 
     >       cskedf(2)(1:trimlen(cskedf(2)))                 
        end if

        itmplen = trimlen(cskedf(j))
        kexist = .false.
        inquire(file=cskedf(j),exist=kexist)      
        if(.not.kexist) goto 500                !quick exit. 

        open(lu,file=cskedf(j),iostat=ierr,status='old')
        if (ierr.ne.0) then
          write(luscn,9100) cskedf(j)(1:itmplen)
9100      format("RDCTL01 ERROR: Error opening control file ",A)
          close(lu)
          return
        end if

        if(j .le. 2) then
          write(luscn,9105) cskedf(j)(1:itmplen)
9105      format("RDCTL02 - Reading system control file ",A)
          kfound_global_file=.true. 
        else
          write(luscn,9106) cskedf(j)(1:itmplen)
9106      format("RDCTL02 - Reading local control file ",A)
        endif

! File exists, and we have opened it.    
        call readline_skdrut(lu,cbuf,keof,ierr,1) !read first $
        do while (.not.keof)
          read(cbuf,'(a)') lsecname
          call capitalize(lsecname)
          call readline_skdrut(lu,cbuf,keof,ierr,2)  !space to next valid line.

C  $CATALOGS
          if (lsecname .eq. "$CATALOGS") then
            do while(.not.keof .and.(cbuf(1:1) .ne. "$"))
              call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
              call capitalize(lkeyword)
! Special case--setting default catalog.
              if(lkeyword .eq. 'CAT_DIR') then
                cat_dir=lvalue
                nch_cat_dir=trimlen(cat_dir)
                if(cat_dir(nch_cat_dir:nch_cat_dir) .ne. "/") then
                   nch_cat_dir=nch_cat_dir+1
                   cat_dir(nch_cat_dir:nch_cat_dir)="/"
                endif
                goto 9200
              endif
! It is assumed that the rest of the values are catalog paths
              if(lvalue(1:1) .ne. "/") then     ! If we don't start with '/', prepend catalog directory
                  nch=trimlen(lvalue)
                  ctemp=cat_dir(1:nch_cat_dir)//lvalue(1:nch)
                  lvalue=ctemp
              endif

              if (lkeyword.eq.'SOURCE') then
                 source_cat=lvalue
              else if (lkeyword.eq.'STATION') then
                 station_cat=lvalue
              else if (lkeyword.eq.'ANTENNA') then
                 antenna_cat=lvalue
              else if (lkeyword.eq.'POSITION') then
                 position_cat=lvalue
              else if (lkeyword.eq.'EQUIP') then
                 equip_cat=lvalue
              else if (lkeyword.eq.'MASK') then
                 mask_cat=lvalue
              else if (lkeyword.eq.'FREQ') then
                 freq_cat=lvalue
              else if (lkeyword.eq.'RX') then
                 rx_cat=lvalue
              else if (lkeyword.eq.'LOIF') then
                 loif_cat=lvalue
              else if (lkeyword.eq.'MODES') then
                 modes_cat=lvalue
              else if (lkeyword.eq.'MODES_DESCRIPTION') then
                 modes_description_cat=lvalue
              else if (lkeyword.eq.'REC') then
                 rec_cat=lvalue
              else if (lkeyword.eq.'HDPOS') then
                 hdpos_cat=lvalue
              else if (lkeyword.eq.'TRACKS') then
                 tracks_cat=lvalue
              else if (lkeyword.eq.'FLUX') then
                 flux_cat=lvalue
              else if (lkeyword.eq.'COMMENTS') then
                 flux_comments=lvalue
              else if (lkeyword.eq.'PROGRAM') then
                cat_program_path=lvalue
              else if (lkeyword.eq.'PARAMETER') then
                par_program_path=lvalue
              else if(lkeyword .eq. 'MASTER') then
                cmaster_dir=lvalue                                
              else
                write(luscn,'("RDCTL04: Unknown catalog ", A)') lkeyword
                end if
9200            continue
                call readline_skdrut(lu,cbuf,keof,ierr,2)
              end do
! $MYSQL
            else if(lsecname .eq. "$MYSQL") then
              do while(.not.keof .and.(cbuf(1:1) .ne. "$"))
               call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
               call capitalize(lkeyword)

               if (lkeyword.eq.'HOST') then
                 lmysql_host=lvalue(1:len(lmysql_host))
                 call null_term(lmysql_host)
               else if (lkeyword.eq.'SOCKET') then
                 lmysql_socket=lvalue(1:len(lmysql_socket))
                 call null_term(lmysql_socket)
               else if (lkeyword.eq.'USER') then
                 call null_term(lmysql_socket)
                 lmysql_user=lvalue(1:len(lmysql_user))
                 call null_term(lmysql_user)
               else if (lkeyword.eq.'PASSWORD') then
                 lmysql_password=lvalue(1:len(lmysql_password))
                 call null_term(lmysql_password)
               else if (lkeyword.eq.'DATABASE') then
                 lmysql_db=lvalue(1:len(lmysql_db))
                 call null_term(lmysql_db)
               else
                  write(luscn,9201) lkeyword
9201              format("RDCTL04x ERROR: Unknown mysql name: ",A)
               end if
               call readline_skdrut(lu,cbuf,keof,ierr,2)
             end do
C  $SCHEDULES
            else if (lsecname .eq.'$SCHEDULES') then
              if ((cbuf(1:1) .ne. '$').and..not.keof) then
                read(cbuf,'(a)') csked
                call add_slash_if_needed(csked)
                call readline_skdrut(lu,cbuf,keof,ierr,1)
              end if
C  $SNAP
            else if (lsecname .eq. "$SNAP" .or.
     >               lsecname .eq. "$DRUDG") then
              if ((cbuf(1:1) .ne. '$').and..not.keof) then
                read(cbuf,'(a)') csnap
                call add_slash_if_needed(csnap)
                call readline_skdrut(lu,cbuf,keof,ierr,1)
              end if
C  $PROC
            else if (lsecname .eq. '$PROC') then
              if ((cbuf(1:1) .ne. '$').and..not.keof) then
                read(cbuf,'(a)') cproc
                call add_slash_if_needed(cproc)
                call readline_skdrut(lu,cbuf,keof,ierr,1)
              end if
C  $SCRATCH
            else if (lsecname .eq. '$SCRATCH') then
              if ((cbuf(1:1) .ne. '$').and..not.keof) then
                read(cbuf,'(a)') ctmpnam
                call add_slash_if_needed(ctmpnam)
                call readline_skdrut(lu,cbuf,keof,ierr,1)
              end if
C  $PRINT
            else if (lsecname .eq.'$PRINT') then
              do while(.not.keof.and.(cbuf(1:1) .ne. '$'))
                call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
                call capitalize(lkeyword)

                ktoken=.false.
                if(lvalue .ne. " ") then
                  nch=trimlen(lvalue)
                  ind=index(cbuf,lvalue(1:nch))
                  nch=trimlen(cbuf)
                  ktoken=.true.
                endif

                if (lkeyword .eq.'LABELS') then
                  if(ktoken) then
                    cprtlab=cbuf(ind:nch)
                    call null_term(cprtlab)
                  else ! null
                    cprtlab=' '
                  endif
                else if (lkeyword .eq.'PORTRAIT') then
                  if(ktoken) then
                    cprtpor=cbuf(ind:nch)
                    call null_term(cprtpor)
                  else ! null
                    cprtpor=' '
                  endif
                else if (lkeyword .eq.'LANDSCAPE') then
                  if(ktoken) then
                    cprtlan=cbuf(ind:nch)
                    call null_term(cprtlan)
                  else ! null
                    cprtlan=' '
                  endif
                else if (lkeyword .eq. 'PRINTER') then ! printer line
                  call capitalize(lvalue)
                  if (lvalue.eq.'EPSON'.or.lvalue.eq.'LASER'.or.
     >                lvalue.eq.'EPSON24') then
                      cprttyp=lvalue
                  else
                     write(luscn,9211) lvalue(1:trimlen(lvalue))
9211                 format('RDCTL05 ERROR: Unknown printer type ',A)
                  endif
                else if (lkeyword .eq. 'LABEL_PRINTER') then
                  if(ktoken) then
                    call capitalize(lvalue)
                    if (lvalue.eq.'EPSON'.or.
     >                  lvalue.eq. 'DYMO' .or.
     >                  lvalue.eq.'POSTSCRIPT'.or.
     .                  lvalue.eq.'LASER+BARCODE_CARTRIDGE'.or.
     .                  lvalue.eq.'EPSON24') then
                      clabtyp=lvalue
                    else
                      write(luscn,9212) lvalue(1:trimlen(lvalue))
9212                  format('RDCTL10 ERROR: Unrecognized label ',
     .                'printer type ',A)
                    endif
                  endif
                else if (lkeyword(1:6) .eq. 'OPTION') then
                  read(lkeyword(7:7),*) ic
                  if (ic.ne.1.and.ic.ne.4.and.ic.ne.5) then
                    write(luscn,9213) ic
9213                format('RDCTL14 ERROR: Invalid option number, ',
     .              i3,' must be 1, 4, or 5.')
                  else
                    if (ktoken) then
                      call capitalize(lvalue)
                      if (lvalue.eq.'PS'.or.lvalue.eq.'PL'.or.
     .                    lvalue.eq.'LS'.or.lvalue.eq.'LL') then
                        if(ic .eq. 4) then
                          ic=2
                        else if(ic .eq. 5) then
                          ic=3
                        endif
                        coption(ic)=lvalue(1:2)
                      else
                        write(luscn,9215) ctemp
9215                    format('RDCTL13 ERROR: Unrecognized option ',
     .                  'type ',A,', only PS, PL, LS, or LL are valid.')
                      endif
                    endif
                  endif
                else if (lkeyword .eq.'LABEL_SIZE') then
C                 label_size ht wid nrows ncols topoff leftoff
                  read(cbuf,*,err=92140) lkeyword,rlabsize
                  goto 9216
92140             write(luscn,'(a)') "RDCTL12 ERROR: Label Size error"
                else
                   write(luscn,'(a)') "Error in $PRINT section"
                   write(luscn,'(a)') cbuf(1:trimlen(cbuf))
                endif
9216            continue
                call readline_skdrut(lu,cbuf,keof,ierr,2)
              end do
C  $MISC
            else if (lsecname .eq. '$MISC') then
              do while(.not.keof.and.(cbuf(1:1) .ne. '$'))
                call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
                call capitalize(lkeyword)

                if(lkeyword .eq. "EPOCH") then
                  if(lvalue .eq. "1950" .or. lvalue .eq. "2000") then
                     cepoch=lvalue(1:4)
                  else
                    write(luscn,'("RDCTL06 ERROR: Invalid epoch ",a)')
     .              lvalue(1:trimlen(lvalue))
                  endif
! Disk2file stuff
                else if (lkeyword .eq. 'DISK2FILE_DIR') then
                  ldisk2file_dir0=lvalue
                  call add_slash_if_needed(ldisk2file_dir0)

                else if(lkeyword .eq. 'AUTOFTP') then
                   call capitalize(lvalue)
                   if(numtoken .eq. 3) lautoftp_string0=ltoken(3)
                   if(lvalue .eq. "YES" .or. lvalue .eq. "Y" .or.
     >               lvalue .eq. "ON" .or. lvalue .eq. "TRUE") then
                     kautoftp0=.true.
                   else if(lvalue .eq. "NO" .or. lvalue .eq. "N" .or.
     >               lvalue .eq. "OFF" .or. lvalue .eq. "FALSE") then
                     kautoftp0=.false.
                   else
                     write(*,*) "RDCTL:     Wrong format for autoftp"
                     write(*,*) "Should be: AUTOFTP [ON|OFF] <String>"
                   endif
C         EQUIPMENT
                else if (lkeyword  .eq.'EQUIPMENT') then
                  dr_rack_type=lvalue(1:8)
                  crec_default(1)=ltoken(3)
                  crec_default(2)=ltoken(4)
                  call capitalize(dr_rack_type)
                  call capitalize(crec_default(1))
                  call capitalize(crec_default(2))
! Now check to see if valid types.
                  itemp=iwhere_in_string_list(crack_type_cap,
     >               max_rack_type, dr_rack_type)
                  if(itemp .eq. 0) then
                    write(*,*) "Invalid rack_type: ",dr_rack_type
                    write(*,*) "Please fix in skedf.ctl"
                    stop
                  else
                    dr_rack_type=crack_type(itemp)
                  endif
                  do i=1,2
                    itemp=iwhere_in_string_list(crec_type_cap,
     >                 max_rec_type,crec_default(i))
                    if(itemp .eq. 0) then
                      write(*,*) "For recorder ", i,
     >                   "Invalid recorder type: ", crec_default(i)
                      if(crec_default(i)(1:5) .eq. "MARK5") then
                        write(*,*)
     >                   "Valid Mark5 recorders: Mark5A, Mark5B, Mark5P"
                      endif
                      stop
                    else
                      crec_default(i)=crec_type(itemp)
                    endif
                  end do
                else if(lkeyword .eq. 'EQUIPMENT_OVERRIDE') then
                  kequip_over=.true.
C         TPICD
                elseif (lkeyword .eq. 'TPICD') then
                  lprompt=lvalue(1:3)
                  call capitalize(lprompt)
                  if(lprompt .eq. "YES" .or. lprompt .eq. "NO") then
                    tpid_prompt=lprompt
                  else
                     write(luscn, *)
     >                "RDCTL10 ERROR: TPI prompt must be YES or NO"
                  endif
                  read(ltoken(3),*) itemp
                  if(itemp .ge. 0) then
                    itpid_period=itemp
                  else
                    write(luscn,*) "RDCTL11 ERROR: Invalid TPI period"
                  endif
! New option for DBBC
               elseif (lkeyword .eq. 'CONT_CAL') then
                  lprompt=lvalue(1:3)
                  call capitalize(lprompt)
                  if(lprompt .eq. "ON" .or. lprompt .eq. "OFF" .or. 
     >               lprompt .eq. "ASK") then
                    contcal_prompt=lprompt
                  else
                     write(luscn, *)
     >             "Error:  Valid CONT_CAL options are ON, OFF, ASK."
                  endif 
                endif ! TPICD line
                call readline_skdrut(lu,cbuf,keof,ierr,2)
              enddo
! End $MISC
            else ! unrecognized
              write(luscn,9220) lsecname
9220          format("RDCTL07 ERROR: Unrecognized section name ",A)
              call readline_skdrut(lu,cbuf,keof,ierr,1)
            end if
        end do
        close (lu)   
500     continue           !quick exit. 
      end do  !"do 1,2"

! save original state
      kautoftp = kautoftp0
      ldisk2file_dir =ldisk2file_dir0
      lautoftp_string=lautoFTP_string0

      if(kequip_over) then
        if(dr_rack_type .eq. 'UNKNOWN' .or.
     >      crec_default(1) .eq. 'UNKNOWN') then
         write(*,*)
     >    "If EQUIPMENT_OVERRIDE is on, must set rack and recoders!"
         write(*,*) "Modify skedf.ctl accordingly!"
         stop
       endif
      endif

      RETURN
      END
