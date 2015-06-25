%--------------------------------------------------------------------------
%                           ISR-TrafSim v2.0
%                        Copyright (C) 2010-2013
%
%--------------------------------------------------------------------------
% This Matlab file is part of the ISR-TrafSim: a Matlab
% library for traffic simulation and pose estimation in Urban environments,
% namely roundabouts and crossroads.
%
% http://www.isr.uc.pt/~conde/isr-trafsim/
%
%-CITATION---------------------------------------------------------------------------
% If you use this software please cite one of the following papers:
% 1) L.C.Bento, R.Parafita, S.Santos and U.Nunes, An Intelligent Traffic Management
% at Intersections legacy mode for vehicles not equipped with V2V and V2I Communications,
% 16th IEEE Int.Conf. Intelligent Transportation Systems, Netherlands, 2013.
% 2) L.C.Bento, R.Parafita and U.Nunes, Inter-vehicle sensor fusion for accurate vehicle
% localization supported by V2V and V2I communications, 15th IEEE Int.Conf. Intelligent
% Transportation Systems, USA, 2012.
% 3) L.C.Bento, R.Parafita and U.Nunes, Intelligent traffic management at intersections
% supported by V2V and V2I communications, 15th IEEE Int.Conf. Intelligent
% Transportation Systems, USA, 2012.
%
%-DESCRIPTION------------------------------------------------------------------------
%
% Write the desired velocity profile on layers
%
%-DISCLAIMER-------------------------------------------------------------------------
% This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% You can use this source code without licensing fees only for NON-COMMERCIAL research
% and EDUCATIONAL purposes only.
% You cannot repost this file without prior written permission from the authors.
%
%-AUTHORS------------------------------------------------------------------
%   Urbano Nunes*
%   Luis Conde Bento**
%   Ricardo Parafita*
%   Sergio Santos*
%
%  *Institute of Systems and Robotics   - University of Coimbra
% **School of Technology and Management - Polytechnic Institute of Leiria
%--------------------------------------------------------------------------

function [M,L] = writeM_isr_trafsim(M,L,tab,traj,car_feat,width,length,margin_w,margin_l,map_res,map_dimx,map_dimy)


% tab -> [time,point,vel,dist]
% car_feat -> [maxvel;accmax;brkmax;delta;cartype]
% Number of layers that will be written
% nlayers=size(tab,2);

for i=1:size(tab,2)
    % Write car on the correct layer
    [M,L]=write_MM(M,L,round2(tab(1,i),0.01),traj(1,tab(2,i)),traj(2,tab(2,i)),traj(5,tab(2,i)),car_feat(5),width,length,margin_w,margin_l,map_res,map_dimx,map_dimy);
end

end

