      subroutine lstsumo(iline,npage,cstn,cid,cexper,maxline,
     .      itearl_local,itlate_local,kwrap,kk4,ks2,cday,kazel,ksat,
     .      kstart,kend,nsline,csor,cwrap,ch1,cm1,cs1,
     .      ihd,imd,isd,ih2,im2,is2,ch3,cm3,cs3,
     .      idm,ids,cpass,ifeet,cnewtap,cdir,
     .      kskd,ncount,ntapes,
     .      rarad,dcrad,xpos,ypos,zpos,mjd,ut,iyear,
     .      crack,creca,crecb,cscan)

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'

C Writes an output line for LSTSUM.
C 960917 nrv New. Removed lines from LSTSUM to make this routine.
C 970131 nrv Remove updating of IFEET and put it back into LSTSUM.
C 970131 nrv Add KET to call. Change tape start into a string.
C 970306 nrv Change S2 to print minutes, not seconds. Add ".and..not.ks2" 
C            to the first two tests for output.
C 970321 nrv Remove KET from call.
C 970401 nrv Remove other extras from call. 
C 970401 nrv Change output to include Tape Stop column for 
C            continuous/late stop schedules.
C 970401 nrv Adaptive output. Don't include tape start or tape stop if
C            no early start or late stop.
C 970401 nrv Add itlate_local to call.
C 970728 nrv Add more explanatory header lines for the last column
C 970728 nrv If no tape motion, print "--" in pass field.
C 970812 nrv Print ifeet to nearest 20 feet (=1 sec at fast speed)
C 971210 nrv Print ifeet to nearest 1 min for S2. Change some headers.
C 980914 nrv Print full date. Add IYEAR to call.
C 990117 nrv Add KK4 to call. Add S2 or K4 to header. Change output
C            for K4 types.
C 991103 nrv Add crack,creca,crecb to call and print in header.
C 991115 nrv If ifeet=-1 then there's no scan to print.
C 000107 nrv If tape_motion_type is null, don't write it.
C 000529 nrv Add scan name.
C 021011 nrv Another digit for printing gap time.

C Input
      double precision rarad,dcrad,xpos,ypos,zpos,ut
      integer mjd
C** temporary
      integer its,itm,is3,im3,iyear
      integer iline,npage,itlate_local,itearl_local,nsline,ncount,
     .ntapes,maxline
      integer ihd,imd,isd,ih2,im2,is2,
     .idm,ids,ifeet
      character*8 csor,cexper,cstn
      character*3 cdir,cday
      character*4 cnewtap
      character*9 cscan
      character*2 cpass,ch1,cm1,cs1,ch3,cm3,cs3
      character*2 cid
      character*7 cwrap
      character*8 crack,creca,crecb
      logical kskd,kend,kstart,kk4,ks2,kmv
      logical kwrap, kazel,ksat

C Output
C These are modified on return: iline, page,ncount,ntapes

C Local
      integer i,il,iaz,iel,ifeet_print,iday
      double precision az,el
      integer trimlen
      logical kcont,kearl
      character lower
      character*128 cbuf

      if (ifeet.eq.-1) return ! nothing to do

      kmv=.not.ks2.and..not.kk4 ! kmv=Mk3/4 or VLBA
      kcont=.true. ! if we don't know, include the column
      if (kskd) kcont=tape_motion_type(istn).eq.'CONTINUOUS'.or.
     .tape_motion_type(istn).eq.'ADAPTIVE'.or.itlate(istn).gt.0
      kearl=itearl_local.gt.0
      if (ks2) then
        ifeet_print = ifeet/60 ! convert seconds to minutes
      else if (kk4) then
        ifeet_print = ifeet  ! counts
      else
        ifeet_print = 10*ifix(float((ifeet+9)/10)) ! nearest 10 feet
      endif

C  1. Headers.

      if (iline.ge.maxline) then ! new page, write header
        if (npage.gt.0) call luff(luprt)
        npage = npage + 1
        write(luprt,9200) cinname(1:trimlen(cinname)),npage
9200    format(' Schedule file: ',a,35x,'Page ',i3)
        if (kskd) then
          write(luprt,9201) (lstnna(i,istn),i=1,4),lpocod(istn),
     .    lstcod(istn),(lexper(i),i=1,4)
9201      format(' Station: ',4a2,' (',a2,')' '(',a1,')'/
     .           ' Experiment: ',4a2)
          i=trimlen(tape_motion_type(istn))
          if (i.gt.0) write(luprt,9203) tape_motion_type(istn)(1:i)
9203      format(' Tape motion type: ',a,$)
          if (tape_motion_type(istn).eq.'ADAPTIVE') then
            write(luprt,'(5x,"gap: ",i4," seconds",$)') itgap(istn)
          else
            write(luprt,'($)')
          endif
          if (ks2) then
            write(luprt,'(5x,"Recorder type: S2")')
          else if (kk4) then
            write(luprt,'(5x,"Recorder type: K4")')
          else
            write(luprt,'()')
          endif
        else
          write(luprt,9204) cstn,cid,cexper
9204      format(' Station: ',a8,' (',a2,')'/' Experiment: ',a8)
        endif
        write(luprt,9205) itearl_local,itlate_local
9205    format(' Early tape start: ',i3,' seconds',
     .      '    Late tape stop: ',i3,' seconds')
        write(luprt,9206) crack,creca,crecb
9206    format(' Rack: ',a8,'  Recorder 1: ',a8,'  Recorder 2: ',a8)
        write(luprt,'()')
        write(luprt,9207)
