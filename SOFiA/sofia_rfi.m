% /// ASAR Research Group
% 
%     Cologne University of Applied Sciences
%     Technical University of Berlin
%     Deutsche Telekom Laboratories
%     WDR Westdeutscher Rundfunk
% 
% SOFiA sound field analysis
% 
% R/F/I Radial Filter Improvement R11-1220
% 
% Copyright (C)2011 by bBrn - benjamin Bernsch�tz   
% 
% This file is part of the SOFiA toolbox under GNU General Public License
% 
%  
% function [dn, kernelSize, latency] = 
%                    sofia_rfi(dn, kernelDownScale, highPass)
% ------------------------------------------------------------------------     
% dn                 Improved radial filters
% kernelSize         Filter kernel size (total)
% latency            Approximate signal latency due to the filters
%         
% ------------------------------------------------------------------------              
% dn                 Analytical frequency domain radial filters 
%                    from SOFiA M/F
% kernelDownScale    Downscale factor for the filter kernel #default: 2                                   
% highPass           Highpass Filter 0:highPass:1
%                    highPass = 1 corresponds to the maximum kr available.
%                    highPass = 0 filter off (#default) 
%                    
% INFORMATION: If HPF is on (highPass>0) the radial filter kernel is 
%              downscaled by a factor of two. Radial Filters and HPF 
%              share the available taps and the latency keeps constant. 
%              Be careful using very small signal blocks because there 
%              may remain too few taps. Observe the filters by plotting
%              their spectra and impulse responses. 
%              > Be very carefull if NFFT/max(kr) < 25 
%              > Do not use R/F/I if NFFT/max(kr) < 15 
%   
% This function improves the FIR radial filters from SOFiA M/F. The filters 
% are made causal and are windowed in time domain. The DC components are
% estimated. The R/F/I module should always be inserted to the filter 
% path when treating measured data even if no use is made of the included 
% kernel downscaling or highpass filters.
%
% Do NOT use R/F/I for single open sphere filters (e.g.simulations). 
% 
% IMPORTANT: Remember to choose a fft-oversize factor (F/D/T) being large
%            enough to cover all filter latencies and reponse slopes.
%            Otherwise undesired cyclic convolution artifacts may appear  
%            in the output signal. 
%
% Dependencies: MATLAB Signal Processing Toolbox required for HPF.
%                   


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
% 


function [dn, kernelSize, latency] = sofia_rfi(dn, kernelDownScale, highPass)

disp('SOFiA R/F/I - Radial Filter Improvement R11-1220');

if nargin <1
   error('Filter coefficients from SOFiA M/F required.');
end

if nargin <2
   kernelDownScale = 2;   %Default: Downscale by a factor of 2
end

if nargin <3
   highPass = 0;          %Default: HPF off
end

sourceKernelSize = (size(dn,2)-1)*2;

if rem(log2(kernelDownScale),1) ~= 0 || kernelDownScale<1 || kernelDownScale>=sourceKernelSize/2
   error('Invalid Kernel downscale factor.');
end

signalProcessingExists = false;
toolboxes = ver;
for i = 1: size(toolboxes,2)
    if ~isempty(strfind(toolboxes(i).Name,'Signal Processing Toolbox'))
       signalProcessingExists = true;   
       break
    end
end

% If HP is active downscale both kernels:
if signalProcessingExists && highPass>0 && highPass <=1 
   kernelDownScale = kernelDownScale*2;
   hpActive = true;
else
   hpActive = false;
end

% DC-Component estimation
dndiff=abs(dn(:,2)./dn(:,3));
oddOrders=2:2:size(dn,1);    
dn(oddOrders,1)=-1i.*dn(oddOrders,2).*2.*kernelDownScale.*dndiff(oddOrders);

% Reconstruct negative spectrals
dn_FULL = [dn(:,:), conj(fliplr(dn(:,2:end-1)))];

% Transform > time domain
dnir=real(ifft(dn_FULL,[],2));

% Make filters causal
dnir=[dnir(:,end/2+1:end), dnir(:,1:end/2)];

% Downsize kernel
kernelSize = sourceKernelSize/kernelDownScale;
latency = kernelSize/2;
dnir=[dnir(:,end/2-kernelSize/2+1:end/2),dnir(:,end/2+1:end/2+1+kernelSize/2-1)];

% Window
j=0:kernelSize-1;   
winfkt = 0.5+0.5*cos(2*pi*(j-((kernelSize-1)/2))/(kernelSize-1));
dnir = dnir.*repmat(winfkt,size(dnir,1),1);

% Transform to frequency domain
dn = fft(dnir,sourceKernelSize,2);

% Highpass
if hpActive
   HP = fft(fir1(kernelSize-2,highPass,'high'),sourceKernelSize);
   dn = dn.*repmat(HP,size(dn,1),1);  
end

% Throw negative spectrals
dn = dn(:,1:end/2+1);


