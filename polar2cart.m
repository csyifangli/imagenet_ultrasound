function [data_out,z,x] = polar2cart(data_in,acq_params,bf_params)

r = bf_params.r;
theta = bf_params.theta;
apex = [0 0 0];
z = r;
x = acq_params.rx_pos(:,1);

if(length(apex)==1), apex=[0 0 apex];
elseif(length(apex)==2), apex=[apex(1) 0 apex(2)];end
r=single(r);theta=single(theta);

[xnew,znew]=meshgrid(x-apex(1),z-apex(3));

theta_new=single(atan2d(xnew,znew));
r_new=single(sqrt(xnew.^2+znew.^2));

data_out=zeros(length(z),length(x),size(data_in,3),'single');
data_in=single(data_in);

for i=1:size(data_out,3)
    data_out(:,:,i)=interp2_fast(r(1),diff(r(1:2)),theta(1),diff(theta(1:2)),single(data_in(:,:,i)),r_new,theta_new,NaN('single'));
end
data_out(isnan(data_out))=0;