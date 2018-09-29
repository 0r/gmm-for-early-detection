function [ inPrototype, win_index, typicality ] = cal_dis( point, mean, covariance)
% Calculate the Mahalnobis distance (new data, existing cluster)
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

    c=size(mean,1);
    eta = 3.5; % parameter controlling cluster size, need tuned
    distance=zeros(1,c);
    for i=1:c
        distance(i)=pdist2(point, mean(i,:), 'mahalanobis', covariance(:,:,i));
    end
    [mahal_min, win_index]=min(distance);
    typicality = 1 / (1 + (mahal_min / eta)^2);
    if(mahal_min < eta)
        inPrototype=true;
    else
        inPrototype=false;
    end

end

