function m=n2m(n,Tblock,Tr,Ts)
% Copyright (c) 2020 NVI, Inc.
%
% This file is part of VLBI Field System
% (see http://github.com/nvi-inc/fs).
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.

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
