function n=m2n(m,Tblock,Tr,Ts)
%convert factor m in Tsys to equivalent to factor n increase in SEFD for 
% partially blocking object
%input:
% m      = factor of increase in Tsys (scalar or vector)
% Tblock = temperature of blocking object
% Tr     = receiver temperature
% Ts     = contribution of sky to Tsys
%
% unblocked Tsys
T0=Tr+Ts;
% blocking fraction
a=T0*(m-1)/(Tblock-Ts);
% factor increase in SEFD
n=m./(1-a);