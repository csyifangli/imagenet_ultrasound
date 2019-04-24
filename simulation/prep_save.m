function prep_save()

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_all.h5';
h5create(filename,'/train_images',[3 192 512 490])
h5create(filename,'/train_labels',[192 512 490])
for pdx = 0:489
    count = count+1;
    t = tic;
    load(sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/stitched/phtm%03d_data.mat',pdx))

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    [xi,yi] = meshgrid(1:200,1:520);
    [xq,yq] = meshgrid(linspace(1,200,192),linspace(1,520,512));
    
    rf_label(:,:,count) = interp2(xi,yi,sum(rf_focused(ax(1):10:ax(2),lat(1):lat(2),:),3),xq,yq);
    a = round(linspace(1,20,5)); a = a(2:end-1);
    for i = 1:3
        ax
        lat
        size(rf_focused)
        rf_sub(:,:,i) = interp2(xi,yi,rf_focused(ax(1):10:ax(2),lat(1):lat(2),a(i)),xq,yq);
    end
    rf_feed(:,:,:,count) = rf_sub;
    if pdx == 0; disp(size(rf_sub)); end
    
    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,500,toc(t))
end
h5write(filename,'/train_images',permute(rf_feed,[3 2 1 4]))
h5write(filename,'/train_labels',permute(rf_label,[2 1 3]))
clear

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_all.h5';
h5create(filename,'/validation_images',[3 192 512 10])
h5create(filename,'/validation_labels',[192 512 10])
for pdx = 490:499
    count = count+1;
    t = tic;
    load(sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/stitched/phtm%03d_data.mat',pdx))

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    [xi,yi] = meshgrid(1:200,1:520);
    [xq,yq] = meshgrid(linspace(1,200,192),linspace(1,520,512));
    
    rf_label(:,:,count) = interp2(xi,yi,sum(rf_focused(ax(1):10:ax(2),lat(1):lat(2),:),3),xq,yq);
    a = round(linspace(1,20,5)); a = a(2:end-1);
    for i = 1:3
        rf_sub(:,:,i) = interp2(xi,yi,rf_focused(ax(1):10:ax(2),lat(1):lat(2),a(i)),xq,yq);
    end
    rf_feed(:,:,:,count) = rf_sub;

    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,500,toc(t))
end
h5write(filename,'/validation_images',permute(rf_feed,[3 2 1 4]))
h5write(filename,'/validation_labels',permute(rf_label,[2 1 3]))
clear
end