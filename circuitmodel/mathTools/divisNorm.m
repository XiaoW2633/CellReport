function  s = divisNorm(x,k)
x_abs=(x+abs(x))/2;
norm_term=k.*sum(sum(x_abs.^2));
s=x_abs.^2/(1+norm_term);
end