function G = GaussAttention2d(range,mux,muy,sigmaE,sigmaI)
g1=gauss2d(range,range,mux,muy,sigmaE,sigmaE);
g2=gauss2d(range,range,mux,muy,sigmaI,sigmaI);
G=3*g1-g2+1;
%G=1;

end

