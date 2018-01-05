function VMEcombine()
%% INPUT DATA
TRIAL = 1;
TIME = 2;
MOUSE_X = 3;
MOUSE_Y = 4;
CURSOR_X = 5;
CURSOR_Y = 6;
TARGET_X = 7;
TARGET_Y = 8;
TYPE = 9;
ANGLE = 10;
DISTANCE = 11;
ROTATION = 12;

% ADDED VALUES
CURSOR_ANGLE = 13;


%% Compute Function
datadir = 'data/';
list_of_csv = dir('data/*.csv');
output_data = [];
% plotfig = figure('name',list_of_csv(condition_num).name(1:end-4));
plotfig = figure;

for condition_num = 1:length(list_of_csv)
    
    plot_data =[];
    
    condition_data = dlmread(sprintf('%s%s',datadir,list_of_csv(condition_num).name),',',1,0);  
    load(sprintf('%s%s%s',datadir,list_of_csv(condition_num).name(1:end-4),'.mat'));
    
    for trial_number = 1:max(condition_data(:,TRIAL))
        
        idx = find(condition_data(:,TRIAL) == trial_number);
        trial_data = condition_data(idx,:);

        % Scale the Data According to Screen Size
        trial_data(:,[MOUSE_X MOUSE_Y CURSOR_X CURSOR_Y TARGET_X TARGET_Y]) = trial_data(:,[MOUSE_X MOUSE_Y CURSOR_X CURSOR_Y TARGET_X TARGET_Y]) / cfg.scale * 100;
        
        % SettingCursor/Mouse End X Y
        cursor_end_x = trial_data(end,CURSOR_X);
        cursor_end_y = trial_data(end,CURSOR_Y);
        mouse_end_x = trial_data(end,MOUSE_X);
        mouse_end_y = trial_data(end,MOUSE_Y);
        trial_data(:,TIME) = trial_data(:,TIME) * 1000; % Converting time to milliseconds
        
        % Rotate Cursor X Y 
%         theta = trial_data(1,ANGLE)
%         targ_rotx=trial_data(:,TARGET_X).*cosd(-theta)-trial_data(:,TARGET_Y).*sind(-theta);
%         targ_roty=trial_data(:,TARGET_X).*sind(-theta)+trial_data(:,TARGET_Y).*cosd(-theta);
%         targ_rotx
%         targ_roty

        theta = trial_data(1,ANGLE);% + trial_data(1,ROTATION);
        rotx=trial_data(:,CURSOR_X).*cosd(-theta)-trial_data(:,CURSOR_Y).*sind(-theta);
        roty=trial_data(:,CURSOR_X).*sind(-theta)+trial_data(:,CURSOR_Y).*cosd(-theta);

        % Path Length
        xdiff= diff(trial_data(:,CURSOR_X));
        ydiff= diff(trial_data(:,CURSOR_Y));
        dist= (xdiff.^2) + (ydiff.^2);
        dist= sqrt(dist);%difference in distance
        path_length=sum(dist);%sum of the path length of each trial
    
        % Max Deviation (Angles)
        trial_data(:,CURSOR_ANGLE) = atan2(trial_data(:,CURSOR_Y),trial_data(:,CURSOR_X)) * 180 / pi;
        trial_data(trial_data(:,CURSOR_Y)<0,CURSOR_ANGLE) = trial_data(trial_data(:,CURSOR_Y)<0,CURSOR_ANGLE) + 360;
        
%         max_dev_idx = max(abs(trial_data(:,CURSOR_ANGLE)));
%         max_dev_angle = find(abs(trial_data(:,CURSOR_ANGLE) == max_dev_idx));
%         max_dev_angle = trial_data(max_dev_angle,CURSOR_ANGLE);
%         max_dev_angle = mean(max_dev_angle) - trial_data(1,ANGLE);
        
%         if (trial_number == 28 || trial_number == 11) && condition_num == 1;
%             trial_data(:,CURSOR_ANGLE)
%         end

        
%         if (trial_number == 28 || trial_number == 11) && condition_num == 1;
%             max_dev_angle
%         end
        
        % Max Deviation (Centimetres)
        y_max = max(abs(roty));
        y_max_idx = find(abs(roty) == y_max);
        y_max = roty(y_max_idx);
        y_max = mean(y_max);
        
        % Time - Duration of whole movement
        time = trial_data(end,TIME) - trial_data(1,TIME);
    
        % 1/3 Dist Calculations
        third_targ_dist = sqrt(trial_data(1,TARGET_X)^2 + trial_data(1,TARGET_Y)^2);
        third_xdiff = trial_data(:,CURSOR_X) - trial_data(1,CURSOR_X);
        third_ydiff = trial_data(:,CURSOR_Y) - trial_data(1,CURSOR_Y);
        third_dist = (third_xdiff.^2) + (third_ydiff.^2);
        third_dist = sqrt(third_dist);
        third_idx = find(third_dist > third_targ_dist/3);
        third_max_angle = trial_data(third_idx(1),CURSOR_ANGLE) - trial_data(1,ANGLE); % 1/3 Angle Deviation
        third_max_y = roty(third_idx(1)); % 1/3 CM Devition
        
        % End Point Calculations    
        end_dev_angle = trial_data(end,CURSOR_ANGLE) - trial_data(end,ANGLE);
        end_dev_dist = roty(end);
%         end_targ_dev = 
        
        
        temp_data = [trial_number ...
                        trial_data(1,ANGLE) ...
                        cursor_end_x ...
                        cursor_end_y ...
                        mouse_end_x ...
                        mouse_end_y ...
                        trial_data(1,ROTATION) ...
                        path_length ...
                        y_max ...
                        time ...
                        third_max_angle ...
                        third_max_y ...
                        end_dev_angle ...
                        end_dev_dist];
                    
        output_data = [output_data; cfg.subject_id cfg.TaskName num2cell(temp_data)];
        plot_data = [plot_data; temp_data];
        
    end
    
    if strfind(list_of_csv(condition_num).name(1:end-4),'Rotation_60_CW')
        plotfig;
        hold on;
%         axis equal;
        title(list_of_csv(condition_num).name(1:end-4),'interpreter','none')
    %     subplot(1,2,1); 
        plot(plot_data(:,2),plot_data(:,14), '*b'); %Plot 1/3 Angle Deviation
    end

end


labels = {'Subjett ID','Task Name','Trial','Target Angle','Cursor End X','Cursor End Y','Mouse End X','Mouse End Y','Rotation(Degrees)','Path Length', ...
            'Max Deviation(Dist)','Time(msec)','1/3 Dist Deviation(Angles)','1/3 Dist Deviation(Dist)','End Point Deviation(Angles)','End Point Deviation(Dist)'};
output_data = [labels; output_data];
xlswrite('Experiment_DV_Data', output_data)




%% OUTPUT DATA
% 1) Subject ID
% 2) Task Name
% 3) Trial
% 4) Target Angle
% 5) End Cursor X
% 6) End Cursor Y
% 7) End Mouse X
% 8) End Mouse Y
% 9) Rotation (Degrees)
% 10) Path Length
% 11) Max Deviation (Distance)
% 12) Time Duration (Whole movement)
% 13) 1/3 Dist Deviation (Angles)
% 14) 1/3 Dist Deviation (Distance)
% 15) End Point Deviation (Angles)
% 16) End Point Deviation (Centimetres from Target)












