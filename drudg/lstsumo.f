      subroutine lstsumo(iline,npage,cstn,cid,cexper,maxline,idir,
     .      speed_snap,itearl_local,kwrap,ks2,cday,kazel,ksat,ket,
     .      kstart,nsline,csor,cwrap,ch1,cm1,cs1,ih1,im1,is1,
     .      ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,ifeet,cnewtap,cdir,
     .      kskd,ncount,ntapes,
     .      rarad,dcrad,xpos,ypos,zpos,mjd,ut)

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

C Input
      double precision rarad,dcrad,xpos,ypos,zpos,ut
      integer mjd,ih1,im1,is1
      integer iline,npage,itearl_local,nsline,ncount,ntapes,maxline
      real speed_snap
      integer ihd,imd,isd,ih2,im2,is2,idm,ids,ifeet,idir
      character*8 csor,cexper,cstn
      character*3 cdir,cnewtap,cday
      character*2 cpass,ch1,cm1,cs1
      character*2 cid
      character*7 cwrap
      logical kskd,kstart,ket,ks2
      logical kwrap, kazel,ksat

C Output
C These are modified on return: iline, page,ncount,ntapes

C Local
      integer i,idur,iaz,iel,trimlen
      double precision az,el
      integer*2 lt
      integer zz2,idum,ib2as

      zz2 = 2+o'40000'+o'400'*2
      if (iline.ge.maxline) then ! new page, write header
        if (npage.gt.0) call luff(luprt)
        npage = npage + 1
        write(luprt,9300) cinname(1:trimlen(cinname)),npage
9300    format(' Schedule file: ',a,35x,'Page ',i3)
        if (kskd) then
          write(luprt,9302) (lstnna(i,istn),i=1,4),lpocod(istn),
     .    (lexper(i),i=1,4)
9302      format(' Station: ',4a2,' (',a2,')'/' Experiment: ',4a2)
        else
          write(luprt,9303) cstn,cid,cexper
9303      format(' Station: ',a8,' (',a2,')'/' Experiment: ',a8)
        endif
        write(luprt,9304) itearl_local
9304    format(' Early tape start: ',i3,' seconds'/)
C
        if (kwrap.and..not.ks2) write(luprt,9310)
9310    format(22x,'        Start    Start    Stop',19x,
     .  '  Change/'/
     .  ' Line#  Source   Az El Cable   Tape     Data     ',
     .  'Data    Dur Pass Dir Tape Check')
        if (.not.kwrap.and..not.ks2) write(luprt,9390)
9390    format(22x,'     Start     Start     Stop',20x,
     .  ' Change/'/
     .  ' Line#  Source    Az El    Tape      Data      ',
     .  'Data     Dur Pass Dir Tape Check')
        if (kwrap.and.ks2) write(luprt,9312)
9312    format(22x,'        Start    Start    Stop',15x,
     .  'Tape'/
     .  ' Line#  Source   Az El Cable   Tape     Data     ',
     .  'Data    Dur Group (min) Change')
        if (.not.kwrap.and.ks2) write(luprt,9391)
9391    format(22x,'     Start     Start     Stop',16x,
     .  'Tape'/
     .  ' Line#  Source    Az El    Tape      Data      ',
     .  'Data     Dur Group (min) Change')
        write(luprt,9311)
9311    format('-----------------------------------------',
     .  '-------------------------------------')
        write(luprt,9320) cday
9320    format('  Day ',a)
        iline=0
      endif ! new page, write header
C   Now write the scan line
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
C     if (cnewtap.eq.'XXX') ket=.true.
      if (kstart) then ! convert start time to characters
        idum=ib2as(ih1,lt,1,zz2)
        call hol2char(lt,1,2,ch1)
        idum=ib2as(im1,lt,1,zz2)
        call hol2char(lt,1,2,cm1)
        idum=ib2as(is1,lt,1,zz2)
        call hol2char(lt,1,2,cs1)
       else ! blank out start time
        ch1='  '
        cm1='  '
        cs1='  '
      endif
      if (kwrap.and..not.ks2) then
        write(luprt,9330) nsline,csor,iaz,iel,cwrap,ch1,cm1,cs1,
     .  ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,cdir,ifeet,cnewtap
9330    format(1x,i5,1x,a8,1x,i3,1x,i2,1x,a5,1x,a2,':',a2,':',
     .  a2,1x,i2.2,':',i2.2,':',i2.2,1x,i2.2,':',i2.2,':',i2.2,
     .  1x,i2.2,':',i2.2,2x,a2,1x,a3,1x,i5,1x,a3)
      else if (.not.kwrap.and..not.ks2) then
        write(luprt,9380) nsline,csor,iaz,iel,ch1,cm1,cs1,ihd,imd,
     .  isd,ih2,im2,is2,idm,ids,cpass,cdir,ifeet,cnewtap
9380    format(1x,i5,1x,a8,2x,i3,1x,i2,1x,1x,a2,':',a2,':',
     .  a2,2x,i2.2,':',i2.2,':',i2.2,2x,i2.2,':',i2.2,':',i2.2,
     .  2x,i2.2,':',i2.2,2x,a2,1x,a3,1x,i5,1x,a3)
      else if (kwrap.and.ks2) then
        write(luprt,9331) nsline,csor,iaz,iel,cwrap,ch1,cm1,cs1,
     .  ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,ifeet/60,cnewtap
9331    format(1x,i5,1x,a8,1x,i3,1x,i2,1x,a5,1x,a2,':',a2,':',
     .  a2,1x,i2.2,':',i2.2,':',i2.2,1x,i2.2,':',i2.2,':',i2.2,
     .  1x,i2.2,':',i2.2,2x,a2,1x,i5,1x,a3)
      else if (.not.kwrap.and.ks2) then
        write(luprt,9381) nsline,csor,iaz,iel,ch1,cm1,cs1,ihd,imd,
     .  isd,ih2,im2,is2,idm,ids,cpass,ifeet/60,cnewtap
9381    format(1x,i5,1x,a8,2x,i3,1x,i2,1x,1x,a2,':',a2,':',
     .  a2,2x,i2.2,':',i2.2,':',i2.2,2x,i2.2,':',i2.2,':',i2.2,
     .  2x,i2.2,':',i2.2,2x,a2,1x,i5,1x,a3)
      endif
      iline=iline+1
      ncount = ncount + 1 ! count of observations
      if (cnewtap.eq.'XXX') ntapes=ntapes+1
      cnewtap = '   '

      return
      end
