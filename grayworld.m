function D=grayworld(imgIN)
% that equal energy produces equal responses in the sensors.
    ratio = [1,1,1];
    % Find the average of each sensor color channel.
for ii = 1:size(imgIN,3),  avg(ii) = mean2(imgIN(:,:,ii)); end

%D = diag([avg(2)/avg(1)*ratio(1), ratio(2), avg(2)/avg(3)*ratio(3)]);
D=[avg(2)/avg(1)*ratio(1), ratio(2), avg(2)/avg(3)*ratio(3)];
return;

end
