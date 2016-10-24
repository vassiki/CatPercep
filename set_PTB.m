function [DegToPix,res_coords,center_coords,window] = set_PTB(DEBUG)
    % Generic PTB setup
    PsychJavaTrouble;
    FlushEvents;
    Screen('Preference', 'SkipSyncTests', DEBUG);
    KbName('UnifyKeyNames');

    %SCREEN SETUP:
    screenNumber = max(Screen('Screens'));
    % Get the resolution of the screen you can draw on
    [resx, resy] = Screen('WindowSize',screenNumber);
    % Get the size of the Monitor-check if it works for Mac!
    [mmx, mmy] = Screen('DisplaySize', screenNumber);
    cmx = mmx/10;
    cmy = mmy/10;
    viewdist = 60;
    centx = .5*resx;
    centy = .5*resy;
    
    CmToPix = (resx/cmx);
    DegToPix = ceil(tan(2*pi/360)*(viewdist*CmToPix));

    AssertOpenGL;
    [window, screenRect] = Screen('OpenWindow',screenNumber,0,[],[],2);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    gray = GrayIndex(window);
    
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen(window,'FillRect', gray);
    Screen('Flip', window);

    center_coords = [centx,centy];
    res_coords = [resx resy];
    HideCursor;

end%function