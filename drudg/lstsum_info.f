      subroutine lstsum_info(kskd,cexper,iyear,cstn,cid1,cid,
     .xpos,ypos,zpos,kazel,kwrap,kk4,ks2,
     .crack,creca,crecb,ierr,kscan)

C LSTSUM_INFO gets the information for the lstsum routine.
C Information is retrieved from common or by reading the
C .snp file directly.
C 
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

C History
C 991103 nrv New. Removed from LSTSUM.
C 000611 nrv Add KSCAN to call.

C Calls: READ_SNAP1, READ_SNAP6

C Input
      logical kskd
C Output
      character*(*) cexper
      integer iyear
      character*(*) cstn
      character*(*) cid1
      character*(*) cid 
      double precision xpos,ypos,zpos
      logical kazel,kwrap,kk4,ks2,kscan
      character*(*) crack,creca,crecb
      integer ierr ! non-zero means some failure
C Local
      integer nline,ix
      character*128 cbuf_in,cbuf
      character*20 c1,c2,c3
      logical km3rack,km4rack,kvrack,kv4rack,
     .  kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,k8bbc,
     .  km3rec(2),km4rec(2),kvrec(2),
     .  kv4rec(2),ks2rec(2),kk41rec(2),kk42rec(2)
      integer trimlen,ichcm_ch

C 4.1 Whether we have a .skd file or not, read line 1 of SNAP file
C     Read first line of SNAP file to get year, experiment name, station.
C     If the first line in the SNAP file is a comment, then all the header 
C     lines are probably there.

      ierr=-1
      read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
      nline=1
      call c2upper(cbuf_in,cbuf)
      if (cbuf(1:1).eq.'"') then
        call read_snap1(cbuf,cexper,iyear,cstn,cid1,cid,ierr)
      else
        ierr = -1
      endif
      if (ierr.lt.0) then ! set defaults instead
        if (ierr.ge.-1) cexper='XXX'
        if (ierr.ge.-2) iyear=0
        if (ierr.ge.-3) cstn='        '
        if (ierr.ge.-4) cid1=' '
        if (ierr.ge.-5) cid='  '
      endif
      ierr=0

C 4.2  Get axis type and station position
      if (kskd) then
        xpos = stnxyz(1,istn)
        ypos = stnxyz(2,istn)
        zpos = stnxyz(3,istn)
        kazel = .true.
        kwrap=.false.
        if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn)
     .       .eq.7) kwrap=.true.
C    Read line 2 to get axis type
      else ! read axis type and position from .snp
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !A line
        nline=2
        call c2upper(cbuf_in,cbuf)
        read(cbuf(2:),*) c1,c2,c3
        if (c3.eq.'AZEL'.or.c3.eq.'SEST'.or.c3.eq.'ALGO') then
          kwrap=.true.
        else
          kwrap=.false.
        endif
C    Read line 3 to get XYZ position
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !P line
        nline=3
        call c2upper(cbuf_in,cbuf)
        if (trimlen(cbuf).lt.40) then ! not there
          write(luscn,9002)
9002      format(' SNAP file does not contain station position ',
     .    'data on line 3, therefore '/,
     .    ' az, el will not be calculated for this listing.')
          kazel = .false.
        else ! it's there
          ix=index(cbuf(6:),' ')
          read(cbuf(6+ix:),*,err=991,end=990,iostat=IERR) 
     .    xpos,ypos,zpos
          kazel = .true.
        endif
      endif ! common/read axis type and position

C 4.3  Find out the equipment.
      if (kskd.and.ichcm_ch(lstrack(1,istn),1,'unknown').ne.0.and.
     .  ichcm_ch(lstrec(1,istn),1,'unknown').ne.0) then ! got it
        call hol2char(lstrack(1,istn),1,8,crack)
        call hol2char(lstrec(1,istn),1,8,creca)
        call hol2char(lstrec2(1,istn),1,8,crecb)
        call set_type(istn,km3rack,km4rack,kvrack,kv4rack,
     .  kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,k8bbc,
     .  km3rec,km4rec,kvrec,
     .  kv4rec,ks2rec,kk41rec,kk42rec)
C NOTE: This logic means that you can't mix (K4,S2) with (VLBA,Mk4)
        kk4 = kk41rec(1).or.kk42rec(1).or.kk41rec(2).or.kk42rec(2)
        ks2 = ks2rec(1).or.ks2rec(2)
      else ! read .snp file
        do while (nline.lt.3)
          nline=nline+1
          read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
        enddo
C       Read line 4 (T line)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !T line
C       Read line 5 (drudg version comment)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in 
C       Read line 6 (equipment)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
        call read_snap6(cbuf_in,crack,creca,crecb,ierr)
        if (ierr.eq.0) then !
C NOTE: This logic means that you can't mix (K4,S2) with (VLBA,Mk4)
          kk4 = creca(1:2).eq.'K4'.or.crecb(1:2).eq.'K4'
          ks2 = creca(1:2).eq.'S2'.or.crecb(1:2).eq.'S2'
        else
C    Couldn't figure out the equipment from the .snp file header,
C    so look at the actual commands.
          nline=0
          ks2=.false.
          kk4=.false.
          do while (nline.lt.50.and..not.kk4.and..not.ks2)
            read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
            nline=nline+1
            call c2upper(cbuf_in,cbuf)
            kk4 = index(cbuf,'STA=RECORD').ne.0.or.
     .            index(cbuf,'STB=RECORD').ne.0
            ks2 = index(cbuf,'FOR,SLP').ne.0.or.
     .            index(cbuf,'FOR,LP').ne.0 
            kscan = index(cbuf,'SCAN_NAME').ne.0
          enddo
        endif ! decode header line 6/read .snp
      endif ! common/read .snp

990   continue
991   continue
      return
      end
