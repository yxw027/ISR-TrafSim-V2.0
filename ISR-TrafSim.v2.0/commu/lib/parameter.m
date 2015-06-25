% clear;

%=======================================
% Global parameters
global s
global Nnodes node;
global Gt Gr freq Lcommu ht hr pathLossExp std_db D0commu;
global cs_threshold;
global white_noise_variance;
global rmodel;
global rv_threshold;
global slot_time CW_min CW_max turnaround_time max_retries;
global packet_id retransmit pending_id;
global mac_queue;
global SIFS DIFS;
global backoff_attmpt;
global size_mac_header;
global default_power;
global cca_time;
global backoff_counter backoff_attempt;
global max_size_mac_body size_mac_header size_rts size_cts size_ack size_plcp;
global basic_rate;
global navcommu;
global ack_tx_time cts_tx_time rts_tx_time;
global default_rate default_ttl;
global size_rreq size_rrep;
global net_queue;
global rreq_timeout net_pending net_max_retries;
global rrep_table;
global bcast_table;
global mac_status;
global adebug bdebug cdebug ddebug edebug fdebug;
global rv_threshold_delta;
global rreq_out rreq_in rreq_forward;
global rreq_out_crosslayer rreq_in_crosslayer rreq_forward_crosslayer;
global rrep_out rrep_in rrep_forward;
global rrep_out_crosslayer rrep_in_crosslayer rrep_forward_crosslayer rrep_destination_crosslayer;
global mobility_model poscommu maxspeedcommu maxpause;
%=======================================

Nnodes=0;

%=======================================
% Debug parameters
% adebug = 1;
% bdebug = 1;
% cdebug = 1;
% ddebug = 1;
%   edebug = 1;
%  fdebug = 1;
%  gdebug = 1;
%=======================================


%=======================================
% MAC and PHY parameters of IEEE 802.11x
% --------------------------------------
% MAC layer packet size
max_size_mac_body = 2312*8;
size_mac_header = (2+2+6+6+6+2+6+4)*8;  % FC+duration+a1+a2+a3+sequence+a4+fcs
size_rts = (2+2+6+6+4)*8;   % FC+duration+ar+at+fcs
size_cts = (2+2+6+4)*8;     % FC+duration+ar+fcs
size_ack = size_cts;
%---------------------------------------
% FHSS PHY: old: may not be correct, not used
% size_plcp_fhss = 96+32; % PLCP preamble + PLCP header
% fhss_turnaround_time = 19*1e-6;
% fhss_slot_time = 50*1e-6;
% fhss_cca_time = 27*1e-6;    % clear channel assessment time?
% fhss_SIFS = 28*1e-6;
% --------------------------------------
% DSSS PHY and HR/DSSS (IEEE 802.11b, 1999, section 15.3.3)
size_plcp_dsss = 144+48;
dsss_turnaround_time = 5*1e-6;
dsss_slot_time = 20*1e-6;
dsss_cca_time = 15*1e-6;
dsss_SIFS = 10*1e-6;
% --------------------------------------
% OFDM 2.4 GHz: IEEE 802.11g (section 19.8.4)
size_plcp_g = 20+4;     % if rate is 1 Mbps
g_RxTxturnaround_time = 5*1e-6;
g_TxRxturnaround_time = 10*1e-6;
g_slot_time = 20*1e-6;   % short is 9 us
g_cca_time = 15*1e-6;   % short is 4 us
g_SIFS = 10*1e-6;
% --------------------------------------
% OFDM 5 GHz: IEEE 802.11a (section 17.5.2)
size_plcp_g = 20+4;     % if rate is 1 Mbps
a_RxTxturnaround_time = 2*1e-6;
a_slot_time = 9*1e-6;
a_cca_time = 4*1e-6;   % short is 4 us
a_SIFS = 16*1e-6;
a_CW_min = 4;           % 16=2^4-1
%===========================================
% IEEE 802.11x (b/g/a) 
if(s.commu_norm=='b')
    size_plcp = size_plcp_dsss;
    turnaround_time = dsss_turnaround_time;
    slot_time = dsss_slot_time;
    cca_time = dsss_cca_time;
    SIFS = dsss_SIFS;
    DIFS = SIFS + 2*slot_time;
    freq=2.4e9;
elseif(s.commu_norm=='g')
    size_plcp = size_plcp_g;
    turnaround_time = g_RxTxturnaround_time;
   % g_TxRxturnaround_time = 10*1e-6;
    slot_time = g_slot_time;
    cca_time = g_cca_time;
    SIFS = g_SIFS;
    DIFS = SIFS + 2*slot_time;
    freq=2.4e9;
elseif(s.commu_norm=='a')
    size_plcp = size_plcp_g;
    turnaround_time = a_RxTxturnaround_time;
    slot_time = a_slot_time;
    cca_time = a_cca_time;
    SIFS = a_SIFS;
    DIFS = SIFS + 2*slot_time;
    freq=5e9;
end

%=======================================
% Radio propagation parameters
if(s.radiopropagmodel==1)
    rmodel='friis';
elseif(s.radiopropagmodel==2)
    rmodel='tworay';
elseif(s.radiopropagmodel==3)   
    rmodel = 'shadowing';
