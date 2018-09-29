function [ new_label ] = change_label( index, new_label, label, win_index )
% label = change_label(anormaly_old, i, label, win_index);
% @author: Wenlong Wu
% @date: 08/29/2018
% @email: ww6p9@mail.missouri.edu
% @University of Missouri-Columbia

    N = size(label, 2);
    for i = 1:N
        if(label(i) == 0)
            index = index - 1;
        end
        if(index == 0)
            new_label(i) = win_index;
            return;
        end
    end

end

