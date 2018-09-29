function [ model, anormaly] = sp1m( data )
% Use current data to find prototype (mean and covariance)
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

%% some hyper-parameters
N =size(data, 1); % number of data
C=100; % cluster number, input a very big number first
fzr=1.5; % fuzzifier
epsilon=0.01; % epsilon threshold
eta=ones(1,C)*3.5; % parameter controlling cluster size, need tuned
Uall=[]; % membership matrix collection
Vall=[]; % cluster matrix collection
cov_max=[]; % covariance maxtrixs
point_num=[]; % each cluster points number
label=zeros(1,N);
U_count=zeros(1,C);
stop_count=0;
stop_code=0; % symbol to stop searching for new clusters
seed=2018; % random seed number

%% Keep searching for clusters until all clusters are found
for iter=1:C
    %-------------------------loop 2---------------------------------------
    while(1)
    % propabilities to choose cluster center
    seed=seed+1;
    selected_v = random_select(data, iter, Uall, seed);
    v(iter, :) = selected_v;

    %% ---------------------------loop 1 < P1M >------------------
    while(1)
        % compute d
        for m=1:N
            d(iter,m)=pdist2(data(m,:),v(iter,:))^2;
        end

        % compute u(v,X)
        for m=1:N
           u(iter,m)=1/(1+(d(iter,m)/eta(iter))^(1/(fzr-1)));
        end

        % compute v(u,X) / for 2 dimensions
        v_up=zeros(1,2);
        v_down=0;
        for m=1:N
            v_up(1,:)=v_up(1,:)+u(iter,m)^fzr*data(m,:);
            v_down=v_down+u(iter,m)^fzr;
        end
        v_new(iter,:)=v_up(1,:)/v_down;
        v_diff=pdist2(v(iter,:), v_new(iter,:))^2;
        v(iter,:)=v_new(iter,:);

        % if cluster center doesn`t move, break the while
        if v_diff<epsilon^2
            break;
        end
    end
    
    %% ----------------------------loop 1 < P1M > end-------------------

    % termination calculation
    stop_count=stop_count+1;
    for m=1:N
        if iter>1 && max(Uall(:,m))>0.5
            U_count(iter)=U_count(iter)+1;
        end
    end
    
    % if no more clusters found, terminate the program
    if stop_count>N*0.8-U_count(iter)
        stop_code=1;
        break;
    end
    
    % remove the coincident cluster center
    vw=zeros(1,iter-1);
    if iter>1
        for j=1:iter-1
           vw(j)=pdist2(v(iter,:),Vall(j,:))^2;
        end
        vw_min=min(vw);
        if vw_min>(sum(eta(1:iter))/iter)^2  % threshold
            break;
        end
    else
        break;
    end
    
    U_count(iter)=0;
    end
    %-----------------------------loop 2 end-------------------------------
    if stop_code == 1
        stop_code=0;
        break;
    end
    Uall=[Uall;u(iter,:)];
    Vall=[Vall;v(iter,:)];
    points=[];
    stop_count=0;
    for s=1:N
        if(u(iter,s)>0.05)
            points=[points;data(s,:)];
            label(s)=iter;
        end
    end
    point_num=[point_num,size(points,1)];
    cov_tmp=cov(points);
    cov_max=cat(3,cov_max,cov_tmp);
end

mean=Vall;
c_num=size(mean,1);

anormaly=[];
for i=1:N
     u_max=max(Uall(:,i));
     if(u_max<0.1)
         anormaly=[anormaly;data(i,:)];
     end
end
% plot outliers
if(size(anormaly) > 0)
    figure(1);plot(anormaly(:,1), anormaly(:,2),'.r', 'MarkerSize', 10); hold on;
end

model.mean=mean;
model.cov_max=cov_max;
model.c_num=c_num;
model.point_num=point_num;
model.label=label;

end

