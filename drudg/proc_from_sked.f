      subroutine proc_from_sked(ierr)
      implicit none 
      
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'

! returned
      integer ierr    !<>0 some error
! history
! 2015Mar20  JMGipson. First version.
! 2015Mar31  JMGipson. If we start a new section, exit.  

! the sked file contains a section like:
!$PROCS
!BEGIN COMMON
!....
!END COMMON
!BEGIN STAT1
!...
!...
!END STAT1
!BEGIN STAT2
!...
!...
!END STAT2
! Put the stuff in the 'common' block and the block for the station in the .prc file. 
! Can have many COMMON sections and STATION sections, and the order does not matter. 

! functions
      integer trimlen 
!local
      character*120 ldum   !input line
      integer nch   
    
      character*8 lbeg_end                !holds BEGIN  -or-  END
      character*8 lkind_beg,lkind_end     !holds  type of section.
      integer num_lines                   !number of lines written
      logical kopen_section               !do we have an open section.
      logical kwrite_line                 !true if we should write out lines   
      logical kend 
    
      ierr=0     

      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)
      if(ierr  .ne. 0) then
        nch=trimlen(lskdfi) 
        write(luscn,*) 
     >    "PROC_FROM_SKED: Failed to open file:"//lskdfi(1:nch)
        return
      endif
      num_lines=0

! Space to start of appropriate section.
90    continue
      call read_nolf(lu_infile,ldum,kend)
      if(kend) goto 500
!      read(lu_infile, '(a)',end=500) ldum 
      if(ldum(1:6) .ne. "$PROCS") goto 90
             
! Here we should be at the start of the section.
100   continue
      call read_nolf(lu_infile,ldum,kend) 
      if(kend) goto 500 
!      read(lu_infile,'(a)', end=500) ldum    
!      ind=index(ldum,char(13))
!      if(ind .ne. 0) ldum(ind:ind)=" "    !replace linefeed with blank. 
 
 
      if(ldum .eq. " ") goto 100         !ignore blank lines
      if(ldum(1:1) .eq. '"') goto 100    !and lines that begin as comments. 
      if(ldum(1:1) .eq. '$') goto 500    !if we start a new section exit. 
      call capitalize(ldum) 
      if(ldum(1:5) .ne. "BEGIN") then
         write(luscn,'(a)') "PROC_FROM_SKED: Did not find BEGIN!"
         ierr=-1
         goto 500
      endif

! At this stage have opened a section. read it and write it out if we should. 
      kopen_section =.true. 
      read(ldum,*) lbeg_end, lkind_beg     !lkind_beg = COMMON or station name
      kwrite_line=lkind_beg.eq.cstnna(istn) .or. lkind_beg .eq. "COMMON"
  
110   continue
      call read_nolf(lu_infile,ldum,kend) 
      if(kend) goto 500 
!      read(lu_infile,'(a)',end=500) ldum
!      ind=index(ldum,char(13))
!      if(ind .ne. 0) ldum(ind:ind)=" "    !replace linefeed with blank. 
      if(ldum .eq. " ") goto 110        !don't bother to write out blank lines.
      if(ldum(1:1) .eq. "$") goto 500   !reached the end of the $PROC section 
      if(ldum(1:3) .eq. "END") then
          call capitalize(ldum)
          read(ldum,*) lbeg_end,lkind_end
          if(lkind_end .ne. lkind_beg) then
            write(luscn,'(a)') 
     >       'PROC_FROM_SKED: Beg,end mismatch: Beg='//lkind_beg//
     >       ' End='//lkind_end
             ierr=2 
             goto 500
           endif            
          kopen_section=.false.
          goto 100 
      endif

      if(kwrite_line) then
         num_lines=num_lines+1 
         nch=trimlen(ldum)
         write(lu_outfile,'(a)') ldum(1:nch)
      endif
      goto 110             

500   continue
      close(lu_infile)
      writE(luscn,'(" Wrote ",i6, " lines to file.")') num_lines
      if(kopen_section) then
          writE(luscn,'(a)') 
     >  'PROC_FROM_SKED: Exited with open section='//lkind_beg
       endif
       if(ierr .ne. 0) then
          write(luscn,'(a,i4)') 'PROC_FROM_SKED_ERROR: ',ierr
       endif
       return
       end 
    


         

