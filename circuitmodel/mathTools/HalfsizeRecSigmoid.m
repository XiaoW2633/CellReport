function s=HalfsizeRecSigmoid(x,beta,x0)
tmp=(x-x0)>=0;
s =tmp.* 1 ./ (1 + exp(-beta .* (x-x0)));

