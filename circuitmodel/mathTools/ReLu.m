function s=ReLu(x,beta,x0)
if x0 < 0 
    s=0;
else
    s=beta*min(max(x,0),x0);
end