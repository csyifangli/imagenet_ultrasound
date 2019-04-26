function stitch_val(pdx,na)

addpath(genpath('/datacommons/ultrasound/jc500/GIT/Field_II_Pro/')); field_init(-1);
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Simulation/'))
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Beamforming/'))

pad=[0 0];

%General parameters
Tx.c=1540;                              % Speed of sound [m/s]
Tx.f0=5e6;                              % Center frequency [Hz]
Tx.fs=100e6;                            % Sampling frequency [Hz]
Tx.BW=.8;                               % Fractional BW
Tx.lambda=Tx.c/Tx.f0;                   % Wavelength [m]

%Lateral dimension
Tx.num_elements_x=128;                  % Number of elements
Tx.kerf_x=.01/1000;                     % Kerf [m]
Tx.pitch_x=Tx.lambda/2;                 % Element pitch
Tx.element_width=Tx.pitch_x-Tx.kerf_x;  % Element width [m]
Tx.sub_x=1;                             % Number of subelements in x and y
Tx.lat_focus=40e-3;                     % Axial-lateral focus [m]

%Elevation dimension
Tx.num_elements_y=1;
Tx.kerf_y=0;
Tx.pitch_y=5/1000;
Tx.element_height=Tx.pitch_y-Tx.kerf_y; % Element height [m]
Tx.sub_y=Tx.sub_x*round(Tx.element_height/Tx.element_width);
Tx.elev_focus=40/1000;                  % Axial-elevation focus [m]

%Set up impulse response
tc = gauspuls('cutoff',Tx.f0,Tx.BW,-6,-40);
t = -tc:1/Tx.fs:tc;
Tx.impulse_response = gauspuls(t,Tx.f0,Tx.BW);
%Remove the mean to avoid DC artifacts
Tx.impulse_response=Tx.impulse_response-mean(Tx.impulse_response);

%Set up excitation
Tx.excitation=1;
if(~exist('fs','var')), fs=Tx.fs; end

num_lines=na;
angles = linspace(-30,30,na);
tagi='sim_plane';

names = {'anechoic','hyperchoic','hypochoic','point'};
tag = sprintf('/work/jc500/DATA/imagenet/validate/%s/%s',names{pdx},tagi);
[rf,t]=stitch_rf_files(tag,num_lines,Tx,fs);
offset=length(conv(Tx.impulse_response,conv(Tx.impulse_response,Tx.excitation)))/2*fs/Tx.fs;
aperture_x=linspace(-(Tx.num_elements_x-1)/2*Tx.pitch_x,(Tx.num_elements_x-1)/2*Tx.pitch_x,Tx.num_elements_x);
pad1=zeros(pad(1),size(rf,2),size(rf,3),'single');
pad2=zeros(pad(2),size(rf,2),size(rf,3),'single');
rf=cat(1,pad1,rf,pad2);
acq_params.c=Tx.c;
acq_params.fs=fs;
acq_params.t0=t(1)*fs-offset-pad(1);
acq_params.samples=size(rf,1);
acq_params.rx_pos=[aperture_x(:) zeros(length(aperture_x),2)];
acq_params.tx_pos=zeros(length(angles),3);
acq_params.f0=Tx.f0;
acq_params.theta=angles;
acq_params.steer=Tx.lat_focus*[sind(angles(:)) zeros(length(angles),1) cosd(angles(:))];

x_size=40/1000;
y_size=2/1000;
z_size=40/1000;
z_start=40/1000;
bf_params.x = linspace(-x_size/2,x_size/2,200);
bf_params.z = (acq_params.t0+(1:acq_params.samples))/acq_params.fs*acq_params.c/2;
bf_params.tx_channel = 1;
bf_params.channel = 1;

order = 3; wn = [0.6 1.4]*Tx.f0/(Tx.fs/2);
[b,a] = butter(3,wn); bf_params.a = a; bf_params.b = b;
bf=planewave(acq_params,bf_params);
rf_focused=bf.beamform(rf);

savepath = sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/validate/%s.mat',names{pdx});
save(savepath,'rf_focused','acq_params','bf_params')
fprintf('Saved to %s\n',savepath);