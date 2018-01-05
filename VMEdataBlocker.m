function VMEdataBlocker(task,mode)
%VMEDblock Organizes VME data into preprocessed sheets.
%   

%% Collect all relevant file- and participant names
datadir = 'Data/';

% collect relevent folder names:
ls = dir(datadir);
subdirs = {datadir};

for id = 1:length(ls)
    if ls(id).isdir
        if ~any(ismember({'.','..'}, ls(id).name))
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
            fprintf(sprintf('WARNING: too many subdirectories in %s\nSkipping.\n',basedir));
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
        hyphen = strfind(csv_file_name,'_');
        csvloc = strfind(csv_file_name,'.csv');
        if any([numel(hyphen)~=1 numel(csvloc)~=1])
            fprintf(sprintf('WARNING: can not get either participant or task from CSV filename:\nSKIPPING file: %s\n',csv_file_name));
            continue
        end;
        allparticipants{numel(allparticipants)+1} = csv_file_name(1:hyphen-1);
        alltasks{numel(alltasks)+1} = csv_file_name(hyphen+1:csvloc-1);
        
    end;
    
    allparticipants = unique(allparticipants);
    alltasks = unique(alltasks);
    
    %% Use input variables to modify how to produce output
    
    switch nargin
        case 0
            % run on all tasks, with separate output sheet for each task
            % generate DVs per block of trials
            mode = 'block';
        case 1
            % run only on the task that is named in variable 1 if it is a
            % string
            % run all tasks that are named in variable 1 if it is a cell array
            % run all tasks that are there if variable 1 has zero elements
            if numel(task) == 0
                % do nothing: use all tasks found
            end;
            if ischar(task)
                alltasks = {task};
            end;
            if iscell(task)
                alltasks = task;
            end;
            % generate DVs per block of trials
            mode = 'block';
        case 2
            % run only on the task that is named in variable 1
            if numel(task) == 0
                % do nothing: use all tasks found
            end;
            if ischar(task)
                alltasks = {task};
            end;
            if iscell(task)
                alltasks = task;
            end;
            % generate DVs depending on second variable:
            % 'block' is averaged per block of trials
            % 'target' is averaged per target (for reach aftereffects)
            if any([strcmp(mode,'target') strcmp(mode,'block')])
                % perfect, do nothing
            else
                error('ERROR, mode not recognized: %s\nHas to be ''block'' or ''target''\nExiting.\n',mode);
            end;
    end
    
    % Now, a list of participants and tasks to process should be ready and a
    % way to structure the output should be known.
    
    fprintf(1,'\n==========================================\n');
    
    if length(groupname) > 0
        fprintf(1,sprintf('Working on Group: ''%s''\n',groupname));
    else
        fprintf(1,'Working on main Data folder:\n');
    end;
    
    fprintf(1,sprintf('Found %d tasks:\n',numel(alltasks)));
    for taskno = 1:numel(alltasks)
        fprintf(1,sprintf('%d: ''%s''\n',taskno,alltasks{taskno}));
    end;

    fprintf(1,sprintf('Found %d participants:\n',numel(allparticipants)));
    for ppno = 1:numel(allparticipants)
        fprintf(1,sprintf('%d: ''%s''\n',ppno,allparticipants{ppno}));
    end;

    %% Loop through tasks, then through participants
    
    for taskno = 1:numel(alltasks)
        
        angular_deviations = [];
        target_angles = [];
        task_file_header = mode;
        trial_file_header = 'trial';
        previousrotations = [];
        
        for ppno = 1:numel(allparticipants)
            
            try
                % read the cfg data:
                cfgfilename = sprintf('%s%s_%s.mat',basedir,allparticipants{ppno},alltasks{taskno});
                load(cfgfilename);
                
                % read the reach data:
                reachfilename = sprintf('%s%s_%s.csv',basedir,allparticipants{ppno},alltasks{taskno});
                reachdata = dlmread(reachfilename,',',1,0);
                
            catch
                fprintf('WARNING, csv and/or mat file does not exist: %s%s_%s\nSkipping.\n',basedir,allparticipants{ppno},alltasks{taskno});
                continue;
            end;
            
            % now process the file:
            [ang_devs, targ_angs, rotations] = processFile(reachdata,cfg);
            
            % store angular deviations in growing array:
            if isempty(angular_deviations)
                angular_deviations = ang_devs;
                target_angles = targ_angs;
            else
                angular_deviations = [angular_deviations ang_devs];
                target_angles = [target_angles targ_angs];
            end;
            
            % add participant ID to file header:
            task_file_header = sprintf('%s,%s',task_file_header,allparticipants{ppno});
            trial_file_header = sprintf('%s,%s',trial_file_header,allparticipants{ppno});
            
            % check if rotations are the same for all participants:
            if ~isempty(previousrotations)
                if ~all(rotations == previousrotations)
                    fprintf('WARNING. cursor rotations not the same within a task.\nWill use *last* encountered set of rotations.\n');
                end;
                previousrotations = rotations;
            end;
            
        end;
        
        % remove outliers per trial:
        angular_deviations = removeOutliers(angular_deviations,rotations);
        
        %% write out the data per trial:
        
        % add new-line to end of the header line:
        trial_file_header = sprintf('%s\n',trial_file_header);
        
        % make file name:
        output_file_name = sprintf('%s%s-trial.csv',groupname,alltasks{taskno});
        
        % first the header line to a file that is emptied if it exists:
        fid = fopen(output_file_name,'w+');
        fprintf(fid,trial_file_header);
        fclose(fid);
        
        % add a column for trial number:
        trial_angular_deviations = [(1:size(angular_deviations,1))' angular_deviations];

        % then the data, which is appended to the existing file:
        dlmwrite(output_file_name,trial_angular_deviations,'-append','delimiter',',','precision',6);
        
        % get the right output given the mode:
        switch mode
            case 'block'
                angular_deviations = getAngularDeviationsByBlock(angular_deviations,target_angles);
            case 'target'
                angular_deviations = getAngularDeviationsByTarget(angular_deviations,target_angles);
        end;
        
        % add new-line to end of the header line:
        task_file_header = sprintf('%s\n',task_file_header);
        
        % write out the stuff for this task:
        output_file_name = sprintf('%s%s-%s.csv',groupname,alltasks{taskno},mode);
        
        % first the header line to a file that is emptied if it exists:
        fid = fopen(output_file_name,'w+');
        fprintf(fid,task_file_header);
        fclose(fid);
        
        % then the data, which is appended to the existing file:
        dlmwrite(output_file_name,angular_deviations,'-append','delimiter',',','precision',6);
        
    end
    
    % end loop over groups / basedirs:
end


end

function [angular_deviations, target_angles, rotations] = processFile(reachdata, cfg)

% columns of all data files:
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

% normalize samples to percentage of home-target distance:
for columnno = [MOUSE_X MOUSE_Y CURSOR_X CURSOR_Y TARGET_X TARGET_Y]
    reachdata(:,columnno) = reachdata(:,columnno) / cfg.scale * 100 ./ reachdata(:,DISTANCE);
end;

% get an angular deviation for every trial,
% need to know which trials there are
trials = unique(reachdata(:,TRIAL));

angular_deviations = NaN(numel(trials),1);
target_angles = NaN(numel(trials),1);
rotations = NaN(numel(trials),1);

% loop through trials:
for trial_idx = 1:numel(trials)
    
    trial_number = trials(trial_idx);
    
    % select rows for the current trial
    idx = reachdata(:,TRIAL) == trial_number;
    trial_data = reachdata(idx,:);
    
    % normalize reach direction to 0
    theta = trial_data(1,ANGLE);% + trial_data(1,ROTATION);
    rotx=trial_data(:,CURSOR_X).*cosd(-theta)-trial_data(:,CURSOR_Y).*sind(-theta);
    roty=trial_data(:,CURSOR_X).*sind(-theta)+trial_data(:,CURSOR_Y).*cosd(-theta);
    
    % get the distance of every sample from home
    distance = sqrt(rotx.^2 + roty.^2);
    % find all samples at one-third the home-target distance or just over:
    crossed = find(distance >= (100/3));
    % if there are none:
    if isempty(crossed)
        % add a NaN?
        angdev = NaN;
    else
        % if there are some, use the first to calculate an angle:
        third = crossed(1);
        angdev = atan2(roty(third),rotx(third)) * 180 / pi;
    end;
    
    % add the result to the return list:
    angular_deviations(trial_idx) = angdev;
    
    % also store the target angle:
    target_angles(trial_idx) = theta;
    
    % store trial rotation:
    rotations(trial_idx) = trial_data(1,ROTATION);
    
end;

end

function blocked_angular_deviations = getAngularDeviationsByBlock(angular_deviations,target_angles)

% get some basic stats on this data:
ntrials = size(angular_deviations,1);
nparticipants = size(angular_deviations,2);

% blocksize is determined by the number of targets:
blocksize = numel(unique(target_angles));

% but should be at least three:
switch blocksize
    case 1
        % just use three
        blocksize = 3;
    case 2
        % repeat every target twice?
        blocksize = 4;
        % actually, targets are not counterbalanced properly
end;

% check if we can divide the trials evenly across blocks:
if mod(ntrials,blocksize) > 0
    % if not, fill up with nans at the end:
    filler = NaN(blocksize-mod(ntrials,blocksize),nparticipants);
    angular_deviations = [angular_deviations; filler];
    ntrials = size(angular_deviations,1);
end;

% get the number of blocks
nblocks = ntrials / blocksize;

% get the nanmean across all trials in a block:
blocked_angular_deviations = squeeze(nanmean(reshape(angular_deviations,[blocksize,nblocks,nparticipants]),1));

% add a column for block number:
blocked_angular_deviations = [(1:nblocks)' blocked_angular_deviations];

end

function target_angular_deviations = getAngularDeviationsByTarget(angular_deviations,target_angles)

targets = unique(target_angles);
nparticipants = size(angular_deviations,2);

target_angular_deviations = NaN(numel(targets),nparticipants);

for ppno = 1:nparticipants
    
    pp_targets = target_angles(:,ppno);
    pp_angdevs = angular_deviations(:,ppno);
    
    for target = 1:numel(targets)
        
        % find the rows where the current target was used:
        target_idx = find(pp_targets == targets(target));
        
        % store the mean for this paricipant and target in the array:
        target_angular_deviations(target,ppno) = nanmean(pp_angdevs(target_idx));
        
    end;
end;

% add a column for target:
target_angular_deviations = [targets target_angular_deviations];

end

function angular_deviations = removeOutliers(angular_deviations,rotations)

% how many trials are there?
ntrials = size(angular_deviations,1);

% loop through trials:
for trial = 1:ntrials
    
    % get all the angular deviations for the trial
    trial_ang_devs = angular_deviations(trial,:);
    
    %% First use absolute criterion:
    
    rot = rotations(trial);
    if rot >= 0
        maximum = 45 + rot;
        minimum = -45;
    else
        maximum = 45;
        minimum = -45 + rot;
    end;
    
    % remove reach directions below range:
    trial_ang_devs(trial_ang_devs < minimum) = NaN;
    
    % remove reach directions above range:
    trial_ang_devs(trial_ang_devs > maximum) = NaN;
    
    %% Now use 2 SD criterion:
    
    % reaches can be within 2 SDs of the mean only:
    envelope = (nanstd(trial_ang_devs) * 2);
    middle = nanmean(trial_ang_devs);
    
    minimum = middle - envelope;
    maximum = middle + envelope;
    
    % remove reach directions below range:
    trial_ang_devs(trial_ang_devs < minimum) = NaN;
    
    % remove reach directions above range:
    trial_ang_devs(trial_ang_devs > maximum) = NaN;
    
    % put result back in the array:
    angular_deviations(trial,:) = trial_ang_devs;
end;

end


%% Hebb lab doesn't have statistics toolbox...

function y = nanvar(x,w,dim)
%NANVAR Variance, ignoring NaNs.
%   Y = NANVAR(X) returns the sample variance of the values in X, treating
%   NaNs as missing values.  For a vector input, Y is the variance of the
%   non-NaN elements of X.  For a matrix input, Y is a row vector
%   containing the variance of the non-NaN elements in each column of X.
%   For N-D arrays, NANVAR operates along the first non-singleton dimension
%   of X.
%
%   NANVAR normalizes Y by N-1 if N>1, where N is the sample size of the 
%   non-NaN elements.  This is an unbiased estimator of the variance of the
%   population from which X is drawn, as long as X consists of independent,
%   identically distributed samples, and data are missing at random.  For
%   N=1, Y is normalized by N. 
%
%   Y = NANVAR(X,1) normalizes by N and produces the second moment of the
%   sample about its mean.  NANVAR(X,0) is the same as NANVAR(X).
%
%   Y = NANVAR(X,W) computes the variance using the weight vector W.  The
%   length of W must equal the length of the dimension over which NANVAR
%   operates, and its non-NaN elements must be nonnegative.  Elements of X
%   corresponding to NaN elements of W are ignored.
%
%   Y = NANVAR(X,W,DIM) takes the variance along dimension DIM of X.
%
%   See also VAR, NANSTD, NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/03/23 20:25:41 $

if nargin < 2 || isempty(w), w = 0; end

sz = size(x);
if nargin < 3 || isempty(dim)
    % The output size for [] is a special case when DIM is not given.
    if isequal(x,[]), y = NaN(class(x)); return; end

    % Figure out which dimension sum will work along.
    dim = find(sz ~= 1, 1);
    if isempty(dim), dim = 1; end
elseif dim > length(sz)
    sz(end+1:dim) = 1;
end

% Need to tile the mean of X to center it.
tile = ones(size(sz));
tile(dim) = sz(dim);

if isequal(w,0) || isequal(w,1)
    % Count up non-NaNs.
    n = sum(~isnan(x),dim);

    if w == 0
        % The unbiased estimator: divide by (n-1).  Can't do this when
        % n == 0 or 1, so n==1 => we'll return zeros
        denom = max(n-1, 1);
    else
        % The biased estimator: divide by n.
        denom = n; % n==1 => we'll return zeros
    end
    denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

    x0 = x - repmat(nanmean(x, dim), tile);
    y = nansum(abs(x0).^2, dim) ./ denom; % abs guarantees a real result

% Weighted variance
elseif numel(w) ~= sz(dim)
    error('MATLAB:nanvar:InvalidSizeWgts','The length of W must be compatible with X.');
elseif ~(isvector(w) && all(w(~isnan(w)) >= 0))
    error('MATLAB:nanvar:InvalidWgts','W must be a vector of nonnegative weights, or a scalar 0 or 1.');
else
    % Embed W in the right number of dims.  Then replicate it out along the
    % non-working dims to match X's size.
    wresize = ones(size(sz)); wresize(dim) = sz(dim);
    wtile = sz; wtile(dim) = 1;
    w = repmat(reshape(w, wresize), wtile);

    % Count up non-NaNs.
    n = nansum(~isnan(x).*w,dim);

    x0 = x - repmat(nansum(w.*x, dim) ./ n, tile);
    y = nansum(w .* abs(x0).^2, dim) ./ n; % abs guarantees a real result
end


end

function y = nanstd(varargin)
%NANSTD Standard deviation, ignoring NaNs.
%   Y = NANSTD(X) returns the sample standard deviation of the values in X,
%   treating NaNs as missing values.  For a vector input, Y is the standard
%   deviation of the non-NaN elements of X.  For a matrix input, Y is a row
%   vector containing the standard deviation of the non-NaN elements in
%   each column of X. For N-D arrays, NANSTD operates along the first
%   non-singleton dimension of X.
%
%   NANSTD normalizes Y by (N-1), where N is the sample size.  This is the
%   square root of an unbiased estimator of the variance of the population
%   from which X is drawn, as long as X consists of independent, identically
%   distributed samples and data are missing at random.
%
%   Y = NANSTD(X,1) normalizes by N and produces the square root of the
%   second moment of the sample about its mean.  NANSTD(X,0) is the same as
%   NANSTD(X).
%
%   Y = NANSTD(X,FLAG,DIM) takes the standard deviation along dimension
%   DIM of X.
%
%   See also STD, NANVAR, NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 2.10.2.6 $  $Date: 2006/10/02 16:34:51 $

% Call nanvar(x,flag,dim) with as many inputs as needed
y = sqrt(nanvar(varargin{:}));

end


function m = nanmean(x,dim)
%NANMEAN Mean value, ignoring NaNs.
%   M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
%   values.  For vector input, M is the mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the mean value of
%   non-NaN elements in each column.  For N-D arrays, NANMEAN operates
%   along the first non-singleton dimension.
%
%   NANMEAN(X,DIM) takes the mean along dimension DIM of X.
%
%   See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $

% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x) ./ n;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x,dim) ./ n;
end

end


function y = nansum(x,dim)
%NANSUM Sum, ignoring NaNs.
%   Y = NANSUM(X) returns the sum of X, treating NaNs as missing values.
%   For vector input, Y is the sum of the non-NaN elements in X.  For
%   matrix input, Y is a row vector containing the sum of non-NaN elements
%   in each column.  For N-D arrays, NANSUM operates along the first
%   non-singleton dimension.
%
%   Y = NANSUM(X,DIM) takes the sum along dimension DIM of X.
%
%   See also SUM, NANMEAN, NANVAR, NANSTD, NANMIN, NANMAX, NANMEDIAN.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.10.2.4 $  $Date: 2004/07/28 04:38:44 $

% Find NaNs and set them to zero.  Then sum up non-NaNs.  Cols of all NaNs
% will return zero.
x(isnan(x)) = 0;
if nargin == 1 % let sum figure out which dimension to work along
    y = sum(x);
else           % work along the explicitly given dimension
    y = sum(x,dim);
end

end
