function prep_save_val()

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_val.h5';
h5create(filename,'/images',[3 192 512 4])
h5create(filename,'/labels',[192 512 4])

names = {'anechoic','hyperchoic','hypochoic','point'};
for pdx = 1:4
    t = tic;
    load(sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/validate/%s.mat',names{pdx}))

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    [xi,yi] = meshgrid(1:200,1:(ax(2)-ax(1)+1));
    [xq,yq] = meshgrid(linspace(1,200,192),linspace(1,ax(2)-ax(1)+1,512));
    
    env = abs(hilbert(sum(rf_focused(ax(1):ax(2),lat(1):lat(2),:),3)));
    env = env/max(env(:));
    
    env_label(:,:,pdx) = interp2(xi,yi,env,xq,yq);
    a = round(linspace(1,20,5)); a = a(2:end-1);
    for i = 1:3
        rf = rf_focused(ax(1):ax(2),lat(1):lat(2),a(i));
        rf = rf/max(abs(rf(:)));
        rf_sub(:,:,i) = interp2(xi,yi,rf,xq,yq);
    end
    rf_feed(:,:,:,pdx) = rf_sub;

    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx,4,toc(t))
end
h5write(filename,'/images',single(permute(rf_feed,[3 2 1 4])))
h5write(filename,'/labels',single(permute(env_label,[2 1 3])))
clear

end