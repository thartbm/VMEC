function runStimulus( configfilename )

% Do some Java stuff to fix a few problems (mainly on Linux, with a non-Sun Java VM)
PsychJavaTrouble;
Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'SkipSyncTests', 1);

load(configfilename);

%% remove forbidden characters from subject id and taskname 

% remove underscores and spaces, leave hyphens and dots for now
% removing underscores makes files work in the data-blocker
% spaces sometimes cause trouble, but it might not be necessary
forbiddenChars = {'_',' '};

for fbcn = 1:numel(forbiddenChars)
    cfg.subject_id(strfind(cfg.subject_id),forbiddenChars{fbcn}) = '';
    cfg.TaskName(strfind(cfg.TaskName),forbiddenChars{fbcn}) = '';
end;

%% set up file and directory names

cfg.datafilename = sprintf('%s_%s',cfg.subject_id,cfg.TaskName);

warning('off');
cfg.datadir = 'Data/';
mkdir(cfg.datadir);
warning('on');


%% Initialize random number generator
rand('seed',sum(double(['visuomotor lab ' cfg.subject_id ' ' cfg.TaskName])));

%% Create random trial order

trialorder = [];
for type = 1:size(cfg.target,1)
    trialorder = [trialorder; zeros(cfg.target{type}.trials,1)+type];
end;
trialorder = Shuffle(trialorder);
cfg.trialorder = trialorder;
cfg.trialcount = zeros(size(cfg.target,1),1);

%% Initialize the Screen:

% Set up keyboard OS-independently:
KbName('UnifyKeyNames');
HideCursor(); % we'll show our own cursor if we want to.

