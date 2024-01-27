function angle = crf2tarAngle(P,center)
%% crf2tarAngle: calculate the angle (in degrees) between crf to target  and crf to frf vector. 



crf2tar_vec = P.tarLoc-center; %% crf to target vector;
fix2tar_vec = P.tarLoc-P.fixLoc; %% fixation to target vector;


% angle1 = calulate_angle(crf2tar_vec,fix2tar_vec);
angle = acos(dot(crf2tar_vec,fix2tar_vec)/(norm(crf2tar_vec)*norm(fix2tar_vec)))*180/pi;
%angle  = abs(tmp_angle); 


end