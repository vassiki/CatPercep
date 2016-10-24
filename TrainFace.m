function TrainFace(Subject,Block,UsingEyeTracker)
%
%   train_face(sub_num,block_num,[,using eye tracker (0 or 1)])
%
%   Exp1 from morphed faces set of experiments.

%% Experiment 1: Face Scanning
%       This experiment consists of 3 blocks-where each block consists of
%       32 trials.
%
%       The experiment should start with a white fixation cross that
%       changes to green after either 700 ms, 800 ms or 900 ms. The
%       white fixation will stay online for 300 ms, 200 ms or 100 ms,
%       making the total time of fixation 1000 ms. Fixation will subtend
%       one degree of visual angle around the center of the screen
%
%       A face image subtending 10 degrees of visual angle around the
%       center of the screen will then stay online for 5 seconds.
%% setup
if ~exist('UsingEyeTracker','var')
    UsingEyeTracker = 0;
end

DEBUG = 0;
[DegToPix,res,center,window] = set_PTB(DEBUG);
centx = center(1); centy = center(2);
resx = res(1); resy = res(2);
ifi = Screen('GetFlipInterval', window);
backgroundEntry = 0;

%% response keys
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
RestrictKeysForKbCheck([spaceKey escapeKey leftKey rightKey]);

%% timing
waitframes = 1;
FirstFixTime = [0.7,0.8,0.9];
StimTime = 5;

%% sizes
FixSizeDeg = 1;
FixSize = FixSizeDeg * DegToPix;
PenWidDeg = .2;
PenWid = PenWidDeg * DegToPix;

ImSizeDeg = 10;
ImSize = ImSizeDeg*DegToPix;

%% locations
StimLoc=[centx-ImSize/2,centy-ImSize/2,centx+ImSize/2,centy+ImSize/2];

%% generate images
Exp = 'Exp1';
[indir,outdir] = set_Exp(Subject,Block,Exp);
filename = fullfile(indir,[Exp,'_S',num2str(Subject),'B',num2str(Block),'.csv']);
f = fopen(filename, 'r');
images = textscan(f, '%s%s%s%s', 'delimiter', ',');
fclose(f);

for i = 1:length(images{1})
    images{1,5}{i,1} = imread(fullfile(images{1,2}{i,1},images{1,1}{i,1}));
end

%% eyetracking setup
if UsingEyeTracker == 1
    eyefilename=sprintf('S%dB%dEye',Subject, Block);
