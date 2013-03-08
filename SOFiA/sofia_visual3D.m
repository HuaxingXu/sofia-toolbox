% /// ASAR Research Group
% 
%     Cologne University of Applied Sciences
%     Technical University of Berlin
%     Deutsche Telekom Laboratories
%     WDR Westdeutscher Rundfunk
% 
% SOFiA sound field analysis
% 
% Visual 3D - sound field data visualisation R11-1220
% 
% Copyright (C)2011 by bBrn - benjamin Bernsch�tz   
% 
% This file is part of the SOFiA toolbox under GNU General Public License
% 
%  
% void = sofia_visual3d(mtxData, visualStyle, [colormap])
% ------------------------------------------------------------------------     
% void
% ------------------------------------------------------------------------              
% mtxData      SOFiA 3D-matrix-data [1�steps]
% visualStyle  0 - Globe,      surface colors indicate the intensity
%              1 - Flat,       surface colors indicate the intensity 
%              2 - 3D pattern, extension indicates the intensity
%              3 - 3D pattern, extension+colors indicate the intensity
% color_map    MATLAB colormaps (see MATLAB reference) [optional]
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


function sofia_visual3D(mtxData, visualStyle, color_map)

disp('SOFiA Visual3D Response Visualization R11-1220');

if nargin == 0
   load sofia_exampleMtxData mtxData
end

if nargin < 2
   visualStyle = 0;
end
 
if (size(mtxData,1)~=181 || size(mtxData,2)~=360)
    error('Data type missmatch: SOFiA 3D-matrix-data with 181x360 pixels expected.');
end


set(gcf,'Color', 'w');

mtxData = abs(mtxData);

if visualStyle == 0
    
    if nargin < 3
       color_map = 'Jet'; 
    end
    set(gca, 'NextPlot','add', 'Visible','off');
    axis equal;
    %view(-90,0);
    [x, y, z] = ellipsoid(0, 0, 0, 1, 1, 1);
    globePlot = surf(-x, -y, -z, 'FaceColor', 'none', 'EdgeColor', [1 1 1]);
    alpha = 1;
    set(globePlot, 'FaceColor', 'texturemap', 'CData', mtxData, 'FaceAlpha', alpha, 'EdgeColor', 'none');
    colorbar('location','EastOutside', 'TickLength',[0 0], 'LineWidth', 2, 'FontSize', 16)
    
    view(105,20);  
    
    text(0,0,1.1,'0^oE','fontsize', 14,'color', [.502 .502 .502])
    text(0,0,-1.1,'180^oE','fontsize', 14,'color', [.502 .502 .502])
    text(0,1.1,0,'90^oA','fontsize', 14,'color', [.502 .502 .502])
    text(0,-1.1,0,'270^oA','fontsize', 14,'color', [.502 .502 .502])
    text(-1.1,0,0,'180^oA','fontsize', 14,'color', [.502 .502 .502])
    text(1.1,0,0,'0^oA','fontsize', 14,'color', [.502 .502 .502])
    

elseif visualStyle == 1
    
    if nargin < 3
       color_map = 'Jet'; 
    end
    imagesc(mtxData)
    xlabel('Azimuth in DEG')
    ylabel('Elevation in DEG')

elseif visualStyle == 2
    
    if nargin < 3
       color_map = [0 1 0]; 
    end
    
    mtxData = [mtxData mtxData(:, 1)];
    theta = (0:360)*pi/180;
    phi = (0:180)*pi/180;
    [theta, phi] = meshgrid(theta, phi);
    [X,Z,Y] = sph2cart(theta, phi-pi/2, mtxData);    
    surf(X,Y,Z,'edgecolor','none'); 
    axis equal
    axis off
    box off
    rotate3d on
    light; 
    lighting phong; 
    camzoom(1.3);
       
elseif visualStyle == 3
    
    if nargin < 3
       color_map = 'Jet'; 
    end
    
    mtxData = [mtxData mtxData(:, 1)];
    theta = (0:360)*pi/180;
    phi = (0:180)*pi/180;
    [theta, phi] = meshgrid(theta, phi);
    [X,Z,Y] = sph2cart(theta, phi-pi/2, mtxData);
    set(gca, 'NextPlot','add', 'Visible','off');
    axis equal;
    view(45,45);   
    globePlot = surf(X, Y, -Z, 'FaceColor', 'none', 'EdgeColor', [1 1 1]);
    alpha = 1;
    set(globePlot, 'FaceColor', 'texturemap', 'CData', mtxData, 'FaceAlpha', alpha, 'EdgeColor', 'none');
    colorbar('location','EastOutside', 'TickLength',[0 0], 'LineWidth', 2, 'FontSize', 16)    
    
end

colormap(color_map);