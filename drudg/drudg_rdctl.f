      SUBROUTINE drudg_rdctl(csked,csnap,cproc,cscratch,
     >   crack_type_def,crec_default,cfirstrec_def, kequip_over)
      
C
! This routine will open the default control file for drudg. 
! Based on old routine rdctl that handlled both sked and drudg.
! This just handles handles drudg.

! 2015Jun05. JMGipson. Size of crack_type_def, crec_default set by calling program. Previously hardwired. 
! 2015Jul06  JMGipson. Initialized "crack_type_def, crec_default to " ". 
! 2015Jul17 JMG. Added cont_cal_polarity.
! 2015Jul21 JMG. Made "ASK" valid option ofr cont_cal_polarity 
! 2016Jul28 JMG. Now also set cfirstrec_def in 'equipment override'
! 2016Sep08 JMG. New keyword 'vsi_align' 
! 2018Jun17 JMG. Father's day. Make sure always a space " " between sections of snap file.
!                Also fix reported error in label size.  Was reporting error when there was not one. 
! 2018Sep25 JMG. skedf.ctl has different locations depending on wheater PC-FS computer or not. This is set in makefile. 


C   parameter file
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/data_xfer.ftni'   !This includes info about data transfer
      include '../skdrincl/valid_hardware.ftni'
      include 'drcom.ftni' 
      include 'bbc_freq.ftni'
     

! Passed
      character*128 csked,csnap,cproc,cscratch     !Various directories. 
      character*(*) crack_type_def,crec_default(2),cfirstrec_def
      logical kequip_over    
          
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
      integer max_dbbc_if_inputs
      parameter(max_dbbc_if_inputs=4)
      character*2 lvalid_dbbc_if_inputs(max_dbbc_if_inputs)

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

      character*4 lvalid_polarity(6)
      character*6 lvalid_vsi_align(4)
      integer ifs_PC


      integer ifile_beg,ifile_end
      character*32 cskedf(3)   
      data cskedf/
     > "/etc/skedf.ctl",  "skedf.ctl",
     > "/usr2/control/skedf.ctl"/
  
      data lvalid_dbbc_if_inputs/"1","2","3","4"/ 
      data lvalid_polarity/"0","1","2","3","NONE","ASK"/     
      data lvalid_vsi_align/"0","1","NONE","ASK"/     

! this is set in makefile. if it is set to 1, then on FS_PC.

        ifs_PC=1        

      if(ifs_PC .eq. 1) then
        ifile_beg=3
        ifile_end=3   
        inquire(exist=kexist,file=cskedf(3))
        if(.not.kexist) then
          write(*,*) "Aborting because we did not find "//cskedf(3)
          stop
        endif                    
      else
        ifile_beg=1
        ifile_end=2
        inquire(exist=kexist,file=cskedf(1))
        if(.not.kexist) then
           inquire(exist=kexist,file=cskedf(2))
           if(.not.kexist) then
             writE(*,*) "Did not find primary file "//cskedf(1)
             write(*,*) "or secondary file "//cskedf(2)
             write(*,*) "aborting!"
             stop
           endif 
        endif 
      endif         
      
! Initialization
! Stuff for DBBC
      do i=1,4
        ldbbc_if_inputs(i)=" "
        idbbc_if_targets(i)=-1
      end do
      idbbc_bbc_target=-1   

      cont_cal_prompt="off" 
      cont_cal_polarity=" "    !default is none!
      lvsi_align_prompt= " "   !default is none!
      ktarget_time=.false.
      klo_config=.false. 
      kignore_mark5b_bad_mask=.false.
      
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
      crack_type_def    = " "
      crec_default(1) = " "
      crec_default(2) = " "
   

      kautoftp0=.false.
      ldisk2file_dir0 =" "
      lautoftp_string0=" "
      iautoftp_abort_time=300         !default value for aborting....

C  2. Process the control file if it exists. Loop throug 3 times.
!     The first two times check for the global skedf.ctl
!     The last time for the local file. 

      kfirst_skip=.true.
      do j=ifile_beg, ifile_end   
        if(.not.kfirst_skip) write(*,*) " "   !close out 'skipping non-sked' line  
         kfirst_skip=.true.     

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

        write(luscn,'("drudg_rdctl: Reading system control file ",A)')
     >       cskedf(j)(1:itmplen)   

    
