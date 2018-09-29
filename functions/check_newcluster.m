function [ mean, covaraince, c_num, point_num, newFound, anormaly, new_label, cov_plot] = check_newcluster( anormaly_old, point, mean, covaraince, c_num, point_num, label, cov_plot)
% Check anormaly history to see if new cluster is produced
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

    M = 10; % the min value for a cluster to be formed
    newFound = false; % symbol of if new cluster is formed
    eta = 3.5; % parameter controlling cluster size, need tuned

    while(1)
        count = 1;
        new_sum = zeros(1,2);
        new_mean = zeros(1,2);
        new_cluster = [];
        for i = 1:size(anormaly_old,1)
            dist = pdist2(point, anormaly_old(i,:));
            if(dist < eta )
                new_sum = new_sum+anormaly_old(i,:);
                new_cluster = [new_cluster; anormaly_old(i,:)];
                count = count + 1;
            end
        end
        new_mean = new_sum / ( count - 1);
        if(pdist2(point, new_mean) < 0.01 || sum(new_sum) == 0)
            break;
        end
        point = new_mean;
    end

    anormaly = anormaly_old;
    new_label = label;

    if(count > M)
        newFound = true;
        cov_new = cov(new_cluster);
        mean = [mean;new_mean];
        covaraince = cat(3,covaraince,cov_new);
        c_num = c_num + 1;
        point_num = [point_num,count];
        figure(1);plot(new_cluster(:,1),new_cluster(:,2),'xb');hold on;drawnow;
        cov_plot = plot_gaussian_ellipsoid([new_mean(1), new_mean(2)],cov_new*9);
        set(cov_plot,'color','k');
        anormaly = [];
        for i = 1:size(anormaly_old,1)
            if(pdist2(new_mean, anormaly_old(i,:)) > eta * 2 )
                anormaly = [anormaly; anormaly_old(i,:)];
            else
                new_label = change_label(i, new_label, label, c_num);
                plot(anormaly_old(i,1),anormaly_old(i,2),'xb');hold on;drawnow;
            end
        end
    end

end
