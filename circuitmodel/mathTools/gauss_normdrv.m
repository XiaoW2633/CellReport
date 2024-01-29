function g = gauss_normdrv(range_x,mu,sigma)
g=-(range_x-mu).*gauss(range_x,mu,sigma)/sigma^2;
if any(g)
  g = g / sum(abs(g));
end