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
%-DESCRIPTION--------------------------------------------------------------
%
% Manage the structure that contains the data for each vehicle
%
%-USE----------------------------------------------------------------------
%
% -> Input(s)
%   � 'arg'   -   Option
%       'init'  -   Initialization of the structure
%       'addc'  -   Add vehicle to the structure
%       'delc'  -   Delete vehicle from the structure
%   � n       - ID of vehicle deleted from the structure
%
% -> Output(s)
%   � Updated structure
%
%-DISCLAIMER---------------------------------------------------------------
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

function [out] = isr_tfs_datacar_isr_trafsim(arg,n)
global c
if(strcmp(arg,'init'))
    out=init();
elseif(strcmp(arg,'addc'))
    %curid=c.lastid+1;
    curid=100; flag=0;
    while(flag==0)
        if(isempty(find(c.listactive==curid, 1)))
            flag=1;
        else
            curid=curid+1;
        end
    end
    c.lastid=curid;
    curcar=car_init(curid);
    c.listactive=[c.listactive curid];
    c.car=[c.car curcar];
    c.car(length(c.listactive)).id=curid;
    out=length(c.listactive);
elseif(strcmp(arg,'delc') )
    pos=find(c.listactive==n);
    %id=c.car(pos).id;
    c.car(pos)=[];
    c.listactive(pos)=[];
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializes all the variables necessary for the simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = init()

out=struct...
    (...
    'car',[],...
    'lastid',1,...          % Last id launch
    'listactive',[] ...     % List of active cars
    );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializes all the variables necessary for the car
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = car_init(cur)

