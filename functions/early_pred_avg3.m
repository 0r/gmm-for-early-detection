function [ early_pred_avg3_value ] = early_pred_avg3( early_pred, index )
% previous 3 average early_pred value
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

    if(index - 2 < 1)
        early_pred_avg3_value = early_pred(index);
        return;
    end

    early_pred_avg3_value=0;
    for i = index: -1: (index - 2)
        early_pred_avg3_value=early_pred_avg3_value + early_pred(i);
    end
    early_pred_avg3_value = early_pred_avg3_value / 3;
end

