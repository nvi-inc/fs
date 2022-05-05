* PARPO.CTL - Control file for XTRAC
*
* 1ST LINE PARAMTERS:
*
*     1. TELESCOPE NAME (8 CHARACTERS MAX)
*     2. TELESCOPE AXIS TYPE (4 CHARACTERS MAX)
*
     MV-3 azel
*
*  2ND LINE Parameters:
*
*    1. 0 OR 1, 1= EDIT THE DATA, 0= DON'T EDIT
*    2. Minimum Acceptable Beamwidth (Degrees)
*    3. Maximum Acceptable Beamwidth (Degrees)
*    4. Ratio Allowed in Difference of Fitted Peaks
*
    0    0.075  0.115  1.25
*
* 3rd line Parameters
*
*  1. hex control flag, bit 0: 0 =FEC in Az(X,HA), 1 =FEC in X-El (X-Y,X-DC)
*                       bit 1: 0 =pdplt uses Az(X,HA) offset, 1=X-EL (X-Y, X-DC)
*
   3