end
default_power = s.default_power;
Gt=1;
Gr=1;
Lcommu=1;
ht=1;
hr=1;
pathLossExp=2;
std_db=0.1; % variance used in shadowing (approximately: 10^(std_db/10) = 2%)
D0commu=1;       % reference distance used in shadowing
% Find N0
% Note: for all three radio propagation models, they are almost the same
% when Dcommu is not too large or the log-normal fading is not large.
% when Gt=Gr=Lcommu=ht=hr=1 and freq=2.4 GHz, Pr=Pt*(lambdacommu/4/pi/Dcommu)^2
% so when Dcommu=D0commu=1, Pr=Pt*1e-6/Dcommu^2
% so we choose background noise N0=Pt*1e10 in order to achieve SNR=40 dB
% so we should choose rv_threshold be somewhere below 40 dB
lambdacommu = 3e8 / freq;
Dcommu=D0commu;
switch rmodel
    case 'friis'
        Pr = friis(default_power, Gt, Gr, lambdacommu, Lcommu, Dcommu);
    case 'tworay'
        [Pr, crossover_dist] = tworay(default_power, Gt, Gr, lambdacommu, Lcommu, ht, hr, Dcommu);
    case 'shadowing'
        Pr = log_normal_shadowing(default_power, Gt, Gr, lambdacommu, Lcommu, pathLossExp, std_db, D0commu, Dcommu);
end
% white_noise_variance is used as N0 when calculating SNR
white_noise_variance = Pr / 1e6;    % SNR will be upper-bounded by 60 dB when Dcommu >= D0commu
max_SNR=db(Pr/white_noise_variance, 'power');
% receive threshold is used to determine if a reception with SNR is above
% this threshold so that the packet can be correctly received.
rv_threshold = s.snr_threshold;      % db
rv_threshold_delta = 0.1;   % around rv_threshold possible packet loss
% carrier sense threthold is used to check if the channel is free to be taken for transmission
% we use Pr(when Dcommu=D0commu)+N0 so if there is a transmitter in distance D0commu or multiple transmitter in longer distance,
% the channel will be regarded as busy.
cs_threshold=Pr+white_noise_variance;   % 0.1
%=======================================


%=======================================
% MAC and PHY parameters
%---------------------------------------


basic_rate = 1e6;
ack_tx_time = (size_ack + size_plcp) / basic_rate;
cts_tx_time = (size_cts + size_plcp) / basic_rate;
rts_tx_time = (size_rts + size_plcp) / basic_rate;
% we use IEEE 802.11 MAC and IEEE802.11 DSSS PHY parameters
% size_plcp = size_plcp_dsss;
% turnaround_time = dsss_turnaround_time;
% slot_time = dsss_slot_time;
% cca_time = dsss_cca_time;
% SIFS = dsss_SIFS;
% DIFS = SIFS + 2*slot_time;
% basic_rate = 1e6;
% ack_tx_time = (size_ack + size_plcp) / basic_rate;
% cts_tx_time = (size_cts + size_plcp) / basic_rate;
% rts_tx_time = (size_rts + size_plcp) / basic_rate;
%---------------------------------------
% other MAC and PHY parameters
default_rate = 5e6;         % question: how much fixed rate should we choose?
CW_min = 5;                 % 31 = 2^5-1
CW_max = 10;                % 1023 = 2^10-1
%backoff_counter = zeros(Nnodes, 1);
%backoff_attempt = zeros(Nnodes, 1);
%packet_id = zeros(Nnodes, 1);    % id for next MAC or NET packet
%pending_id = zeros(Nnodes, 1);   % id of current transmitting MAC packet, used for timeout
max_retries = s.max_retries;      % for RTS
%retransmit = zeros(Nnodes, 1);   % retransmit times for a pending mac packet, <= max_retries
navcommu = []; 
% for i=1:Nnodes, 
%     navcommu(i).start=0; 
%     navcommu(i).end=0; 
% end
mac_queue = []; 
% for i=1:Nnodes,
%     mac_queue(i).list=[]; 
% end
mac_status = []; 
% for i=1:Nnodes, 
%     mac_status(i)=0; 
% end
%=======================================


%=======================================
% NET parameters
default_ttl = 7;
rreq_timeout = 0.2;   % question
size_rreq = 22*8;
size_rrep = 22*8;
net_max_retries = 3;
net_pending = []; 
% for i=1:Nnodes, 
%     net_pending(i).id=[]; 
%     net_pending(i).retransmit=[]; 
% end
net_queue = []; 
% for i=1:Nnodes, 
%     net_queue(i).list=[]; 
% end
rrep_table = []; 
% for i=1:Nnodes, 
%     rrep_table(i).list=[]; 
% end
% record of sent RREP
%bcast_table = zeros(Nnodes, Nnodes);              % record of broadcast id
bcast_table=[];
%rreq_out = zeros(Nnodes, 1);
%rreq_in = zeros(Nnodes, 1);
%rreq_forward = zeros(Nnodes, 1);
%rreq_out_crosslayer = zeros(Nnodes, 1);
%rreq_in_crosslayer = zeros(Nnodes, 1);
%rreq_forward_crosslayer = zeros(Nnodes, 1);
%rep_out = zeros(Nnodes, 1);
%rrep_in = zeros(Nnodes, 1);
%rrep_forward = zeros(Nnodes, 1);
%rrep_out_crosslayer = zeros(Nnodes, 1);
%rrep_in_crosslayer = zeros(Nnodes, 1);
%rrep_forward_crosslayer = zeros(Nnodes, 1);
%rrep_destination_crosslayer = zeros(Nnodes, 1);
%=======================================


%=======================================
% Mobility parameters
mobility_model = 'none'; % or 'random_waypoint'
poscommu=[];
%poscommu = zeros(Nnodes, 6);
maxspeedcommu = 0;
maxpause = 0;
%=======================================
