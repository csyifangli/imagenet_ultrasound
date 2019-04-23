function prep_save()

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_all.h5';
h5create(filename,'/train_images',[520 200 3 79])
h5create(filename,'/train_labels',[520 200 79])
for pdx = [0:9 11:79]
    count = count+1;
    t = tic;
    loadpath = sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/phtm%03d/',pdx);
    load([loadpath 'data.mat'])

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    rf_label(:,:,count) = sum(rf_focused(ax(1):10:ax(2),lat(1):lat(2),:),3);
    a = round(linspace(1,50,5)); a = a(2:end-1);
    rf_feed(:,:,:,count) = rf_focused(ax(1):10:ax(2),lat(1):lat(2),a);

    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,100,toc(t))
end
h5write(filename,'/train_images',rf_feed)
h5write(filename,'/train_labels',rf_label)
clear

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_all.h5';
h5create(filename,'/validation_images',[520 200 3 10])
h5create(filename,'/validation_labels',[520 200 10])
for pdx = 80:89
    count = count+1;
    t = tic;
    loadpath = sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/phtm%03d/',pdx);
    load([loadpath 'data.mat'])

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    rf_label(:,:,count) = sum(rf_focused(ax(1):10:ax(2),lat(1):lat(2),:),3);
    a = round(linspace(1,50,5)); a = a(2:end-1);
    rf_feed(:,:,:,count) = rf_focused(ax(1):10:ax(2),lat(1):lat(2),a);

    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,100,toc(t))
end
h5write(filename,'/validation_images',rf_feed)
h5write(filename,'/validation_labels',rf_label)
clear

count = 0;
filename = '/datacommons/ultrasound/jc500/DATA/imagenet/training/data_all.h5';
h5create(filename,'/test_images',[520 200 3 9])
h5create(filename,'/test_labels',[520 200 9])
for pdx = [90:94 96:99]
    count = count+1;
    t = tic;
    loadpath = sprintf('/datacommons/ultrasound/jc500/DATA/imagenet/field/phtm%03d/',pdx);
    load([loadpath 'data.mat'])

    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    rf_label(:,:,count) = sum(rf_focused(ax(1):10:ax(2),lat(1):lat(2),:),3);
    a = round(linspace(1,50,5)); a = a(2:end-1);
    rf_feed(:,:,:,count) = rf_focused(ax(1):10:ax(2),lat(1):lat(2),a);

    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,100,toc(t))
end
h5write(filename,'/test_images',rf_feed)
h5write(filename,'/test_labels',rf_label)
clear
end