      double precision function refr(del)

      double precision del
C
      dimension p(5)
      include '../include/dpi.i'
C
      data a/40./,b/2.7/,c/4./,d/42.5/,e/0.4/,f/2.64/,g/.57295787e-4/
      data p/.458675e1,.322009e0,.103452e-1,.274777e-3,.157115e-5/
      data tempc/15./,humi/50./,pres/1000./,cvt/1.33289/
C
      el=amax1(1.0,sngl(del*rad2deg))
C
C  Compute SN (surface refractivity)
C
      rhumi = (100.-humi)*.9
      dewpt = tempc-rhumi*(.136667+rhumi*1.33333e-3+tempc*1.5e-3)
      x = dewpt
      pp = p(1)
      do i=2,5
        pp=pp+x*p(i)
        x=x*dewpt
      enddo
      tempk=tempc+273.
      sn=77.6*(pres+(4810.*cvt*pp)/tempk)/tempk
C
      aphi = a/(el+b)**c
      ang = deg2rad*(90.-el)
      dele = -d/(el+e)**f
      bphi = g*(sin(ang)/cos(ang)+dele)
      if(el.eq.0) bphi = g*(1.+dele)
      refr = bphi*sn-aphi
C
      refr=refr*deg2rad
C
      return
      end
