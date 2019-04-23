%% Plot
for pdx = 0:99
    clearvars -except pdx
    t = tic;
    loadpath = sprintf('Y:/jc500/DATA/imagenet/field/phtm%03d/',pdx);
    load([loadpath 'data.mat'])
    load([loadpath 'phtm.mat'])
    %fprintf('Loaded in %1.2f seconds.\n',toc(t))
    %f = msgbox(sprintf('Loaded in %1.2f seconds.\n',toc(t)));
    
    scatpercell=15;
    x_size=40/1000;
    y_size=2/1000;
    z_size=40/1000;
    z_start=40/1000;
    
    [~,lat] = min(abs(bf_params.x-[-x_size/2; x_size/2]),[],2);
    [~,ax] = min(abs(bf_params.z-[z_start; z_start+z_size]),[],2);
    x = bf_params.x(lat(1):lat(2)); z = bf_params.z(ax(1):ax(2));
    
    rf_sum = sum(rf_focused(ax(1):ax(2),lat(1):lat(2),:),3);
    env = abs(hilbert(rf_sum));
    envdb = db(env/max(env(:)));
    
    x_img = linspace(-x_size/2,x_size/2,size(img,2));
    z_img = linspace(z_start,z_start+z_size,size(img,1));
    [~,ix] = min(abs(pts(:,1)-x_img),[],2);
    [~,iz] = min(abs(pts(:,3)-z_img),[],2);
    col = gray(256);
    for i = 1:length(amp)
        C(i,:) = col(img(iz(i),ix(i))*255+1,:);
    end
    
    close
    figure('pos',[-1900 50 1600 900])
    
    subplot(231)
    imagesc(img); colormap gray; axis image; axis off
    title('JPEG')
    
    subplot(232)
    
    scatter(pts(:,1),pts(:,3),3,C,'filled'); axis image; axis off; axis ij
    title('Scatterers')
    
    subplot(233)
    imagesc(x,z,envdb,[-40 -5]); colormap gray; axis image; axis off
    title('NA = 50')
    
    for i = 1:3
        subplot(2,3,i+3)
        a = [1 4 7; 1 24 47; 12 26 33]; r = a(i,:);
        
        rf_sub = sum(rf_focused(ax(1):ax(2),lat(1):lat(2),r),3);
        env_sub = abs(hilbert(rf_sub));
        envdb_sub = db(env_sub/max(env_sub(:)));
        imagesc(x,z,envdb_sub,[-40 -5]); colormap gray; axis image; axis off
        title(sprintf('NA = 3, (%d,%d,%d)',r(1),r(2),r(3)))
    end
    
    saveas(gcf,[loadpath 'comp_img.png'])
    fprintf('Loaded and saved %d of %d in %1.2f seconds.\n',pdx+1,100,toc(t))
    
end