out=struct...
    (...
    'id',cur,...                % ID of car
    'type',0,...                % 1-Car 2-Truck
    'auto',0,...                % 1 if car is a autonomous vehicle
    'inRound',0,...               % 1 - If the car is inside the Roundabout
    'inCross',1,...               % 1 - If the car is inside the CrossRoad
    'road',0,...                % Current road
    'roadprev',0,...            % Previous road
    'roadori',0,...             % Road of origin
    'roaddes',0,...             % Road of destination
    'path',0,...                % Path that the car will follow
    'prevsetp',0,...            % Previous destination setpoint
    'setp',0,...                % Current destination setpoint
    'time',0,...                % Time of car in simulation
    'traj',0,...                % Trajectory setpoints                      (point)[x;y;road;dist;ang]
    'trajn',0,...               % Number of trajectory setpoints
    'cause',0,...               % ID of car that cause the stop
    'cmdacc',0,...              % Acelarator comand [-1 1]
    'cmdste',0,...              % Steer comand [-1 1]
    'steerval',0,...            % Steer value [Rad]
    'dyn',[0 0],...             % Current dynamic [LinearVel AngularVel]
    'prvdyn',[0 0],...          % Previous dynamic
    'timeinsim',0,...           % Time in simulator
    'pwf',0,...                 % Pulses emited by encoder of front wheel
    'pwr',0,...                 % Pulses emited by encoder of rear wheel
    'Pwf',0,...                 % Total of pulses emited by encoder of front wheel
    'Pwr',0,...                 % Total of pulses emited by encoder of rear wheel
    ... % Car properties
    'commu',0,...                     % 1 if car can have communications
    'mag_rule',[],...               % 1 if car can detect magnets
    'width',0,...                   % Width of car
    'length',0,...                  % Length of car
    'mass',0,...                    % Mass [kg]
    'r_dyn',0,...                   % Wheel radius [m]
    'c_d',0,...                     % Aerodynamic Drag Coefficient
    'c_r',0,...                     % Rolling Resistance Coefficient
    'A',0,...                       % Frontal Area [m^2]
    'Wsbw',0,...                    % Space between wheels
    'NStWteeth',0,...               % Steering teeth's
    'NWteeth',0,...                 %
    'WheelD',0,...                  % Wheel diameter
    'WheelR',0,...                  % Wheel radius
    'WRadii_RR',0,...               % Rear right wheel
    'WRadii_RL',0,...               % Rear left wheel
    'WRadii_FR',0,...               % Front right wheel
    'WRadii_FL',0,...               % Front left wheel
    'max_stering_lock2lock',0,...
    ...     % Driver
    'dri',driver(),...          % Driver information
    'dri_ignore_trf_round',0,...% Driver ignore traffic rules when inside of roundabout
    'dri_ignore_trf_cross',0,...% Driver ignore traffic rules when inside of roundabout
    ...     % Car position
    'pos',pos(),...             % Current position
    'posprv',pos(),...          % Previous position
    'cornX',0,...               % Corners X positions
    'cornY',0,...               % Corners Y positions
    ...     % Dynamic Proprieties
    'dynmaxacc',[0 0],...       % [maxVelAcc/s maxVelBrk/s]
    'dynmaxste',[0 0],...       % [MaxSteer x�Rad/s x�Rad]
    ...     % Security distance to the front car
    'time2stop',0,...           % Treshold on collision time
    'dist2stop',0,...           % Minimum distance to stop
    'dist2light',0,...          % distance to trafic light
    'rand1',rand(1),...         % rand(1)
    ...     % Handlers
    'hcar',-1,...               % Handler to the car
    'hinfo',-1,...              % Handler to info (plot with the car)
    'hgpspos',-1,...            % Handler to GPS ghost
    'hinspos',-1,...            % Handler to INS ghost
    'hodopos',-1,...            % Handler to Odometry ghost
    'hfuspos',-1,...            % Handler to ghost given by Kalman filter
    'hfus2pos',-1,...           % Handler to ghost given by Kalman filter
    'hfus3pos',-1,...           % Handler to ghost given by Kalman filter
    'hfus4pos',-1,...           % Handler to ghost given by Kalman filter
    'hsetp',-1,...              % Handler to plot the current setpoint
    'hsidelight',-1,...         % Handler to the light of changing direction
    'hcarsec',-1,...            % Handler to security vectors
    'hcarsecl',-1,...            % Handler to security vectors (lateral)
    ...     % Localization methods
    'gps',zeros(3,2)*NaN,...              % To store GPS positions (1-3 receivers)       EX: [x1 y1 ; x2 y2; x3 y3]
    'ins',zeros(1,3)*NaN,...              % (x,y,t) position given by INS
    'mag',zeros(1,2)*NaN,...              % (x,y) position given by Magnets
    'fus',zeros(1,3)*NaN,...              % (x,y,t) position given by Sensorial Fusion
    'odo',zeros(1,3)*NaN,...              % (x,y) position given by Odometry
    'fus2',zeros(1,3)*NaN,...             % (x,y,t) position given by Sensorial fusion
    'fus3',zeros(1,3)*NaN,...             % (x,y,t) position given by Sensorial fusion
    'fus4',zeros(1,3)*NaN,...             % (x,y,t) position given by Sensorial fusion
    'fus4prev',zeros(1,3)*NaN,...         % (x,y,t) position given by Sensorial fusion
    ...     % Data (Position errors and other stuff)
    'data',[],...
    ...     % GPS/RTK-GPS
    'gps_type',NaN,...      % Type of gps used
    'gps_native',NaN,...    % Current gps used
    'gps_rtk',NaN,...       % 1 if car can have RTK-GPS
    'gps_time',0,...        % Time of gps information received
    'gps_time_prev',0,...   % Previous time of gps information received
    'gps_time_count',0,...  % Number of times that gps uses  the same information provide by roundabout
    'gps_f1',NaN,...        % Frequency of native GPS system
    'gps_f2',NaN,...        % Frequency of RTK-GPS system
    'gps_nrec',NaN,...      % Number of receivers
    'gps_data',[],...       % GPS position over the time
    'gps_usrxyz',[],...     % To store receivers position in XYZ referencial
    'gps_sat_pos',[],...    % To store satelites position
    'gps_sat_num',[],...    % To store satelites ID number
    ...     % Fusion 1 (INS + GPS)
    'ins_count',0,...
    'fusion_init',0,...
    'X_pre',0,...
    'X_est',0,...
    'K',0,...
    'P_pre_KF',0,...
    'P_est_KF',0,...
    'G',0,...
    'W',0,...
    'R',0,...
    'gps_update',0,...
    ...     % Fusion 2 (Laser + GPS)
    'Pk_las',diag([1e0 1e0 1e-1]),...
    'fus2_pos',[],...
    'fus2_las_xpos',[],...
    'fus2_las_ypos',[],...
    'fus2_las_tpos',[],...
    'fus2_las_ipos',[],...
    'fus2_mag_xpos',[],...
    'fus2_mag_ypos',[],...
    'fus2_mag_tpos',[],...
    'fus2_mag_ipos',[],...
    ...     % Fusion 3 (GPS + INS + KF)
    'fus3_init',0,...
    'fus3_init_KF',0,...
    'init_vel_e_err',0,...
    'init_vel_n_err',0,...
    'init_x_tilt',0,...
    'init_y_tilt',0,...
    'init_z_mis',0,...
    'dvparam',0,...
    'dthparam',0,...
    ...         -> Preallocate arrays for speed
    'f3_deltheta',[],...
    'f3_dvtot',[],...
    'est_lat',[],...
    'est_lon',[],...
    'est_alpha',[],...
    'est_height',[],...
    'est_roll',[],...
    'est_pitch',[],...
    'est_yaw',[],...
    'height1',[],...
    'height2',[],...
    'vx1',[],...
    'vx2',[],...
    'vy1',[],...
    'vy2',[],...
    'vel_L',[],...
    'vel2',[],...
    'vel1',[],...
    'lat1',[],...
    'lat2',[],...
    'DCMnb',[],...
    'est_DCMbn',[],...
    'tmp',[],...
    'est_DCMel',[],...
    'omega2_el_L',[],...
    'omega1_el_L',[],...
    'deltav_b',[],...
    'deltheta',[],...
    'est_roll_',[],...
    'est_pitch_',[],...
    'est_yaw_',[],...
    'est_alpha_',[],...
    'est_height_',[],...
    'est_height1_',[],...
    'est_height2_',[],...
    'height1_',[],...
    'height2_',[],...
    'est_lat_',[],...
    'est_lon_',[],...
    'vx1_',[],...
    'vy1_',[],...
    'vx2_',[],...
    'vy2_',[],...
    'vel_l_',[],...
    'vel1_',[],...
    'vel2_',[],...
    'lat2_',[],...
    'lat1_',[],...
    'est_DCMbn_',[],...
    'est_DCMel_',[],...
    'omega2_el_L_',[],...
    'omega1_el_L_',[],...
    'H',[],...
    'P_pre',[],...
    'est_lat_KF',[],...
    'est_lon_KF',[],...
    'est_height_KF',[],...
    'est_alpha_KF',[],...
    'est_vel_l_KF',[],...
    'est_roll_KF',[],...
    'est_pitch_KF',[],...
    'est_yaw_KF',[],...
    'omega_ie_E_',[],...
    'accum_accel_bias',[],...
    'accum_gyro_bias',[],...
    ...         -> To plot (fusion 3)
    'state_est',zeros(18,1),...
    'x_rms_KF',0,...
    'y_rms_KF',0,...
    'z_rms_KF',0,...
    'x_v_rms_KF',0,...
    'y_v_rms_KF',0,...
    'z_v_rms_KF',0,...
    'x_psi_rms_KF',0,...
    'y_psi_rms_KF',0,...
    'z_psi_rms_KF',0,...
    'x_accel_rms_KF',0,...
    'y_accel_rms_KF',0,...
    'z_accel_rms_KF',0,...
    'x_gyro_rms_KF',0,...
    'y_gyro_rms_KF',0,...
    'z_gyro_rms_KF',0,...
    'accum_accel_x',0,...
    'accum_accel_y',0,...
    'accum_accel_z',0,...
    'accum_gyro_x',0,...
    'accum_gyro_y',0,...
    'accum_gyro_z',0,...
    ...     % INOV-CT (fusion4)
    ...         -> Slip details
    'slip_state',-1,...         % -1 no slip, 1 detect, 0 already slip
    'slip_state_list',[],...    % List of oil places already listed
    'slip_state_type',[],...    % List of type of slip (1-RL;2-RR;3-FL;4-FR;5-RL/RR;6-FL;FR)
    'init_odoKF',1,...          %
    'init_ekf',1,...            %
    'mag_detect',NaN,...        % Magnet detected
    'mag_field',NaN,...         % Magnetic field detected on z component
    'det_mag_fus4',0,...        % Magnet detected in fus4
    ...         -> Noise variance
    'variance_WRadii_RR_noise',0,...
    'variance_WRadii_RL_noise',0,...
    'variance_WRadii_FR_noise',0,...
    'variance_WRadii_FL_noise',0,...
    'variance_RR_enc_noise',0,...
    'variance_RL_enc_noise',0,...
    'variance_FR_enc_noise',0,...
    'variance_FL_enc_noise',0,...
    'L_noise_variance',0,...
    'W_noise_variance',0,...
    'variance_phiF_noise',0,...
    'variance_phiFL_enc_noise',0,...
    'variance_phiFR_enc_noise',0,...
    'mag_xpos_variance',0,...
    'mag_ypos_variance',0,...
    'mag_dist_variance',0,...
    'mag_angle_variance',0,...
    'Q_odo',0,...
    'Pk_odo',0,...
    'Pk_INOV',0,...
    'Pk_CT',0,...
    'R1_odo',0,...
    'R2_odo',0,...
    'R3_odo',0,...
    'R4_odo',0,...
    'R5_odo',0,...
    'R_mag',0,...
    'Q_mag',0,...
    'Pk_mag',0,...
    'Pk_mag_aux',0,...
    'T_mag',0,...
    'ekf_odo_threshold',0,...
    'ekf_mag_threshold',0,...
    'CT_threshold',0,...
    'ramdom_walk_variance',0,...
    'deltaS_odoKF',0,...
    'deltaW_odoKF',0,...
    'deltaS_odoKF_INOV',0,...
    'deltaW_odoKF_INOV',0,...
    'deltaS_odoKF_CT',0,...
    'deltaW_odoKF_CT',0,...
    'xPos_odoNOISE',0,...
    'yPos_odoNOISE',0,...
    'theta_odoNOISE',0,...
    'xPos_ct',0,...
    'yPos_ct',0,...
    'theta_ct',0,...
    'xPos_odoKF',0,...
    'yPos_odoKF',0,...
    'theta_odoKF',0,...
    'xPos_MAG',0,...
    'yPos_MAG',0,...
    'theta_MAG',0,...
    ...'xPos_MAG_aux1',0,...
    ...'yPos_MAG_aux1',0,...
    ...'xPos_MAG_aux2',0,...
    ...'yPos_MAG_aux2',0,...
    ...'xPos_MAG_aux3',0,...
    ...'yPos_MAG_aux3',0,...
    'xPos_MAG_aux4',[],...
    'yPos_MAG_aux4',[],...
    'timePos_MAG_aux4',[],...
    'xPos_odoKF_CT',[],...
    'yPos_odoKF_CT',[],...
    'theta_odoKF_CT',[],...
    ...     -> Noise vectors
    'WRadii_RR_noise',[],...
    'WRadii_RL_noise',[],...
    'WRadii_FR_noise',[],...
    'WRadii_FL_noise',[],...
    'RR_enc_noise',[],...
    'RL_enc_noise',[],...
    'FR_enc_noise',[],...
    'FL_enc_noise',[],...
    'L_noise',[],...
    'W_noise',[],...
    'phiF_noise',[],...
    'phiFL_enc_noise',[],...
    'phiFR_enc_noise',[],...
    'ramdom_walk',[],...
    'mag_xpos_noise',[],...
    'mag_ypos_noise',[],...
    'mag_dist_noise',[],...
    'mag_angle_noise',[],...
    ...     -> Noise vectors state
    'nv_setp',1,...
    'nv_time',0,...
    ...     % INS data
    'dins',datains(),...            % To save ins data
    'pdins',datains(),...           % To save previous ins data
    ...     % Laser distances
    'laserdist',0,...               % Distances returned by the laser
    ...     % Errors
    'traj_err',[],...                   1 - Lateral error of mass center
    ...                                 2 - Angular error of mass center (between car orientation and the tangent to the curve)
    ...                                 3 - Lateral error of point seen ahead
    ...                                 4 - Angular error of point seen ahead (between car orientation and the tangent to the curve)]
    'mag_error',[NaN NaN],...             % Last error in permanent magnets localization method
    ...     % Occupation Map
    'list',[],...                   % List of cars in the neighborhood (driver's vision)
    'commulistcar',[],...           % List of cars in the neighborhood (communication)
    ...     % velocity profile data
    'vel_prof',[],...               % Velocity profile defined by the management system of the roundabout  ([time;traj_point;vel])
    'vp',1,...                      % Current stage of velocity profile that car is follow
    'vpn',1,...                     % Number of stages of profile velocity
    'vel_prof2',[],...               % Velocity profile defined by the management system of the crossroads  ([time;traj_point;vel])
    'vp2',1,...                      % Current stage of velocity profile (cross) that car is follow
    'vpn2',1,...                     % Number of stages of profile velocity (cross)
    ...     % Traffic gestion data
    'rar',[],...                    % Road after roundabout
    'rac',[],...                    % Road after cross
    'rbc',[],...                    % Road before cross
    'lightdirection',[],...         % Direction light turned on in the cross
    'crosscels',[],...              % Cross cels intercepted by the trajectory
    'nostop',[],...                 % Stops ignored
    ...     % OTA communication
    'commu_gps_info',-1,...          % 1 if car receives GPS information
    'commu_vel_prof',-1,...          % 1 if car receives velocity profile from roundabout
    'commu_vel_prof2',-1,...         % 1 if car receives velocity profile from crossroads
    ...     % Data to plot estimation errors
    'deltaS_Real',[],...
    'deltaW_Real',[],...
    'deltaS_Noise',[],...
    'deltaW_Noise',[],...
    'deltaS_KF_CT',[],...
    'deltaW_KF_CT',[],...
    ...%'deltaS_KF',[],...
    ...%'deltaW_KF',[],...
    ...%'deltaS_KF_INOV',[],...
    ...%'deltaW_KF_INOV',[],...
    'posReal',[],...            % Real position
    'posNoise',[],...           % Position with error
    'posCt',[],...              % Position estimated with KF (CT)
    'posMag',[],...
    'TRUEpos',[],...
    ...     % Auxiliary variables (used occasionally and for debug)
    'aux2',0,...
    'aux',[] ...
    );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% datains() - Information of INS (and fusion)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = datains()

out=struct...
    (...
    'est_roll',0,...
    'est_pitch',0,...
    'est_yaw',0,...
    'est_lat',0,...
    'est_lon',0,...
    'est_height',0,...
    'est_alpha',0,...
    'del_Vl',0,...
    'omega_el_L',0,...
    'omega_ie_L',0,...
    'est_DCMbn',0,...
    'est_DCMel',0,...
    'g_extr',0,...
    'est_laterr',0,...
    'est_longerr',0,...
    'lat_prof',0,...
    'lon_prof',0,...
    'height_prof',0,...
    'vel_l',zeros(2,3) ...
    );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% driver() - Information of driver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = driver()

out=struct...
    (...
    'type',NaN,...      % Type of driver
    'color',[0 0 0],... % Color of car
    'velmax',NaN,...    % Maximum speed
    'velcur',NaN ...    % Current speed
    );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wpos() - Position in the simulator (x,y,t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = pos()

out=struct...
    (...
    'x',NaN,...
    'y',NaN,...
    't',NaN ...
    );

end
