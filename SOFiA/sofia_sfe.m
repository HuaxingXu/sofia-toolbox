% /// ASAR Research Group
% 
% Cologne University of Applied Sciences
% Technical University of Berlin
% Deutsche Telekom Laboratories
% WDR Westdeutscher Rundfunk
% 
% SOFiA sound field analysis
% 
% S/F/E Sound Field Extrapolation 1407.11
% 
% Copyright (C)2011 by bBrn - benjamin Bernsch�tz 
%                             rockzentrale 'AT' me.com
%                             Germany +49 171 4176069  
% 
% This file is part of the SOFiA toolbox under GNU General Public License
% 
% Pnm_krb = sofia_sfe(Pnm_kra, kra, krb, problem) 
% ------------------------------------------------------------------------     
% Pnm_krb Spatial Fourier Coefficients, extrapolated to rb
% ------------------------------------------------------------------------              
% 
% Pnm_kra Spatial Fourier Coefficients from SOFiA S/T/C
% 
% kra     k*ra Vector
% krb     k*rb Vector
% problem 1: Interior problem [default]  2: Exterior problem



% CONTACT AND LICENSE INFORMATION:
%
% /// ASAR Research Group 
%  
%     [1] Cologne University of Applied Sciences
%     [2] Technical University of Berlin 
%     [3] Deutsche Telekom Laboratories 
%     [4] WDR Westdeutscher Rundfunk 
%
% SOFiA sound field analysis
%
% Copyright (C)2011 bBrn - benjamin Bernsch�tz [1,2] et al.(�)   
%
% Contact ------------------------------------
% Cologne University of Applied Sciences 
% Institute of Communication Systems
% Betzdorfer Street 2
% D-50679 Germany (Europe)
%
% phone       +49 221 8275 -2496 
% cell phone  +49 171 4176069 
% mail        rockzentrale 'at' me.com 
% --------------------------------------------
% 
% This file is part of the SOFiA sound field analysis toolbox 
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
% 
%
% (�) Christoph P�rschmann [1]   christoph.poerschmann 'at' fh-koeln.de
%     Sascha Spors         [2,3] sascha.spors 'at' telekom.de  
%     Stefan Weinzierl     [2]   stefan.weinzierl 'at' tu-berlin.de


function Pnm_krb = sofia_sfe(Pnm_kra, kra, krb, problem) 

disp('SOFiA S/F/E - Sound Field Extrapolation R11-1220');
disp(' ');

if nargin < 3
    error('Arguments missing. 3 Args required: Pnm_krb = sofia_sfe(Pnm_kra, kra, krb)')
end

if nargin < 4
   problem = 1;
end

if size(kra,2) ~= size(krb,2) ||  size(kra,2) ~= size(Pnm_kra,2) 
   error('FFT bin number or dimension mismatch. Pnm_kra, kra and krb must have the same M-dimension.') 
end

FCoeff  = size(Pnm_kra,1);
N       = sqrt(FCoeff)-1;

nvector=zeros(FCoeff,1);

index = 1;
for n=0:N
    for m=-n:n
        nvector(index) = n;
        index = index+1;
    end
end

nvector = repmat(nvector,1,size(Pnm_kra,2));
kra     = repmat(kra,FCoeff,1);
krb     = repmat(krb,FCoeff,1);

if problem == 2
    hn_kra  = sqrt(pi./(2*kra)).*besselh(nvector+.5,1,kra);
    hn_krb  = sqrt(pi./(2*krb)).*besselh(nvector+.5,1,krb);
    exp     = hn_krb./hn_kra;
else
    jn_kra  = sqrt(pi./(2*kra)).*besselj(n+.5,kra);
    jn_krb  = sqrt(pi./(2*krb)).*besselj(n+.5,krb);
    plot(abs(jn_kra'))
    exp     = jn_krb./jn_kra;
    if ~isempty(find(abs(exp)>1e2)) %40dB
       disp('WARNING: Extrapolation might be unstable for one or more frequencies/orders!');
    end
end

Pnm_krb = Pnm_kra.*exp;

