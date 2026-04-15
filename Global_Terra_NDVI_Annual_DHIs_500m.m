%This code is designed to calculate the annual DHIs over global scale 
%The input data are over twenty four year MODIS Terra EVI data (2000.2-2023)
%All the twenty four years data will be used to conduct the data process,
%including linear interpolation, median selection, and sg filter.
%After data process, annual DHIs will be calculate in each year
clc
clear
%obtain the global tiles name
tile_names = importdata('global_tiles.xlsx');
tile_names = cell2mat(tile_names);
[tile_m, tile_n] = size(tile_znames)
%% load the MODIS Terra EVI data over global scale
main_path = 'Z:\Duanyang\VIIRS V2\VNP13A1A2\MOD13A1_';
land_cover_main = 'Z:\Duanyang\VIIRS V2\VNP13A1A2\MCD12Q1\';
for tile_num = 1:1:292
    tile_name = (tile_names(tile_num,:))
    count_full_years = 0;
    full_year_vi = [];
    %import the land cover data
    land_cover_key = strcat(land_cover_main,'*',tile_name,'*.hdf');
    land_cover_info = dir(land_cover_key);
    if isempty(land_cover_info)
        land_cover_data = ones(2400,2400);
    else
        land_cover_path = strcat(land_cover_main,land_cover_info.name);
        land_cover_data = hdfread(land_cover_path,'LC_Type1');
    end
    %% Because of the limitation of memory and CPU, i will calculate each tile (2400*2400) by 200 crows
    crow_num = 1;
    update_VI_data_col = [];
    scale_cum_data = [];
    scale_min_data = [];
    scale_var_data = [];
    for cum = 1:1
        cum_str = crow_num(cum); %start of crow number
        cum_end = cum_str + 2399;
        count_full_years = 0;
        full_year_vi = [];
        % for 2001, we only need the second half year data
            for doy_num = 177:16:353  %time resolution 16 days
                count_full_years = count_full_years + 1;
                doy_str = doy_num_2_str(doy_num);
                file_key = strcat('MOD13A1.A2000',doy_str,'*',tile_name,'*.hdf');
                path_key = strcat(main_path,'2000\',file_key);
                file_dir = dir(path_key);
                if ~isempty(file_dir)
                    file_path = strcat(main_path,'2000\',file_dir.name)
                    %read the MODIS Terra EVI and QA data
                    vi_data = hdfread(file_path,'500m 16 days NDVI');
                    vi_data = vi_data(cum_str:cum_end,:); 
                    qa_data = hdfread(file_path,'500m 16 days VI Quality');
                    qa_data = qa_data(cum_str:cum_end,:);
                    %convert the QA data to binary, with consistent length 16, and mask
                    %the snow and cloud values
                    qa_data_binary = dec2bin(qa_data,16);
                    pro_vi_data = double(vi_data);
                    pro_vi_data(pro_vi_data<0) = 0;
                    %for snow/ice covered data, set as 0
                    snow_index = qa_data_binary(:,2);
                    snow_index = double(snow_index) - double('0');
                    snow_index = reshape(snow_index,2400,2400);
                    pro_vi_data(snow_index == 1) = 0;
                    %for cloud covered data, set as NaN
                    cloud_index = qa_data_binary(:,15);
                    cloud_index = double(cloud_index) - double('0');
                    %cloud_index = qa_data_binary(:,15:16);
                    %cloud_index = double(cloud_index) - double('01');
                    %cloud_index = sum(abs(cloud_index),2);
                    cloud_index = reshape(cloud_index,2400,2400);
                    pro_vi_data(cloud_index == 1) = NaN;
                    full_year_vi(:,:,count_full_years) = pro_vi_data;
                else
                    pro_vi_data = zeros(2400,2400)*NaN;
                    full_year_vi(:,:,count_full_years) = pro_vi_data;
                end
            end
            % load the complete year data (2001-2023)
            for year = 2001:2022
                year_str = string(year);
                 for doy_num = 1:16:353
                      count_full_years = count_full_years + 1;
                      doy_str = doy_num_2_str(doy_num);
                      file_key = strcat('MOD13A1.A',year_str,doy_str,'*',tile_name,'*.hdf');
                      path_key = strcat(main_path,year_str,'\',file_key);
                      file_dir = dir(path_key);
                      if ~isempty(file_dir)
                          file_path = strcat(main_path,year_str,'\',file_dir.name)
                          %load the MODIS Terra EVI and QA data
                          vi_data = hdfread(file_path,'500m 16 days NDVI');
                          vi_data = vi_data(cum_str:cum_end,:);
                          qa_data = hdfread(file_path,'500m 16 days VI Quality');
                          qa_data = qa_data(cum_str:cum_end,:);
                          %convert the qa data to binary, with consistent length 16
                          qa_data_binary = dec2bin(qa_data,16);
                          pro_vi_data = double(vi_data);
                          %for snow/ice covered data, set as 0
                          snow_index = qa_data_binary(:,2);
                          snow_index = double(snow_index) - double('0');
                          snow_index = reshape(snow_index,2400,2400);
                          pro_vi_data(snow_index == 1) = 0;
                          %for cloud covered data, set as NaN
                          cloud_index = qa_data_binary(:,15);
                          cloud_index = double(cloud_index) - double('0');
                          cloud_index = reshape(cloud_index,2400,2400);
                          pro_vi_data(cloud_index == 1) = NaN;
                          full_year_vi(:,:,count_full_years) = pro_vi_data;
                      else
                          pro_vi_data = zeros(2400,2400)*NaN;
                          full_year_vi(:,:,count_full_years) = pro_vi_data; 
                      end
                 end
            end
            % for 2023, we only need the first half year data
            for doy_num = 1:16:161  %time resolution 16 days
                count_full_years = count_full_years + 1;
                doy_str = doy_num_2_str(doy_num);
                file_key = strcat('MOD13A1.A2023',doy_str,'*',tile_name,'*.hdf');
                path_key = strcat(main_path,'2023\',file_key);
                file_dir = dir(path_key);
                if ~isempty(file_dir)
                    file_path = strcat(main_path,'2023\',file_dir.name)
                    %read the MODIS Terra EVI and QA data
                    vi_data = hdfread(file_path,'500m 16 days NDVI');
                    vi_data = vi_data(cum_str:cum_end,:); 
                    qa_data = hdfread(file_path,'500m 16 days VI Quality');
                    qa_data = qa_data(cum_str:cum_end,:);
                    %convert the QA data to binary, with consistent length 16, and mask
                    %the snow and cloud values
                    qa_data_binary = dec2bin(qa_data,16);
                    pro_vi_data = double(vi_data);
                    pro_vi_data(pro_vi_data<0) = 0;
                    %for snow/ice covered data, set as 0
                    snow_index = qa_data_binary(:,2);
                    snow_index = double(snow_index) - double('0');
                    snow_index = reshape(snow_index,2400,2400);
                    pro_vi_data(snow_index == 1) = 0;
                    %for cloud covered data, set as NaN
                    cloud_index = qa_data_binary(:,15);
                    cloud_index = double(cloud_index) - double('0');
                    %cloud_index = qa_data_binary(:,15:16);
                    %cloud_index = double(cloud_index) - double('01');
                    %cloud_index = sum(abs(cloud_index),2);
                    cloud_index = reshape(cloud_index,2400,2400);
                    pro_vi_data(cloud_index == 1) = NaN;
                    full_year_vi(:,:,count_full_years) = pro_vi_data;
                else
                    pro_vi_data = zeros(2400,2400)*NaN;
                    full_year_vi(:,:,count_full_years) = pro_vi_data;
                end
            end
%% conduct the data process,
%  step1: fill gap using linear interpolation
%  step2: fit long-term change trend by SG filter
%  step3: calculate the new time-series data and weight
%  step4: conduct the iteration process, which including median selectiong
%         and SG smoothing filters
%  step5: calculate the fitting effect index and update the new time-series
%         vegetation indice data
%  step6: compare the fitting effect index and continue

%  step1: fill gap using linear interpolation
%  step1: fill gap using linear interpolation
Ag = reshape(full_year_vi, [], 529);
Ag = Ag./10000;
clear full_year_vi
% fill gap using linear interpolation
Ag_interp = fillmissing(Ag, 'linear', 2); 

%step2: fit long-term change trend by SG filter (with small order and large window size)
Ag_sg_trend = sgolayfilt(Ag_interp, 4, 11, [], 2);
clear Ag

%  step3: calculate the new time-series data (max) and weight
max_liner_sg_trend = max(Ag_interp, Ag_sg_trend);
diff_linear_trend = Ag_interp - Ag_sg_trend;
clear Ag_sg_trend
abs_diff_linear_trend = abs(diff_linear_trend);
clear diff_linear_trend
max_abs_diff_linear_trend =max(abs_diff_linear_trend, [], 2);
clear abs_diff_linear_trend
clear max_abs_diff_linear_trend

F_default = ones(2400,2400);
F_default = F_default.*100;
F_default = reshape(F_default, [], 1);
%% the 1st iteration
medfilt_data = medfilt2(max_liner_sg_trend, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data
diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_1.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data = Ag_interp;
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
%update_VI_data_1 = update_VI_data;
clear rows_to_update
F_default = f_value;

%% the 2nd iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_2.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 3rd iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_3.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 4th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_4.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;
%% the 5th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_5.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 6th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_6.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 7th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2);
save('f_value_7.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 8th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_8.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 9th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_9.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

%% the 10th iteration
clear max_matrix
clear medfilt_data
clear sg_smooth
medfilt_data = medfilt2(update_VI_data, [1, 5]);
sg_smooth = sgolayfilt(medfilt_data, 6, 9, [], 2);
clear medfilt_data

diff = Ag_interp - sg_smooth;
abs_diff = abs(diff);
max_abs_diff = max(abs_diff, [], 2);

%calculate new weight
weights_new = 1 - abs_diff./max_abs_diff;
clear max_abs_diff

weights_new(diff > 0) = 1;
f_data = abs_diff.*weights_new;
clear weights_new
clear diff
f_value = sum(f_data, 2); 
save('f_value_10.mat','f_value')
% calculate the difference of f_value
diff_f_value = F_default - f_value;
clear F_default
clear f_data
%find the pixel with posivit difference F value (need to update)
rows_to_update = find(diff_f_value > 0);
clear diff_f_value
max_matrix = max(sg_smooth,Ag_interp);
update_VI_data(rows_to_update, :) = max_matrix(rows_to_update, :);
clear rows_to_update
clear sg_smooth

F_default = f_value;

update_VI_data = reshape(update_VI_data,2400,2400,529);
%save(out_name,'update_VIs_all')
 %% calculate DHIs
 % select one year to calculate the annual DHIs
      for year_num = 1:22
         year_star = (year_num-1)*23+13;
         year_end = year_num*23+12;
         year_vi = update_VI_data(:,:,year_star:year_end);
         cum_data = sum(year_vi,3);
         min_data = min(year_vi,[],3);
         mean_data = mean(year_vi,3);
         std_data = std(year_vi,0,3);
         var_data = std_data./mean_data;
         %scale DHIs3
         scale_cum_data(cum_str:cum_end,1:2400,year_num) = cum_data./(23)*100;
         scale_min_data(cum_str:cum_end,1:2400,year_num) = min_data.*100;
         scale_var_data(cum_str:cum_end,1:2400,year_num) = var_data; 

      end
    end
     %mask the DHIs and export to tif files
     for year_num = 1:22
         %mask the water body by MCD12Q1.061 product (Land Cover Type1,2018)
         land_cover_main = 'Z:\Duanyang\VIIRS V2\VNP13A1A2\MCD12Q1\';
         land_cover_key = strcat(land_cover_main,'*',tile_name,'*.hdf');
         land_cover_info = dir(land_cover_key);
        if isempty(land_cover_info)
            land_cover_data = ones(2400,2400);
        else
            land_cover_path = strcat(land_cover_main,land_cover_info.name);
            land_cover_data = hdfread(land_cover_path,'LC_Type1');
        end 
        %mask the water body
        scale_cum_data_year = scale_cum_data(:,:,year_num);
        scale_min_data_year = scale_min_data(:,:,year_num);
        scale_var_data_year = scale_var_data(:,:,year_num);

        scale_cum_data_year(land_cover_data==17) =NaN;
        scale_min_data_year(land_cover_data==17) =NaN;
        scale_var_data_year(land_cover_data==17) =NaN;
    
        scale_cum_data_year(scale_cum_data_year <0 ) = 0;
        scale_min_data_year(scale_min_data_year <0 ) = 0;
        scale_var_data_year(scale_var_data_year <0 ) = 0;
    
        scale_cum_data_year(scale_cum_data_year >100 ) = NaN;
        scale_min_data_year(scale_min_data_year >100 ) = NaN;
        scale_var_data_year(scale_var_data_year >100 ) = NaN;
        %save the DHIs reuslts
        tiff_main_path = 'Z:\Duanyang\VIIRS V2\VNP13A1A2\2015\tiff_2015\';
        tiff_key = strcat(tiff_main_path,'*2015193.',tile_name,'*.tif');
        tiff_info = dir(tiff_key);
        tiff_file_path = strcat(tiff_main_path,tiff_info.name);
        [evi_data, R] = geotiffread(tiff_file_path);
        info = geotiffinfo(tiff_file_path);
        out_main = ['Z:\Duanyang\annual_DHIs\Terra_NDVI\output\tiles\'];
        year_str = num2str(year_num + 2000);
        cum_name = strcat(out_main,'new_',year_str,'_','Cum_',tile_name,'_MODIS_C61_Terra_NDVI.tif');
        min_name = strcat(out_main,'new_',year_str,'_','Min_',tile_name,'_MODIS_C61_Terra_NDVI.tif');
        var_name = strcat(out_main,'new_',year_str,'_','Var_',tile_name,'_MODIS_C61_Terra_NDVI.tif');
        geotiffwrite(cum_name,scale_cum_data_year,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        geotiffwrite(min_name,scale_min_data_year,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        geotiffwrite(var_name,scale_var_data_year,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
     end

end

