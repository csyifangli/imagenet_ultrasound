function [pts,amp,Tx] = make_phtm(idx)

%loadpath = 'Y:/jc500/DATA/imagenet/images/';
loadpath = '/datacommons/ultrasound/jc500/DATA/imagenet/images/';
loadname = [loadpath sprintf('val_%d.JPEG',idx-1)];
img = single(rgb2gray(imread(loadname))); img = img/255;

%Generate tissue phantom
scatpercell=15;
x_size=40/1000;
y_size=2/1000;
z_size=40/1000;
z_start=30/1000;

%General parameters
Tx.c=1540;                              % Speed of sound [m/s]
Tx.f0=5e6;                              % Center frequency [Hz]
Tx.fs=120e6;                            % Sampling frequency [Hz]
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

%The elev_focus^2 term here represents z^2
N=round(scatpercell*(x_size*z_size*y_size)/...%density*FOV vol/Res vol
    (Tx.lambda.^3*Tx.elev_focus.^2/(Tx.num_elements_x*Tx.pitch_x*Tx.num_elements_y*Tx.pitch_y)));
x=(rand(N,1)-.5)*x_size;
y=(rand(N,1)-.5)*y_size;
z=rand(N,1)*z_size+z_start;
pts=[x y z];
amp=rand(N,1)*2-1;

x_img = linspace(-x_size/2,x_size/2,size(img,2));
z_img = linspace(z_start,z_start+z_size,size(img,1));

[~,ix] = min(abs(pts(:,1)-x_img),[],2);
[~,iz] = min(abs(pts(:,3)-z_img),[],2);
col = gray(256);
for i = 1:length(amp)
    amp(i) = img(iz(i),ix(i));
    C(i,:) = col(img(iz(i),ix(i))*255+1,:);
end

if ispc
    close
    scatter3(pts(:,1),pts(:,2),pts(:,3),2,C,'filled'); axis image
    title(sprintf('n_scatterers = %d',length(amp)))
end

end