! File exists, and we have opened it.    
        call readline_skdrut(lu,cbuf,keof,ierr,1) !read first $           
        do while (.not.keof)
!          write(*,*) "**>",cbuf(1:60) 
          do while(cbuf(1:1) .eq. "$")
            read(cbuf,'(a)') lsecname
            call capitalize(lsecname)    
! Read the next valid line.
            call readline_skdrut(lu,cbuf,keof,ierr,2)  !space to next valid line.         
            if(keof) goto 500
          end do     
C  $SCHEDULES
          write(*,'(a," ",$)') lsecname(1:trimlen(lsecname)) 
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
               goto 9216    !Skip emitting error message
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
!            write(*,*) "-->",cbuf(1:60)
            do while(.not.keof.and.(cbuf(1:1) .ne. '$'))
!              write(*,*) "-->",cbuf(1:60) 
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
                crack_type_def=lvalue
                crec_default(1)=ltoken(3)
                if(NumToken .eq. 3) then
                   crec_default(2)="NONE"                
                else
                   crec_default(2)=ltoken(4)
                endif 
                if(NumToken .eq. 5) then
                   cfirstrec_def=ltoken(5)
                else
                   cfirstrec_def="1 "
                endif 
              
                call capitalize(crack_type_def)
                call capitalize(crec_default(1))
                call capitalize(crec_default(2))         
! Now check to see if valid types.
                itemp=iwhere_in_string_list(crack_type_cap,
     >                 max_rack_type, crack_type_def)
                if(itemp .eq. 0) then
                   write(*,*) "Error in line: "//cbuf(1:60) 
                   write(*,*) "Invalid rack_type: ",crack_type_def
                   write(*,*) "Please fix in control file!"                   
                else
                  crack_type_def=crack_type(itemp)
                endif
                do i=1,2
                  ltoken(2)=crec_default(i)
                  call capitalize(ltoken(2)) 
                  itemp=iwhere_in_string_list(crec_type_cap,
     >                 max_rec_type,ltoken(2))
 
                  if(itemp .eq. 0) then
                    write(*,*) "Error in line: "//cbuf(1:60) 
                    write(*,*) "For recorder ", i,
     >                   " Invalid recorder type: ", crec_default(i)
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
                cont_cal_prompt=" "
                kcont_cal=.false.
                if(lprompt .eq. "ON") then 
                  kcont_cal=.true.
                else if(lprompt .eq. "OFF") then
                  continue 
                else if(lprompt .eq. "ASK") then
                  cont_cal_prompt="ASK"
                else
                   write(luscn, *)
     >              "Error:  Valid CONT_CAL options are ON, OFF, ASK."
                 endif 
              elseif (lkeyword .eq. 'CONT_CAL_POLARITY') then
                call capitalize(lvalue)
                itemp=iwhere_in_string_list(lvalid_polarity,6,lvalue)
                if(itemp .eq. 0) then
                  write(*,*) "drudg_rdctl: Invalid cont_cal_polarity: ",
     >              lvalue
                  write(*,*) "  valid options are: ", 
     >              lvalid_polarity
                   cont_cal_polarity="ASK"
                else if(itemp .le. 4) then
                    cont_cal_polarity=lvalue
                else if(lvalue .eq. "NONE") then    !value set to "NONE"
                    cont_cal_polarity=" "
                else if(lvalue .eq. "ASK") then
                    cont_cal_polarity="ASK"
                endif 

             elseif (lkeyword .eq. 'VSI_ALIGN') then
                call capitalize(lvalue)
                itemp=iwhere_in_string_list(lvalid_vsi_align,4,lvalue)
                if(itemp .eq. 0) then
                  write(*,*) "drudg_rdctl: Invalid vsi_align: ",
     >              lvalue
                  write(*,*) "  valid options are: ", 
     >              lvalid_vsi_align
                   lvalue="ASK"           !set to ask if not valid. 
                endif
                lvsi_align_prompt=lvalue                                    
        
              elseif(lkeyword .eq. "DEFAULT_DBBC_IF_INPUTS") then
                if(NumToken .gt. 5) then 
                   write(*,*) "drudg_rdctl: Too many tokens for "//      
     >                        "DEFALUT_DBBC_IF_INPUTS"
                   write(*,*) "can specify upto 4 inputs"
                else
