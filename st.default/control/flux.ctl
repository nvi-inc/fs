* flux.ctl - source flux control file
*
* source records:
*
* originally from John Conway based on (Casa, Cygnusa, TauA) from Baars et al
* 1977, AA, 61, 99 and (others) Ott et al 1994, AA 284, 331, see sflux.f
* subroutine, WEH 020813
*
* min freq on L band sources decreased to 500 per John Conway, WEH 0209xx
*
*               freq MHz  ---- flux 10** ----   "     FS
* source  type  min  max  log   log(f) 2log(f) size  model
   3c48     c   500 23780 2.465 -0.004 -0.1251   1.5 gauss 100    1s
   3c123    c   500 23780 2.525  0.246 -0.1638  23   gauss 100   23s 5s
   3c147    c   500 23780 2.806 -0.140 -0.1031   1   gauss 100    1s
   3c161    c   500 10550 1.250  0.726 -0.2286   3   gauss 100    3s
   3c218    c   500 10550 4.729 -1.025  0.0130  47   gauss 100   47s 14s
   3c227    c   500  5000 6.757 -2.801  0.2969 200   gauss 100  200s 50s
   3c249.1  c   500  5000 2.537 -0.565 -0.0404  15   gauss 100   15s
* virgo structure guessed from FS manuals, WEH 0208xx
   virgoa   c   500  2520 4.484 -0.603 -0.0280 200   gauss  80.8 40s 20s 19.2 10m 10m
   virgoa   c  2520 10550 4.484 -0.603 -0.0280 200   gauss  97.3 40s 20s  2.7 10m 10m
   3c286    c   500 43200 0.956  0.584 -0.1644   1.5 gauss 100    1s
   3c295    c   500 32000 1.490  0.756 -0.2545   5   gauss 100    5s  1s
* changed to "p" per Alex Kraus, WEH 020814
   3c309.1  p   500 32000 2.617 -0.437 -0.0373   1.5 gauss 100  1.5s 1.5s
   3c348    c   500 10550 3.852 -0.361 -0.1053 170   gauss 100  170s  25s
   3c353    c   500 10550 3.148 -0.157 -0.0911 210   gauss 100  210s  60s
   cygnusa  c    20  2000 4.695  0.085 -0.178  115   2pts  115s
   cygnusa  c  2000 31000 7.161 -1.244  0.0    115   2pts  115s
   taurusa  c   500 35000 3.915 -0.299  0.0    300   gauss 100 4.2m 2.6m
*
*  Flux of ngc7027 scaled by -0.5% per year (from Ott et al 1994) to 
*  epoch 13th Oct 2003 gives a flux density reduction to  93.7% 
*  of the 1990 level. John Conway 030205
*
   ngc7027  c 10550 43200 1.2937 -0.134  0       10   gauss 100 7s   10s
*
*  Flux density of DR21 at K band taken from Ott et al (1994)
*  Ott et al 1994. John Conway 030205
*
   dr21     c 21000 24000 1.231  0.000  0.0     20  gauss  100 20s  20s 
*
* casa is special name with flux decreasing from 1980.0
*  casa     p   300 31000 5.745 -0.770  0       240  disk  4m
* new value for casa decreasing from 2006 per D. Graham 060928
   casa     p   300 31000 5.660 -0.760  0       240  disk  4m
* the following points added from FS Manual WEH 0208xx
   3c380    p  2020  2520 1.041  0      0         1  gauss 100 1s
   3c380    p  8080  9080 0.716  0      0         1  gauss 100 1s
   3c391    p  2020  2520 1.204  0      0       270  gauss 100 4.5m
   3c391    p  8080  9080 0.875  0      0       270  gauss 100 4.5m
   0521m365 p  2020  2520 1.130  0      0        15  gauss 100 15s
   0521m365 p  8080  9080 0.740  0      0        15  gauss 100 15s
   sun      p  2020  2520 5.60206 0      0     1872  disk  0.52d
   sun      p  8080  9080 6.39794 0      0     1872  disk  0.52d
   moon     p  2020  2520 3.35218 0      0     1872  disk  0.52d
   moon     p  8080  9080 4.49136 0      0     1872  disk  0.52d
   oriona   p  2020  2520 2.64345 0      0      240  gauss 100 4m
   oriona   p  8080  9080 2.53147 0      0      240  gauss 100 4m
*3c84 from DBS flux tabe, note source is variable, WEH 020916
   3c84     p  2020  2520 1.60205 0      0        1  gauss 100 1s  
   3c84     p  8080  9080 1.69987 0      0        1  gauss 100 1s  
*
