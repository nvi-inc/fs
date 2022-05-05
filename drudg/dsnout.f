*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine dsnout(ldsn)

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

C Input
      integer*2 ldsn ! DSN ID, e.g. 45, 15, 65
C Local
      integer idum,i,icode,i1lo,i1hi,i2lo,i2hi,idrate
      integer i1,i2
      integer*2 lif1(2),lif2(2)
      double precision dvc(max_chan),idvc(max_chan)
      integer ichmv_ch,ichcm_ch


      icode=1
C     nfreq(1,istn,icode)=8
C     nfreq(2,istn,icode)=6
      i1=1
      i2=nfreq(1,istn,icode)+1
      write(lu_outfile,"('*END'/' $FREQUENCIES')")
      write(lu_outfile,9601) nfreq(1,istn,icode),nfreq(2,istn,icode)
9601  format(' BAND    = ',i1,'*2, ',i1,'*1,')
      write(lu_outfile,9602) nfreq(1,istn,icode),freqlo(1,istn,icode),
     .nfreq(2,istn,icode),freqlo(i2,istn,icode)
9602  format(' BIAS    =',2(1x,i1,'*',f17.10,4x,','))
      write(lu_outfile,9603)
9603  format(' DWELL   = 14*0.0000000000000000E+00,')
      do i=1,nfreq(1,istn,icode)
        dvc(i) = (freqrf(i,istn,icode)-freqlo(i,istn,icode))
      enddo
      do i=nfreq(1,istn,icode)+1,nfreq(1,istn,icode)+nfreq(2,istn,icode)
          dvc(i) = (freqrf(i,istn,icode)-freqlo(i,istn,icode))
      enddo
      do i=1,max_chan
        idvc(i)=(dvc(i)+.001)*100.d0
      enddo
      write(lu_outfile,9604) (idvc(i),i=1,14)
9604  format(' ONEWAYFREQ      =',2(3x,i5,'0000.0000000',4x,',')
     .4(/3x,i5,'0000.0000000',4x,','2x,i5,'0000.0000000',4x,',',
     .2x,i5,'0000.0000000',4x,','))
      write(lu_outfile,9605) ldsn
9605  format(' STATIONID       = ',6x,a2/' $END')
      write(lu_outfile,9606)
9606  format(' $CONFIGDATA'/
     .           ' AMPNUMBER1      =          1,'/
     .           ' AMPNUMBER2      =          2,'/
     .           ' AMPSELECT1      = ''MAS'','/
     .           ' AMPSELECT2      = ''MAS'','/
     .           ' BANDCOMB        = ''OFF'','/
     .           ' DRIFT1  =  0.1494000    ,'/
     .           ' DRIFT2  =  0.2968000    ,'/
     .           ' JITTERTHRESH1   =         10,'/
     .           ' JITTERTHRESH2   =         20,'/
     .           ' MAGTOLER1       =  7.0000000000000000E-03,'/
     .           ' MAGTOLER2       =  7.0000000000000000E-03,'/
     .           ' PCGCOMBDIV1     =          5,'/
     .           ' PCGCOMBDIV2     =          5,'/
     .           ' PCGPOWER1       =   6.000000    ,'/
     .           ' PCGPOWER2       =   6.000000    ,'/
     .           ' POLARIZ1        = ''RCP'','/
     .           ' POLARIZ2        = ''RCP'',')
      idrate = 2.d0*vcband(1,istn,icode)
      idum=ichmv_ch(lif1,1,'NOR ')
      idum=ichmv_ch(lif2,1,'NOR ')
C************ Not correct for ALT input. Must find proper channel for
C each group of inputs
      if (ichcm_ch(lifinp(1,istn,icode),1,'A') .eq.0)
     .idum=ichmv_ch(lif1,1,'ALT ')
      if (ichcm_ch(lifinp(1,istn,icode),1,'A') .eq.0)
     .idum=ichmv_ch(lif2,1,'ALT ')
      i2lo=0
      i2hi=0
      do i=1,nfreq(1,istn,icode)
        if (dvc(i).lt.220.0) i2lo=i2lo+1
        if (dvc(i).gt.220.0) i2hi=i2hi+1
      enddo
      i1lo=0
      i1hi=0
      do i=nfreq(1,istn,icode)+1,nfreq(1,istn,icode)+
     .                           nfreq(2,istn,icode)
        if (dvc(i).lt.220.0) i1lo=i1lo+1
        if (dvc(i).gt.220.0) i1hi=i1hi+1
      enddo
      write(lu_outfile,9607) lmode(1,istn,icode),idrate,ldsn,lif1,lif2,
     .i2lo,i2hi,i1lo,i1hi,vcband(1,istn,icode)
9607  format(' RECORDERMODE    = ''',a1,''','/
     .           ' SAMPLERATE      =     ',i1,'000000,'/
     .           ' TESTWORD        =        12,        34,',
     .                                '    56,      78,'/
     .           ' WCBINSRC1N      =         2,'/
     .           ' WCBINSRC2N      =         3,'/
     .           ' SESSIONTYPE     = ''WBRADIOASTRY'','/
     .           ' STATIONID       =        ',a2,','/
     .           ' WCBIF1SEL       = ''',a2,a1,''','/
     .           ' WCBIF2SEL       = ''',a2,a1,''','/
     .           ' WCBVCINP        = ',i1,'*''2LO'', ',i1,'*''2HI'', ',
     .                                 i1,'*''1LO'', ',i1,'*''1HI'','/
     .           ' WCBVCBW =   ',f8.6,'    ,'/
     .           ' WCBAUXDAT       = ''WCBAUXDAT   '','/
     .           ' WCBFRQ15        =   110990000.0000000'/' $END')

      return
      end
