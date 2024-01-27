function [mu,d] = circular_mean(alpha)
% Computes the mean direction for circular data
% Modified from circ_mean.m
li=sqrt(-1);
r = sum(exp(li*alpha));
% obtain mean angle by
mu=angle(r);
% obtain mean length by
d=abs(r);

end
