%% read in and save data

hinfo = h5info('model_results.h5');
data = h5read('model_results.h5','/predictions'); data = permute(data,[2 1 3]);
save('model_results.mat','data')