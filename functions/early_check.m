function [ early_pred, early_change, priority, trend ] = early_check(stream, early_pred, index, typicality, win_mean, trend)
% Early check for outliers in streaming data
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

    lowPriority = 3; % weak warning window
    mediumPriority = 5; % medium warning window
    highPriority = 7; % strong warning window
    starter = highPriority; % starter window
    early_pred(index) = typicality;
    priority = 0;
    window = 5;
    epsilon = 0.002; % a small threshold
    
    % at the beginning window, no warning
    if (index <= starter + 1)
        early_change = false;
        return;
    end

    %% trend of streaming data
    cur_point = stream(index,:);

    vec1s = zeros(window,2);
    for i=1:window
        vec1s(i,:) = stream(index+1-i,:) - stream(index-i,:);
    end
    vec1 = sum(vec1s,1) / window;
    
    vec2 = win_mean - cur_point;
    cos_alpha = vec1 * vec2' / (norm(vec1) * norm(vec2)); % [-1, 1], trend of current point
    trend(index) = cos_alpha;

    % if it has trend to go outside, plot it
    if(cos_alpha < 0)
        quiver(stream(index,1),stream(index,2),vec1(1)/(norm(vec1))/5 ,vec1(2)/(norm(vec1))/5,'LineWidth',1, 'MaxHeadSize',3, 'Color','k');
    end

    %% max typicality check
    % weak warning
    for i = index: -1: (index - lowPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = false;
            return;
        end
    end

    % medium warning
    for i = index: -1: (index - mediumPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = true;
            priority = 1;
            return;
        end
    end
    
    % strong warning
    for i = index: -1: (index - highPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = true;
            priority = 2;
            return;
        end
    end

    early_change = true;
    priority = 3;
end