! Temporarily undo indent. 
                  do i=2,NumToken
                    call capitalize(ltoken(i))
                    itemp=iwhere_in_string_list(
     >              lvalid_dbbc_if_inputs,max_dbbc_if_inputs,ltoken(i))
                    if(itemp .eq. 0) then
                      write(*,*) "drudg_rdctl: Invalid dbbc_if_input ", 
     >                   ltoken(i)(1:trimlen(ltoken(i)))
                    else
                      ldbbc_if_inputs(i-1)=ltoken(i) 
                    endif
                  end do                                        
                endif 
              elseif(lkeyword .eq. "DBBC_IF_TARGETS") then
                if(NumToken .gt. 5) then 
                   write(*,*) "drudg_rdctl: Too many tokens for"//      
     >                          "DBBC_IF_TARGETS"
                   write(*,*) "can specify upto 4 inputs"                  
                else
! Temporarily undo indent. 
                  do i=1,4
                    read(ltoken(i+1),*,err=900) idbbc_if_targets(i)
                    if(idbbc_if_targets(i) .gt. 65535 .or. 
     >                 idbbc_if_targets(i) .lt. 0) then
                      write(*,*) " "
                      write(*,*)
     >                  "drudg_rdctl: Warning! DBBC_IF_TARGET ", 
     >                   idbbc_if_targets(i), " out of range!"
                      write(*,*) "Valid values between 1 and 65535"
                      write(*,*) "Setting to 0."
                     idbbc_if_targets(i)=0
                   endif 
                  end do                                        
                endif 
              else if(lkeyword .eq. "DBBC_BBC_TARGET") then 
                if(NumToken .ne. 2) then
                   write(*,*) "drudg_rdctl: No argument given for"//      
     >                          "DBBC_BBC_TARGET"
                else
                  read(ltoken(2),*,err=900) idbbc_bbc_target
                  if(idbbc_bbc_target .gt. 65535 .or. 
     >               idbbc_bbc_target .lt. 0) then
                     write(*,*) " " 
                     write(*,*)
     >                 "drudg_rdctl: Warning! DBBC_BBC_TARGET ", 
     >                 idbbc_bbc_target,      " out of range!"
                     write(*,*) "Valid values between 1 and 65535"
                     write(*,*) "Setting to 0."
                     idbbc_bbc_target=0
                  endif 
                endif 
              else if(lkeyword .eq. "LO_CONFIG") then
                if(NumToken .ne. 2) then
                  write(*,*) 
     >             "drudg_rdctl: No argument given for LO_CONFIG"
                else 
                  call capitalize(ltoken(2))
                  klo_config = ltoken(2) .eq. "Y" .or. 
     >                         ltoken(2) .eq. "YES" .or.
     >                         ltoken(2) .eq."ON"
                endif     
              else if(lkeyword .eq. "IGNORE_MARK5B_BAD_MASK") then  
                if(NumToken .ne. 2) then
                  write(*,*) 
     >       "drudg_rdctl: No argument given for IGNORE_MARK5B_BAD_MASK"
                else 
                  call capitalize(ltoken(2))
                  kignore_mark5b_bad_mask = 
     >                        ltoken(2) .eq. "Y" .or. 
     >                         ltoken(2) .eq. "YES" .or.
     >                         ltoken(2) .eq."ON"
                endif     

                         
              else if(lkeyword .eq. "TARGET_TIME") then 
               if(NumToken .ne. 2) then
                  write(*,*) 
     >             "drudg_rdctl: No argument given for TARGET_TIME"
                else 
                  call capitalize(ltoken(2))
                  ktarget_time = ltoken(2) .eq. "Y" .or. 
     >                         ltoken(2) .eq. "YES" .or.
     >                         ltoken(2) .eq."ON"
                endif


              endif
              call readline_skdrut(lu,cbuf,keof,ierr,2)        
! End $MISC
              enddo
           else ! Some unrecognized section....
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
        if(crack_type_def .eq. 'UNKNOWN' .or.
     >      crec_default(1) .eq. 'UNKNOWN') then
         write(*,*)
     >    "If EQUIPMENT_OVERRIDE is on, must set rack and recoders!"
         write(*,*) "Modify skedf.ctl accordingly!"
         stop
       endif
      endif
      write(*,*) " " 
      RETURN

! Come here on error parsing line
900   continue
      write(*,*) "drudg_rdctl: Error parsing line: "//
     >     cbuf(1:Trimlen(Cbuf))
      END
