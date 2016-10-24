function TestFaceControl(Subject,Block,UsingEyeTracker)
%   This experiment consists of 4 blocks 60 trials each
%
%   The experiment begins with a fixation cross that stays
%   online for either 500 ms or 700 ms. A priming face then replaces the fixation
%   cross and stay online for 1000 ms. A screen with two images showing
%   ends of the primimg face appear, asking the subjects to pick the image
%   the prime was more similar to.

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
FirstFixTime = [0.5,0.7];
StimTime = 1;

%% sizes
FixSizeDeg = 1;
FixSize = FixSizeDeg * DegToPix;
PenWidDeg = .2;
PenWid = PenWidDeg * DegToPix;

ImSizeDeg = 10;
ImSize = ImSizeDeg*DegToPix;

DiffBetImDeg = 10;
DiffBetIm = DiffBetImDeg*DegToPix;

%% locations
StimLoc=[centx-ImSize/2,centy-ImSize/2,centx+ImSize/2,centy+ImSize/2];

LeftIm = [centx-((DiffBetIm/2)+ImSize),centy-(ImSize/2),centx-(DiffBetIm/2),centy+(ImSize/2)];
RightIm = [centx+(DiffBetIm/2),centy-(ImSize/2),centx+((DiffBetIm/2)+ImSize),centy+(ImSize/2)];

%% generate images
Exp = 'Exp3';
[indir,outdir] = set_Exp_control(Subject,Block,Exp);
filename = fullfile(indir,[Exp,'_S',num2str(Subject),'B',num2str(Block),'_Control','.csv']);
f = fopen(filename, 'r');
images = textscan(f, '%s%s%s%s%s', 'delimiter', ',');
fclose(f);

for i = 1:length(images{1})
    images{1,6}{i,1} = imread(fullfile(images{1,2}{i,1},images{1,1}{i,1}));
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
    
    TrialInfo(trial).cond = images{1,4}{trial,1};
    TrialInfo(trial).faceid = images{1,1}{trial,1};
    
    % First fixation timing
    FirstFix = datasample(FirstFixTime,1);
    FirstFixFrames = round((FirstFix) / ifi);
    TrialInfo(trial).firstfix = FirstFix;
    
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
    
    Screen('FillRect',window,backgroundEntry);
    FaceTex=Screen('MakeTexture',window,images{1,6}{trial,1});
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
    
    promptdir = fullfile(pwd,'orig_id_control',images{1,4}{trial,1});
    origs = extractfield(dir(promptdir),'name');
    origs = origs(1,3:4);
    FamIm = imread(fullfile(promptdir,origs{2}));
    UnFamIm = imread(fullfile(promptdir,origs{1}));
    Screen('FillRect',window,backgroundEntry);
    FamTex=Screen('MakeTexture',window,FamIm);
    UnFamTex = Screen('MakeTexture',window,UnFamIm);
    
    respMade = 0;
    PromptStart = GetSecs(); 
    while respMade == 0
        
        %Screen('DrawTexture',window,FamTex,[],LeftIm);
        %Screen('DrawTexture',window,UnFamTex,[],RightIm);
        if strcmp(images{1,5}{trial,1},'left')
            TrialInfo(trial).famfaceloc = 'left';
            Screen('DrawTexture',window,FamTex,[],LeftIm);
            Screen('DrawTexture',window,UnFamTex,[],RightIm);
        else
            TrialInfo(trial).famfaceloc = 'right';
            Screen('DrawTexture',window,FamTex,[],RightIm);
            Screen('DrawTexture',window,UnFamTex,[],LeftIm);
        end
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(leftKey) == 1
            TrialInfo(trial).resp = 'left';
            TrialInfo(trial).rt = secs-PromptStart;
            respMade = 1;
        elseif keyCode(rightKey) == 1
            TrialInfo(trial).resp = 'right';
            TrialInfo(trial).rt = secs-PromptStart;
            respMade = 1;
        elseif keyCode(KbName('ESCAPE')) == 1
            sca;
            disp('*** Experiment terminated ***');
            return
        end
    end % while loop
    if UsingEyeTracker == 1
        Eyelink('Message', sprintf('TRIALID OVER %d',trial));
    end
    
    emptiness=arrayfun(@(x) isempty(x.cond),TrialInfo);
    TrialInfo=TrialInfo(~emptiness);
    
    out_file=['Sub' num2str(Subject) 'Block' num2str(Block)];
    save (fullfile(outdir,out_file), 'TrialInfo');
    
end%presentation loop

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