9207    format(
     .  ' Scan=scan_name command in .snp file'/
     .  ' Line#=line number in .snp file where this scan starts'/
     .  ' Dur=time interval of on-source data (Start Data to',
     .  ' Stop Data) in mmm:ss'/
     .  ' Data and tape times are in the format hh:mm:ss'/
     .  ' Feet = footage at start of scan, ',
     .         'to nearest 10 feet (Mk3/4/VLBA)'/
     .  ' Counts = tape counts at start of scan (K4)'/
     .  ' Group (min) = group number and nearest minute on tape (S2)'/
     .  ' Tape Usage:  XXX or Rec1=start recorder 1,',
     .  ' Rec2=start recorder 2'/
     .  '              *=parity check, @=no tape motion'/  )
        write(luprt,'()')
C
C  2. Column heads.

        if (.not.kwrap) cbuf='                            '//
     .    '       Start'
        if (     kwrap) cbuf='                            '//
     .    '             Start'
        il=trimlen(cbuf)
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'     Start'
        il=trimlen(cbuf)
        cbuf=cbuf(1:il)//'     Stop'
        il=trimlen(cbuf)
        if (kcont) cbuf=cbuf(1:il)//'     Stop'
        il=trimlen(cbuf)
        if (.not.ks2) cbuf=cbuf(1:il)//'                     Tape '
        if (ks2) cbuf=cbuf(1:il)//'               Tape' ! no stops
        il=trimlen(cbuf)
        write(luprt,'(a)') cbuf(1:il)
        cbuf=' Scan      Line#  Source   Az El'
        il=trimlen(cbuf)
        if (kwrap) cbuf=cbuf(1:il)//' Cable'
        il=trimlen(cbuf)
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'    Tape'
        il=trimlen(cbuf)
        if (.not.kearl) cbuf=cbuf(1:il)//'    Data      Data'
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'      Data      Data'
        il=trimlen(cbuf)
        if (kcont) cbuf=cbuf(1:il)//'     Tape'
        il=trimlen(cbuf)
        if (kmv) cbuf=cbuf(1:il)//'      Dur  Pass Feet Usage'
        if (ks2) cbuf=cbuf(1:il)//'      Dur Group (min)'
        if (kk4) cbuf=cbuf(1:il)//'      Dur   Counts Usage'
        il=trimlen(cbuf)
        write(luprt,'(a)') cbuf(1:il)

C       write(luprt,9320) cday
C9320   format('  Day ',a)
        read(cday,'(i3)') iday
        call wrday(luprt,iyear,iday)
        iline=0
      endif ! new page, write header

C  3.  Now write the scan line

      if (kazel.and..not.ksat) then
        call cazel(rarad,dcrad,xpos,ypos,zpos,mjd,ut,az,el)
        iaz = (az*180.d0/PI)+0.5
        iel = (el*180.d0/PI)+0.5
      else if (ksat) then ! already got az,el
        iaz = az
        iel = el
      else
        iaz = 0
        iel = 0
      endif
      if (.not.kend) then ! blank out end time
        ch3='  '
        cm3='  '
        cs3='  '
      endif
      if (.not.kstart) then ! blank out start time
        ch1='  '
        cm1='  '
        cs1='  '
      endif

C  Source info
      cscan(9:9) = lower(cscan(9:9))
      write(luprt,'(1x,a9,1x,i5,1x,a8,1x,i3,1x,i2,$)') 
     .cscan,nsline,csor,iaz,iel
C  Cable wrap field
      if (kwrap) write(luprt,'(1x,a5,$)') cwrap
C  Early start, "Tape Start" field
      if (kearl.or.kcont) write(luprt,'(2x,a2,":",a2,":",a2,$)') ch1,
     .cm1,cs1
C  "Data Start" field
      write(luprt,'(2x,i2.2,":",i2.2,":",i2.2,$)') ihd,imd,isd
C  "Data Stop" field
      write(luprt,'(2x,i2.2,":",i2.2,":",i2.2,$)') ih2,im2,is2
C  Continuous or adaptive, "Tape Stop" field
      if (kcont) write(luprt,'(2x,a2,":",a2,":",a2,$)') ch3,cm3,cs3
C  Duration
      write(luprt,'(2x,i3,":",i2.2,$)') idm,ids
C  Pass
      if (.not.kk4) then ! pass or S2 group
        if (cnewtap.eq.'@   ') then
          write(luprt,'(1x,"--",$)') 
        else
          write(luprt,'(1x,a2,$)') cpass
        endif
      endif ! pass or S2 group
C  Footage
      if (kmv) then
        if (cnewtap.eq.'@   ') then
          write(luprt,'("-",1x,i5,$)') ifeet_print
        else
          write(luprt,'(a1,1x,i5,$)') cdir(1:1),ifeet_print
        endif
      endif
      if (ks2) write(luprt,'(i5,$)') ifeet_print
      if (kk4) write(luprt,'(i8,$)') ifeet_print
C  New tape flag
      write(luprt,'(1x,a4,$)') cnewtap
 
C***** temporary check
      if (kcont.and.kend) then ! check stop time
        read(cs3,*) is3
        read(cm3,*) im3
        its=is2-is3
        itm=im2-im3
C       if (itm.gt.0.or.(itm.eq.0.and.its.gt.0)) write(luprt,
C    .       '("time dif=",i2,":",i2,$)') itm,its
      endif ! check stop time

      write(luprt,'()')
      iline=iline+1
      ncount = ncount + 1 ! count of observations
      if (cnewtap(1:3).eq.'XXX'.or.
     .    cnewtap(1:3).eq.'Rec') ntapes=ntapes+1

      return
      end
