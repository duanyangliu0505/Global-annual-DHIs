function doy_str = doy_num_2_str(doy_num)
%This function will convert the doy from number to string
if doy_num < 10
    doy_str = strcat('00',string(doy_num));
else
    if doy_num < 100
        doy_str = strcat('0',string(doy_num));
    else
        doy_str = string(doy_num);
    end
end
doy_str = doy_str;
end