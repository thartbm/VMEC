function VMEclearNames(number,keep,replacement)
%VMEclearNames makes sure filenames have only 1 underscore.
%   

if nargin < 2
    fprintf('ERROR: specify the number of underscores in each file, and which to keep.\n');
    fprintf('Alternatively, also specify the replacement string.\n');
    return
end;

switch nargin
    
    case 2
        % number should be a positive integer, larger than 1
        if ~isnumeric(number)
            fprintf('NUMBER should be a postive integer\n');
        end;
        if number < 2
            return;
        end;
        % keep should be a positive integer, larger than 1 and smaller
        % than or equal to number
        if ~isnumeric(keep)
            fprintf('KEEP should be a postive integer\n');
        end;
        if keep < 1
            return;
        end
        if keep > number
            return;
        end;
        replacement = '';
    case 3
        if ~ischar(replacement)
            return;
        end;
    otherwise
        fprintf('only three arguments are considered\n');
end



%% Collect all relevant file- and participant names
datadir = 'Data/';

% collect relevent folder names:
ls = dir(datadir);
subdirs = {datadir};

for id = 1:length(ls)
    if ls(id).isdir
        if ~any(ismember({'.','..'}, ls(id).name))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if the subdir name has any underscores... then what?
            scores = strfind(ls(id).name,'_');
            if scores > 0
                fprintf('Folder names have underscores, please fix first.\n');
                return;
            end;
            subdirs{length(subdirs)+1} = sprintf('%s%s/',datadir,ls(id).name);
        end;
    end;
end;

% directory names are equal to experimental groups:
for groupnumber = 1:length(subdirs)
    basedir = subdirs{groupnumber};
    
    slashlocs = strfind(basedir,'/');
    switch numel(slashlocs)
        case 1
            groupname = '';
        case 2
            groupname = basedir(slashlocs(1)+1:slashlocs(2)-1);
        otherwise
            fprintf(sprintf('WARNING: too many subdirectories in %s\nOr not Data folder\nSkipping.\n',basedir));
            continue;
    end;
    
    list_of_csv = dir(sprintf('%s*.csv',basedir));
    
    if numel(list_of_csv) == 0
        fprintf(sprintf('WARNING: no .csv files in folder %s\nSkipping.\n',basedir));
        continue
    end;
    
    alltasks = {};
    allparticipants = {};
    
    % extract the participants and tasks from the filenames:
    for csv_file_num = 1:length(list_of_csv)
        
        csv_file_name = list_of_csv(csv_file_num).name;
        scores = strfind(csv_file_name,'_');
%         fprintf(sprintf('%d: %s\n',numel(scores), csv_file_name));
        csvloc = strfind(csv_file_name,'.csv');
        
        if ~(numel(scores) == number)
            fprintf(sprintf('Number of underscores does not match: %s.\nSkipping.\n',csv_file_name));
            continue;
        end;
        
        if all([numel(scores)==number numel(csvloc)==1])
            
            % check if the accompanying mat file is there
            mat_file_name = [basedir csv_file_name(1:csvloc-1) '.mat'];
            if ~exist(mat_file_name,'file')
                fprintf('CSV file not matched with MAT file: %s\nSkipping.\n', csv_file_name);
                continue;
            end;
            
            scores(keep) = [];
            scores = fliplr(scores);
            
            new_file_name = [csv_file_name(1:csvloc-1)];
            
            for scoreno = 1:numel(scores)
                score = scores(scoreno);
                if strcmp(replacement, '');
                    new_file_name(score) = '';
                else
                    new_file_name(score) = replacement;
                end;
            end;
            
%             new_file_name
%             new_file_name(scores)
%             replacement
%             new_file_name(scores) = replacement;
            
            [STATUS,MESSAGE,MESSAGEID] = movefile([basedir csv_file_name],                  [basedir new_file_name '.csv']);
            [STATUS,MESSAGE,MESSAGEID] = movefile([basedir csv_file_name(1:csvloc-1) '.mat'], [basedir new_file_name '.mat']);
            
        end;

    end;
    
end;    
