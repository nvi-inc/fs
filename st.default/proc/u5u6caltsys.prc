define  caltsys       00000000000
"normal levels and diode off assumed on entry
"note: passing for settling provide by u5,u6 station code
tpi=u5,u6
"set maximize attentuation, then
tpzero=u5,u6
"set normal attenuation, then:
"set cal on, then
tpical=u5,u6
tpdiff=u5,u6
"set cal off, then:
"define user device characteriscs, for example:
user_device=u5,7681,usb,rcp,750
user_device=u6,1601,usb,rcp,750
caltemp=u5,u6
tsys=u5,u6
enddef
