

function [fwd,cvg]  =  discom(tmp_rfvec,para)
% decomposite shift vector to forward remapping and convergent remapping
% direction.





tmpFwd = [tmp_rfvec(para.CRF2FRF),tmp_rfvec(para.CRF2FRF+1)]; % forward vector
tmpCvg = [tmp_rfvec(para.SACAMP)+tmp_rfvec(para.CRF2FP ),tmp_rfvec(para.CRF2FP +1)]; % convergent vector
% normlize the vector as unit vector  (|fwd|^2+|cvg|^2 = 1)
tmpFwd = tmpFwd/norm(tmpFwd);
tmpCvg = tmpCvg/norm(tmpCvg);
tmpDirec = [tmpFwd',tmpCvg']; % b
% pRF vector;
shiftVec = [tmp_rfvec(para.CRF2PRF),tmp_rfvec(para.CRF2PRF+1)]; %A
% A = tmpDirec,b=shiftVec', solve Ax=b, x = A\b, x are the two components
dec = tmpDirec\shiftVec';
fwd = dec(1);
cvg = dec(2);







%%%%

end




% a1 = [3,3];
% a2 = [3,-3];
% x  = [0,1];
% A = [a1',a2'];
% y = A\x';
