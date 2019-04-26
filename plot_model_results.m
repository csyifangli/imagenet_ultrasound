%%
clear
clc
data_results = h5read('model_results.h5','/predictions'); data_results = permute(data_results,[2 1 3]);
data_1 = h5read('data_all.h5','/train_labels'); data_2 = h5read('data_all.h5','/validation_labels');
data_init = cat(3,data_1,data_2); data_init = permute(data_init,[2 1 3]);
%%
close
for i = 1:80
    
    subplot(8,10,i)
    test = data_results(:,:,i);
    env = abs(hilbert(test));
    envdb = db(env/max(env(:)));
    imagesc(envdb); colormap gray; axis square
    
end

%%
clear
clc
data_results = h5read('model_results.h5','/predictions'); data_results = permute(data_results,[2 1 3]);
data_1 = h5read('data_all.h5','/train_images'); data_2 = h5read('data_all.h5','/validation_images');
data_init = cat(4,data_1,data_2); data_init = permute(data_init,[3 2 1 4]);
data_init = squeeze(sum(data_init,3)); clear data_1 data_2

data_1 = h5read('data_all.h5','/train_labels'); data_2 = h5read('data_all.h5','/validation_labels');
data_label = cat(3,data_1,data_2); data_label = permute(data_label,[2 1 3]); clear data_1 data_2

%%
for i = 1:500
    load(sprintf('Y:/jc500/DATA/imagenet/field/stitched/phtm%03d_data.mat',i-1),'img');
    data_img(:,:,i) = img;
end
%%

tsize = 14;
clims = [-40 0];

for i = 500
    
    close
    figure('pos',[-1900 500 1500 400],'color','w')
    ha = tight_subplot(1,4,0.02,0.05,0.1);
    
    rf = data_init(:,:,i); env = abs(hilbert(rf));
    envdb = db(env/max(env(:)));
    axes(ha(1)); imagesc(envdb,clims); colormap gray; axis square; axis off;
    title('PW_{na = 3}','fontsize',tsize)
    
    env = data_results(:,:,i);
    envdb = db(env/max(env(:)));
    axes(ha(2)); imagesc(envdb,clims); colormap gray; axis square; axis off;
    title('PW_{na = 3} + U-Net','fontsize',tsize)
    
    env = data_label(:,:,i);
    envdb = db(env/max(env(:)));
    axes(ha(3)); imagesc(envdb,clims); colormap gray; axis square; axis off;
    title('PW_{na = 20}','fontsize',tsize)
    
    axes(ha(4));  imagesc(data_img(:,:,i)); colormap gray; axis square; axis off;
    title('Truth','fontsize',tsize)
    
    saveas(gcf,sprintf('Y:/jc500/DATA/imagenet/results/img_%03d.png',i-1))
end
