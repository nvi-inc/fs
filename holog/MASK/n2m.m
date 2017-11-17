function m=n2m(n,Tblock,Tr,Ts)
%convert factor n increase in SEFD to equivalent factor m in Tsys
% partially blocking object
%input:
% n      = factor of increase in SEFD (scalar or vector)
% Tblock = temperature of blocking object
% Tr     = receiver temperature
% Ts     = contribution of sky to Tsys
%output:
% m      = factor increase in Tsys
% unblocked Tsys
T0=Tr+Ts;
% blocking fraction
a=T0*(n-1)./(Tblock-Ts+n*T0);
% resulting Tsys 
Tsys=T0+(Tblock-Ts)*a;
% factor increase in Tsys
m=Tsys/T0;