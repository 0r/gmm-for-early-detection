function [ model, anormaly ] = sp1ms( stream, model, anormaly )
% Streaing Sequential Possibilistic One-Means to update the prototype
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

mean = model.mean;
cov_max = model.cov_max;
c_num = model.c_num;
point_num = model.point_num;
label = model.label;

means = plot(mean(:,1), mean(:,2),'.r', 'MarkerSize', 25); hold on; title('Early prediction in weather data');
xlim([min(stream(:,1))-1,max(stream(:,1))+1]);ylim([min(stream(:,2))-1,max(stream(:,2))+1]);
cov_plot = plot_gaussian_ellipsoid([mean(:,1), mean(:,2)],cov_max*9);
early_pred=zeros(1, size(stream,1)); % max typicality
early_pred_avg = early_pred; % average max typicality
trend=zeros(1, size(stream,1)); % trend of stream data, cos value

for i=1:size(stream,1)
    figure(1);
    [inPrototype, win_index, typicality] = cal_dis(stream(i,:), mean, cov_max); % 1 for normal; 0 for outliers
    if(inPrototype == true) 
        % early prediction of health changes
        [early_pred, early_change, priority, trend] = early_check(stream, early_pred, i, typicality, mean(win_index,:), trend);
        early_pred_avg(i) = early_pred_avg3(early_pred, i);
        
        if(early_change == true && trend(i) < 0)
            switch priority 
                case 1 % weak warning
                    plot(stream(i,1),stream(i,2),'db','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                case 2 % medium warning
                    plot(stream(i,1),stream(i,2),'dm','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','m','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                case 3 % strong warning
                    plot(stream(i,1),stream(i,2),'dr','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                otherwise % no warning
                    plot(stream(i,1),stream(i,2),'.b');hold on;drawnow;
            end  
        else
            plot(stream(i,1),stream(i,2),'.b');hold on;drawnow; % normal pattern, no warning
        end
        
        % update the winnning mean and covariance
        point_num(win_index) = point_num(win_index) + 1;
        cov_max(:,:,win_index) = ((point_num(win_index)-1) * cov_max(:,:,win_index) + transpose(stream(i,:) - mean(win_index,:)) * (stream(i,:) - mean(win_index,:))) / point_num(win_index);
        mean(win_index,:) = mean(win_index,:) + (stream(i,:) - mean(win_index,:))/ point_num(win_index);
        delete(means);
        means = plot(mean(:,1), mean(:,2),'.r', 'MarkerSize', 25); hold on; 
        delete(cov_plot);
        cov_plot = plot_gaussian_ellipsoid([mean(win_index,1), mean(win_index,2)],cov_max(:,:,win_index)*9);
        set(cov_plot,'color','k');
        label = [label, win_index];
        
        % check if anormaly becomes normal 
        [anormaly, mean, cov_max, point_num, label] = check_anormaly(anormaly, mean, cov_max, point_num, label);
        
    else % not in the model, maybe outliers
        early_pred(i) = typicality;
        early_pred_avg(i) = early_pred_avg3(early_pred, i);
        pre_points = stream(i:-1:i-4,:); % window = 5
        vec1s = stream(i,:) - pre_points;
        vec1 = sum(vec1s) /5;
        vec2 = mean(win_index,:) - stream(i,:) ;
        cos_alpha = vec1 * vec2' / (norm(vec1) * norm(vec2)); % [-1, 1]
        trend(i) = cos_alpha;
        
        % check anomaly history to see if new cluster produced 
        [mean, cov_max, c_num, point_num, newFound, anormaly, label, cov_plot] = check_newcluster(anormaly,stream(i,:) ,mean, cov_max, c_num, point_num, label, cov_plot);
        % set this as outliers
        if(newFound == false)
            anormaly = [anormaly;stream(i,:)];
            plot(stream(i,1),stream(i,2),'xr');hold on;drawnow;
            label = [label, 0];
        else
            plot(stream(i,1),stream(i,2),'xb');hold on;drawnow;
            label = [label, c_num];
        end
    end
    
end

model.mean=mean;
model.cov_max=cov_max;
model.c_num=c_num;
model.point_num=point_num;
model.label=label;

end