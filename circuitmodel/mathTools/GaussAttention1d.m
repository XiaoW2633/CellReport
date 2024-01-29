function G = GaussAttention1d(range,mux,sigmaE,sigmaI)
g1=gauss(range,mux,sigmaE);
g2=gauss(range,mux,sigmaI);
G=5*g1-g2;

end

