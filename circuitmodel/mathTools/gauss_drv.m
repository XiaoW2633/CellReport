function g = gauss_drv(range_x,mu,sigma)
% gauss_drv : first-order derivative of gaussian function.
g1 = gauss(range_x,mu,sigma);
g2 = exp(-0.5 * (range_x-mu).^2 / sigma^2);
g=-(range_x-mu).*gauss(range_x,mu,sigma)/sigma^2;

end
