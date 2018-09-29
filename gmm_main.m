% Sequential Possibilistic One-Means Clustering 
% For streaming clustering to detect outliers and trajectory trends
% In Gaussian Mixture Model 
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

close all;
clear;clc;

% import data
addpath(genpath(pwd));
all_data = importdata('weather_1h.dat'); N = size(all_data,1); piece=5;
% use 1/5 of data to find prototype, use the rest as streaming data
data = all_data(1:round(N / piece),:);
stream = all_data(round(N / piece)+1:N,:);

%% Use current data to find prototype
figure(1);plot(data(:,1),data(:,2),'.b');hold on
[model, anormaly] = sp1m(data);

%% Use streaming data to update prototype
 [model, anormaly] = sp1ms(stream, model, anormaly);