% [maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference', 'SyncTestSettings', 0.003, 20, .5);
% if cfg.skipsynctest, % useful for laptops / bad screens / bad graphics card
     Screen('Preference', 'SkipSyncTests', 1);
% end;

pause(1);

% Make sure we can use alpha-blending:
AssertOpenGL; % only on high-end graphics cards, not necessary here

% better looking text:
Screen('Preference', 'TextAntiAliasing', 2);

% open a Screen object
[windowPtr, windowRect] = Screen('OpenWindow', 0);

cfg.windowPtr  = windowPtr;
cfg.windowRect = windowRect;


%% Stimulus parameters

% only use the central 2/3rds of the screen:
Hscale = (windowRect(3) - windowRect(1)) * (2/3);
Vscale = (windowRect(4) - windowRect(2)) * (2/3);
% in a 2x1 rectangle (that fits the top half of a circle)
if (Vscale*2) < Hscale,
    Hscale = Vscale * 2;
else
    Vscale = Hscale / 2;
end;

% 100% of the scale is the maximum distance within this rectangle
% target locations are scaled according to this distance
cfg.scale = Vscale;
cfg.cursorsize = Vscale * 0.05; % cursor/target is sqrt(5 percent of used screen estate)
cfg.cursorRect = [-(cfg.cursorsize/2) -(cfg.cursorsize/2) (cfg.cursorsize/2) (cfg.cursorsize/2)];
cfg.background = [0,0,0]; % black
cfg.foreground = [196,196,196]; % gray

% this is the home position, and most stuff is calculated relative to these
% screen coordinates:
cfg.cX = round((cfg.windowRect(3) - cfg.windowRect(1)) / 2);
cfg.cY = round(((cfg.windowRect(4) - cfg.windowRect(2)) / 2) + (Vscale / 2));

cfg.homeRect = [cfg.cX cfg.cY cfg.cX cfg.cY] + cfg.cursorRect;

Screen(cfg.windowPtr, 'FillRect', [0, 0, 0]);
Screen(cfg.windowPtr, 'Flip');

%% monitoring keyboard events

abort_key = KbName('Escape');
abort = 0;

%% arrow for now cursor trials:

arrowX = [-4 -4  1  1  4  1  1] * cfg.cursorsize/9; % divide by 8 to fill exactly in home position
arrowY = [-1  1  1  3  0 -3 -1] * cfg.cursorsize/9;

[arrowT, arrowR] = cart2pol(arrowX,arrowY);

%% Timing
% pre-load MEXs that are crucial for timing:
GetSecs();
WaitSecs(.01);

cfg.trialtracks = {};

for trialno = 1:length(cfg.trialorder)
    % what kind of trial are we going to do now?
    trialtype = cfg.trialorder(trialno);
    
    % clear the screen:
    Screen(cfg.windowPtr, 'FillRect', [0, 0, 0]);
    Screen(cfg.windowPtr, 'Flip');
    
    % determine rotation of visual feedback:
    rotation = 0;
    switch cfg.Rot_type,
        case 'None'
            rotation = 0;
        case 'Gradual'
%            rotation = cfg.target{trialtype}.rot_degree * cfg.target{trialtype}.rot_direct * (cfg.trialcount(trialtype) / cfg.target{trialtype}.trials);
            rotation = min(trialno-1 ,cfg.target{trialtype}.rot_degree) * cfg.target{trialtype}.rot_direct;
        case 'Abrupt'
            rotation = cfg.target{trialtype}.rot_degree * cfg.target{trialtype}.rot_direct;
    end;
%     rotation = rotation / 180 * pi; % for when rotation output was in radians
    
    % determine position of target:
    target_angle = cfg.target{trialtype}.angle_locate;
    target_dist  = cfg.target{trialtype}.targ_dist;
    targetX = cfg.cX + (target_dist * cos(target_angle*(pi/180)) * cfg.scale);
    targetY = cfg.cY - (target_dist * sin(target_angle*(pi/180)) * cfg.scale);
    targetRect = [targetX targetY targetX targetY] + cfg.cursorRect;
    
    % set up trialdata struct:
    trialdata.type = trialtype;
    trialdata.angle = target_angle;
    trialdata.distance = target_dist;
    trialdata.rotation = rotation;
    trialdata.VBLtime = [];
    trialdata.Xmouse = [];
    trialdata.Ymouse = [];
    trialdata.Xcursor = [];
    trialdata.Ycursor = [];
    trialdata.Xtarget = [];
    trialdata.Ytarget = [];
    
    % wait a second and reset the mouse to the centre of the screen
%     abort = abort + WaitKeyPressed([abort_key], .5);
%     SetMouse(round(cfg.cX),round(cfg.cY));
%     abort = abort + WaitKeyPressed([abort_key], .5);
    SetMouse(round(cfg.cX),round(cfg.cY));
    
    if abort > 0;
        AbortExperiment(cfg);
        return;
    end;
    
    [xp, yp, oldbuttons] = GetMouse();
    
    % now participants make their move while we record stuff
    % the trial ends when people get close to the target
    % (center of the cursor position is on the target)
    out = false;
    back = false;
    
    % clear the screen, and get timestamp for start of the trial:
    Screen(cfg.windowPtr, 'FillRect', [0, 0, 0]);
    VBLstart = Screen(cfg.windowPtr, 'Flip');
    
    while ~back,
        [xp, yp, buttons] = GetMouse();
        
        [pressed, secs, kbData] = KbCheck;
        abort = abort + kbData(abort_key);
        
        if abort > 0;
            AbortExperiment(cfg);
            return;
        end;
        
        [theta, r] = cart2pol(xp-cfg.cX, -1*(yp-cfg.cY));
        [cursorX, cursorY] = pol2cart(theta+(rotation*(pi/180)), r);
        cursorX = cfg.cX + cursorX;
        cursorY = cfg.cY - cursorY;
        cursorRect = [cursorX cursorY cursorX cursorY] + cfg.cursorRect;
        
        Screen(cfg.windowPtr, 'FillRect', cfg.background);
        if ~out
            Screen(cfg.windowPtr, 'FrameOval', cfg.foreground, targetRect, 2); % target
        else
            Screen(cfg.windowPtr, 'FrameOval', cfg.foreground, cfg.homeRect, 2); % home
        end;
        switch cfg.Feed_type,
            case 'Cursor'
                Screen(cfg.windowPtr, 'FillOval', cfg.foreground, cursorRect, cfg.cursorsize); % cursor
            case 'No_Cursor'
                XYdist = sqrt((cfg.cX - xp)^2 + (cfg.cY - yp)^2);
                if XYdist < (0.2 * target_dist * cfg.scale)
                    Screen(cfg.windowPtr, 'FillOval', cfg.foreground, cursorRect, cfg.cursorsize);
                end;
                if out
                    % %                     show circle:
                    % XYdist = sqrt((cfg.cX - cursorX)^2 + (cfg.cY - cursorY)^2);
                    % no_cursor_rect = [cfg.cX - XYdist cfg.cY - XYdist cfg.cX + XYdist cfg.cY + XYdist];
                    % Screen(cfg.windowPtr, 'FrameOval', cfg.foreground, no_cursor_rect, 2);
                    % %                     show arrow:
                    XYdist = sqrt((cfg.cX - xp)^2 + (cfg.cY - yp)^2);
                    if XYdist < (0.5 * target_dist * cfg.scale)
                        arrow_angle = ((fix((mod(theta,2*pi)/(2*pi)) * 8) / 8) * (2*pi)) + ((2*pi)/8/2);
                        [arrowPlotX, arrowPlotY] = pol2cart(arrowT+arrow_angle,arrowR);
                        Screen('FillPoly', cfg.windowPtr, cfg.foreground, [arrowPlotX+cfg.cX;(-1*arrowPlotY)+cfg.cY]');
                    end;
                end;
        end;
        
        VBLtime = Screen(cfg.windowPtr, 'Flip');
        VBLtime = VBLtime - VBLstart;
        
        % record the data here, only for the outward movement though
        if ~out
            trialdata.Xmouse = [trialdata.Xmouse xp];
            trialdata.Ymouse = [trialdata.Ymouse yp];
            trialdata.Xcursor = [trialdata.Xcursor cursorX];
            trialdata.Ycursor = [trialdata.Ycursor cursorY];
            trialdata.VBLtime = [trialdata.VBLtime VBLtime];
            trialdata.Xtarget = [trialdata.Xtarget targetX];
            trialdata.Ytarget = [trialdata.Ytarget targetY];
        end;
        
        if ~out,
            % test if the target is reached:
            switch cfg.Feed_type
                case 'Cursor'
                    % if the cursor is visible, the trial terminates
                    % whenever you get close enough to the target
                    if sqrt((targetX - cursorX)^2 + (targetY - cursorY)^2) <= (cfg.cursorsize / 2)
                        out = true;
                    end;
                case 'No_Cursor'
                    % when the cursor is not visible, you have to have
                    % moved some distance away from the home position...
                    if (sqrt((xp-cfg.cX)^2 + (yp-cfg.cY)^2)) > (target_dist * .5 * cfg.scale)
                        % AND you have to have stopped moving...
                        % which requires some minimum amount of samples
                        if (VBLtime - 0.5) > min(trialdata.VBLtime)
                            idx = find(trialdata.VBLtime > (VBLtime - 0.5));
                            if sum(sqrt(diff(trialdata.Xmouse(idx)).^2 + diff(trialdata.Ymouse(idx)).^2)) < numel(idx)
                                out = true;
                            end;
                        end;
                    end;
            end;
        else
            % test if the cursor is close enough to the home position:
            if sqrt((cfg.cX - cursorX)^2 + (cfg.cY - cursorY)^2) <= (cfg.cursorsize / 2)
                back = true;
            end;
        end;
    end;
    
    cfg.trialcount(trialtype) = cfg.trialcount(trialtype) + 1; % bookkeeping to do the right rotation for each target
    
    trialdata.Xmouse  =  trialdata.Xmouse  - cfg.cX;
    trialdata.Ymouse  = ((cfg.windowRect(4) - cfg.windowRect(2)) - trialdata.Ymouse) - ((cfg.windowRect(4) - cfg.windowRect(2)) - cfg.cY);
    trialdata.Xcursor = trialdata.Xcursor - cfg.cX;
    trialdata.Ycursor = ((cfg.windowRect(4) - cfg.windowRect(2)) - trialdata.Ycursor) - ((cfg.windowRect(4) - cfg.windowRect(2)) - cfg.cY);
    trialdata.Xtarget = trialdata.Xtarget - cfg.cX;
    trialdata.Ytarget = ((cfg.windowRect(4) - cfg.windowRect(2)) - trialdata.Ytarget) - ((cfg.windowRect(4) - cfg.windowRect(2)) - cfg.cY);
    
%     cfg.trialtracks{size(cfg.trialtracks,1)+1} = trialdata;
    save(sprintf('%s%s_%d',cfg.datadir,cfg.datafilename,trialno),'trialdata')
    save(sprintf('%s%s',cfg.datadir,cfg.datafilename),'cfg');
    
end;

convertToCSV(cfg);

Screen('CloseAll');
ShowCursor();

end



function key = WaitKeyPressed( keysWanted, waitTime )

% If something is wrong with the input, your programm will keep running but
% a warning message can be read in the Matlab commandline screen:
if isempty(keysWanted),
    fprintf('empty list of keys to wait for: infinite loop\n');
    return;
end;

% Check if waittime argument was provided
if nargin < 2
    % no waittime: unlimited response time
    unlimited = true;
else
    % impose a maximum response time
    unlimited = false;
end;

% Set some variables:
startTime = GetSecs();
key = 0;

% Start with a fresh keyboard:
FlushEvents('keyDown');

% When one of the target keys is pressed, the success variable is set to 1:
success = 0;
while success == 0,
    
    % Wait for new key-presses as long as pressed = 0
    pressed = 0;
    while pressed == 0,
        % Check the keyboard, when pressed is 1, we stop checking it:
        [pressed, secs, kbData] = KbCheck;
        % Check if the time limit has not been exceeded:
        if ~unlimited && (GetSecs()-startTime > waitTime)
            success = 1;
            break
        end;
    end;
    
    % For each of the keys in 'keysWanted' we check if it was one of the
    % pressed keys:
    for k = 1:length(keysWanted),
        if kbData(keysWanted(k)) == 1,
            % If one of the sought keys is pressed, we report that to the
            % calling function:
            success = 1;
            key = k;
            break;
        end;
    end;
    
end;

end

function AbortExperiment( cfg )

Screen('CloseAll');
ShowCursor();

end

function convertToCSV( cfg )

datamatrix = [];

labels = {'trialno','time','Xmouse','Ymouse','Xcursor','Ycursor','Xtarget','Ytarget','type','angle','distance','rotation'};

for trialno = 1:length(cfg.trialorder)
    
    load(sprintf('%s%s_%d',cfg.datadir,cfg.datafilename,trialno));
    trialmatrix = zeros(length(trialdata.VBLtime),12);
    
    trialmatrix(:,1) = trialno;
    trialmatrix(:,2) = trialdata.VBLtime;
    trialmatrix(:,3) = trialdata.Xmouse;
    trialmatrix(:,4) = trialdata.Ymouse;
    trialmatrix(:,5) = trialdata.Xcursor;
    trialmatrix(:,6) = trialdata.Ycursor;
    trialmatrix(:,7) = trialdata.Xtarget;
    trialmatrix(:,8) = trialdata.Ytarget;
    trialmatrix(:,9) = trialdata.type;
    trialmatrix(:,10) = trialdata.angle;
    trialmatrix(:,11) = trialdata.distance;
    trialmatrix(:,12) = trialdata.rotation;
    
    datamatrix = [datamatrix; trialmatrix];
    
end;

CSVfilename = sprintf('%s%s_%s.csv',cfg.datadir,cfg.subject_id,cfg.TaskName); % one file per subject
writeCSVtable(CSVfilename,datamatrix,labels);

% after the CSV file has been successfully created, remove the mat files
% for the individual trials:

for trialno = 1:length(cfg.trialorder)
    delete(sprintf('%s%s_%d.mat',cfg.datadir,cfg.datafilename,trialno));
end;

end

function writeCSVtable( filename, data, labels )
%WRITECSVTABLE Writes a matrix to a file that can be opened by Excel
%   Usage:
%   writeCSV( FILENAME, M, LABELS);
%
%   FILENAME: file to write the data to, if it exist, it will be
%   overwritten (to match the default behavior of dlmwrite)
%   M: matrix with data, this should be a 2-dimensional matrix
%   LABELS: optional argument with column names in a cell array


fh = fopen(filename, 'w');

if nargin >= 3,
    
    % check if number of labels matches columns in data??
    
    for labelno = 1:length(labels),
        if labelno < length(labels),
            fprintf(fh,sprintf('%s,',labels{labelno}));
        else
            fprintf(fh,sprintf('%s\n',labels{labelno}));
        end;
    end;
    
end;

fclose(fh);

% check if data is 2D?

dlmwrite(filename,data,'-append','delimiter',',');

end

