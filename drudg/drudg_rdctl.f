      SUBROUTINE drudg_rdctl(csked,csnap,cproc,cscratch,
     >   dr_rack_type,crec_default,  kequip_over,ldbbc_if_inputs)
      
C
! This routine will open the default control file for drudg. 
! Based on old routine rdctl that handlled both sked and drudg.
! This just handles handles drudg.

C
C   parameter file
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/data_xfer.ftni'   !This includes info about data transfer
      include '../skdrincl/valid_hardware.ftni'
      include 'drcom.ftni' 

! Passed
      character*128 csked,csnap,cproc,cscratch     !Various directories. 
      character*8 dr_rack_type,crec_default(2)
      logical kequip_over
      character*1 ldbbc_if_inputs(4) 
          
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
      character*25 lkeyword     !keyword
      character*128 lvalue      !value
      character*1 lvalid_dbbc_if_inputs(4)   

      integer MaxToken
      integer NumToken
      parameter(MaxToken=6)
      character*128 ltoken(MaxToken)
      equivalence (lkeyword,ltoken(1))
      equivalence (lvalue,ltoken(2))

      integer lu          !open lu
      integer ic,i,j,ilen,ierr
      
      logical ktoken
      logical keof      !EOF reached in reading in file
      logical kfound_global_file
      logical kfirst_skip    

      character*32 cskedf(3)   
      data cskedf/
     > "/usr/local/bin/skedf.ctl", "/usr2/control/skedf.ctl",
     > "skedf.ctl"/ 

      data lvalid_dbbc_if_inputs/"1","2","3","4"/

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
   

      kautoftp0=.false.
      ldisk2file_dir0 =" "
      lautoftp_string0=" "
      iautoftp_abort_time=300         !default value for aborting....

C  2. Process the control file if it exists. Loop throug 3 times.
!     The first two times check for the global skedf.ctl
!     The last time for the local file. 

      kfirst_skip=.true.
      do j=1,3      
         if(.not.kfirst_skip) write(*,*) " "   !close out 'skipping non-sked' line  
         kfirst_skip=.true. 
     
! If already found the global file, don't need to check the alternative.
        if(j .eq. 2 .and. kfound_global_file) goto 500    !quick exit. 
! If we are the start of the third round and haven't found the global file, 
! write a warning message but try to read the local file. 
        if(j .eq. 3 .and. .not.kfound_global_file) then
          write(luscn,
     >'("WARNING! drudg_rdctl: Did not find global skedf.ctl file:",a)')
     >       cskedf(1)(1:trimlen(cskedf(1)))
         write(luscn,
     > '("                or alternate global skedf.ctl file:",a)') 
     >       cskedf(2)(1:trimlen(cskedf(2)))                 
        end if

        itmplen = trimlen(cskedf(j))
        kexist = .false.
        inquire(file=cskedf(j),exist=kexist)      
        if(.not.kexist) goto 500                !quick exit. 

        open(lu,file=cskedf(j),iostat=ierr,status='old')
        if (ierr.ne.0) then
          write(luscn,9100) cskedf(j)(1:itmplen)
9100      format("drudg_rdctl ERROR: Error opening control file ",A)
          close(lu)
          return
        end if

       if(j .le. 2) then
         write(luscn,'("drudg_rdctl: Reading system control file ",A)')
     >       cskedf(j)(1:itmplen)
             kfound_global_file=.true. 
        else
          write(luscn,'("drudg_rdctl: Reading local control file ",A)')
     >       cskedf(j)(1:itmplen)
        endif
        write(*,'(a,$)') "   "
   
! File exists, and we have opened it.    
        call readline_skdrut(lu,cbuf,keof,ierr,1) !read first $     
        do while (.not.keof)
          do while(cbuf(1:1) .eq. "$")
            read(cbuf,'(a)') lsecname
            call capitalize(lsecname)    
! Read the next valid line.
            call readline_skdrut(lu,cbuf,keof,ierr,2)  !space to next valid line.         
            if(keof) goto 500
          end do     
C  $SCHEDULES
          write(*,'(a,$)') lsecname(1:trimlen(lsecname)+1) 
          if (lsecname .eq.'$SCHEDULES') then                  
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
               read(cbuf,'(a)') cscratch
               call add_slash_if_needed(cscratch)
               call readline_skdrut(lu,cbuf,keof,ierr,1)
             end if
C  $PRINT
          else if (lsecname .eq.'$PRINT') then
            do while(.not.keof.and.(cbuf(1:1) .ne. '$'))
              call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