end
if UsingEyeTracker ==1
    % Initialize ----------------------------------------------------------
    Screen('Preference', 'SkipSyncTests', window)
    EyelinkInit();
    el=EyelinkInitDefaults(window); % Tell eyelink about the PTB window
    
    % Set-up datafile -----------------------------------------------------
    eyefilename = deblank(eyefilename);
    Eyelink('Openfile', eyefilename);
    
    % Set-up screen res ---------------------------------------------------
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, resx-1, resy-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, resx-1, resy-1);
    
    % Set calibration type ------------------------------------------------
    Eyelink('command', 'calibration_type = HV5');
    Eyelink('command', 'generate_default_targets = YES');
    
    % Set sampling rate ---------------------------------------------------
    Eyelink('command', 'sample_rate = 1000');
    
    % Set movement thresholds (conservative) ------------------------------
    Eyelink('command', 'saccade_velocity_threshold = 35');
    Eyelink('command', 'saccade_acceleration_threshold = 9500');
    
    % Get tracker and software versions -----------------------------------
    [v,vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    vsn = regexp(vs,'\d','match');
    
    % Link to edf data ----------------------------------------------------
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    
    % Link data to Matlab -------------------------------------------------
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    
    % Calibrate -----------------------------------------------------------
    EyelinkDoTrackerSetup(el);
    
    % Do a final check of calibration using driftcorrection ---------------
    success=EyelinkDoDriftCorrection(el);
    if success~=1
        cleanup;
        return;
    end
end

%% starting eyetracker
if UsingEyeTracker ==1
    Eyelink('StartRecording');
    WaitSecs(0.1);
    % Mark zero-plot time in edf file
    Eyelink('message', 'SYNCTIME');
end

%% instruction screen

%% start presentation
FlushEvents('keyDown');

for trial = 1:length(images{1})
    if UsingEyeTracker == 1
        Eyelink('Message',sprintf('TRIALID: %d', trial));
        Eyelink('Command','record_status_message "TRIAL/TOTAL %d/%d"' ,...
            trial, Num_Trials);
        Eyelink('StartRecording');
    end
    % First flip for VBL
    vbl = Screen('Flip', window);
    
    % First fixation timing
    FirstFix = datasample(FirstFixTime,1);
    FirstFixFrames = round((FirstFix) / ifi);
    TrialInfo(trial).firstfix = FirstFix;
    SecondFix = 1-FirstFix;
    SecondFixFrames = round((SecondFix) / ifi);
    TrialInfo(trial).secfix = SecondFix;
    
    % Display First fixation cross
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('FIX ON'));
    end
    for n=1:FirstFixFrames
        Screen('FillRect',window,backgroundEntry);
        Screen(window, 'FillRect', 255, [(centx - FixSize/2),(centy - PenWid/2),...
            (centx + FixSize/2), (centy + PenWid/2)]);
        Screen(window, 'FillRect', 255, [(centx - PenWid/2), (centy - FixSize/2),...
            (centx + PenWid/2),(centy + FixSize/2)]);
        
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('FIX OFF'));
    end
    
    % Display Second fixation cross
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('SEC_FIX ON'));
    end
    for n=1:SecondFixFrames
        Screen('FillRect',window,backgroundEntry);
        Screen(window, 'FillRect',  [0,255,0], [(centx - FixSize/2),(centy - PenWid/2),...
            (centx + FixSize/2), (centy + PenWid/2)]);
        Screen(window, 'FillRect', [0,255,0], [(centx - PenWid/2), (centy - FixSize/2),...
            (centx + PenWid/2),(centy + FixSize/2)]);
        
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('SEC_FIX OFF'));
    end
    
    % which face
    TrialInfo(trial).stimid = images{1,1}{trial,1};
    % familiar or unfamiliar
    TrialInfo(trial).cond = images{1,3}{trial,1};
    TrialInfo(trial).faceid = images{1,4}{trial,1};
    
    Screen('FillRect',window,backgroundEntry);
    FaceTex=Screen('MakeTexture',window,images{1,5}{trial,1});
    Screen('DrawTexture',window,FaceTex,[],StimLoc);
    
    StimFrames = round((StimTime) / ifi);
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('STIM ON'));
    end
    for n=1:StimFrames
        Screen('DrawTexture',window,FaceTex,[],StimLoc);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    if UsingEyeTracker ==1
        Eyelink('Message', sprintf('STIM OFF'));
    end
    
    Screen('Close',FaceTex);
    
    if UsingEyeTracker == 1
        Eyelink('Message', sprintf('TRIALID OVER %d',trial));
    end
    
    emptiness=arrayfun(@(x) isempty(x.cond),TrialInfo);
    TrialInfo=TrialInfo(~emptiness);
    
    out_file=['Sub' num2str(Subject) 'Block' num2str(Block)];
    save (fullfile(outdir,out_file), 'TrialInfo')
end

%% stop eyetracker
if UsingEyeTracker == 1
    Eyelink('Message',sprintf('Block %d over',BlockNum))
    Eyelink('StopRecording') 
    Eyelink('CloseFile');
    
    fprintf('Receiving data file ''%s''\n', eyefilename);
    status = Eyelink('ReceiveFile');
    if status <= 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist([eyefilename, '.edf'], 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', eyefilename, pwd);
    end
    
    WaitSecs(1.0); % Give tracker time to execute all commands
  
    Eyelink('shutdown');
end
%% end experiment
ShowCursor;
Screen('CloseAll');

end




