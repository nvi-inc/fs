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
c---------------------------------------------------------------
      subroutine latlon(nptsfp,ltpar,lttim,lttemp,ltoff,
     &                         lnpar,lntim,lntemp,lnoff,coslat)
c     
      real ltpar(*),lttim(*),lttemp(*),ltoff(*),
     &     lnpar(*),lntim(*),lntemp(*),lnoff(*)
c
c---- Comment on xxpar(*) (xx:lt for latitude, ln for longitude.)
c (1) peak temperature (degrees K)
c (2) offset of the peak (degrees);lnpar(2) is not corrected for cos(lat).
c (3) half-width of the Gaussian (degrees K);lnpar(3) is corrected for cos(lat).
c (4) temperature offset of the baseline(degrees K).
c (5) slope of the baseline (degrees K/second)
c----> The order in the log at latfit/lonfit is:
c     xxxfit (2) (3) (1) (4) (5); xxx for lat or lon.
c
      integer numer         ! Resolution of the fitted model.
      parameter (numer=101) ! Input odd number.
      real ltoi(numer),ltti(numer),ltrit,ltlft,lttop,ltbot
      real lnoi(numer),lnti(numer),lnrit,lnlft,lntop,lnbot
c
c     ->Longitude offset (lnpar(2) and lnoff) must be timed by cos(latitude).
        lnpar(2)=lnpar(2)*coslat
        do j=1,abs(nptsfp)
          lnoff(j)=lnoff(j)*coslat
        end do
c---- Set parameters for latitude
c     -> Window parameters
      call winparm(nptsfp,ltoff,lttemp,ltlft,ltrit,lttop,ltbot)
c     -> Function parameters
      call tmodl(ltoff,lttim,nptsfp,ltpar,ltrit,ltlft,numer,ltoi,ltti)
c---- Plot latitude data/model
      call pgopen('') ! default window control environment.
      call pgsubp(1,2)       ! Separate panel
      call pgpap(4.,1.618)   ! Aspect ratio
      call pgask(.FALSE.)    ! Not wait for <return>.  To wait, .TRUE.
      call pgsch(2.0)        ! Font size (1/40 of the plot window times)
      call pgenv(ltlft,ltrit,ltbot,lttop,0,0)
      call pglab('Offset','Temperature','Fivept (Latitude)')
      call pgline(numer,ltoi,ltti)
      call pgpt(abs(nptsfp),ltoff,lttemp,10)
c
c---- Set parameters for longitude
c     -> Window parameters
      call winparm(nptsfp,lnoff,lntemp,lnlft,lnrit,lntop,lnbot)
c     -> Fnction parameters
      call tmodl(lnoff,lntim,nptsfp,lnpar,lnrit,lnlft,numer,lnoi,lnti)
c---- plot longitude data/model
      call pgenv(lnlft,lnrit,lnbot,lntop,0,0)
      call pglab('Offset','Temperature','Fivept (Longitude)')
      call pgline(numer,lnoi,lnti)
      call pgpt(abs(nptsfp),lnoff,lntemp,10)
ccc      call pgclos
      return
      end
c---------------------------------------------------------------
      subroutine tmodl(off,tim,nptsfp,lpar,wright,wleft,numer,oi,ti)
c---- Set functional parameters
      dimension off(*),tim(*)
      real lpar(*)
      real oi(*),ti(*)
      t0=lpar(4) ! temperature offset
      ts=lpar(5) ! slope offset defined as dt/dtime
      tp=lpar(1) ! peak of the Gaussian part
      fwhm=lpar(3) ! full-width-half-maximum of the Gaussian.
      oo=lpar(2) ! offset of the peak
      oto=off((1+abs(nptsfp))/2) ! offset at t0(midpoint)
      o2time=(tim(abs(nptsfp))-tim(1))/(off(abs(nptsfp))-off(1))
      drstep=(wright-wleft)/(numer-1)! numer-1 is the step to plot.
c---- Create model numerical data
      do i=1,numer
        oi(i)=wleft+drstep*(i-1)
        ti(i)=t0+ts*slopfit(oi(i),oto,o2time)+tp*gausfit(oi(i),oo,fwhm)
      end do
      return
      end
c---------------------------------------------------------------
      subroutine winparm(nptsfp,off,temp,wleft,wright,wtop,wbot)
      dimension off(*),temp(*)
c---- Set window parameters
      wlrtmp=abs(amax1(abs(off(1)),abs(off(nptsfp))))
      wleft=-1.*wlrtmp
      wright=wlrtmp
      wtop=temp(1)
      wbot=temp(1)
      do j=1,abs(nptsfp)
        wtop=amax1(wtop,temp(j))
        wbot=amin1(wbot,temp(j))
      end do
c---- Set margin
      whor=abs(wright-wleft)*0.1
      wvar=abs(wtop-wbot)*0.1
      wleft=wleft-whor
      wright=wright+whor
      wtop=wtop+wvar*2. ! The model peak must be higher than the observation.
      wbot=wbot-wvar
      return
      end
c---------------------------------------------------------------
      real function gausfit(oi,oo,fwhm)
c
      gausfit=exp(-4*alog(2.)*((oi-oo)/fwhm)**2)
      return
      end
c---------------------------------------------------------------
      real function slopfit(oi,oto,o2time)
c
      slopfit=(oi-oto)*o2time
      return
      end
