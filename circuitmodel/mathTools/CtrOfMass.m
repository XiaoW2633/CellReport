function centeOfMass=CtrOfMass(activity,fieldsize,h)
x=1:fieldsize;
y=1:fieldsize;
act=max(activity+h,0);
[xx,yy]=meshgrid(x,y);
M=sum(act(:));
x_mean=xx.*act;
y_mean=yy.*act;
x_mean=sum(x_mean(:))/M;
y_mean=sum(y_mean(:))/M;
centeOfMass=[y_mean,x_mean];


end