!              lkeyword=ltoken(1)
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
9211                format('RDCTL05 ERROR: Unknown printer type ',A)
                 endif
              else if (lkeyword .eq. 'LABEL_PRINTER') then
                 if(ktoken) then
                    call capitalize(lvalue)
                    if (lvalue.eq.'EPSON'.or.lvalue.eq.'EPSON24' .or. 
     >                  lvalue.eq. 'DYMO'.or.lvalue.eq.'POSTSCRIPT'.or.
     >                  lvalue.eq.'LASER+BARCODE_CARTRIDGE') then
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
C              label_size ht wid nrows ncols topoff leftoff
               read(cbuf,*,err=92140) lkeyword,rlabsize
               goto 9216
92140          write(luscn,'(a)') "RDCTL12 ERROR: Label Size error"
             else
                 write(luscn,'(a)') "Error in $PRINT section"
                 write(luscn,'(a)') cbuf(1:trimlen(cbuf))
              endif
9216          continue
              call readline_skdrut(lu,cbuf,keof,ierr,2)
            end do
C  $MISC
          else if (lsecname .eq. '$MISC') then
            do while(.not.keof.and.(cbuf(1:1) .ne. '$'))
              call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
              lkeyword=ltoken(1) 
              call capitalize(lkeyword)   

              if(lkeyword .eq. "EPOCH") then
                if(lvalue .eq. "1950" .or. lvalue .eq. "2000") then
                   cepoch=lvalue(1:4)
                else
                  write(luscn,'("RDCTL06 ERROR: Invalid epoch ",a)')
     >             lvalue(1:trimlen(lvalue))
               endif
! Disk2file stuff
              else if (lkeyword .eq. 'DISK2FILE_DIR') then
                ldisk2file_dir0=lvalue
                call add_slash_if_needed(ldisk2file_dir0)

              else if(lkeyword .eq. 'AUTOFTP') then
                call capitalize(lvalue)
                if(numtoken .eq. 3) lautoftp_string0=ltoken(3)
                if(lvalue .eq. "YES" .or. lvalue .eq. "Y" .or.
     >             lvalue .eq. "ON" .or. lvalue .eq. "TRUE") then
                   kautoftp0=.true.
                else if(lvalue .eq. "NO" .or. lvalue .eq. "N" .or.
     >             lvalue .eq. "OFF" .or. lvalue .eq. "FALSE") then
                      kautoftp0=.false.
                else
                    write(*,*) "RDCTL:     Wrong format for autoftp"
                    write(*,*) "Should be: AUTOFTP [ON|OFF] <String>"
                endif
              else if(lkeyword .eq. 'AUTOFTP_ABORT_TIME') then
                 read(ltoken(2),*) iautoftp_abort_time                

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
     >                 max_rack_type, dr_rack_type)
                if(itemp .eq. 0) then
                   write(*,*) "Invalid rack_type: ",dr_rack_type
                   write(*,*) "Please fix in control file!"                   
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
     >                  "Valid Mark5 recorders: Mark5A, Mark5B, Mark5P"
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
     >             lprompt .eq. "ASK") then
                   contcal_prompt=lprompt
                else
                   write(luscn, *)
     >              "Error:  Valid CONT_CAL options are ON, OFF, ASK."
                 endif 
               elseif(lkeyword .eq. "DEFAULT_DBBC_IF_INPUTS") then
                 if(NumToken .gt. 5) then 
                     write(*,*)
     >        "drudg_rdctl: Too many tokens for defualt_dbbc_if_inputs"
                     write(*,*) "can specify upto 4 inputs"
                  else
! Temporarily undo indent. 
                    do i=2,NumToken
          itemp=iwhere_in_string_list(lvalid_dbbc_if_inputs,4,ltoken(i))
          if(itemp .eq. 0) then
             write(*,*) "drudg_rdctl: Invalid dbbc_if_input ", 
     >        ltoken(i)(1:trimlen(ltoken(i)))
          else
            ldbbc_if_inputs(i-1)=ltoken(i) 
          endif
                    end do                                        
                  endif 
                endif ! TPICD line
                call readline_skdrut(lu,cbuf,keof,ierr,2)
              enddo
! End $MISC
           else ! unrecognized
              if(kfirst_skip) then
                 write(luscn,'("Skipping non-drudg section: ",$)') 
                 kfirst_skip=.false.
               endif
               write(luscn,'(a," ",$)') lsecname 
               call readline_skdrut(lu,cbuf,keof,ierr,1)
           end if
        end do
        close (lu)   
500     continue           !quick exit. 
      if(kfound_global_file) write(*,*) " "  
      end do  !"do 1,2"
      if(.not.kfirst_skip) write(*,*) " "   !close out 'skipping non-sked' line 

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
!      write(*,*) " " 

      RETURN
      END
