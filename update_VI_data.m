function update_VI = update_VI_data(diff_f,linear_vi,process_vi)
%this function is designed to update the VIs based on end condition
%the input variable will be the difference of fitting effect (diff_f), the
%VI curve after linear interpolation (linear_vi), and VI data after sg
%filter and max selection process(process_vi)
[line, column] = size(diff_f);
update_VI = linear_vi;
for i = 1:line
    for j = 1: column
        %if diff_f less than 0, replace the VI data by processed result,
        %else, keep as the linear interpolation result
        if diff_f(i,j)>0
            update_VI(i,j,:) = max(linear_vi(i,j,:),process_vi(i,j,:));
        end
    end
end
update_VI = update_VI;
end