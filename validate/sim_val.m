function sim_val(part,na)

addpath(genpath('/datacommons/ultrasound/jc500/GIT/Field_II_Pro/')); field_init(-1);
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Simulation/'))
angles = linspace(-30,30,na);

%% Transducer parameters

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

%% Initialize phantom

%Generate tissue phantom
rng(0)
scatpercell=15;
x_size=40/1000;
y_size=2/1000;
z_size=40/1000;
z_start=40/1000;

%The elev_focus^2 term here represents z^2
N=round(scatpercell*(x_size*z_size*y_size)/...%density*FOV vol/Res vol
    (Tx.lambda.^3*Tx.elev_focus.^2/(Tx.num_elements_x*Tx.pitch_x*Tx.num_elements_y*Tx.pitch_y)));
x=(rand(N,1)-.5)*x_size;
y=(rand(N,1)-.5)*y_size;
z=rand(N,1)*z_size+z_start;
pts=[x y z];
ampi=rand(N,1)*2-1;

cysts=[0 0 60]/1000;
cyst_r=ones(size(cysts,1),1)*1.5/1000;
inside = ((x-cysts(1)).^2+(y-cysts(2)).^2+(z-cysts(3)).^2) < cyst_r.^2;

%% Init field
fprintf('Starting part %d\n',part)

if(~(exist('field_init','file')==2)), error('Must add Field II to path before calling'); end
field_init(-1);

%Set field parameters
set_field('c',Tx.c);
set_field('fs',Tx.fs);

%  Set the attenuation to 5*0.5 dB/cm, 0.5 dB/[MHz cm] around
%  f0 and use this:
set_field ('att',2.5*100);
set_field ('Freq_att',0.5*100/1e6);
set_field ('att_f0',Tx.f0);
set_field ('use_att',0);          %  Set this flag to one when including attenuation

%Generate transmit aperture
emit_aperture = xdc_linear_array(Tx.num_elements_x,Tx.element_width, ...
    Tx.element_height,Tx.kerf_x,Tx.sub_x,Tx.sub_y,...
    [0 0 0]);
xdc_impulse(emit_aperture, Tx.impulse_response);
xdc_excitation(emit_aperture, Tx.excitation);

%Generate receive aperture
receive_aperture = xdc_linear_array(Tx.num_elements_x,Tx.element_width, ...
    Tx.element_height,Tx.kerf_x,Tx.sub_x,Tx.sub_y,...
    [0 0 0]);
xdc_impulse(receive_aperture, Tx.impulse_response);
xdc_focus_times(receive_aperture,0,zeros(1,Tx.num_elements_x));

%Calculate response
aperture=linspace(-(Tx.num_elements_x-1)/2*Tx.pitch_x,(Tx.num_elements_x-1)/2*Tx.pitch_x,Tx.num_elements_x);
delays=aperture*sind(angles(part))/Tx.c;
xdc_focus_times(emit_aperture,0,delays);

%% Add anechoic
amp = ampi;
amp(inside)=[]; pts(inside,:)=[];
[v, t1]=calc_scat_multi(emit_aperture, receive_aperture, pts, amp);

tag='sim_plane';
savepath = '/work/jc500/DATA/imagenet/validate/anechoic/';
if ~exist(savepath,'dir'); mkdir(savepath); end
save(sprintf('%s%s_part%d',savepath,tag,part),'v','t1')
if part == 1; save([savepath 'phtm.mat'],'pts','amp'); end

%% Add hypoechoic
amp = ampi;
contrast_dB = -6; amp(inside)= amp(inside)*10^(contrast_dB/20);

tag='sim_plane';
savepath = '/work/jc500/DATA/imagenet/validate/hypochoic/';
if ~exist(savepath,'dir'); mkdir(savepath); end
save(sprintf('%s%s_part%d',savepath,tag,part),'v','t1')
if part == 1; save([savepath 'phtm.mat'],'pts','amp'); end

%% Add hyperechoic
amp = ampi;
contrast_dB = 6; amp(inside)= amp(inside)*10^(contrast_dB/20);

tag='sim_plane';
savepath = '/work/jc500/DATA/imagenet/validate/hyperchoic/';
if ~exist(savepath,'dir'); mkdir(savepath); end
save(sprintf('%s%s_part%d',savepath,tag,part),'v','t1')
if part == 1; save([savepath 'phtm.mat'],'pts','amp'); end

%% Add point
pts=[0 0 60]/1000;
amp=1;

tag='sim_plane';
savepath = '/work/jc500/DATA/imagenet/validate/point/';
if ~exist(savepath,'dir'); mkdir(savepath); end
save(sprintf('%s%s_part%d',savepath,tag,part),'v','t1')
if part == 1; save([savepath 'phtm.mat'],'pts','amp'); end

%% Free space for aperture
xdc_free (emit_aperture)
xdc_free (receive_aperture)

end