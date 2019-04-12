function sim_img(idx,na)

addpath(genpath('/datacommons/ultrasound/jc500/GIT/Field_II_Pro/')); field_init(-1);
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Simulation/'))

angles = linspace(-30,30,na);
part = 1:na;
pdx = 1:100;
[part,pdx] = meshgrid(part,pdx);
part = part(idx); pdx = pdx(idx);

[pts,amp,Tx] = make_phtm(pdx);

fprintf('Starting part %d\n',part)

if(~(exist('field_init','file')==2)), error('Must add Field II to path before calling'); end
field_init(-1);

tag='sim_plane';

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
[v, t1]=calc_scat_multi(emit_aperture, receive_aperture, pts, amp);

savepath = sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/phtm%03d/',pdx-1);
if ~exist(savepath,'dir'); mkdir(savepath); end
save(sprintf('%s%s_part%d',savepath,tag,part),'v','t1')

%Free space for aperture
xdc_free (emit_aperture)
xdc_free (receive_aperture)

end