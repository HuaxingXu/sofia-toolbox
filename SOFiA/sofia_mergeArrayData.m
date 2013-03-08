% /// ASAR Research Group
% 
%     Cologne University of Applied Sciences
%     Technical University of Berlin
%     Deutsche Telekom Laboratories
%     WDR Westdeutscher Rundfunk
% 
% SOFiA sound field analysis
% 
% Array data import R11-1220
% 
% Copyright (C)2011 by bBrn - benjamin Bernsch�tz   
% 
% This file is part of the SOFiA toolbox under GNU General Public License
% 
%  
% timeData = sofia_mergeArrayData(impulseResponses, FS, temperature,...
%                                              [downSample], [normalize])
% ------------------------------------------------------------------------     
% timeData            Struct with fields:
% 
%                     .impulseResponses     [N:Channels M:Samples]          
%                     .FS
%                     .downSample
%                     .averageAirTemp       Temperature in DEG 
%                     .irOverlay            Plot this for a good total 
%                                           overview of the dataset.
% ------------------------------------------------------------------------
% impulseResponses   Impulse response data [M:Channels N:Samples]
%                    !The audio data must be in in columns as it is  
%                    usual in MATLAB. But SOFiA works on audio data 
%                    in rows as it is usual in audio editors etc.
%                    Therefore the output IR matrix is flipped over.
% 
%                    WARNING: Be sure the IRs come in the same order  
%                    as the sample grid points are organized!
% 
% FS                 Sampling frequency of the source material in 1/s
% 
% radius             Array sphere radius in meters
% 
% temperature        Average air temperature during the capture
%                    This is important for F/D/T to calculate the
%                    kr-vector. (This value is simply passed thru).
% 
% downSample         Downsampling factor  [default = 1: No downsampling]
%                    Downsampling is done using DECIMATE and a FIR low 
%                    pass filter of order 30. See MATLAB documentation 
%                    for more information. 
%                    !!! MATLAB Signal Processing Library required
% 
% normalize          Normalize flag 1:on, 0:off         [default = 1: on]       
%                    Normalizes the impulse responses with respect to the 
%                    absolute maximum value within the complete dataset.
% 
% directory          VSA dataset directory. If not defined a user dialog
%                    opens to pick a directory.




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


function timeData = sofia_mergeArrayData(impulseResponses, FS, temperature, downSample, normalize)
    
disp('SOFiA Merge microphone array data R11-1220');

if nargin < 2
   error('Input arguments missing: timeData = sofia_mergeArrayData(impulseResponses, FS, [temperature], [downSample], [normalize])');
end

if nargin < 3
   temperature = 20; %Default 
end

if nargin < 4
   downSample = 1; %Default 
end

if nargin < 5
   normalize = 1; %Default 
end
  
if downSample > 1
   impulseResponses=decimate(cast(impulseResponses,'double'),downSample ,'FIR');
end

if normalize == 1
   impulseResponses = impulseResponses./max(max(abs(impulseResponses)));     
end

%Combine struct

timeData.impulseResponses = impulseResponses';
timeData.FS               = FS;
timeData.downSample       = downSample;
timeData.averageAirTemp   = temperature;
timeData.irOverlay        = sum(timeData.impulseResponses,1);
timeData.irOverlay        = abs(timeData.irOverlay/max(abs(timeData.irOverlay)));

disp([num2str(size(impulseResponses,2)),' impulse responses merged.']); 

if size(impulseResponses,2) > size(impulseResponses,1)
   disp(' ');
   warning('Impulse responses must be delivered as [M:Channels N:Samples]. The dimensions of your IRs are suspicious...')
end

fprintf('\n');
