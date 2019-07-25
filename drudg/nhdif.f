	integer function nhdif(idnow,ihnow,imnow,id1,ih1,im1)

C  NHSK computes the number of hours between day/hour/min now (end)
C       and day/hour/min 1 (start).
C       Assumes time "now" is later than time "1".
C NRV 910911 Removed rounding to next higher hour

	nd = idnow - id1
	nh = ihnow - ih1
	nm = imnow - im1
	if (nm.lt.0) then
	  nm = nm + 60
	  nh = nh - 1
	endif
	if (nh.lt.0) then
	  nh = nh + 24
	  nd = nd - 1
	endif
C       nhdif = nd*24 + nh + (nm+30)/60
        nhdif = nd*24 + nh

	return
	end
