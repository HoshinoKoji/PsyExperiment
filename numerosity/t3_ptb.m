clear; clc; close;
cjMatrix = importdata('cjMatrix.mat');
stimuli = './stimuli';
results = zeros(240, 2);

PsychDefaultSetup(2);
KbName('UnifyKeyNames');
LKEY = KbName('f');
RKEY = KbName('j');
ESCKEY = KbName('escape');

Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference','VisualDebugLevel', 4);
Screen('Preference','SuppressAllWarnings', 1);
screenNumber = max(Screen('Screens'));
[wptr, rect] = Screen('OpenWindow', screenNumber, [255, 255, 255]);
[xCenter, yCenter] = RectCenter(rect);
HideCursor;
Priority(2);

startTexture = Screen('MakeTexture', wptr, imresize(imread(fullfile(stimuli, 'instructions_1.jpg')), rect(4: -1: 3)));
endTexture = Screen('MakeTexture', wptr, imresize(imread(fullfile(stimuli, 'instructions_2.jpg')), rect(4: -1: 3)));
dotTexture = Screen('MakeTexture', wptr, imread(fullfile(stimuli, 'dot.jpg')));
fixTexture = 

stim = zeros(240, 2);
for i = 1: 240
    if cjMatrix(i, 5) == 1
        imgType = 'A';
    else
        imgType = 'E';
    end
    lFile = fullfile(stimuli, sprintf('%s%d_Left.jpg', imgType, cjMatrix(i, 2)));
    rFile = fullfile(stimuli, sprintf('%s%d_Right.jpg', imgType, cjMatrix(i, 3)));
    lImg = imread(lFile);
    rImg = imread(rFile);
    stim(i, :) = [Screen('MakeTexture', wptr, lImg), Screen('MakeTexture', wptr, rImg)];
end

Screen('DrawTexture', wptr, startTexture);
Screen('Flip', wptr);
while KbCheck(); end
while true
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if keyCode(ESCKEY), sca; error('Stopped.');
        else, break;
        end
    end
end

Screen('Flip', wptr);
WaitSecs(5);

startTS = GetSecs;
for i = 1: 240
    Screen('DrawTexture', wptr, dotTexture);
    fixTS = Screen('Flip', wptr);
    while GetSecs - fixTS < 0.5
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown && keyCode(ESCKEY), sca; error('Stopped.'); end
    end
    blankTS = Screen('Flip', wptr);
    
    lRect = Screen('Rect', stim(i, 1));
    rRect = Screen('Rect', stim(i, 2));
    Screen('DrawTexture', wptr, stim(i, 1), lRect, [xCenter - 200, yCenter - 100, xCenter, yCenter + 100]);
    Screen('DrawTexture', wptr, stim(i, 2), rRect, [xCenter, yCenter - 100, xCenter + 200, yCenter + 100]);
    while GetSecs - blankTS < (cjMatrix(i, 6) / 1000 - 0.005)
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown && keyCode(ESCKEY), sca; error('Stopped.'); end
    end
    stimTS = Screen('Flip', wptr, blankTS + cjMatrix(i, 6) / 1000);
    
    RT = 0;
    response = 0;
    while true
        [keyIsDown, keyTS, keyCode] = KbCheck();
        if keyIsDown && keyCode(ESCKEY), sca; error('Stopped.');
        elseif keyIsDown && keyCode(LKEY), response = 0; RT = keyTS - stimTS; break;
        elseif keyIsDown && keyCode(RKEY), response = 1; RT = keyTS - stimTS; break;
        end
    end
    
    endTS = Screen('Flip', wptr);
    while GetSecs - endTS < 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown && keyCode(ESCKEY), sca; error('Stopped.'); end
    end
    
    results(i, :) = [RT, response];
end

Screen('DrawTexture', wptr, endTexture);
Screen('Flip', wptr);
WaitSecs(5); sca;